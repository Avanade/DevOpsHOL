# Avanade DevOps HOL - Lab 1 - Create a CI/CD pipeline for .NET with the Azure DevOps Project

In this lab, we create our own application in Visual Studio with Unit Tests.

## Prerequisites

- Complete [Getting Started](getting-started.md).

## Tasks

1. Follow the steps in [this](https://docs.microsoft.com/en-us/vsts/build-release/apps/cd/azure/azure-devops-project-aspnetcore) tutorial.

1. Create project in visual studio

1. Create unit test project + unit test
   - <details><summary>Click here to expand the example code</summary>

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

1. Use Azure DevOps project

1. Configure unit test in build with argument !Integration
   - Stretch: what should be added is ARM which can be reverse engineered.

## Next steps

Continue with [Lab 2 - Define your multi-stage continuous deployment process with approvals and gates](lab-2-multi-stage-deployments.md).