param ApplicationGatewayName string = 'appgateway'
param location string = 'indiasouthcentral'
param PublicIPId string
param appGatewaySubnetId string

resource applicationGateway 'Microsoft.Network/applicationGateways@2023-02-01' = {
  name: ApplicationGatewayName
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    backendAddressPools: [
      {
        name: 'backendPool1'
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings1'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfig1'
        properties: {
          publicIPAddress: {
            id: PublicIPId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontendPort1'
        properties: {
          port: 80
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'gatewayIPConfig1'
        properties: {
          subnet: {
            id: appGatewaySubnetId
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', ApplicationGatewayName, 'frontendIPConfig1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', ApplicationGatewayName, 'frontendPort1')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          priority: 10
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', ApplicationGatewayName, 'httpListener1')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', ApplicationGatewayName, 'backendPool1')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', ApplicationGatewayName, 'backendHttpSettings1')
          }
        }
      }
    ]
  }
}   