# Avanade DevOps HOL
These are the hands on labs associated with the Avanade DevOps Practitioners course.  This is based to a large part on the [PartsUnlimitedHOL](https://microsoft.github.io/PartsUnlimited/basic/GettingStarted.html) but simplified to use the Visual Studio MVC sample application.  It does not use the PartsUnlimited HOL, but we want to acknowledge that project's contribution to this project.

## Course Pre-requisites ##
If you are taking the Avanade DevOps Practitioners course, then the following are pre-requisites for the beginning of the course.  The pre-requisites are straightforward but a few of the tasks take some time so doing this before the class will save time during the course and allow you to get the maximum value from the class.
1. Make sure your Azure subscription is enabled and you can log in and create resources.<br>
	[Azure Portal](https://portal.azure.com)<br>
	If you are using your Avanade email to access the Azure portal, then you will need to create a new Active Directory instance.  This is because the labs require creating an enterprise application id and individual users do not have permissions to create enterprise applications on the Avanade AD instance.
	- In the [Azure Portal](https://portal.azure.com), *Create a Resource* of *Azure Active Directory* with a meaningful name. This is probably something you will use as a general purpose AD instance (i.e. not just for the class) so you may want to name it appropriately. 
		- For more information, you can reference [Create an Azure Active Directory tenant](https://docs.microsoft.com/en-us/power-bi/developer/create-an-azure-active-directory-tenant#create-an-azure-active-directory-tenant). **DO NOT** execute steps in *Create some users in your Azure Active Directory tenant* section. 	
	- Once the AD instance is created, click on the *All services* menu item and search for *Subscriptions*.  Choose the subscription that is tied to your MSDN account (this is the one you will use for the class).  If you don't see the correct subscripiton, you might need to switch directories.
	- On the Subscriptions' Overview panel, choose the ->Change directory link and select the new AD instance that you just created.
		- For more information, you can reference [Associate an existing subscription to your Azure AD directory](https://docs.microsoft.com/en-us/azure/active-directory/active-directory-how-subscriptions-associated-directory#to-associate-an-existing-subscription-to-your-azure-ad-directory)
1. An active Visual Studio Team Services account.<br>
	[Sign up for Visual Studio Team Services](https://www.visualstudio.com/en-us/docs/setup-admin/team-services/sign-up-for-visual-studio-team-services)
1. Verify that PowerShell v5+ is installed along with the AzureRM modules.
    - Install-Module Powershellget -Force
    - Install-Module -Name AzureRm -AllowClobber
    - Import-Module -Name AzureRM
1. Using an Azure development environment is strongly encouraged.  This avoids conflicts with your existing development environment.  Complete the steps listed below in the [Azure Development Environment](#azure-development-environment).
1. Complete the [Getting Started](getting-started/README.md) lab.  This will make sure that your environment is correctly configured and ready to execute the remaining labs in the course.
1.  Configure a private VSTS agent from the [Private Agent](private-agent/README.md) lab.

## Azure Development Environment ##
You can accomplish these labs using Visual Studio 2017 on your local computer, but you may want to consider doing the labs using an Azure VM as the development machine.  This not only keeps you from having to make changes to your local environment, but it gives you additional experience using Azure.  You can either configure an Azure development environment on your own or an easy way to do this is to use PowerShell ISE and execute the following commands.  This will create a new Azure resource group and then configure an Azure VM with Windows 10 and Visual Studio 2017 Community edition.  It will also use Chocolatey to install a collection of other tools and applications.  **Review and modify the script to suit your own needs before executing such as changing the VmVisualStudioVersion to VS Enterprise and Window Server 2016 (VS-2017-Ent-Latest-WS2016) or changing the ResourceGroupLocation to "South Central US"**

>**Note:** Not all VM SKUs are available in every region.  You can get the list of SKUs in a particular location with the following PowerShell commands.
```PowerShell
$locName="South Central US"
Get-AzureRMVMImageSku -Location $locName -Publisher "MicrosoftVisualStudio" -Offer "VisualStudio" | Select Skus
```

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

