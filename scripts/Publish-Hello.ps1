dotnet publish "$PSScriptRoot/../applications/hello" `
  --configuration "Release" `
  --no-self-contained `
  --output "$PSScriptRoot/../applications/hello/bin/publish"
