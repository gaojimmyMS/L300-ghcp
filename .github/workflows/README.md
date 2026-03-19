# CI/CD Setup

## GitHub Secrets

| Secret | Description |
|---|---|
| `AZURE_CREDENTIALS` | Service principal JSON for Azure login |

Create the service principal and secret in one step:

```bash
az ad sp create-for-rbac --name "zavastore-cicd" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP> \
  --json-auth
```

Copy the full JSON output and save it as a repository secret named `AZURE_CREDENTIALS` under **Settings > Secrets and variables > Actions**.

The service principal also needs **AcrPush** on the container registry:

```bash
az role assignment create \
  --assignee <SP_APP_ID> \
  --role AcrPush \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.ContainerRegistry/registries/<ACR_NAME>
```

## GitHub Variables

Set these under **Settings > Secrets and variables > Actions > Variables**:

| Variable | Example Value |
|---|---|
| `AZURE_ACR_LOGIN_SERVER` | `zavastoreacrxxx.azurecr.io` |
| `AZURE_ACR_NAME` | `zavastoreacrxxx` |
| `AZURE_WEB_APP_NAME` | `zavastore-web-test-xxx` |

You can find these values in `.azure/test/.env` after running `azd provision`.
