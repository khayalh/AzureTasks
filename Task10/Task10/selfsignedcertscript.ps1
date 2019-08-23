param (
    [Parameter(Mandatory=$true)]
    [string]$certpath,
    [Parameter(Mandatory=$true)]
    [securestring]$CertPass,
    [Parameter(Mandatory=$true)]
    [string]$dnsname
)
$cert=New-SelfSignedCertificate -DnsName $dnsname -CertStoreLocation "cert:\LocalMachine\My"
Export-PfxCertificate -Cert $cert -FilePath "$certpath\selfsignedcert.pfx" -Password $CertPass
[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$certpath\selfsignedcert.pfx")) > $certpath\encodedpfx64cert.txt
Export-Certificate -FilePath "$certpath\selfsignedcert.cer" -Cert $cert -Type CERT -NoClobber
certutil.exe -encode $certpath\selfsignedcert.cer $certpath\encodedcer64cert.txt