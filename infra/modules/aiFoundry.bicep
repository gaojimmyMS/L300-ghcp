@description('Name of the AI Services account')
param name string

@description('Location for the resource')
param location string

@description('SKU for the AI Services account')
param sku string = 'S0'

resource aiServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  kind: 'AIServices'
  sku: {
    name: sku
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
  }
}

resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiServices
  name: 'gpt-4o'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-11-20'
    }
  }
}

resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiServices
  name: 'Phi-4-mini'
  dependsOn: [gpt4oDeployment]
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'Microsoft'
      name: 'Phi-4-mini-instruct'
      version: '1'
    }
  }
}

@description('The endpoint of the AI Services account')
output endpoint string = aiServices.properties.endpoint

@description('The name of the AI Services account')
output name string = aiServices.name
