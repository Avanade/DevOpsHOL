# Avanade DevOps HOL - Getting Started

In this lab, we will be installing the required development components to setup your lab environment.

You can either configure an Azure development environment on your own, or use a simple PowerShell script provided in this document. The script will create a new Azure resource group and then configure an Azure VM with Windows 10 and Visual Studio 2017 Community edition. It will also use Chocolatey to install a collection of other tools and applications. **Review and modify the script to suit your own needs before executing such as changing to VS Enterprise and Windows Server 2016 (VS-2017-Ent-Latest-WS2016)**

## Prerequisites

1. An active Azure subscription
   - Visit the [Azure Portal](https://portal.azure.com)

1. An active Visual Studio Team Services account.
   - [Sign up for Visual Studio Team Services](https://www.visualstudio.com/en-us/docs/setup-admin/team-services/sign-up-for-visual-studio-team-services)

1. Install [Azure PowerShell](https://docs.microsoft.com/nl-nl/powershell/azure/install-azurerm-ps) on your local machine

## Environment requirements

1. [Visual Studio 2017](http://go.microsoft.com/fwlink/?LinkId=517106)
   - Select the following workloads:
     - ASP.NET and web development
     - Azure development (including PowerShell tools)
     - .NET Core cross-platform development

## Optional: Setup through PowerShell

In case you chose not to set up your own environment through the Azure Portal, this section is just for you!

Execute the following steps:

1. Run PowerShell ISE as an administrator.

1. Paste the following PowerShell code in the script pane:

    ```PowerShell
    Login-AzureRmAccount
    Select-AzureRmSubscription -SubscriptionName <MyAzureSubscriptionName>
    $VmName = "DevOpsHOL"
    $DnsLabelPrefix = "<UniqueDNSName>"
    $VmIPName = $VmName+"-ip"
    $VmAdminUserName = "<VmAdminUserName>"
    $VmAdminPassword ="<TopSecretPassword>"
    $ResourceGroupName = "DevOpsHOL"
    $ResourceGroupLocation = "East US 2"
    $SecureStringPwd = ConvertTo-SecureString $VmAdminPassword -AsPlainText -Force
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force
    New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
        -TemplateUri "https://raw.githubusercontent.com/Avanade/DevOpsHOL/master/azure-rm/azuredeploy.json" `
        -VmName $VmName `
        -VmSize "Standard_D2s_v3" `
        -VmVisualStudioVersion "VS-2017-Comm-Latest-Win10-N" `
        -VmAdminUserName $VmAdminUserName `
        -VmAdminPassword $SecureStringPwd `
        -DnsLabelPrefix $DnsLabelPrefix `
        -ChocoPackages 'visualstudiocode;googlechrome' `
        -Force -Verbose
    ```

    **Note:** Sometimes this all works great but other times, the Chocolatey packages do not install when the VM is first created so you may need to run choco install for the individual packages to complete the environment setup.

1. Replace all the \<placeholders\> with your own values and run the script.

1. Once the script above completes, you can use the following to start the VM and check to see that everything was installed correctly.

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

## Optional: Cleanup resources

Finally, when you are done, you can use the following code to:

- Shut down the VM to minimize Azure charges
    ```PowerShell
    Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName -Force
    ```
- Delete the entire resource group when done with the labs or to start fresh.
    ```PowerShell
    Remove-AzureRmResourceGroup -Name $ResourceGroupName
    ```