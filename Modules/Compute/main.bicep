param location string = 'indiasouthcentral'
param subnetId string 
param vm1Name string = 'vm-01'
param vm2Name string = 'vm-02'
param vmSize string = 'Standard_B2s'
param admin1Username string = 'azureuser'
param admin2Username string = 'azureuser'
@secure()
param admin1Password string 
@secure()
param admin2Password string 
param nic1Name string = 'nic-vm-01'
param nic2Name string = 'nic-vm-02'

resource nic1 'Microsoft.Network/networkInterfaces@2025-09-01' = {
  name: nic1Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource nic2 'Microsoft.Network/networkInterfaces@2025-09-01' = {
  name: nic2Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig2'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
              id: subnetId
            }
          }
      }
    ]
  }
}

resource vm1 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vm1Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vm1Name
      adminUsername: admin1Username
      adminPassword: admin1Password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'Ubuntu-24_04-LTS'
        sku: 'server'
        version: 'latest'
      }
    }
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vm2Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vm2Name
      adminUsername: admin2Username
      adminPassword: admin2Password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic2.id
        }
      ]
    }
     storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'Ubuntu-24_04-LTS'
        sku: 'server'
        version: 'latest'
      }
    }
  }
}

output nic1Id string = nic1.id
output nic2Id string = nic2.id


