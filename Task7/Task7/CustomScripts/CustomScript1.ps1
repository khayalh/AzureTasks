# Path for the workdir
$workdir = "c:\installer\"
$SolrUrl = "http://archive.apache.org/dist/lucene/solr/6.6.6/solr-6.6.6.zip"
$pathforsolr = "F:\Solr"
$zipFileSourcePath = "F:\Solr\solr.zip"
$JavaUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=238729_478a62b7d4e34b78b671c754eaaf38ab"
$pathforjava = "C:\Java"
# Check if work directory exists if not create it

If (Test-Path -Path $workdir -PathType Container)
{ Write-Host "$workdir already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $workdir  -ItemType directory }
If (Test-Path -Path $pathforsolr -PathType Container)
{ Write-Host "$pathforsolr already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $pathforsolr  -ItemType directory }
If (Test-Path -Path $pathforjava -PathType Container)
{ Write-Host "$pathforjava already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $pathforjava  -ItemType directory }
# Download the installer

$source = "http://www.7-zip.org/a/7z1604-x64.msi"
$destination = "$workdir\7-Zip.msi"

# Check if Invoke-Webrequest exists otherwise execute WebClient

if (Get-Command 'Invoke-Webrequest') {
    Invoke-WebRequest $source -OutFile $destination
}
else {
    $WebClient = New-Object System.Net.WebClient
    $webclient.DownloadFile($source, $destination)
}

Invoke-WebRequest $source -OutFile $destination 

# Start the installation

msiexec.exe /i "$workdir\7-Zip.msi" /qn

# Wait XX Seconds for the installation to finish

Start-Sleep -s 35

# Remove the installer

Remove-Item -Force $workdir\7*
Function Expand-Archive([string]$zipFileSourcePath, [string]$zipFileDestinationPath) {
    $7z_Application = "C:\Program Files\7-Zip\7z.exe"
    $7z_Arguments = @(
        'x'							## eXtract files with full paths
        '-y'						## assume Yes on all queries
        "`"-o$($zipFileDestinationPath)`""		## set Output directory
        "`"$($zipFileSourcePath)`""				## <archive_name>
    )
    & $7z_Application $7z_Arguments 
    Remove-Item * -Include *.7z
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest $SolrUrl -OutFile $pathforsolr\solr.zip
Expand-Archive -zipFileSourcePath $zipFileSourcePath -zipFileDestinationPath $pathforsolr
Invoke-WebRequest $JavaUrl -OutFile $pathforjava\jre-8u211-windows-x64.exe
$Java =  (Get-ChildItem -Path $pathforjava | Select-Object -property * | Where-Object name -match ".exe").fullname

$switches = @(
"REBOOT=0"
"INSTALL_SILENT=1"
"AUTO_UPDATE=0"
"WEB_JAVA=1"
"WEB_JAVA_SECURITY_LEVEL=M"
"WEB_ANALYTICS=0"
"EULA=0"
"SPONSORS=0"
"REMOVEOUTOFDATEJRES=1"
)#end@
Start-Process $Java -ArgumentList $switches -NoNewWindow -Wait

[xml]$masterxml=@"
<requestHandler name="/replication" class="solr.ReplicationHandler" > 
    <!--
       To enable simple master/slave replication, uncomment one of the 
       sections below, depending on whether this solr instance should be
       the "master" or a "slave".  If this instance is a "slave" you will 
       also need to fill in the masterUrl to point to a real machine.
    --> 
       
       <lst name="master">
         <str name="replicateAfter">commit</str>
         <str name="replicateAfter">startup</str>
         <str name="confFiles">schema.xml,stopwords.txt</str>
       </lst>

    <!--
       <lst name="slave">
         <str name="masterUrl">http://http://10.0.0.4:8983/solr</str>
         <str name="pollInterval">00:00:60</str>
       </lst>
    -->
</requestHandler>
"@
$solrconfigfiles=Get-ChildItem -Path $pathforsolr -Recurse | Where-Object {$_.Name -like "solrconfig.xml"}
foreach ($solrconfigfile in $solrconfigfiles) {
[xml]$solrconfigxml=Get-Content $solrconfigfile.pspath
$solrconfigxml.config.AppendChild($solrconfigxml.ImportNode($masterxml.requestHandler, $true))
$directory = $solrconfigfile.DirectoryName
$solrconfigxml.Save("$directory\solrconfig.xml")
}
$myarray=@("enable.master=true","enable.slave=false")
$solrconfigfiles=Get-ChildItem -Path $pathforsolr -Recurse | Where-Object {$_.Name -like "core.properties"}
foreach ($solrconfigfile in $solrconfigfiles) {
Set-Content -Path $solrconfigfile.pspath -Value $myarray
}