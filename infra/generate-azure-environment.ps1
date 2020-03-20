$kubernetesResourceGroup="wisco-ipsum" # needs to be unique to your subscription
$acrName='wiscoipsumacr' #must conform to the following pattern: '^[a-zA-Z0-9]*$
$aksClusterName='wisco-ipsum-cluster'
$location = 'eastus'
$numberOfNodes = 1 # In production, you're going to want to use at least three nodes.

az group create -l $location -n $kubernetesResourceGroup

az acr create --resource-group $kubernetesResourceGroup --name $acrName --sku Standard --location $location

$sp= az ad sp create-for-rbac --skip-assignment | ConvertFrom-Json
$appId = $sp.appId
$appPassword = $sp.password

Start-Sleep -Seconds 120

$acrID=az acr show --resource-group $kubernetesResourceGroup --name $acrName --query "id" --output tsv

az role assignment create --assignee $appId --scope $acrID --role acrpull

az aks create `
   --resource-group $kubernetesResourceGroup `
   --name $aksClusterName `
   --node-count $numberOfNodes `
   --service-principal $appId `
   --client-secret $appPassword `
   --generate-ssh-keys `
   --location $location