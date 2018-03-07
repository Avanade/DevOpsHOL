# Avanade DevOps HOL - Lab 1 - Create a CI/CD pipeline for .NET with the Azure DevOps Project

In this lab, we create our own application in Visual Studio with Unit Tests and setup a DevOps Project in Azure to create our CI/CD pipeline.

Based on [this](https://docs.microsoft.com/en-us/vsts/build-release/apps/cd/azure/azure-devops-project-aspnetcore) tutorial.

## Prerequisites

- Complete [Getting Started](getting-started.md).

## Tasks

1. Create a new project in visual studio:
   - ASP.NET Core 2.0 Web Application (MVC)

1. Add new Unit Test Project (.NET Core) + unit test
   - <details><summary>Click here to expand the sample unit test code</summary>

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

1. Build your solution and run the unit tests. Make sure that the tests pass

1. Commit your code to your favourite git provider (GitHub / VSTS / etc.)

1. Go to your Azure Portal and create a new DevOps Project. Make sure it meets the following demands:
    - Using your own code
    - WebApp on Windows
    - Linked to your VSTS account

1. Configure unit test in build with argument !Integration
   - Stretch: what should be added is ARM which can be reverse engineered

## Next steps

Continue with [Lab 2 - Define your multi-stage continuous deployment process with approvals and gates](lab-2-multi-stage-deployments.md).