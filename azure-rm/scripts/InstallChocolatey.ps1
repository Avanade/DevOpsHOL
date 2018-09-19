param([Parameter(Mandatory=$true)][string]$chocoPackages)
Write-Output $chocoPackages
cls

New-Item "c:\choco" -type Directory -force | Write-Output
$LogFile = "c:\choco\Script.log"
$chocoPackages | Out-File $LogFile -Append

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Assign Packages to Install
$Packages = 'googlechrome',`
            'visualstudiocode',`
            'git',`
            'visualstudio2017community',`
            'visualstudio2017-workload-azure',`
            'visualstudio2017-workload-netweb'

#Install Packages
ForEach ($PackageName in $Packages)
{choco install $PackageName -y}

#Reboot
Restart-Computer
