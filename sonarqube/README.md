# Static code analysis with SonarQube

This lab contains instructions to enable automated code analysis using SonarQube.\
The instructions are based on the following documentation:

- [Analyzing with SonarQube Extension for VSTS-TFS](https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Extension+for+VSTS-TFS)

## Prerequisites

- Complete lab: [Pipeline as code with K8s and Terraform](https://dev.azure.com/thx1139/_git/workshop1?path=%2FREADME.md)

## Create a SonarQube instance and project

1. Using the [Azure Portal](https://portal.azure.com), create a SonarQube container instance. Follow instructions from
[Quickstart: Deploy a container instance in Azure using the Azure portal](https://docs.microsoft.com/azure/container-instances/container-instances-quickstart-portal)\
Ensure the following settings:
   - *Resource group:* sonarqube-rg (new)
   - *Container name:* sonarqube-aci
   - *Region:* (Europe) West Europe
   - *Image type:* Public
   - *Image name:* sonarqube
   - *OS type:* Linux
   - *Size:* 2vcpus, 4 GiB memory, 0 gpus
   - *DNS name label:* sonar-\<youruniquealias>
   - *Port:* 9000 TCP

1. When provisioning is complete, create a project in SonarQube:
   - **Visit** the **SonarQube** instance at\
*http:\//sonar-\<youruniquealias>\.westeurope.azurecontainer.io:9000*
   - Login using the default credentials (admin/admin) 
   - Under Projects, select **Create new project**. Ensure the following settings:
     - *Project key:* devopshol
     - *Display name:* devopshol
   - On the resulting project page, select **Generate** to generate a project token. As token name you can use *devopsholtoken* \
*NOTE: store the token somewhere, it is needed in the next steps to configure the Release*

## Configure SonarQube analysis on the Build stage

1. Install the SonarQube extension, go to the [Marketplace](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarqube) and press on **Get it free**. Make sure you select the right Azure DevOps organization, the one you are using for this training.

1. Add SonarQube service connection to your Azure DevOps pipelines
    - Go to Project Settings --> Service Connections
    - Add a new SonarQube service connection with the following demands:
       * Server url: http://sonar-**youruniquealias**.westeurope.azurecontainer.io:9000
       * Token: The just generated token from SonarQube
       * Service connection name: sonarqubeconn1

1. In the App pipeline add a new job *Run_SonarQube_analysis* as first job in the Build stage with the following steps:
    1. Job pool vmImage = *ubuntu-latest*

    1.  Prepare Analysis Configuration (SonarQube)
        * SonarQube Server Enpoint: sonarqubeconn1
        * Integrate with MSBuild
        * Project key: devopshol
        * Project name: devopshol
        * Project version: 1.0

    1. Use .NET Core
        * PackageType: sdk
        * Version: 3.x

    1. .NET Core
        * Command: build
        * Projects: **/mywebapp.csproj

    1. Use .NET Core
        * PackageType: sdk
        * Version: 2.x

    1. Run Code Analysis (SonarQube)

    1. Publish Quality Gate Result (SonarQube)
        * Timeout (s): 300

1. Save the changes to your pipeline, but don't start it yet.

1. Add a project guid to the **mywebapp** project.\
*This is a workaround for the SonarQube runner to work with dotnet core projects.\
Otherwise, the dotnet build task will have an error similar to:*\
```No analyzable projects were found. SonarQube analysis will not be performed. Check the build summary report for details.```\
Edit the project file (mywebapp.csproj), and ensure the *ProjectGuid* property is present:

   <details><summary>mywebapp.csproj (expand to view code)</summary>

    ```xml
    <PropertyGroup>
        <ProjectGuid>c1182fc3-8c56-4d10-b550-965843e9e9b4</ProjectGuid>
    </PropertyGroup>
    ```
    </details>

1. Commit and push the project file changes, to queue a build.

1. When finished, inspect the SonarQube results for the build:
   - Check the build Summary tab
   - Inspect the status in the tab **Extensions**
   - Open the SonarQube project results by following the **Detailed SonarQube report** link. 
   - Review the code analysis outcome in the SonarQube project results

## Stretch goals

1. Install 'SonarLint for Visual Studio 2019' via 'Extensions'
2. Configure your Sonar server via Team Explorer - SonarQube
3. Build your application and see the Sonar issues appear in the Error List of Visual Studio
4. Mark an issue in SonarQube as false positive and rebuild your application
5. Resolve technical debt or issues reported by SonarQube
6. Set up own SonarQube server to use in this lab using Bitnami

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab