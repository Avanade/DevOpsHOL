# Feature branching and branch protection

This lab contains instructions to ensure code quality using pull requests and branch protection.\
The instructions are based on the following documentation:

- [Review code with pull requests](https://docs.microsoft.com/en-us/azure/devops/repos/git/pull-requests)
- [Improve code quality with branch policies](https://docs.microsoft.com/azure/devops/repos/git/branch-policies)

## Prerequisites

- Complete lab: [Pipeline as code with K8s and Terraform](https://dev.azure.com/thx1139/_git/workshop1?path=%2FREADME.md)

## Enable branch protection

1. Protect the **master** branch of your repository by enabling a **branch policy** using:\
   [Improve code quality with branch policies](https://docs.microsoft.com/azure/devops/repos/git/branch-policies)
   Ensure the following policy settings are enabled:
   - Require a minimum number of 1 reviewers (Allow users to approve their own changes)
 
## Configure pull request build

1. Create a new pipeline:
   * **Code location:** Azure Repos Git YAML
   * **Repository:** azdotraining1
   * **Configure:** Starters pipeline

1. Change the name of the pipeline/file towards **pr-pipeline.yml**.

1. Change **vmImage** towards **windows-latest**.

1. Remove the two script steps.

1. In the section steps add the **.Net Core** task with the following settings:  
* **command:** build
* **projects:** **/*.csproj 
    
1. Click on Save and Run. This should successfully build your projects.

1. Edit the **master** branch policy, enable **Build validation** and set it to the pipeline you just created.

## Create a feature branch and make a pull request

1. In your Azure DevOps project, under Repos - Branches, create a new feature branch:
   On the **azdotraining1** repository, create a feature branch named 'feature/newFeature'

1. Switch to the feature branch in Visual Studio

1. In the **mywebapp** project, add a slogan to the home page:\
        ```
        <div>
            <p>Awesome new feature!</p>
        </div>
        ```

1. Commit the changes to the feature branch, and **push** or **sync** the changes to Azure DevOps

1. Create a pull request, from the feature branch to master.\ 
   Inspect the pull request overview page
   Approve the pull request, and notice the CI Build is triggered after approval.

## Stretch goals
1. Try to add other steps/tasks we have added in other labs which would make sense to have in your PR build, for example: SonarQube.

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab
