param virtualNetworkName string
param subnetName string
param networkProfileName string
param heartbeatContainerName string
param heartbeatImageName string
param containerRegistryLoginServer string
param containerRegistryUsername string
@secure()
param containerRegistryPassword string
param tags object = {
  'project': 'shared'
  'costcenter': 'shared'
  'team': 'devops'
  'status': 'testing'
}
param location string = resourceGroup().location

var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)

resource networkProfile 'Microsoft.Network/networkProfiles@2021-03-01' = {
  name: networkProfileName
  location: location
  properties: {
    containerNetworkInterfaceConfigurations: [
      {
        name: 'eth0'
        properties: {
          ipConfigurations: [
            {
              name: 'ipconfigprofile'
              properties: {
                subnet: {
                  id: subnetId
                }
              }
            }
          ]
        }
      }
    ]
  }
}

resource heartbeatContainer 'Microsoft.ContainerInstance/containerGroups@2021-07-01' = {
  name: heartbeatContainerName
  location: location
  tags: tags
  properties: {
    containers: [
      {
        name: heartbeatContainerName
        properties: {
          image: heartbeatImageName
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              memoryInGB: 1
              cpu: 1
            }
          }
        }
      }
    ]
    imageRegistryCredentials: [
      {
        server: containerRegistryLoginServer
        username: containerRegistryUsername
        password: containerRegistryPassword
      }
    ]
    osType: 'Linux'
    restartPolicy: 'OnFailure'
    ipAddress: {
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
      ip: '10.3.15.7'
      type: 'Private'
    }
    subnetIds: [
      {
        id: subnetId
      }
    ]
  }
}
