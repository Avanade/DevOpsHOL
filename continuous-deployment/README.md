Avanade DevOps HOL - Continuous Deployment with Visual Studio Release Management
====================================================================================
In this lab, you have an example MVC application, committed to a Git repository in Visual Studio Team Services (VSTS) and a Continuous Integration build that builds the app and runs unit tests whenever code is pushed to the master branch. Now you want to set up Release Management (a feature of Visual Studio Team Services) to be able continuously deploy the application to an Azure Web App. Initially the app will be deployed to a dev deployment slot. The staging slot will require and approver before the app is deployed into it. Once an approver approves the staging slot, the app will be deployed to the production site.

### Pre-requisites: ###
- Complete [Continuous Integration](../continuous-integration/README.md) lab.


### Tasks Overview: ###

**1. Add ARM Template to Solution:** In this step, add a deployment project to the solution.  This will create an ARM template which will be used to create the App Service and web site in Azure for deploying the solution into.

**2. Create Service Endpoint:** In this step, create a service endpoint in VSTS that will allow you to connect to the Azure subscription and use ARM templates to create the deployment environments.

**3. Create a VSTS Release:** In this step, the release will be created that will configure the deployment environment in Azure and deploy the website to multiple environments.


### I. Create Service Endpoint
1. Open the DevOpsHOL solution, that was created in the [Getting Started](../getting-started/README.md) lab, in Visual Studio.  Right click on the solution in Solution Explorer and choose **Add project...**

![](<media/CD1.png>)

2.  Choose a Cloud -> Azure Resource Group project type and name it DevOpsHOL.Deployment.  On the next dialog, choose the **Web App** template.

![](<media/CD2.png>)
3. The **Website.json** file will be used to create the deployment environments in task III below.<br>
NOTE: There are a number of ways that the ARM template could have been created and added to the solution.  However, since a deployment project also automatically creates a PowerShell script for deployment and a template parameters file, this can also be used to manually deploy the solution if desired (but not in this lab).

4. Check in the solution and push to VSTS (Team Explorer -> Changes -> Commit All and Push).  This checks in the ARM template into source control.  This will also trigger a new build (check to make sure this happened and was successful)

### II. Create Service Endpoint
1. Go to your **account’s homepage**:
	https://\<your-alias\>.visualstudio.com
2. Select the DevOpsHOL team project that was created in the [Getting Started](../getting-started/README.md) lab.  
This will take you to the project dashboard page.  Click on the Setting icon (gear) in the project menu bar and select Services.  Choose **New Service Endpoint** and select **Azure Resource Manager** from the drop down.

![](<media/CD3.png>)

3. This will open the **Add Azure Resource Manager Service Endpoint** dialog.  Set the Connection Name to "DevOpsHOLDeployment", choose your subscription and click **OK**.<br>
**NOTE:** You will need to allow popups in the browser, otherwise the popup to authenticate to Azure will fail to appear.

![](<media/CD4.png>)

4. Next sign in to your Azure account to complete the endpoint creation process.

### III. Create Release
1. In the DevOpsHOL project in VSTS, navigate to **Build and Release** -> **Releases** and choose the + icon to create a new release definition.  Near the top of the page next to **New Release Defintion**, click on the pencil icon and rename the release to **DevOpsHOL-CI - CD**

![](<media/CD5.png>)

2. Near the top of the **Select a Template** panel, choose **Empty process**.  As in the previous lab, you normally would choose a template that closely matches the type of deployment you are doing (or import an existing template), but for this lab we are building it from scratch to see more of the process.

3. On the **Environment** panel, rename the environment to DevInt (development integration)

4. Click on the Artifacts +Add link and select the DevOpsHOL-CI as the Source.  Leave the version at "Latest" so the release will deploy the latest build.  Click Add button to add the build to the release artifacts list.

5. In the Environments box, click on the 1 phase, 0 task link under the DevInt environment name.  This will open a panel to allow adding of tasks to the release.

6. Click on the **Agent phase** accordion item and review the options for this phase of the release.  Leave these settings as is for now. Click on the + icon to the right of Agent phase and add the following two tasks: **Azure Resource Group Deployment** and **Azure App Service Deploy**.

7. Click on the **Azure Deployment:Create Or Update Resource Group...** accordion and fill out the settings as follows:
>+ Azure Subscription: DevOpsHOLDeployment
>>+ this is the service endpoint set up earlier
>+ Resource Group: $(ResourceGroupName)
>>+ this is a variable set up in the next step
>+ Location: \<pick a location from the list\>
>+ Template: $(System.DefaultWorkingDirectory)\\**\\WebSite.json
>+ Override Template Parameters: Enter the following in a single line (shown split here for convenience):
		```powershell
		-WebsiteName $(WebsiteName)
		-AppServiceName $(AppServiceName)
		-HostingPlanName $(HostingPlan)
		```
>>+ You will shortly define the values for each parameter, like `$(ServerName)`, in the Environment variables.
>>+  **Note**: If you open the FullEnvironmentSeWebSite.parameters.json file, you will see empty placeholders for these parameters. You could hard code values in the file instead of specifying them as "overrides". Either way is valid. If you do specify  values in the parameters file, remember that in order to change values, you would have to edit the file, commit and create a  new build in order for the Release to have access the new values.

8. Click on the **Azure App Service Deploy:** accordion and fill out the settings as follows:
>+ Azure Subscription: DevOpsHOLDeployment
>>+ The name of the endpoint created earlier
>+ App Service name: $(AppServiceName)
>+ NOTE: Leave the **Deploy to slot** unchecked for now.

9. Click **Variables** link and add the following variables and values.
	* **WebsiteName** - Name of the website in Azure
	* **HostingPlan** - Name of the hosting plan for the website

		> **Note**: Use unique values for your variables by adding something custom at the end like your initials. Example for WebsiteName : devopshol-am 

		> **Note**: You can hide passwords and other sensitive fields by clicking the padlock icon to the right of the value text box.

10. Click **Save** and then click **Release -> Create Release**, click **Create**


