# Avanade DevOps HOL - Prerequisites

In this lab, we will be installing the required development components to setup your lab environment.

You can either configure an Azure development environment on your own, or use a simple PowerShell script provided in this document. The script will create a new Azure resource group and then configure an Azure VM with Windows 10 and Visual Studio 2017 Community edition. It will also use Chocolatey to install a collection of other tools and applications. **Review and modify the script to suit your own needs before executing such as changing to VS Enterprise and Windows Server 2016 (VS-2017-Ent-Latest-WS2016)**

## Prerequisites

1. An active Azure subscription on a personal AD (Not the Avanade AD).
   - Visit the [Azure Portal](https://portal.azure.com)

1. An active Visual Studio Team Services account.
   - [Sign up for Visual Studio Team Services](https://www.visualstudio.com/en-us/docs/setup-admin/team-services/sign-up-for-visual-studio-team-services)

1. Install [Azure PowerShell](https://docs.microsoft.com/nl-nl/powershell/azure/install-azurerm-ps) on your local machine

## Set up your environment with Azure DevTestLabs

1. Download the [devtestlabs demo](./demos/devtestlabs) directory or clone this entire repository to your local filesystem with Git.

1. Run Windows PowerShell ISE as an administrator and open [ProvisionDemoLab.ps1](./demos/devtestlabs/ProvisionDemoLab.ps1).

1. Edit the ResourceGroup variables in the top of this script to your personal preference. Make sure the subscription name is the name of an actual subscription on your Azure account:
    ```PowerShell
    $ResourceGroupName = "rg-ADP2018"
    $ResourceGroupLocation = "West Europe"
    $subscriptionName = "Visual Studio Enterprise"
    ```

1. Run the script (F5) to start deploying this template to Azure. Wait for the operation to complete before closing the PowerShell ISE.

1. Go to [your Azure Portal](https://portal.azure.com) and open your DevTestLab.

1. Go to "My virtual machines" to add a new VM to your lab.
    ![Add new DevTestLab VM](./images/prereq-addvm.png)

1. Choose the formula that was created as part of your Lab (Developer) as base.
    ![Vsts](./images/prereq-choosevmbase.png)

1. Enter a name for your Virtual Machine and click "Create" to begin creating the VM.

1. One eternity later, your VM has been created.