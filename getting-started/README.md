
# Avanade DevOps HOL - Getting Started
In this lab, we will be installing the required development components and verifying that the solution builds and is able to be pushed to Azure DevOps.
## Pre-requisites ##
1. An active Azure subscription<br>
	[Azure Portal](https://portal.azure.com)
2. An active Azure DevOps account.<br>
	[Sign up for Visual Studio Team Services](https://azure.microsoft.com/en-us/services/devops/)
3. Having your subscription linked with your own Azure Active Directory instance<br>
	Check the [Course Pre-Requisites #1](../README.md#course-pre-requisites)
 
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
    + Configure for https: UnChecked (unless you are up for the challenge)<br>
    + Click OK<br>

4.  Build and run the solution to make sure everything is OK to this point.
    + Debug -> Start Debugging (F5)<br>
		+ If application doesn't start the first time, just run again.
    + Do a quick smoke test to verify that the solution built and runs correctly.<br>
    + Close browser and stop debugging<br>

5. Choose File -> New -> Project... and add a MSTest Test Project (.NET Core) project, to the solution *not the .NET Framework unit test project*.
    + Name: DevOpsHOL.Tests<br>
    + Solution: Add to solution<br>

6. Rename **UnitTest.cs** to **HomeControllerTest.cs** and replace the file contents with the content in the details section below.
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<details><summary>Click here to expand the sample unit test code</summary>

     ```csharp
      [TestClass]
      public class HomeControllerTest
      {
          [TestMethod]
          public void Index()
          {
              // Arrange
              HomeController controller = new HomeController();

              // Act
              ViewResult result = controller.Index() as ViewResult;

              // Assert
              Assert.IsNotNull(result);
          }

          [TestMethod]
          public void About()
          {
              // Arrange
              HomeController controller = new HomeController();

              // Act
              ViewResult result = controller.About() as ViewResult;

              // Assert
              Assert.IsNotNull(result);
              Assert.AreEqual("Your application description page.", result.ViewData["Message"]);
          }

          [TestMethod]
          public void Contact()
          {
              // Arrange
              HomeController controller = new HomeController();

              // Act
              ViewResult result = controller.Contact() as ViewResult;

              // Assert
              Assert.IsNotNull(result);
          }
      }
     ```
     </details>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NOTE: This source is also available here: [HomeControllerTest.cs](../source/tests/HomeControllerTest.cs)

7. Add the "DevOpsHOL" as a reference to the DevOpsHOL.Tests project. Tip: Use quick refactoring.

8. Add references to Microsoft.AspNetCore.Mvc.Abstractions and Microsoft.AspNetCore.Mvc.ViewFeatures as well.  Use the NuGet package manager to add these libraries to the project.

9. Build, run unit tests and run the solution to make sure everything is OK to this point.
    + Test -> Run -> All Tests (Ctrl+R,A)<br>
    + Debug -> Start Debugging (F5)<br>
    + Do another quick smoke test to verify that the solution built and runs correctly.<br>
    + Close browser and stop debugging<br>

10. Add solution to VSTS project (Team Explorer -> Sync -> Publish Git Repo)
    + Push to Visual Studio Team Services<br>
    + Repository name: DevOpsHOL<br>
    + Publish repository will create a project in VSTS (NOTE: if you have multiple VSTS accounts, make sure this is published to the correct Team Services Domain).<br>

![](<media/GS1.png>)

11. Create the first commit for your project (Team Explorer -> Changes -> Commit All and Push).  NOTE: This could be automatically staged so choose Commit Staged and Push.

12. Log in to VSTS with browser and verify that DevOpsHOL project was created and source code is uploaded.

## Next steps

- [Continuous Integration](../continuous-integration/README.md)
