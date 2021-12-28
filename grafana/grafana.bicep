param virtualNetworkName string
param subnetName string
param storageAccountName string
param fileShareName string
param networkProfileName string
param grafanaContainerName string
param grafanaImageName string
@secure()
param grafanaPassword string
@secure()
param grafanaDatabaseUrl string
param mysqlUser string
@secure()
param mysqlPassword string
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

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
    minimumTlsVersion: 'TLS1_2'
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-06-01' = {
  name: '${storageAccountName}/default/${fileShareName}'
  dependsOn: [
    storageAccount
  ]
}

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

resource grafanaContainers 'Microsoft.ContainerInstance/containerGroups@2021-07-01' = {
  name: grafanaContainerName
  location: location
  tags: tags
  properties: {
    containers: [
      {
        name: 'grafana-mysql'
        properties: {
          image: 'mysql'
          environmentVariables: [
            {
              name: 'MYSQL_USER'
              value: mysqlUser
            }
            {
              name: 'MYSQL_PASSWORD'
              secureValue: mysqlPassword
            }
            {
              name: 'MYSQL_RANDOM_ROOT_PASSWORD'
              value: 'yes'
            }
            {
              name: 'MYSQL_DATABASE'
              value: 'grafana'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
          ports: [
            {
              port: 3306
              protocol: 'TCP'
            }
            {
              port: 443
              protocol: 'TCP'
            }
          ]
          volumeMounts: [
            {
              name: fileShareName
              mountPath: '/var/lib/mysql'
            }
          ]
        }
      }
      {
        name: grafanaContainerName
        properties: {
          image: grafanaImageName
          environmentVariables: [
            {
              name: 'GF_SECURITY_ADMIN_PASSWORD'
              secureValue: grafanaPassword
            }
            {
              name: 'GF_DATABASE_URL'
              secureValue: grafanaDatabaseUrl
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
          ports: [
            {
              port: 3000
              protocol: 'TCP'
            }
          ]
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
    volumes: [
      {
        name: fileShareName
        azureFile: {
          readOnly: false
          shareName: fileShareName
          storageAccountName: storageAccountName
          storageAccountKey: listKeys(storageAccount.id, '2019-06-01').keys[0].value
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'OnFailure'
    ipAddress: {
      ports: [
        {
          port: 3000
          protocol: 'TCP'
        }
      ]
      ip: '10.3.15.6'
      type: 'Private'
    }
    subnetIds: [
      {
        id: subnetId
      }
    ]
  }
}
