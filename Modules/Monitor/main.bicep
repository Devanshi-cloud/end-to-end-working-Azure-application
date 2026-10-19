param LogAnalyticsWorkspaceName string= 'lawservices'
param location string = 'indiasouthcentral'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2026-03-01' = {
  name: LogAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}
