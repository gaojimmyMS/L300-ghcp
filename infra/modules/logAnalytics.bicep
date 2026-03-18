@description('Name of the Log Analytics workspace')
param name string

@description('Location for the resource')
param location string

@description('Retention period in days')
param retentionInDays int = 30

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
  }
}

@description('The resource ID of the Log Analytics workspace')
output id string = logAnalytics.id
