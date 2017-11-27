
# Avanade DevOps HOL - Getting Started
In this lab, we will be installing the required development components and verifying that the solution builds and is able to be pushed to VSTS.
## Pre-requisites ##
1. An active Azure subscription<br>
	[Azure Portal](https://portal.azure.com)
2. An active Visual Studio Team Services account.<br>
	[Sign up for Visual Studio Team Services](https://www.visualstudio.com/en-us/docs/setup-admin/team-services/sign-up-for-visual-studio-team-services)

## Set up your machine ##
1. Install [Visual Studio 2017](http://go.microsoft.com/fwlink/?LinkId=517106)<br>
      Select ASP.NET and web development and Azure development tools on the installer.
2. Install [Azure Power Shell](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.1.0)

## Create MVC web application ##
1. Open Visual Studio 2017

2. Make sure GIT is the current source control plugin (under Tools -> Options -> Source Control -> Plug-in Selection)

3. Go to File -> New -> Project... and create a new ASP.NET Core Web Application<br>
    + Name: DevOpsHOL<br>
    + Location: *where ever you put project source*<br>
    + Create Directory for solution: Checked<br>
    + Create new Git repository: Checked<br>
    + Click OK<br>
    + On the next dialog, choose Web Application (Model-View-Controller) as the application type, No Authentication<br>
    + Click OK<br>

4.  Build and run the solution to make sure everything is OK to this point.
    + Debug -> Start Debugging (F5)<br>
		+ If application doesn't start the first time, just run again.
    + Do a quick smoke test to verify that the solution built and runs correctly.<br>
    + Close browser and stop debugging<br>

5. Choose File -> New -> Project... and add a Unit Test Project (.NET Core) project, to the solution *not the .NET Framework unit test project*.
    + Name: DevOpsHOL.Tests<br>
    + Solution: Add to solution<br>

6. Rename **UnitTest.cs** to **HomeControllerTest.cs** and replace the file contents with the content of this file [HomeControllerTest.cs](../source/tests/HomeControllerTest.cs)

7. Add the "DevOpsHOL" and "Microsoft.AspNetCore.Mvc.ViewFeatures.dll" as references to the DevOpsHOL.Tests project. Tip: Use quick refactoring.

8. Build, run unit tests and run the solution to make sure everything is OK to this point.
    + Test -> Run -> All Tests (Ctrl+R,A)<br>
    + Debug -> Start Debugging (F5)<br>
    + Do another quick smoke test to verify that the solution built and runs correctly.<br>
    + Close browser and stop debugging<br>

9. Add solution to VSTS project (Team Explorer -> Sync -> Publish Git Repo)
    + Push to Visual Studio Team Services<br>
    + Repository name: DevOpsHOL<br>
    + Publish repository will create a project in VSTS (NOTE: if you have multiple VSTS accounts, make sure this is published to the correct Team Services Domain).<br>

![](<media/GS1.png>)

9. Create the first commit for your project (Team Explorer -> Changes -> Commit All and Push)

10. Log in to VSTS with browser and verify that DevOpsHOL project was created and source code is uploaded.

## Next steps

- [Continuous Integration](../continuous-integration/README.md)
