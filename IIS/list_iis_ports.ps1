Import-Module WebAdministration

$allSitesBindings = ""
$outputFile = "IIS_sites_And_BindingsPorts.txt"
$Websites = Get-ChildItem IIS:\Sites

foreach ($Site in $Websites) {

    $Binding = $Site.bindings
    [string]$BindingInfo = $Binding.Collection
    [string]$IP = $BindingInfo.SubString($BindingInfo.IndexOf(" "),$BindingInfo.IndexOf(":")-$BindingInfo.IndexOf(" "))         
    [string]$Port = $BindingInfo.SubString($BindingInfo.IndexOf(":")+1,$BindingInfo.LastIndexOf(":")-$BindingInfo.IndexOf(":")-1) 

	$siteBinding = "Site: " + $Site.name + " - IP:" + $IP + ", Port:" + $Port
	$allSitesBindings += "`n" + $siteBinding
}
#write to file
Write-Output $allSitesBindings > $outputFile

#notify to user
Write-Host $allSitesBindings 
Write-Host "`nBindings also write to file " $outputFile 
Write-Host "--------Finished--------"
