param serverName string
param location string = resourceGroup().location
param administratorLogin string
@secure()
param administratorLoginPassword string
param skuName string = 'Standard_B1ms'
param skuTier string = 'Burstable'
param version string = '14'
param storageSize int = 128
param backupRetentionDays int = 7

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storage: {
      storageSizeGB: storageSize
    }    
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
  resource configurations 'configurations@2022-12-01' = {
    name: 'azure.extensions'
    properties: {
      value: 'vector'
      source: 'user-override'
    }
  }
}

resource langchainDB 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  parent: postgres
  name: 'langchain'
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}

output fullyQualifiedDomainName string = postgres.properties.fullyQualifiedDomainName
