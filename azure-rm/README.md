# Avanade DevOps HOL - Prerequisites - Set up your development environment with PowerShell and ARM
If you are taking the Avanade DevOps Practitioners course, then the following are pre-requisites for the beginning of the course.  The pre-requisites are straightforward but a few of the tasks take some time so doing this before the class will save time during the course and allow you to get the maximum value from the class.

## Preparing your Azure subscription

Make sure your Azure subscription is enabled and you can log in and create resources. Visit the [Azure Portal](https://portal.azure.com) to verify.

If you are using your Avanade email to access the Azure portal, then you will need to create a new Active Directory instance. This is because the labs require creating an enterprise application id and individual users do not have permissions to create enterprise applications on the Avanade AD instance.

- In the [Azure Portal](https://portal.azure.com), *Create a Resource* of *Azure Active Directory* with a meaningful name. This is probably something you will use as a general purpose AD instance (i.e. not just for the class) so you may want to name it appropriately.

- For more information, you can reference [Create an Azure Active Directory tenant](https://docs.microsoft.com/en-us/power-bi/developer/create-an-azure-active-directory-tenant#create-an-azure-active-directory-tenant). **DO NOT** execute steps in *Create some users in your Azure Active Directory tenant* section. 	
	- Once the AD instance is created, click on the *All services* menu item and search for *Subscriptions*.  Choose the subscription that is tied to your MSDN account (this is the one you will use for the class).  If you don't see the correct subscription, you might need to switch directories.
	- On the Subscriptions' Overview panel, choose the -> Change directory link and select the new AD instance that you just created.
		- For more information, you can reference [Associate an existing subscription to your Azure AD directory](https://docs.microsoft.com/en-us/azure/active-directory/active-directory-how-subscriptions-associated-directory#to-associate-an-existing-subscription-to-your-azure-ad-directory)

## Preparing a Development environment

1. Make sure you have an active Azure DevOps account.<br>
[Sign up for Azure DevOps](https://dev.azure.com/)

2. Verify that PowerShell v5+ is installed along with the AzureRM modules.
    - Install-Module Powershellget -Force
    - Install-Module -Name AzureRm -AllowClobber
    - Import-Module -Name AzureRM

3. Using an Azure development environment is strongly encouraged. This avoids conflicts with your existing development environment.  Complete the steps listed below in the [Azure Development Environment](#azure-development-environment).

4. Complete the [Getting Started](getting-started/README.md) lab. This will make sure that your environment is correctly configured and ready to execute the remaining labs in the course.

5. Configure a private Build/Release agent from the [Private Agent](private-agent/README.md) lab.

## Set up the Azure Development Environment
You can either configure an Azure development environment on your own or use the PowerShell script provided by this lab. This will create a DevTestLab in a new Azure Resource Group and then configure an Azure VM with Windows 10 and the latest Visual Studio Community edition. It will also use Chocolatey to install a collection of other tools and applications.

>**Note:** Not all VM SKUs are available in every region.  You can get the list of SKUs in a particular location with the following PowerShell commands.
```PowerShell
$locName="South Central US"
Get-AzureRMVMImageSku -Location $locName -Publisher "MicrosoftVisualStudio" -Offer "VisualStudio" | Select Skus
```

To start setting up your environment, follow these steps:

1. Clone this repository or download the [azure-rm](../azure-rm) folder and extract the files on your system.

1. Open **ProvisionEnvironment.ps1** and modify the following lines of PowerShell code in the top of the file:
    ```PowerShell
    $subscriptionName = "Services"  # Change to the name of your azure subscription
    $ResourceGroupName = "adp2019"  # Change if you want to name the resource group differently
    ```

1. Then open a PowerShell console in the same folder and execute the file: .\ProvisionEnvironment.ps1

1. Watch how the script will create your required resources in Azure. **The  process may take 20 minutes.**

## Next steps
Return to [the lab index](../README.md) and continue with the next lab.