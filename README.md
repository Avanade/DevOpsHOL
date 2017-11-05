# Avanade DevOps HOL
These are the hands on labs associated with the Avanade DevOps Practitioners course.

You can accomplish these labs using Visual Studio 2017 on your local computer, but you may want to consider doing the labs using an Azure VM as the development machine.  This not only keeps you from having to make changes to your local environment, but it gives you additional experience using Azure.  You can either configure an Azure development environment on your own or an easy way to do this is to use PowerShell ISE and execute the following commands.  This will create a new Azure resource group and then configure an Azure VM with Windows 10 and Visual Studio 2017 Community edition.  It will also use Chocolatey to install a collection of other tools and applications.  **Review and modify the script to suit your own needs before executing.**

>**Note:** Sometimes this all works great but other times, the Chocolatey packages do not install when the VM is first created so you may need to run choco install for the individual packages to complete the environment setup.

```PowerShell
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName andrewmo
$VmName = "DevOpsHOL"
$DnsLabelPrefix = "<uniqueDNSName>"
$VmIPName = $VmName+"-ip"
$VmAdminUserName = "<VmAdminUserName>"
$VmAdminPassword ="<TopSecretPassword>"
$ResourceGroupName = "DevOpsHOL"
$ResourceGroupLocation = "East US 2"
$SecureStringPwd = ConvertTo-SecureString $VmAdminPassword -AsPlainText -Force
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
    -TemplateUri "https://raw.githubusercontent.com/nagroma/DevOpsHOL/master/azure-rm/azuredeploy.json" `
    -VmName $VmName `
    -VmSize "Standard_D2s_v3" `
    -VmVisualStudioVersion "VS-2017-Comm-Latest-Win10-N" `
    -VmAdminUserName $VmAdminUserName `
    -VmAdminPassword $SecureStringPwd `
    -DnsLabelPrefix $DnsLabelPrefix `
    -ChocoPackages 'nodejs-lts;python2;visualstudiocode;notepadplusplus;googlechrome;"dotnetcore --version 1.1.2"' `
    -Force -Verbose
```

Once the script above completes, you can use the following to start the VM and check to see that everything was installed correctly.

```PowerShell
Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName
while((Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status | `
    select -ExpandProperty Statuses | `
    ?{ $_.Code -match "PowerState" } | `
    select -ExpandProperty DisplayStatus) -ne "VM running")
{
    Start-Sleep -s 2
}
Start-Sleep -s 5 ## Give the VM time to come up so it can accept remote requests
$vmip = Get-AzureRmPublicIpAddress -Name $VmIPName -ResourceGroupName $ResourceGroupName
$hostdns = $vmip.IpAddress.ToString() ## $vmip.DnsSettings.Fqdn
cmdkey /generic:TERMSRV/$hostdns /user:"$VmName\$VmAdminUserName" /pass:$VmAdminPassword
Start-Process "mstsc" -ArgumentList "/V:$hostdns /f" ## use /span to use both monitors
```

Finally, when you are done, you can use the following scripts to
1. Shut down the VM to minimize Azure charges
```PowerShell
Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName -Force
```
2. Delete the entire resource group when done with the labs or to start fresh.
```PowerShell
Remove-AzureRmResourceGroup -Name $ResourceGroupName
```


Once you have a development environment set up, dive right in to the first [Getting Started](getting-started/README.md) lab.

