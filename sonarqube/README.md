# Static code analysis with SonarQube

This lab contains instructions to enable automated code analysis using SonarQube.\
The instructions are based on the following documentation:

- [Analyzing with SonarQube Extension for VSTS-TFS](https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Extension+for+VSTS-TFS)

## Prerequisites

- Complete lab: [Continuous Integration with Azure DevOps](../azure-devops-project/README.md)
- Complete lab: [Multi-stage deployments with Azure DevOps](../multi-stage-deployments/README.md)

## Create a SonarQube instance and project

1. Using the [Azure Portal](https://portal.azure.com), create a SonarQube container instance. Follow instructions from\
[Quickstart: Deploy a container instance in Azure using the Azure portal](https://docs.microsoft.com/azure/container-instances/container-instances-quickstart-portal)\
Ensure the following settings:
   - *Container name:* sonarqube-aci
   - *Container image:* sonarqube
   - *Resource group:* sonarqube-rg (new)
   - *DNS name label:* sonar\<youruniquealias>
   - *Port:* 9000

1. When provisioning is complete, create a project in SonarQube:
   - Visit the SonarQube instance at\
*http:\//sonar\<youruniquealias>.\<location>.azurecontainer.io:9000*
   - Login using the default credentials (admin/admin) 
   - Under Projects, select **Create new project**. Ensure the following settings:
     - *Project key:* devopshol
     - *Display name:* devopshol
   - On the resulting project page, select **Generate** to generate a project token.\
*NOTE: store the token somewhere, it is needed in the next steps to configure the Release*

## Configure SonarQube analysis on the CI Build

1. Add the SonarQube analysis tasks to the **Build**:
   - Edit the CI **Build** 
   - Add the following SonarQube tasks **before** the Build task:
     - Prepare analysis on SonarQube. Ensure the following settings:
     - SonarQube Server Endpoint: *(new)*
       - *Connection name:* 'sonarqube \<project name>'
       - *Server Url:* \<sonarqube instance url>
       - *Token*: \<sonarqube project token>
     - Project Key: \<sonarqube project name>
     - Project Name: \<sonarqube project name>
   - Add the following SonarQube tasks **after** the Build task:
     - Run Code Analysis
     - Publish Quality Gate Result
   - Save the build, do not queue it

1. Add a project guid to the **Website** project.\
*This is a workaround for the SonarQube runner to work with dotnet core projects.\
Otherwise, the dotnet build task will have an error similar to:*\
```No analysable projects were found. SonarQube analysis will not be performed. Check the build summary report for details.```\
Edit the project file (\<websiteprojectname>.csproj), and ensure the *ProjectGuid* property is present:

   <details><summary>&lt;websiteprojectname&gt;.csproj (expand to view code)</summary>

    ```xml
    <PropertyGroup>
        <ProjectGuid>c1182fc3-8c56-4d10-b550-965843e9e9b4</ProjectGuid>
    </PropertyGroup>
    ```
    </details>

1. Commit and push the project file changes, to queue a build.

1. When finished, inspect the SonarQube results for the build:
   - Check the build Summary tab
   - Inspect the status in the section **SonarQube Analysis Report**
   - Open the SonarQube project results by following the **Detailed SonarQube report** link. 
   - Review the code analysis outcome in the SonarQube project results

## Stretch goals

1. Install 'SonarLint for Visual Studio 2017' via 'Tools - Extensions and Updates...'
2. Configure your Sonar server via Team Explorer - SonarQube
3. Build your application and see the Sonar issues appear in the Error List of Visual Studio
4. Mark an issue in SonarQube as false positive and rebuild your application
5. Resolve technical debt or issues reported by SonarQube
6. Set up own SonarQube server to use in this lab using Bitnami

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab