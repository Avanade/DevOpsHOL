# Terraform

This lab contains instructions to learn the basics of Terraform.

This instructions are based on the following documentation
- [Getting started - Azure](https://learn.hashicorp.com/terraform?track=azure#azure)

## Prerequisites
- PowerShell installed on local machine

## Install Terraform
1. [Click here](https://www.terraform.io/downloads.html) to go to the download page of Terraform. Download here the Terraform package for your local machine.

1. After the download is finished unzip the downloaded package in a directory of your choosing (Documents, Desktop, etc...). Don't unzip the package the program files, because this will give access rights issues.

1. Modify Environment Variables to include the path of the Terraform directory.
    1. On your local machine go to `Control Panel -> System -> Advanced system settings -> Environment Variables`
    1. Select Variable `Path` and click on Edit
    1. Click on New and provide as input value the location path where the Terraform has been unzipped

1. Verifying the installation
    1. Open a new PowerShell prompt and execute the command `terraform`
    1. This will trigger the help text of Terraform. When you see the help text Terraform has been correctly installed on your machine.

1. Close the PowerShell prompt, you will need a new one to continue this lab.

## Create configuration
1. In the File Explorer navigate to the installation directory of Terraform. Here you will create a new text file named `main.txt`

1. Open `main.txt` and put the following text in the file":
    ```PowerShell
    		# Configure the Azure provider
			provider "azurerm" {
			    version = "~>1.32.0"
			}
			
			# Create a new resource group
			resource "azurerm_resource_group" "rg" {
			    name     = "myTFResourceGroup"
			    location = "westeurope"
			}
    ```

1. Save and close the file `main.txt`

1. Change the file extension from `.txt` to `.tf`

## Build Infrastructure
1. Navigate with the File Explorer to the installation directory of Terraform. 
1. In the File Explorer location path type `PowerShell` and press enter.

    ![alt text](../images/terraform-powershell.jpg "")

1. A new PowerShell prompt will open with the Terraform directory as his current location path

1. Execute the PowerShell command `Add-AzureAccount` to login in your Azure account inside the PowerShell prompt

1. Initialize the Terraform configuration directory by executing the command `terraform init`

1. Create an Terraform execution plan with the command `terraform plan` this will show all the changes Terraform will do when you apply the configuration.

1. Now execute the Terraform configuration and actualy create the new Resource Group in the [Azure Portal](https://portal.azure.com) execute the command `terraform apply`

1. Go to the [Azure Portal](https://portal.azure.com) and there you will see a new empty Resource Group with the name `myTFResourceGroup`

## Change Infrastructure
1. Open the file `main.tf` (for example with Notepad, VS Code or Notepad++)

1. Add tags for the Resource Group to the current configuration. The configuration should look like this:
    ```PowerShell
    			resource "azurerm_resource_group" "rg" {
			    name     = "myTFResourceGroup"
			    location = "westeurope"
			
			    tags = {
			        environment = "TF sandbox"
			    }
    }
    ```

1. Save and close the file `main.tf`

1. Open the PowerShell prompt again and login to Azure with the command `Add-AzureAccount`. This is not needed when you still use the PowerShell prompt of the exercise `Build Infrastructure`

1. Create a Terraform plan and save it with the command `terraform plan -out=newplan`

1. The PowerShell prompt will show the changes that Terraform will make when you will execute this plan
    - ~ indicates that the object will be updated
    - \+ indicates that the object will be created
    - \- indicates that the object will be removed

1. To execute the just created plan use the command `terraform apply "newplan"`

1. To view the new values associated with the resource group execute the command `terraform show`

## Destroy Infrastructure
1. You can easily destroy your whole created Infrastructure with the command `terraform destroy`. Execute this command to remove the created resource group

1. In the [Azure Portal](https://portal.azure.com) you will see that the resource group `myTFResourceGroup` won't exists anymore

## Dependencies
!! Todo: Explain dependencies

## Variables
1. !! Todo: Explain terraform variables

1. Create a terraform template 
    - The template must contain the variables `resource-prefix` and `location`
    - The template must contain configuration for a Resource Group
        - The configuration for a Resource Group can be found in the previous exercises
    - The template must contain configuration for a Virtual Network
        - Example of a Virtual Network configuration:
        ```PowerShell
        	resource "azurerm_virtual_network" "vnet" {
			  name                = "PrefixTFVnet"
			  address_space       = ["10.0.0.0/16"]
			  location            = "westeurope"
			  resource_group_name = "<name of the resource group>"
			}
        ```
    - The template must contain configuration for a Subnet
        - Example of a Subnet configuration:
        ```Powershell
        	resource "azurerm_subnet" "subnet" {
			  name                 = "PrefixTFSubnet"
			  resource_group_name  = "<name of the resource group>"
			  virtual_network_name = "<name of the virtual network>"
			  address_prefix       = "10.0.1.0/24"
            }
        ```

1. Use an external variables.tf file which will contain the two variables `resource-prefix` and `location`

1. Use an external terraform.tfvars file which will contain the two variables `resource-prefix` and `location`

1. Use an output variable to display the resource group name

## Modules
1. !! Todo: explain modules

1. Modify the template `main.tf` so it will use modules to create a `Network` and a `Virtual Machine`

## Stretch goals
1. Create a custom template (no modules) which will deploy a Virtual Machine. The template must contain the following parts:
    - Resource Group
    - Virtual Network
    - Subnet
    - Public IP
    - Network Security Group and rule
    - Network interface
    - Virtual Machine

1. Use a provisioner in your custom template for deploying a Virtual Machine
    - !! Todo: explain provisioners
