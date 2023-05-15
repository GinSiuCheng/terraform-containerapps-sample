# Secured Container Apps Sample
The following sample aims to create a secure ACA environment using the latest preview features for custom VNET, UDR, NSGs and Azure FW. The target deployment is depicted below along with key learnings so far.

![Secured ACA](./Secured%20ACA.png)

## Features leveraged
- [Public preview: UDR with Azure FW](https://learn.microsoft.com/en-us/azure/container-apps/networking#user-defined-routes-udr---preview)
- [Public preview: Workload profile](https://learn.microsoft.com/en-us/azure/container-apps/plans#consumption--dedicated-plan-structure-preview)
    - Needed for UDR and Azure FW feature along with no public ingress.
- [Custom Subnet and NSG](https://learn.microsoft.com/en-us/azure/container-apps/firewall-integration)
    - Needed to secure comms betw. other internal network environments 

### <b>Important</b>
As some of these features are in public preview, there are no SLAs and they should not be leveraged in production as they may yield unexpected behaviors. Bugs and other issues are actively being worked on by the ACA engineering team.

## Design considerations
ACA should be deployed in a secure manner such that ingress and egress points are known and stable to control plane or other related resources. To support this:  
- NSG will be used to filter ACA's communications to other subnets if intravnet is not allowed by default. NSG may also be leveraged to block AzurePlatformDNS, if possible, as it can be a potential DNS data exfiltration vector. 
- All ACA control plane and required egress should be via azure firewall. The egress should not be too permissive (ie. service tags that are too broad in scope should not be used) such that it creates data exfiltration risks. 
- DNS should resolve via a forwarder/proxy to match closely to customers who may have hybrid environments.
    - Azure FW DNS proxy will be used to facilicate this scenario. 
- Connections across the environment should remain private (ex. ACA -> ACR)

## Observed issues and risks
- Blocking AzurePlatformDNS at NSG layer will break ACA deployment. 
- ACA does not appear to pull from private endpoint, but instead pulls from public endpoint. This appears to be a potential ACA custom subnet feature bug. 
    - ACA requires ACR service tag on both NSG and AzFW and public IP whitelist for AzFW Public IP for a successful deployment. This introduces an insider malware risk where they pull from any azure container image. 
- ACA requires Any:443 on both NSG and AzFW for some operations that may be health checks/probes for containers to come up and also to ref. ACR. 
    - This allow Any:443 is too permissive and can be a potential data exfiltration vector. We are currently working on scoping this down further to an acceptable / known MSFT range. 

## IaC notes
### Components 
- Networking: 
    - Hub-spoke VNETs and peering - Custom DNS is set to Azure FW Private IP
        - Hub VNET
            - 3 Subnets (Default, Bastion and Azure FW)
        - Spoke VNET
            - 3 Subnets (Default, PE and ACA)
        - VNET peering
    - UDR from ACA subnet to AzFW (Private IP)
    - NSG on ACA subnet
    - Azure Firewall (Egress and DNS forwarding to Azure DNS)
    - Azure Bastion (SSH into default subnet VMs for connectivity testing)
- Compute/App
    - Azure Container Apps
        - Workload profile and environment
        - ACA app with hello-world container
    - Azure Container Registry w/ PE

### ACA with AzAPI 
As the workload profile feature is in preview, AzAPI provider was leveraged for the API calls to create the dedicated workload profile environment and ACA. AzAPI reference can be found [here](https://registry.terraform.io/providers/Azure/azapi/latest/docs). This is the equivalent of running the below CLI command: 

```bash
# user assigned identity
az containerapp create \
  -n acadevuseaca230510-342am-uai -g acadev-eastus-230509-rg \
  --environment acadevuseacaenv230509 \
  --image acadevuseacr230509.azurecr.io/azuredocs/containerapps-helloworld \
  --ingress internal --target-port 80 \
  --workload-profile-name Dedicated \
  --registry-server acadevuseacr230509.azurecr.io \
  --user-assigned "/subscriptions/aa86e73d-372b-4cd6-a37e-0d12ae93e964/resourceGroups/acadev-eastus-230509-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aca-identity" \
  --registry-identity "/subscriptions/aa86e73d-372b-4cd6-a37e-0d12ae93e964/resourceGroups/acadev-eastus-230509-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aca-identity" \
  --min-replicas 2 \
  --cpu 0.5 --memory 1.0Gi \
  --query properties.configuration.ingress.fqdn
```


