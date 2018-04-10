# Avanade DevOps HOL
These are the hands on labs associated with the Avanade DevOps Practitioners course.  This is based to a large part on the [PartsUnlimitedHOL](https://microsoft.github.io/PartsUnlimited/basic/GettingStarted.html) but simplified to use the Visual Studio MVC sample application.  It does not use the PartsUnlimited HOL, but we want to acknowledge that project's contribution to this project.

## Course Pre-requisites ##
If you are taking the Avanade DevOps Practitioners course, then the following are pre-requisites for the beginning of the course.  The pre-requisites are straightforward but a few of the tasks take some time so doing this before the class will save a lot of time for you during the course and will allow you to get the maxium value from the class.
1. Make sure your Azure subscription is enabled and you can log in and create resources.<br>
	[Azure Portal](https://portal.azure.com)
2. An active Visual Studio Team Services account.<br>
	[Sign up for Visual Studio Team Services](https://www.visualstudio.com/en-us/docs/setup-admin/team-services/sign-up-for-visual-studio-team-services)
3. Using an Azure development environment is strongly encouraged.  Complete the steps listed below in the Azure Development Environment.
4. Complete the [Getting Started](getting-started/README.md) lab.  This will make sure that your environment is correctly configured and ready to execute the remaining labs in the course.
5.  Configure a private VSTS agent from the [Private Agent](../private-agent/README.md) lab.

## Azure Development Environment ##
You can accomplish these labs using Visual Studio 2017 on your local computer, but you may want to consider doing the labs using an Azure VM as the development machine.  This not only keeps you from having to make changes to your local environment, but it gives you additional experience using Azure.  You can either configure an Azure development environment on your own or an easy way to do this is to use PowerShell ISE and execute the following commands.  This will create a new Azure resource group and then configure an Azure VM with Windows 10 and Visual Studio 2017 Community edition.  It will also use Chocolatey to install a collection of other tools and applications.  **Review and modify the script to suit your own needs before executing such as changing to VS Enterprise and Window Server 2016 (VS-2017-Ent-Latest-WS2016)**

>**Note:** Sometimes this all works great but other times, the Chocolatey packages do not install when the VM is first created so you may need to run choco install for the individual packages to complete the environment setup.

>**Note:** Run PowerShell as an administrator.

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
    -ChocoPackages 'visualstudiocode;notepadplusplus;googlechrome' `
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

