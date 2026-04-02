[CmdletBinding()]
param(
    [Parameter()]
    [string]$GitHubUser,

    [Parameter()]
    [string]$UserName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Administrator {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script from an elevated PowerShell session (Run as Administrator).'
    }
}

function Get-CurrentAccountName {
    return [Security.Principal.WindowsIdentity]::GetCurrent().Name
}

function Test-IsAdministratorAccount {
    param([string]$AccountName)

    $candidates = @($AccountName)
    if ($AccountName -notmatch '\\' -and $AccountName -notmatch '@') {
        $candidates += "$env:COMPUTERNAME\$AccountName"
    }

    try {
        $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)

        if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            foreach ($candidate in $candidates) {
                try {
                    $candidateSid = ([Security.Principal.NTAccount]$candidate).Translate([Security.Principal.SecurityIdentifier]).Value
                    if ($candidateSid -eq $currentIdentity.User.Value) {
                        return $true
                    }
                }
                catch {
                }
            }
        }
    }
    catch {
    }

    $groupMemberSids = @()

    try {
        $groupMemberSids = @(
            Get-LocalGroupMember -Group 'Administrators' -ErrorAction Stop |
                Select-Object -ExpandProperty SID |
                ForEach-Object { $_.Value }
        )
    }
    catch {
        throw "Failed to inspect the local Administrators group. $_"
    }

    foreach ($candidate in $candidates) {
        try {
            $sid = ([Security.Principal.NTAccount]$candidate).Translate([Security.Principal.SecurityIdentifier]).Value
            if ($groupMemberSids -contains $sid) {
                return $true
            }
        }
        catch {
        }
    }

    return $false
}

function Get-GitHubPublicKeys {
    param([string]$AccountName)

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $requestParams = @{
        Uri         = "https://api.github.com/users/$AccountName/keys"
        Headers     = @{
            Accept     = 'application/vnd.github+json'
            'User-Agent' = 'WindowsOpenSSHSetup'
        }
        ErrorAction = 'Stop'
    }

    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $requestParams.UseBasicParsing = $true
    }

    try {
        $response = Invoke-RestMethod @requestParams
    }
    catch {
        throw "Failed to download public SSH keys for GitHub user '$AccountName'. $_"
    }

    $keys = @(
        $response |
            ForEach-Object { $_.key } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Select-Object -Unique
    )

    if ($keys.Count -eq 0) {
        throw "GitHub user '$AccountName' does not have any public SSH keys available from GitHub."
    }

    foreach ($key in $keys) {
        if ($key -notmatch '^(ssh-(rsa|ed25519)|ecdsa-sha2-|sk-ssh-ed25519@openssh.com|sk-ecdsa-sha2-) ') {
            throw "GitHub user '$AccountName' returned a key that does not look like a valid OpenSSH public key."
        }
    }

    return ,$keys
}

function Resolve-GitHubUser {
    param([string]$AccountName)

    if (-not [string]::IsNullOrWhiteSpace($AccountName)) {
        return $AccountName.Trim()
    }

    $promptedAccountName = Read-Host 'Enter the GitHub username to import SSH keys from'
    if ([string]::IsNullOrWhiteSpace($promptedAccountName)) {
        throw 'A GitHub username is required.'
    }

    return $promptedAccountName.Trim()
}

function Ensure-WindowsCapabilityInstalled {
    param([string]$CapabilityName)

    $capability = Get-WindowsCapability -Online -Name $CapabilityName
    if ($capability.State -ne 'Installed') {
        Write-Host "Installing $CapabilityName..."
        Add-WindowsCapability -Online -Name $CapabilityName | Out-Null
    }
    else {
        Write-Host "$CapabilityName is already installed."
    }
}

function Ensure-SshServiceRunning {
    Ensure-ServiceRunning -ServiceName 'sshd'
}

function Ensure-ServiceRunning {
    param([string]$ServiceName)

    $service = Get-Service -Name $ServiceName -ErrorAction Stop
    if ($service.StartType -ne 'Automatic') {
        Set-Service -Name $ServiceName -StartupType Automatic
    }

    if ($service.Status -ne 'Running') {
        Start-Service -Name $ServiceName
    }
}

function Ensure-SshFirewallRule {
    $ruleName = 'OpenSSH-Server-In-TCP'
    $rule = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue

    if (-not $rule) {
        New-NetFirewallRule -Name $ruleName -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
    }
}

function Set-SshdDirective {
    param(
        [string]$Path,
        [string]$Directive,
        [string]$Value
    )

    $replacement = "$Directive $Value"
    $pattern = '^\s*#?\s*' + [Regex]::Escape($Directive) + '\b.*$'
    $existing = @()

    if (Test-Path -Path $Path -PathType Leaf) {
        $existing = Get-Content -Path $Path
    }

    $updated = New-Object System.Collections.Generic.List[string]
    $found = $false

    foreach ($line in $existing) {
        if ($line -match $pattern) {
            if (-not $found) {
                $updated.Add($replacement)
                $found = $true
            }
        }
        else {
            $updated.Add($line)
        }
    }

    if (-not $found) {
        $updated.Add($replacement)
    }

    Set-Content -Path $Path -Value $updated -Encoding ascii
}

function Resolve-ProfilePath {
    param([string]$AccountName)

    if ([string]::IsNullOrWhiteSpace($AccountName)) {
        return [Environment]::GetFolderPath('UserProfile')
    }

    $candidates = @($AccountName)
    if ($AccountName -notmatch '\\' -and $AccountName -notmatch '@') {
        $candidates += "$env:COMPUTERNAME\$AccountName"
    }

    foreach ($candidate in $candidates) {
        try {
            $sid = ([Security.Principal.NTAccount]$candidate).Translate([Security.Principal.SecurityIdentifier]).Value
            $profileKey = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid"
            $profilePath = (Get-ItemProperty -Path $profileKey -Name ProfileImagePath -ErrorAction Stop).ProfileImagePath
            return [Environment]::ExpandEnvironmentVariables($profilePath)
        }
        catch {
        }
    }

    throw "Could not resolve a profile path for user '$AccountName'. Make sure that user has logged in to Windows at least once."
}

function Ensure-FileContainsLines {
    param(
        [string]$Path,
        [string[]]$Lines
    )

    $existing = @()
    if (Test-Path -Path $Path -PathType Leaf) {
        $content = Get-Content -Path $Path
        if ($null -ne $content) {
            $existing = @($content)
        }
    }

    foreach ($line in $Lines) {
        if ($existing -notcontains $line) {
            Add-Content -Path $Path -Value $line -Encoding ascii
            $existing += $line
        }
    }
}

Assert-Administrator

$GitHubUser = Resolve-GitHubUser -AccountName $GitHubUser

$targetAccountName = if ([string]::IsNullOrWhiteSpace($UserName)) {
    Get-CurrentAccountName
}
else {
    $UserName
}

$isAdministratorAccount = Test-IsAdministratorAccount -AccountName $targetAccountName
$publicKeys = Get-GitHubPublicKeys -AccountName $GitHubUser

Ensure-WindowsCapabilityInstalled -CapabilityName 'OpenSSH.Client~~~~0.0.1.0'
Ensure-WindowsCapabilityInstalled -CapabilityName 'OpenSSH.Server~~~~0.0.1.0'
Ensure-SshServiceRunning
Ensure-SshFirewallRule

$sshRoot = 'C:\ProgramData\ssh'
$sshdConfigPath = Join-Path -Path $sshRoot -ChildPath 'sshd_config'

if (-not (Test-Path -Path $sshRoot -PathType Container)) {
    New-Item -Path $sshRoot -ItemType Directory -Force | Out-Null
}

if ($isAdministratorAccount) {
    $authorizedKeysPath = Join-Path -Path $sshRoot -ChildPath 'administrators_authorized_keys'
    if (-not (Test-Path -Path $authorizedKeysPath -PathType Leaf)) {
        New-Item -Path $authorizedKeysPath -ItemType File -Force | Out-Null
    }

    Write-Host "Target account is administrator. Writing keys to administrators_authorized_keys"
    Write-Host "Keys to import: $($publicKeys.Count)"
    Ensure-FileContainsLines -Path $authorizedKeysPath -Lines $publicKeys
}
else {
    $profilePath = Resolve-ProfilePath -AccountName $targetAccountName
    $sshDir = Join-Path -Path $profilePath -ChildPath '.ssh'
    $authorizedKeysPath = Join-Path -Path $sshDir -ChildPath 'authorized_keys'

    Write-Host "Target account is NOT administrator. Writing keys to user .ssh directory"
    Write-Host "Profile path: $profilePath"

    if (-not (Test-Path -Path $sshDir -PathType Container)) {
        New-Item -Path $sshDir -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path -Path $authorizedKeysPath -PathType Leaf)) {
        New-Item -Path $authorizedKeysPath -ItemType File -Force | Out-Null
    }

    Write-Host "Keys to import: $($publicKeys.Count)"
    Ensure-FileContainsLines -Path $authorizedKeysPath -Lines $publicKeys
}

Set-SshdDirective -Path $sshdConfigPath -Directive 'PasswordAuthentication' -Value 'no'
Set-SshdDirective -Path $sshdConfigPath -Directive 'PermitRootLogin' -Value 'no'
Set-SshdDirective -Path $sshdConfigPath -Directive 'PubkeyAuthentication' -Value 'yes'

Restart-Service -Name sshd

Write-Host ''
Write-Host 'OpenSSH setup is complete.'
Write-Host "Imported GitHub user: $GitHubUser"
Write-Host "Imported key count: $($publicKeys.Count)"
Write-Host "Target Windows account: $targetAccountName"
Write-Host "Target account is administrator: $isAdministratorAccount"
Write-Host "Authorized keys file: $authorizedKeysPath"
Write-Host "SSHD config file: $sshdConfigPath"
Write-Host ''
Write-Host 'Example tunnel command from a client:'
Write-Host 'ssh -L 8889:192.168.1.90:3389 <windows-user>@<windows-server-ip>'
Write-Host 'Then you can remote desktop to the server using localhost:8889 or 127.0.1.1:8889'
Write-Host ''
