# Avanade DevOps HOL - Continuous Integration with Visual Studio Team Services
In this lab, we use the application created in the Getting Started HOL to set up
Visual Studio Team Services to be able continuously integrate code into the master
branch of code. This means that whenever code is committed and pushed to the
master branch, we want to ensure that it integrates into our code correctly to
get fast feedback. To do so, we are going to be setting up a Continuous Integration build (CI) that
will allow us to compile and run unit tests on our code every time a commit is
pushed to Visual Studio Team Services.

**NOTE:** Microsoft changes the way things work all the time so you may have to figure some of this out as the screens may not exactly follow but the principles are the same.

## Pre-requisites: ##
- Complete [Getting Started](../getting-started/README.md) hands on lab.

## Tasks Overview: ##

**1. Create Continuous Integration Build:** In this step, you will create a build definition that will be triggered every time a commit is pushed to your repository in Visual Studio Team Services.

**2. Test the CI Trigger in Visual Studio Team Services:** In this step, test the Continuous Integration build (CI) build we created by changing code in the Parts Unlimited project with Visual Studio Team Services.


## I. Create Continuous Integration Build

A continuous integration build will give us the ability check whether the code
we checked in can compile and will successfully pass any automated tests that we
have created against it.

1. Go to your **account’s homepage**:
	https://dev.azure.com/<your-alias\>
2. Select the DevOpsHOL team project that was created in the [Getting Started](../getting-started/README.md) lab.  
This will take you to the project dashboard page.  From the menu on the left side of the page, choose Pipelines -> Builds. Now click on the **New Pipeline** button.  On the "Select your repository" page, make sure everything is correct and then click **Continue**. 

![](<media/CI1.png>)

3. Select the **Empty job**  link near the top to create a build definition.  
>**Note:** Normally you would just select one of the available templates that is closest to the type of solution you are 
deploying but for this lab we want to walk through a few extra steps to allow you to become more familiar with the process.

>> "Beware of knowledge you did not earn"

4. After clicking the **Empty job** link you'll need to fill out the build definition starting with the Process task and it's children.
>- Process<br>
	Name: **DevOpsHOL-CI**<br>
	Agent queue: **Hosted VS2017**<br>
> **Note:** This will use a hosted (i.e. built in) build server.  
For more flexibility in the build (and for a more in depth learning experience), a private agent can be configured and used following the steps in the [Private Agent](../private-agent/README.md) lab.  This is not necessary for this lab, but you can do this if you are up for the adventure.
>- Process -> Get Sources<br>
	Azure Repos Git<br>
	Team Project: DevOpsHOL<br>
	Repository: DevOpsHOL
5. To the right of the **Agent job 1** item click on the + sign and add the following tasks:<br>
    For each of the tasks, the settings for that task (if different than the default) are listed below<br>
 (*Hint: use the search box to filter in order to find the tasks in the list*)
>- NuGet Tool Installer (Use NuGet 4.3.0)
>- NuGet (NuGet restore)
>- Visual Studio Build<br>
	MSBuild Arguments: /p:DeployOnBuild=true /p:WebPublishMethod=Package /p:PackageAsSingleFile=true /p:SkipInvalidConfigurations=true /p:PackageLocation="$(build.artifactstagingdirectory)"<br>
	Platform: $(BuildPlatform)<br>
	Configuration: $(BuildConfiguration)
>- .NET Core<br>
	Display name: Test Assemblies<br>
	Command: test<br>
	Path to project(s): **/\*test\*.csproj<br>
	Publish test results: Checked<br>
>- Publish Build Artifacts<br>
	Path to publish: $(build.artifactstagingdirectory)<br>
	Artifact name: drop<br>
	Artifact publish location: Azure Pipelines/TFS<br>

![](<media/CI2.png>)

6. Click on the **Variables** tab and add the following Variables:
>- **BuildConfiguration** with a value of **release**
>- **BuildPlatform** with a value of **any cpu**
7. Click on the **Triggers** tab and verify that the **Continuous integration (CI)** option is selected to build the solution every time a change is checked in. Also make sure the filter includes the appropriate branch (in this case **master** and **Batch Changes** checkbox is unchecked
8. Click on the **Options** tab and change the following settings
>- Build number format: $(date:yyyyMMdd)$(rev:.r)
>- Automatically link new work in this build: Enabled
9. Choose **Save & queue** to save the build definition and manually trigger the build.

![](<media/CI3.png>)

10. Click on the **Build Number**, and you should get the build in progress. Here you can also see the commands being logged to console and the current steps that the build is on.

![](<media/CI4.png>)


## II. Test the CI Trigger in Visual Studio Team Services

We will now test the **Continuous Integration build (CI)** build we created by changing code in the project with Visual Studio.

1. Go back to the DevOpsHOL solution in Visual Studio and navigate to the **/Controllers** open the **HomeController.cs** file for editing.
2. Find the ViewBag.Message within the About() method and change the string to something different such as "My description page.".

![](<media/CI5.png>)

3. Build and test the solution locally.  NOTE: You may have to **Accept** the cookie policy to see the menu for the **About** page if you made the suggested change above.

![](<media/CI6.png>)

4. Once you have validated the change locally, **Commit All and Push**. This will check in the changes to the local Git repository and push the change to the VSTS Git repository.

![](<media/CI7.png>)

5. Go back to the VSTS DevOpsHOL project and verify that another build has been automatically started.  Once the build is complete, check the build status and review the results.  If the build failed on the Test step, it might have been because you didn't run and fix the unit tests before checking in.  Go back and get the unit tests working and retry.

![](<media/CI8.png>)

## Next steps ##
----------

In this lab, you learned how to push new code to Visual Studio Team Services, setup a Git repo and create a Continuous
Integration build that runs when new commits are pushed to the master branch.
This allows you to get feedback as to whether your changes made breaking syntax
changes, or if they broke one or more automated tests, or if your changes are a okay.

Next do the [Continuous Deployment](../continuous-deployment/README.md) lab

## Shortcut ##
1. Download the [DevOpsHOL-CI.json](../source/build/DevOpsHOL-CI.json) file locally
2. Go to your project home page and select the **Build and Release** menu item.
3. Click the **+Import** button and select the file downloaded in step 1 and click Import.
4. After the import choose the Hosted VS2017 agent and click on the "Get Sources" process step and verify that it is correctly configured as described above.
5. Choose "Save & queue" to verify that the import and build were successful.

**NOTE: Due to constant changes in Azure DevOps, the import file may not successfully import all the required settings.  You'll still need to go through each setting and verify that it is valid. This may not really be much of a shortcut after all but it does illustrate that you can export and import build and release configurations to some extent.**
