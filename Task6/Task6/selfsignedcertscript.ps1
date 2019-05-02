param (
    [Parameter(Mandatory=$true)]
    [string]$exportedcertdestinationpath,
    [Parameter(Mandatory=$true)]
    [securestring]$CertPass
)
$cert=New-SelfSignedCertificate -DnsName "iissrv.westeurope.cloudapp.azure.com" -CertStoreLocation "cert:\LocalMachine\My"
Export-PfxCertificate -Cert $cert.Thumbprint -FilePath $exportedcertdestinationpath -Password $CertPass