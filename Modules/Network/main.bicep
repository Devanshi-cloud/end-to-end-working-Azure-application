
param location string = 'indiasouthcentral'

param pIPname string = 'Public-IP'

param vnetname string ='vnet-secure-app'
param vnet string = '10.1.0.0/16'

param mgtname string = 'Mgmt-Subnet'
param mgmtSub string = '10.1.3.0/24'

param appGWname string = 'appgw-prod'
param appGWSub string = '10.1.2.0/24'

param webname string= 'Web-Subnet'
param webSub string = '10.1.1.0/24'

param nsgnameweb string = 'NSG-web'
param nsgnamemgmt string= 'NSG-mgmt'

resource PublicIP 'Microsoft.Network/publicIPAddresses@2025-03-01' = {
   name:pIPname
   location: location 
   sku: {
     name: 'Standard'
      tier: 'Regional'
   }
   properties: {
     publicIPAllocationMethod: 'Static'
   }
    
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-09-01' = {
   name: vnetname
    location: location 
     properties: {
      addressSpace: {
        addressPrefixes: [
           vnet
        ]
      }
      subnets: [
         {
           name: webname 
            properties: {
               addressPrefix: webSub 
               networkSecurityGroup: {
                 id: nsgweb.id
               }
                
            }
         }
         {
          name: mgtname 
          properties: {
             addressPrefix: mgmtSub
             networkSecurityGroup: {
               id: nsgmtgm.id
             }

          }
         }
         {
          name: appGWname 
          properties: {
             addressPrefix: appGWSub

          }
         }
      ]
     }
}


resource nsgweb 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
   name: nsgnameweb
    location: location 
     properties:  {
       securityRules:   [
         {
          name: 'Allow-SSH'
            properties:  {
              access: 'Allow'
              direction: 'Inbound'
              priority: 100
              protocol: 'Tcp'
              sourceAddressPrefix: mgmtSub
              destinationAddressPrefix: webSub
              sourcePortRange: '*'
              destinationPortRange:'22'
            }
         }
                   {
                name:'Allow-HTTP'
                properties: {
                    access: 'Allow'
                    direction: 'Inbound'
                    priority: 200
                    protocol: 'Tcp'
                    sourceAddressPrefix: appGWSub
                    destinationAddressPrefix: webSub
                    sourcePortRange:'*'
                    destinationPortRange: '80'
                }
            }
       ]
     }
}

resource nsgmtgm 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
    name: nsgnamemgmt
    location: location 
      properties: {
    securityRules: [
      {
        name: 'Allow-SSH-Admin'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: mgmtSub
          sourcePortRange: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

output PublicIPId string = PublicIP.id
output appGatewaySubnetId string ='${virtualNetwork.id}/subnets/${appGWname}'
output webSubId string ='${virtualNetwork.id}/subnets/${webname}'
