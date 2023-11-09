param (
  [String] $Name = "clusty"
)

$GroupName = "${Name}_g"

$ExistingGroups = az group list --query "[?name=='$GroupName']" | ConvertFrom-Json

if ($ExistingGroups.Count -ne 0) {
  Write-Host "Cluster already exists." -ForegroundColor "Green"
  Write-Host "Starting cluster..." -ForegroundColor "Yellow"

  az aks start `
    --name $Name `
    --resource-group $GroupName `
    --only-show-errors
} else {
  Write-Host "Creating group..." -ForegroundColor "Yellow"

  az group create `
    --name $GroupName `
    --location "uksouth" `
    --only-show-errors

  Write-Host "Creating cluster..." -ForegroundColor "Yellow"

  az aks create `
    --name $Name `
    --resource-group $GroupName `
    --enable-vpa `
    --k8s-support-plan "KubernetesOfficial" `
    --kubernetes-version "1.27.3" `
    --load-balancer-sku "basic" `
    --location "uksouth" `
    --node-count 1 `
    --node-vm-size "standard_b2pls_v2" `
    --tier "free" `
    --vm-set-type "VirtualMachineScaleSets" `
    --only-show-errors
}
