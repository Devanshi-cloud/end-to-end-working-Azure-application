param keyvaultname string = 'keyvault01'
param location string = 'indiasouthcentral'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyvaultname
  location: location
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}