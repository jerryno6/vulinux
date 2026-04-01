# Setup Windows OpenSSH Server and Import GitHub SSH Keys

## Description
Run this script from an elevated PowerShell session on the Windows machine that will accept SSH connections.

The script:
- Requires `Run as Administrator`.
- Prompts for `-GitHubUser` if it is not provided.
- Uses the current Windows account by default, or `-UserName` if provided.
- Downloads public SSH keys from `https://api.github.com/users/<github-user>/keys`.
- Installs `OpenSSH.Client~~~~0.0.1.0` and `OpenSSH.Server~~~~0.0.1.0` if needed.
- Sets the `sshd` service startup type to `Automatic` and starts it.
- Ensures the inbound firewall rule `OpenSSH-Server-In-TCP` exists for TCP port `22`.
- Updates `C:\ProgramData\ssh\sshd_config` to:
  - `PasswordAuthentication no`
  - `PermitRootLogin no`
  - `PubkeyAuthentication yes`
- Restarts the `sshd` service after updating the configuration.

## Key Placement
The script checks whether the target Windows account is a member of the local `Administrators` group.

- If the target account is an administrator, keys are written to `C:\ProgramData\ssh\administrators_authorized_keys`.
- If the target account is not an administrator, keys are written to `%USERPROFILE%\.ssh\authorized_keys` for that target user.

When writing to `C:\ProgramData\ssh\administrators_authorized_keys`, the script also resets ACL inheritance and grants access to `Administrators` and `SYSTEM`.

## Parameters
- `-GitHubUser`
  GitHub username used to fetch public SSH keys. If omitted, the script prompts for it.
- `-UserName`
  Windows account to configure for SSH access. If omitted, the script uses the current account returned by the elevated PowerShell session.

## Notes
- The GitHub user must have at least one public SSH key published on GitHub.
- The script rejects downloaded keys that do not match expected OpenSSH public key formats.
- If `-UserName` is used for a non-administrator account, that user must already have a Windows profile on the machine.

## Examples
Prompt for a GitHub username and configure the current Windows account:

```powershell
.\setup-windows-openssh.ps1
```

Configure the current Windows account with an explicit GitHub username:

```powershell
.\setup-windows-openssh.ps1 -GitHubUser anotheruser
```

Configure a specific Windows user with keys from a specific GitHub account:

```powershell
.\setup-windows-openssh.ps1 -UserName myuser -GitHubUser anotheruser
```

## Output
At the end, the script prints:
- Imported GitHub user
- Imported key count
- Target Windows account
- Whether the target account is an administrator
- Authorized keys file path
- `sshd_config` file path

It also prints this example SSH tunnel command:

```text
ssh -L 8889:192.168.1.90:3389 <windows-user>@<windows-server-ip>
```
