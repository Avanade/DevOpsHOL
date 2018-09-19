param([Parameter(Mandatory=$true)][string]$chocoPackages)
#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Assign Packages to Install
$Packages = 'googlechrome',`
            'visualstudiocode',`
            'git'

#Install Packages
ForEach ($PackageName in $chocoPackages)
{choco install $PackageName -y}

#Reboot
Restart-Computer
