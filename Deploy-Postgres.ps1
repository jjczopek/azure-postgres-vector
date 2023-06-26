param (
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]$Location,
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName
)

# Validate parameters
if (-not $SubscriptionId -or -not $Location -or -not $ResourceGroupName) {
    Write-Host "SubscriptionId, Location, and ResourceGroupName are required."
    exit
}

# Read the contents of the parameters file
$paramsContent = Get-Content -Raw -Path "postgres.params.json" | ConvertFrom-Json

# Extract the values and store them in variables
$ServerName = $paramsContent.parameters.serverName.value
$AdminLogin = $paramsContent.parameters.administratorLogin.value
$AdminPassword = $paramsContent.parameters.administratorLoginPassword.value

# Check if the user is already logged in to Azure
$loggedIn = az account show --output tsv --query 'user.type' 2>$null

if ($loggedIn -eq 'user') {
    Write-Host "User is already logged in to Azure."
}
else {
    # Login to Azure
    Write-Host "Logging in to Azure..."
    az login
}


# Get the current subscription
$currentSubscription = az account show --output tsv --query 'id'

# Check if the current subscription is different from the provided subscription
if ($currentSubscription -ne $SubscriptionId) {
    # Set the provided subscription
    Write-Host "Setting subscription..."
    az account set --subscription $SubscriptionId
}

# Create a Resource Group
Write-Host "Creating resource group..."
az group create --name $ResourceGroupName --location $Location

# Deploy Bicep file to the Resource Group with parameters specified
Write-Host "Deploying Bicep file..."
az deployment group create --resource-group $ResourceGroupName `
    --template-file "./postgres.bicep" `
    --parameters "@postgres.params.json"

# Get current IP address and add it to the firewall
Write-Host "Adding current IP to the firewall..."
$ip = Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty ip
$RuleName = "AllowMyIP_$($ip.Replace('.',''))"
az postgres flexible-server firewall-rule create --resource-group $ResourceGroupName --name $ServerName --rule-name $RuleName --start-ip-address $ip --end-ip-address $ip

# Get the extensions that are on the allow-list for the server
Write-Host "Getting the extensions on the allow-list..."
az postgres flexible-server parameter show --resource-group $ResourceGroupName --server-name $ServerName --name azure.extensions --query '{Name: name, Value: value}'

# Install rdbms-connect extension if not installed
Write-Host "Installing rdbms-connect extension..."
az extension add --name rdbms-connect --version 1.0.3

# Connect to the server and activate the pgvector extension on 'langchain' database
Write-Host "Activating the pgvector extension..."
az postgres flexible-server execute --admin-password $AdminPassword --admin-user $AdminLogin --name $ServerName --database langchain --querytext "CREATE EXTENSION IF NOT EXISTS vector;"

Write-Host "Script completed."
