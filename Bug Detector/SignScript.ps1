$certPath = "Cert:\CurrentUser\My"
$certSubject = "CN=MalwareScanner_SelfSigned"

# Check if cert already exists
$cert = Get-ChildItem -Path $certPath | Where-Object { $_.Subject -eq $certSubject }

if (-not $cert) {
    Write-Host "Creating new self-signed code signing certificate..."
    $cert = New-SelfSignedCertificate -Subject $certSubject -Type CodeSigningCert -CertStoreLocation $certPath
}
else {
    Write-Host "Using existing certificate: $($cert.Thumbprint)"
}

# Export certificate so it can be trusted by others
$certExportPath = Join-Path $PSScriptRoot "MalwareScanner_Certificate.cer"
Export-Certificate -Cert $cert -FilePath $certExportPath -Force
Write-Host "Certificate exported to: $certExportPath"

# Sign the script
$scriptPath = Join-Path $PSScriptRoot "MalwareScanner.ps1"
Set-AuthenticodeSignature -FilePath $scriptPath -Certificate $cert

Write-Host "Successfully signed $scriptPath"
