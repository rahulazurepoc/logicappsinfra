@description('Logic App Service Plan Name')
param logicAppPlanName string

@allowed(['East US 2'
'East US'
]
)
param location string

@allowed(['WS1', 'WS2'])
param logicAppSKUSize string

@minValue(1)
@maxValue(20)
param logicAppInitialCapcity int

param logicAppName string

param storageAccountName string

resource logicAppPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: logicAppPlanName
  location: location
  sku: {
    name: logicAppSKUSize
    capacity: logicAppInitialCapcity
  }
}



resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  tags: {
  }
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}



resource logicAppCompute  'Microsoft.Web/sites@2022-03-01' = {
  name: logicAppName
  location: location
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    
    serverFarmId: logicAppPlan.id
    clientAffinityEnabled: false
    httpsOnly: true

    siteConfig: {

      cors: {
      }
      use32BitWorkerProcess: true
      ftpsState: 'AllAllowed'
      netFrameworkVersion: 'v4.0'

      appSettings: [

          {
             name : 'FUNCTIONS_EXTENSION_VERSION'
             value : '~3'
        }
        {
            name:  'FUNCTIONS_WORKER_RUNTIME'
            value: 'node'
        }

        {
            name : 'WEBSITE_NODE_DEFAULT_VERSION'
            value : '~14'
        }
        {
             name:  'AzureWebJobsStorage'
             value : 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountName_resource.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
             name : 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
            value : 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountName_resource.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
             name : 'WEBSITE_CONTENTSHARE'
             value : '${toLower(logicAppName)}abc2'
          }
        {
             name :  'AzureFunctionsJobHost__extensionBundle__id'
             value : 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
            name :  'AzureFunctionsJobHost__extensionBundle__version'
            value : '[1.*, 2.0.0)'
        }
        {
            name : 'APP_KIND'
            value : 'workflowApp'
        }
        
      ]
      
    }

  }

}

