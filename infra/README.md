# ZavaStorefront Azure Infrastructure

## Architecture

This infrastructure provisions the following Azure resources for the ZavaStorefront web application in a **dev** environment:

| Resource | Module | SKU | Purpose |
|---|---|---|---|
| Azure Container Registry | `modules/acr.bicep` | Basic | Docker image storage |
| App Service Plan | `modules/appService.bicep` | B1 (Linux) | Compute for web app |
| Web App for Containers | `modules/appService.bicep` | — | Hosts the .NET 6 app |
| Log Analytics Workspace | `modules/logAnalytics.bicep` | PerGB2018 | Log aggregation |
| Application Insights | `modules/appInsights.bicep` | — | Application monitoring |
| AI Services (Foundry) | `modules/aiFoundry.bicep` | S0 | GPT-4 and Phi models |
| AcrPull Role Assignment | `modules/roleAssignment.bicep` | — | RBAC-based image pull |

## Region

All resources are deployed to **westus3** (required for AI model availability).

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- An Azure subscription with permissions to create resources

## Deployment

```bash
# Login to Azure
az login
azd auth login

# Initialize the environment
azd init

# Preview what will be provisioned
azd provision --preview

# Deploy everything (provision + deploy app)
azd up
```

## Image Build (No Local Docker Required)

Build and push the container image using ACR cloud builds:

```bash
az acr build --registry <acr-name> --image zavastore:latest .
```

## Security

- **No admin credentials**: ACR admin user is disabled
- **Managed identity**: Web App uses system-assigned managed identity with AcrPull role
- **HTTPS only**: Web App enforces HTTPS

## Cost Notes

This is a dev configuration using minimal-cost SKUs:
- ACR Basic (~$5/mo)
- App Service B1 (~$13/mo)
- Log Analytics (pay-per-GB)
- AI Services (pay-per-use)
