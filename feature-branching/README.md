# Feature branching and branch protection

This lab contains instructions to ensure code quality using pull requests and branch protection.
The instructions are based on the following documentation:

- [Review code with pull requests](https://docs.microsoft.com/en-us/azure/devops/repos/git/pull-requests)
- [Improve code quality with branch policies](https://docs.microsoft.com/azure/devops/repos/git/branch-policies)

## Prerequisites

- Complete lab: [Continuous Integration with Azure DevOps](../azure-devops-project/README.md)
- Complete lab: [Multi-stage deployments with Azure DevOps](../multi-stage-deployments/README.md)

## Enable branch protection

1. Protect the **master** branch of your repository by enabling a **branch policy** using:\
   [Improve code quality with branch policies](https://docs.microsoft.com/azure/devops/repos/git/branch-policies)
   Ensure the following policy settings are enabled:
   - Require a minimum number of 1 reviewers (Allow users to approve their own changes)
 
## Configure pull request build

1. Create a copy of the **CI Build**, and name it **PR Build**

1. In the **PR Build**, remove all tasks that are publishing artifacts.\
   Ensure the pull request build only contains build and test tasks.

1. Edit the **master** branch policy, enable **Build validation** and set it to the **PR Build**

## Create a feature branch and make a pull request

1. In your Azure DevOps project, under Repos - Branches, create a new feature branch:
   On the **devopshol** repository, create a feature branch named 'feature/slogan' Protect the **master** branch of your repository by enabling a branch policy using:\
   [Review code with pull requests](https://docs.microsoft.com/en-us/azure/devops/repos/git/pull-requests)

1. Switch to the feature branch in Visual Studio

1. In the **Website** project, add a slogan to the home page:
        <details><summary>Views\Home\Index.cshtml (expand to view code)</summary>

        ```csharp
        ...
        <div class="cloud-image">
            <center><h4>DevOps HOL application slogan</h4></center>
            <img src="~/images/successCloudNew.svg" />
        </div>
        ...
        ```
        </details>

1. Commit the changes to the feature branch, and **push** or **sync** the changes to Azure DevOps

1. Create a pull request, from the feature branch to master.\ 
   Inspect the pull request overview page
   Approve the pull request, and notice the CI Build is triggered after approval.

## Stretch goals

1. Move the shared tasks of the **CI** (Continous Integration) build and the **PR** (Pull Request) to a **Task Group**.\
   Ensure the following setup:
   - **PR Build:**
     - 'Build application' task group, containing: Build + Test tasks
   - **CI Build:**
     - 'Build application' task group, containing: Build + Test tasks
     - Publish artifact tasks
1. Prefix the Build number with 'feature'

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab