Avanade DevOps HOL - Continuous Deployment with Visual Studio Release Management
====================================================================================
In this lab, you have an example MVC application, committed to a Git repository in Visual Studio Team Services (VSTS) and a Continuous Integration build that builds the app and runs unit tests whenever code is pushed to the master branch. Now you want to set up Release Management (a feature of Visual Studio Team Services) to be able continuously deploy the application to an Azure Web App. Initially the app will be deployed to a dev deployment slot. The staging slot will require and approver before the app is deployed into it. Once an approver approves the staging slot, the app will be deployed to the production site.

### Pre-requisites: ###
- Complete [Continuous Integration](../continuous-integration/README.md) lab.


### Tasks Overview: ###

**1. Add ARM Template to Solution:** In this step, add a deployment project to the solution.  This will create an ARM template which will be used to create the App Service and web site in Azure for deploying the solution into.

**2. Create Service Endpoint:** In this step, create a service endpoint in VSTS that will allow you to connect to the Azure subscription and use ARM templates to create the deployment environments.

**3. Create a VSTS Release:** In this step, the release will be created that will configure the deployment environment in Azure and deploy the website to multiple environments.


### I. Add ARM Template to Solution
1. Open the DevOpsHOL solution, that was created in the [Getting Started](../getting-started/README.md) lab, in Visual Studio.  Right click on the solution in Solution Explorer and choose **Add project...**

![](<media/CD1.png>)

2.  Choose a Cloud -> Azure Resource Group project type and name it DevOpsHOL.Deployment.  On the next dialog, choose the **Web App** template.

![](<media/CD2.png>)

3. This will create a new project in the solution that contains the files for deployment to Azure. The **Website.json** file will be used to create the deployment environments in task III below.<br>
NOTE: There are a number of ways that the ARM template could have been created and added to the solution.  However, since a deployment project also automatically creates a PowerShell script for deployment and a template parameters file, this can also be used to manually deploy the solution if desired (but not in this lab).

4. Open the **WebSite.json** file and replace the contents with the content of(https://raw.githubusercontent.com/nagroma/DevOpsHOL/master/source/deploy/azuredeploy.json).  This adds additional features to the deployment such as deployment slots which will be used later in the lab.

5. Open the **WebSite.parameters.json** file and replace the contents with the content of(https://raw.githubusercontent.com/nagroma/DevOpsHOL/master/source/deploy/azuredeploy.parameters.json).  This matches the parameters with the azuredeploy.json file.

4. Check in the solution and push to VSTS (Team Explorer -> Changes -> Commit All and Push).  This checks in the ARM template into source control both locally and in the VSTS repository.  This will also trigger a new build (check to make sure this happened and was successful).

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
1. In the DevOpsHOL project in VSTS, navigate to **Build and Release** -> **Releases** and choose the + icon to create a new release definition.

![](<media/CD5.png>)

2. Near the top of the **Select a Template** panel, choose **Empty process**.  As in the previous lab, you normally would choose a template that closely matches the type of deployment you are doing (or import an existing template), but for this lab we are building it from scratch to see more of the process.

3. Near the top of the page next to **New Release Definition**, click on the pencil icon and rename the release to **DevOpsHOL-CI - CD**

4. On the **Environment** panel, rename the environment to Dev (this will be the development integration environment).

5. Click on the Artifacts +Add link and select the DevOpsHOL-CI as the Source.  Leave the version at "Latest" so the release will deploy the latest build.  Click Add button to add the build to the release artifacts list.

6. In the Environments box, click on the 1 phase, 0 task link under the Dev environment name.  This will open a panel to allow adding of tasks to the release.

6. Click on the **Agent phase** accordion item and review the options for this phase of the release.  Leave these settings as is for now. Click on the + icon to the right of Agent phase and add the following two tasks: **Azure Resource Group Deployment** and **Azure App Service Deploy**.

7. Click on the **Azure Deployment:Create Or Update Resource Group...** accordion and fill out the settings as follows:
>+ Azure Subscription: DevOpsHOLDeployment
>>+ this is the service endpoint set up earlier
>+ Resource Group: $(ResourceGroupName)
>>+ this is a variable set up in the next step
>+ Location: $(SiteLocation)
>+ Template: $(System.DefaultWorkingDirectory)/DevOpsHOL-CI/drop/DevOpsHOL.Deployment/WebSite.json
>+ Override Template Parameters: Click on the ellipsis to the right of the edit box and enter the following names and values:<br>
NOTE: ARM parameters are case sensitive so the name much match the case of the parameters in the ARM template.
```PowerShell
appServicePlanName $(AppServicePlan)
siteName $(WebSiteName)
siteLocation $(SiteLocation)
workerSize "0"
```

![](<media/CD6.png>)

>>+ You will shortly define the values for each parameter, like `$(siteName)`, in the Environment variables.
>>+  **Note**: If you open the WebSite.parameters.json file, you will see placeholders for these parameters. You could hard code values in the file instead of specifying them as "overrides". Either way is valid. If you do specify  values in the parameters file, remember that in order to change values, you would have to edit the file, commit and create a  new build in order for the Release to have access the new values.

8. Click on the **Azure App Service Deploy:** accordion and fill out the settings as follows:
>+ Azure Subscription: DevOpsHOLDeployment
>>+ The name of the endpoint created earlier
>+ App Service name: $(WebSiteName)
>+ Deploy to slot: Checked
>+ Resource group: $(ResourceGroupName)
>+ Slot: Dev

9. Click **Variables** link and add the following variables and values.
	* **AppServicePlan**: DevOpsHOL *(or any name you would like)*
	* **ResourceGroupName**: DevOpsHOL *(or any name you would like)*
	* **SiteLocation**: *Choose a valid Azure location such as "centralus"*
	* **WebsiteName**: *Unique name of the website in Azure*

		> **Note**: Use a unique value for your WebsiteName by adding something custom at the end like your initials. Example for WebsiteName : devopshol-am 

10. Click **Save** and then click **Release -> Create Release**, click **Create**.  Inside the Green notification bar, click on the *Release-1* link to be taken to a page to show the release progress.  If this page doesn't refresh automatically, periodically refresh the page until the release succeeds (if the release fails, review the error message and go back and make adjustments and re-release).

11. Open a browser page and navigate to the website in Azure.  The url will depend on the $(WebsiteName).  For example, if the $(WebsiteName) was devopshol-am, then the naviage to https://devopshol-am-dev.azurewebsites.net/.<br>
NOTE: The website address can be seen on the Azure portal on the WebApp

![](<media/CD7.png>)

12.  Once the initial deployment has been verified, go back and edit the release to add staging and production releases.
>+ Navigate to Build and Release -> Releases
>+ Hover over the **DevOpsHOL-CI - CD** Release Definition and right click on the ellipse (...) and select the Edit menu option.
>+ Hover over the **Dev** environment and select the **Clone** link.

![](<media/CD8.png>)

>+ Rename **Copy of Dev** to **Stage**
>+ Click on the **1 phase, 2 tasks** link in the Stage environment.
>+ Remove the **Azure Deployment:Create Or Update Resource Group** task (no need to re-run the ARM template)
>+ Click on the **Azure App Service Deploy: $(WebSiteName)** task and edit the Slot to change **Dev** to **Staging**.
>+ Save
>+ Click on the **Pipeline** link and repeat the above steps to create a clone of **Staging** called **Prod**
>>+ Uncheck the **Deploy to slot** which will make the release deploy to the production slot.
>+ Save
>+ Release -> Create Release -> Create
>>+ This wil create a release that is deployed to Dev, Stage and Prod
13. Once the release completes successfully to all three environments, verify that the application has been deployed to all three environments
>+ https://\<WebsiteName>-dev.azurewebsites.net/
>+ https://\<WebsiteName>-staging.azurewebsites.net/
>+ https://\<WebsiteName>-dev.azurewebsites.net/
14. By default, the Release process is manual.  Go back to the **Pipeline** tab and click on the lightning bolt icon in the Artifacts panel and enable the Continuous deployment trigger
15. Now go back into Visual Studio and make a change to the code that will be visible in the application.  Observe the status of the Build and Release and verify that all the items configured in the CI and CD labs complete successfuly.

Next steps
----------
In this lab you created a series of environments using an Azure ARM template and automatically deployed to each of these environments.

1. Next do the [Feature Flag](../feature-flag/README.md) lab

2. Explore other options.  Here are some additional tasks that you may want to try to expand your knowledge further.
>+ By default, the releases automatically move from environment to environment upon successful deployment to the previous deployment.  Go back to the release definition
and modify the settings to require approvals prior to deploying to the next environment.
>+ Modify the ARM template (Website.json) to modify some of the properties (e.g. change the worker size or tier; modify the app settings per slot)
>+ Add additional variables to the build or release to make them more dynamic (i.e. less dependent on hard coded names)
>+ Use the ARM template and the Visual Studio deployment and publish process to create an individual Azure environment in addition to the Dev, Stage and production environments.
>+ Delete the DevOpsHOL resource group and re-release the same build to make sure that the environments can be dynamically re-created.
>+ Export the build and release definitions.  Check them into source control.  Delete these definitons and restore from the source files.


