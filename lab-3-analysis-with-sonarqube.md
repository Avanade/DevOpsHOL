# Avanade DevOps HOL - Lab 3 - Analysis with SonarQube

In this lab, we enable SonarQube for analysis of our code.

Based on [this](https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Extension+for+VSTS-TFS) tutorial.

## Prerequisites

- Complete [Lab 2 - Add QA environment and define your multi-stage continuous deployment process with approvals and gates](lab-2-multi-stage-deployments.md).
- Your VSTS Agent Machine needs Java 8 installed.

## Tasks

1. Login to SonarQube and open the Help menu. This menu can be found here:
    ![Tutorial steps](images/lab-3-tutorial.png)

1. Start the "Analyze a new project" tutorial and follow steps 1 and 2. For step 2 do not run the manual command line instructions from the tutorial. Make sure you save the Token and Project Key somewhere safe for later use in VSTS.

1. Edit your build definition and add task "Prepare analysis on SonarQube" before any Msbuild or VSBuild task.
    - Install SonarQube extension from marketplace if the task is not yet available on your VSTS account
    - Add a new SonarQube endpoint if you don't have one yet (Use the saved Token)
    - Enter the saved Project Key and make up a name for your Project
    - Under Advanced, use the following additional properties:
        - sonar.exclusions=wwwroot/lib/**
        - d:sonar.login="\<your token\>"

1. Add task "Run Code Analysis" and "Publish Quality Gate Result" to your build.

1. Reorder the tasks to respect the following order:
   - Prepare Analysis task before any MSBuild or Visual Studio Build task
   - Run Code Analysis task after the Visual Studio Test task
   - Publish Quality Gate Result task after the Run Code Analysis task

1. Save the build, do not queue it.

1. Edit your Web Application's Project file (csproj) and add a ProjectGuid. This is a workaround for the SonarQube runner to work with dotnet core projects, because the dotnet build task will come up with the following warning: "```The project does not have a valid ProjectGuid. Analysis results for this project will not be uploaded to SonarQube```".
   - <details><summary>Click here for the project file change</summary>

        ```xml
        <PropertyGroup>
            <TargetFramework>netcoreapp2.0</TargetFramework>

            ...

            <ProjectGuid>c1182fc3-8c56-4d10-b550-965843e9e9b4</ProjectGuid>
        </PropertyGroup>
        ```
     </details>

1. Once the project file is updated, push these changes to queue the next build.

1. When the build process has finished, open the latest build and click on "Detailed SonarQube report" in the build Summary tab. Review the project analysis on the SonarQube site.

## Stretch goals

1. Install 'SonarLint for Visual Studio 2017' via 'Tools/Extensions and Updates...'
2. Configure your Sonar server via Team Explorer/SonarQube
3. Build your application and see the Sonar issues appear in the Error List of Visual Studio
4. Mark an issue in SonarQube as false positive and rebuild your application
5. Resolve technical debt or issues reported by SonarQube
6. Set up own SonarQube server to use in this lab using Bitnami

## Next steps

Continue with [Lab 4 - Feature Toggle](lab-4-feature-toggle.md).