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
Make sure that your development environment contains the following prerequisites:

- Google Chrome v87.0.4280.8800 or higher
- Visual Studio 2019
- .NET Core SDK version 3.1
- GIT
- Azure CLI
   - Open a PowerShell window and run the following command:

      ```PowerShell
      Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
      ```
- VS Code *(Optional)*

## Next steps
Return to the [Lab index](../README.md) to continue with the course labs.