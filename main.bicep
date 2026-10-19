@secure()
param admin1Password string
@secure()
param admin2Password string



module Network 'Modules/Network/main.bicep' = {
 name: 'Network' 
}

module Compute  'Modules/Compute/main.bicep' = {
  name: 'Compute'
  params: {
      subnetId: Network.outputs.webSubId
     admin1Password:admin1Password
     admin2Password:admin2Password 

  }
}

module KeyValue 'Modules/Keyvault/main.bicep' = {
  name: 'KeyValue'
  params: {
    keyvaultname: 'kv-oculyx-344c61a7'
  }
}

module Storage 'Modules/Storage/main.bicep' = {
  name: 'Storage'
}

module Monitor 'Modules/Monitor/main.bicep' = {
  name:'Monitor'
}

module AppGateway 'Modules/AppDefaulGateway/main.bicep' = {
  name: 'AppGateway'

  params: {
     PublicIPId: Network.outputs.PublicIPId
     appGatewaySubnetId: Network.outputs.appGatewaySubnetId
  }
}




