param (
  [String] $Name = "clusty"
)

$GroupName = "${Name}_g"

$ExistingGroups = az group list --query "[?name=='$GroupName']" | ConvertFrom-Json

if ($ExistingGroups.Count -eq 0) {
  Write-Error "Cluster does not exist."
} else {
  Write-Host "Stopping cluster..." -ForegroundColor "Yellow"

  az aks stop `
    --name $Name `
    --resource-group $GroupName `
    --only-show-errors
}
