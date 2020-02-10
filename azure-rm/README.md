# Prerequisites lab - Set up your development environment
Follow this lab to set up a development environment for the course labs. Creating the environment can take some time, so it is recommended to complete this before attending the course.

## Prepare Azure DevOps and Azure subscription

1. Make sure you have an active Azure DevOps account.\
[Sign up for Azure DevOps](https://dev.azure.com/)

1. Make sure you have an active Azure subscription.\
Sign in to the [Azure Portal](https://portal.azure.com) to verify you can log in and create resources.\
If you used a (Avanade) organization MDSN account, go to the next step.

1. (only for organization accounts) If you are using your Avanade email to access the Azure portal, then you will need to create a new Active Directory instance. This is because the labs require creating an enterprise application id and individual users do not have permissions to create enterprise applications on the Avanade AD instance.

- In the [Azure Portal](https://portal.azure.com), *Create a Resource* of *Azure Active Directory* with a meaningful name. This is probably something you will use as a general purpose AD instance (i.e. not just for the class) so you may want to name it appropriately.

- For more information, you can reference [Create an Azure Active Directory tenant](https://docs.microsoft.com/en-us/power-bi/developer/create-an-azure-active-directory-tenant#create-an-azure-active-directory-tenant). **DO NOT** execute steps in *Create some users in your Azure Active Directory tenant* section. 	
	- Once the AD instance is created, click on the *All services* menu item and search for *Subscriptions*.  Choose the subscription that is tied to your MSDN account (this is the one you will use for the class).  If you don't see the correct subscription, you might need to switch directories.
	- On the Subscriptions' Overview panel, choose the -> Change directory link and select the new AD instance that you just created.
		- For more information, you can reference [Associate an existing subscription to your Azure AD directory](https://docs.microsoft.com/en-us/azure/active-directory/active-directory-how-subscriptions-associated-directory#to-associate-an-existing-subscription-to-your-azure-ad-directory)

## Prepare development environment

1. Create a DevTest lab\
Follow instructions from [Create a lab in Azure DevTest Labs](https://docs.microsoft.com/azure/lab-services/devtest-lab-create-lab). Ensure the following settings:
   - Lab name: devopslab
   - Resource group: devopslab (new)
   - Location: West Europe
   - Auto-shutdown: default (Enabled, 19:00)

1. Add a Virtual Machine to your DevTest lab\
Follow instructions from [Add a VM to a lab in Azure DevTest Labs](https://docs.microsoft.com/azure/lab-services/devtest-lab-add-vm). Ensure the following settings:
   - Choose a base: Visual Studio 2019 Community on Windows 10 Enterprise N (x64)
   - Virtual machine name: devopsvm
   - User name: devopshol
   - Password: ADP#2019
   - Virtual machine size:
     - Pick any size that fits within your subscription
   - OS disk type: Standard SSD
   - Artifacts selection: Install Chocolatey Packages, configuration:
     - Packages: `git,vscode,microsoft-edge-insider`
     - Allow Empty Checksums: true
     - Ignore Checksums: true

1. Verify connection to the Virtual Machine
   - Wait untill the virtual machine is fully provisioned and the artifacts are applied.\
   *(this can take up to 20 minutes)*
   - Verify you can use the virtual machine by connecting to it:\
   Select 'Connect' in the Virtual machine Overview in the portal and provide the credentials you used in the previous step. 

1. Install .NET Core SDK version 3.1:
   - Open a PowerShell window
   - Enter this command and press Enter:
     - `choco install dotnetcore-sdk`

1. Install Azure CLI
    - Open a PowerShell window
    - Enter this command and press Enter:
      
       `Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'`

## Next steps
Return to the [Lab index](../README.md) to continue with the course labs.