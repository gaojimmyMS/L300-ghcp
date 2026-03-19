targetScope = 'resourceGroup'

@description('Environment name (e.g., dev, staging, prod)')
param environmentName string

@description('Azure region for all resources')
param location string

@description('Unique resource name prefix')
param resourcePrefix string = 'zavastore'

// Derived resource names
var uniqueSuffix = uniqueString(resourceGroup().id)
var acrName = replace('${resourcePrefix}acr${uniqueSuffix}', '-', '')
var appServicePlanName = '${resourcePrefix}-plan-${environmentName}'
var webAppName = '${resourcePrefix}-web-${environmentName}-${uniqueSuffix}'
var logAnalyticsName = '${resourcePrefix}-logs-${environmentName}'
var appInsightsName = '${resourcePrefix}-insights-${environmentName}'
var aiServicesName = '${resourcePrefix}-ai-${environmentName}-${uniqueSuffix}'

// Azure Container Registry
module acr 'modules/acr.bicep' = {
  name: 'acr-deployment'
  params: {
    name: acrName
    location: location
  }
}

// Log Analytics Workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    name: logAnalyticsName
    location: location
  }
}

// Application Insights
module appInsights 'modules/appInsights.bicep' = {
  name: 'app-insights-deployment'
  params: {
    name: appInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// App Service Plan + Web App
module appService 'modules/appService.bicep' = {
  name: 'app-service-deployment'
  params: {
    appServicePlanName: appServicePlanName
    webAppName: webAppName
    location: location
    appInsightsConnectionString: appInsights.outputs.connectionString
  }
}

// AcrPull role assignment for managed identity
module roleAssignment 'modules/roleAssignment.bicep' = {
  name: 'role-assignment-deployment'
  params: {
    acrId: acr.outputs.id
    acrName: acr.outputs.name
    principalId: appService.outputs.principalId
  }
}

// Microsoft AI Foundry (Cognitive Services)
module aiFoundry 'modules/aiFoundry.bicep' = {
  name: 'ai-foundry-deployment'
  params: {
    name: aiServicesName
    location: location
  }
}

// Outputs
output AZURE_ACR_LOGIN_SERVER string = acr.outputs.loginServer
output AZURE_ACR_NAME string = acr.outputs.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = acr.outputs.loginServer
output AZURE_WEB_APP_NAME string = appService.outputs.name
output AZURE_WEB_APP_HOSTNAME string = appService.outputs.hostname
output AZURE_AI_ENDPOINT string = aiFoundry.outputs.endpoint
