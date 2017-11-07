Param(
    [Parameter(Mandatory=$false)][string]$ChocoPackages,
    [Parameter(Mandatory=$false)][string]$PartsUnlimited,
    [Parameter(Mandatory=$false)][string]$Extras,
    [Parameter(Mandatory=$false)][string]$VmAdminUserName,
    [Parameter(Mandatory=$false)][string]$VmAdminPassword
    )

cls
function buildVS 
{
    param
    (
        [parameter(Mandatory=$true)]
        [String] $path,

        [parameter(Mandatory=$false)]
        [bool] $nuget = $true,
        
        [parameter(Mandatory=$false)]
        [bool] $clean = $true
    )
    process
    {
        $msBuildExe = 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\msbuild.exe'

        if ($nuget) {
            Write-Host "Restoring NuGet packages" -foregroundcolor green
            nuget restore "$($path)"
        }

        if ($clean) {
            Write-Host "Cleaning $($path)" -foregroundcolor green
            & "$($msBuildExe)" "$($path)" /t:Clean /m
        }

        Write-Host "Building $($path)" -foregroundcolor green
        & "$($msBuildExe)" "$($path)" /t:Build /m
    }
}

New-Item "c:\choco" -type Directory -force | Out-Null
$LogFile = "c:\choco\Script.log"
$ChocoPackages | Out-File $LogFile -Append
$PartsUnlimited | Out-File $LogFile -Append
$Extras | Out-File $LogFile -Append
$VmAdminUserName | Out-File $LogFile -Append
$VmAdminPassword | Out-File $LogFile -Append

$secPassword = ConvertTo-SecureString $VmAdminPassword -AsPlainText -Force		
$credential = New-Object System.Management.Automation.PSCredential("$env:COMPUTERNAME\$($VmAdminUserName)", $secPassword)

# Ensure that current process can run scripts. 
"Enabling remoting" | Out-File $LogFile -Append
Enable-PSRemoting -Force -SkipNetworkProfileCheck

"Changing ExecutionPolicy" | Out-File $LogFile -Append
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

#"Install each Chocolatey Package"
if (-not [String]::IsNullOrWhiteSpace($ChocoPackages)){
    $ChocoPackages.Split(";") | ForEach {
        $command = "cinst " + $_ + " -y -force"
        $command | Out-File $LogFile -Append
        $sb = [scriptblock]::Create("$command")

        # Use the current user profile
        Invoke-Command -ScriptBlock $sb -ArgumentList $ChocoPackages -ComputerName $env:COMPUTERNAME -Credential $credential | Out-Null
    }
}

if (-not [String]::IsNullOrWhiteSpace($PartsUnlimited)){
    Invoke-Command -ScriptBlock {
        $slnPath = "$env:userprofile\Desktop\PartsUnlimitedHOL"
        "slnPath: $slnPath"
        npm install bower -g
        npm install grunt-cli -g
        Copy-Item C:\Python27\python.exe C:\Python27\python2.exe
        New-Item $slnPath -type directory -force
        git clone https://github.com/Microsoft/PartsUnlimited.git $slnPath # The error message "CategoryInfo : NotSpecified: (Switched to branch..." is a documented issues but no workaround.  This still works fine.
        #Sometimes the \AppData\Roaming\npm gets added to the path and some times it doesn't. This makes sure.
        "Adding $env:userprofile\AppData\Roaming\npm to path"
        $AddedLocation ="$env:userprofile\AppData\Roaming\npm"
        $Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
        $OldPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path
        "OldPath: $OldPath"
        if(-Not $OldPath.Contains($AddedLocation)) {
            $NewPath= $OldPath + ';' + $AddedLocation
            Set-ItemProperty -Path "$Reg" -Name PATH -Value $NewPath
            $UpdatedPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path
            "UpdatedPath: $UpdatedPath"
        }

        refreshenv
        buildVS "$slnPath\PartsUnlimited.sln" -nuget $true -clean $false
        Remove-Item $slnPath\src\PartsUnlimitedWebsite\node_modules -Force -Recurse
        buildVS "$slnPath\PartsUnlimited.sln" -nuget $true -clean $true
    } -ComputerName $env:COMPUTERNAME -Credential $credential | Out-File $LogFile -Append
}

#A few more settings that I like but are not required for the PartsUnlimitedHOL
if (-not [String]::IsNullOrWhiteSpace($Extras)){
    Invoke-Command -ScriptBlock {
        # Show file extensions (have to restart Explorer for this to take effect if run maually - Stop-Process -processName: Explorer -force)
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value "0"

        Set-TimeZone -Name "Eastern Standard Time"

        Enable-WindowsOptionalFeature –online –featurename IIS-WebServerRole

    } -ComputerName $env:COMPUTERNAME -Credential $credential | Out-File $LogFile -Append
}

Disable-PSRemoting -Force
