# Declare variables
# needs to be unique to your subscription
$kubernetesResourceGroup='DockerAzureTest' 
#must conform to the following pattern: '^[a-zA-Z0-9]*$
$acrName='DockerAzureTestRegistry007'
$aksClusterName='myAKSCluster'
$location = 'eastus'
$vnetName = 'DockerAzureTest-vnet'
# In production, you're going to want to use at least three nodes.
$numberOfNodes = 1

#create a resource group
az group create -l $location -n $kubernetesResourceGroup

#create a container registry
az acr create --resource-group $kubernetesResourceGroup --name $acrName --sku Basic --location $location

#get ACR ID
$acrID=az acr show --resource-group $kubernetesResourceGroup --name $acrName --query "id" --output tsv

#create AKS cluster
az aks create --resource-group $kubernetesResourceGroup --name $aksClusterName --node-count $numberOfNodes --enable-addons monitoring --generate-ssh-keys --location $location

#AKS cluster configured to authenticate with the ACR registry
az aks update -n $aksClusterName -g $kubernetesResourceGroup --attach-acr $acrID

#creates a default virtual network named DockerAzureTest-vnet with one subnet named default
az network vnet create --name $vnetName --resource-group $kubernetesResourceGroup --subnet-name default
