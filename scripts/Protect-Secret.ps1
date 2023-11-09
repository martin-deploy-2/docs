$BasePath = "$PSScriptRoot/../sealed-secrets"

Get-ChildItem -Path "$BasePath/*.yaml.secret" -File -Name | ForEach-Object {
  $Secret = "$BasePath/$_"
  $SealedSecret = $Secret -replace ".yaml.secret", ".yaml"

  Write-Host "+ Secret: $Secret" -ForegroundColor "Gray"
  Write-Host "  Sealed: $SealedSecret" -ForegroundColor "Gray"

  $Utf8NoBom = New-Object System.Text.UTF8Encoding $false

  # Using [System.IO.File]::WriteAllLines here because Powershell's >> encodes output in UTF8 with BOM, which then breaks everything...
  [System.IO.File]::WriteAllLines(
    $SealedSecret,
    @(
      "# This file is generated, do not edit manually."
      "# When editing, run ``Protect-Secret.ps1`` to regenerate."
      kubeseal `
        --secret-file $Secret `
        --allow-empty-data `
        --cert "$PSScriptRoot/sealed-secrets-cert.pem" `
        --format yaml
    ),
    $Utf8NoBom
  )
}
