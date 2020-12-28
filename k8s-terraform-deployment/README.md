# Avanade DevOps HOL - Define your continuous deployment process with Kubernetes and Terraform
In this lab, we modify the automated generated CD pipeline so it will work with Kubernetes and Terraform.

## Prerequisites
- Complete lab [Continuous Integration with Azure DevOps](../azure-devops-project/README.md).

## Tasks

### Replace ARM templates with Terraform
The automated generated CD pipeline uses ARM templates for setting up the environment. You should probably see some releases that are failed. This happened because the CD pipeline was automatically triggered after every successfull build. The published build artifacts doesn't contain any ARM templates, which are needed in the current version of the CD pipeline. We will remove the old ARM deployment step and replace it with Terraform deployment steps.

1. Edit the current CD pipeline and open the stage dev.

1. Remove `Azure Deployment: Create AKS cluster` this is the ARM deployment step.

1. Add a new Copy Files step after step 1 `Azure CLI: Preserve Cluster Tags`. Make sure it configured as:
    - Display name: `Copy Terraform templates`
    - Source Folder: `$(System.DefaultWorkingDirectory)/Drop/drop/TerraformTemplates`
    - Contents: `*.tf`
    - Target Folder: `$(System.DefaultWorkingDirectory)/Terraform`

1. After the just created copy step, create a new Terraform step with the following settings:
     - Display name: `Terraform: init`
     - Command: `init`
     - Configuration directory: `$(System.DefaultWorkingDirectory)/Terraform`
     - Azure subscription: `<your Azure subscription>`
     - Resource group: `<your Azure resource group>`
     - Storage account: `devopsholstorage`
     - Container: `terraform-state`
     - Key: `<Can be found in the Azure Storage Account --> Settings --> Access keys>`

1. After the just created Terraform step add a new Terraform step with the following configuration:
    - Display name: `Terraform: validate and apply`
    - Command: `validate and apply`
    - Configuration directory: `$(System.DefaultWorkingDirectory)/Terraform`
    - Azure subscription: `<your Azure subscription>`

1. Now the CD pipeline is adjusted to use Terraform. Save your changes and create a new release.

### Wat moet er nog bij
- Test application, reach out naar het


az aks get-credentials -n cl0020 -g rg0020
az aks install-cli
kubectl get services --all-namespaces


- Stretch: Blue/Green - namespaces 
