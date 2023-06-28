# Deploy Azure PostgreSQL with pgvector 

This repository contains a PowerShell script for deploying a PostgreSQL database with the pgvector extension on Azure.

## Prerequisites 

- Azure CLI: You need to have Azure CLI installed on your machine. You can download it from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- Azure Subscription: You need to have an active Azure subscription.

## Steps to Deploy 

1. **Update the `postgres.params.json` parameters file**: This file contains the parameters needed for the Bicep template. Update the values in this file according to your requirements.

**Required Parameters:**

- `serverName`: The name of the PostgreSQL server.
- `administratorLogin`: The login name of the server admin.
- `administratorLoginPassword`: The password for the server admin.

**Optional Parameters:**

- `skuName`: The SKU name for the PostgreSQL server. Default is 'Standard_B1ms', indicating Standard, B1ms.
- `skuTier`: The pricing tier of the PostgreSQL server. Default is 'Burstable'.
- `version`: The version of PostgreSQL. Default is '14'.
- `storageSize`: The storage size in GB. Default is 128.
- `backupRetentionDays`: The backup retention period in days. Default is 7.

These parameters are also used in the PowerShell script to connect to the server and run SQL statements against it.

2. **Run the PowerShell script**: The `Deploy-Postgres.ps1` script is used to deploy the PostgreSQL database. You need to pass the `SubscriptionId`, `Location`, and `ResourceGroupName` as parameters to this script. You can run the script using the following command:

```powershell
.\Deploy-Postgres.ps1 -SubscriptionId "your-subscription-id" -Location "your-location" -ResourceGroupName "your-resource-group-name"
```

Replace `"your-subscription-id"`, `"your-location"`, and `"your-resource-group-name"` with your actual Azure subscription ID, location, and resource group name. 
Alternatively, you can use PowerShell's splatting feature to pass the parameters as a hashtable. This is especially useful when you have a lot of parameters. Here is an example:

```powershell
$params = @{
    SubscriptionId = "your-subscription-id"
    Location = "your-location"
    ResourceGroupName = "your-resource-group-name"
}
.\Deploy-Postgres.ps1 @params
```

Replace `"your-subscription-id"`, `"your-location"`, and `"your-resource-group-name"` with your actual Azure subscription ID, location, and resource group name. 
It might take several minutes to complete.