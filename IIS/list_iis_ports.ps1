Import-Module WebAdministration
$Websites = Get-ChildItem IIS:\Sites

$outputFile = "IIS_sites_And_BindingsPorts.txt"
$allSitesBindings = ""
foreach ($Site in $Websites) {

    $Binding = $Site.bindings
    [string]$BindingInfo = $Binding.Collection
    [string]$IP = $BindingInfo.SubString($BindingInfo.IndexOf(" "),$BindingInfo.IndexOf(":")-$BindingInfo.IndexOf(" "))         
    [string]$Port = $BindingInfo.SubString($BindingInfo.IndexOf(":")+1,$BindingInfo.LastIndexOf(":")-$BindingInfo.IndexOf(":")-1) 

	$siteBinding = "Site: " + $Site.name + " - IP:" + $IP + ", Port:" + $Port
	$allSitesBindings += "`n" + $siteBinding
}
Write-Output $allSitesBindings > $outputFile
Write-Host $allSitesBindings
Write-Host "--------Finished--------"







