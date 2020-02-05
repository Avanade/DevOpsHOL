# UI Testing with Selenium and Azure DevOps

This lab contains instructions to create automated functional UI tests.\
The instructions are based on the following documentation:

- [UI test with Selenium](https://docs.microsoft.com/azure/devops/pipelines/test/continuous-test-selenium)
- [dotnet vstest](https://docs.microsoft.com/dotnet/core/tools/dotnet-vstest)

## Prerequisites

- Complete lab: [Continuous Integration with Azure DevOps](../azure-devops-project/README.md)
- Complete lab: [Multi-stage deployments with Azure DevOps](../multi-stage-deployments/README.md)

## Configure local UI Testing
1. Open the mywebapp.csproj (TRAIN/workshop1/app/mywebapp) in Visual Studio.

1. Add a new project to the solution with the following settings:
    - **Project Type:** xUnit Test Project (.NET Core) Visual C#
    - **Name:** FunctionalTests 

1. Close the solution in Visual Studio and open the mywebapp folder (./TRAIN/azdotraining1/app/mywebapp) in file explorer. Move the **mywebapp.sln** towards the app folder (./TRAIN/azdotraining1/app).

1. Edit the **mywebapp.sln** with Notepad or VS Code:
    - Change `"mywebapp.csproj"` to `".\mywebapp\mywebapp.csproj"`
    - Change `""..\FunctionalTests\FunctionalTests.csproj` to `".\FunctionalTests\FunctionalTests.csproj"`
    - Save and close the **mywebapp.sln** file.

1. Reopen the **mywebapp.sln** in Visual Studio. 

1. In the **FunctionalTests** project, remove the sample test (UnitTest1.cs) if it exists

1. On the **FunctionalTests** project, add the following NuGet packages:
   - MSTest.TestFramework
   - MSTest.TestAdapter
   - Selenium.Support
   - Selenium.WebDriver
   - Selenium.WebDriver.ChromeDriver

1. Ensure the Selenium Chrome driver executable is copied to the output during publish. Also make sure that the testproject is using .NET Core 2.2. On the **FunctionalTests** project, edit the project file
    - Add the following PropertyGroup:
        ```xml
        <PropertyGroup>
            <PublishChromeDriver>true</PublishChromeDriver>
        </PropertyGroup>
        ```
    - Verify that the project is using .NET Core 2.2
        ```xml
        <PropertyGroup>
            <TargetFramework>netcoreapp2.2</TargetFramework>
        </PropertyGroup>
        ```


1. In the **FunctionalTests** project, (modify or) create a .runsettings file containing the siteUrl as parameter. Find the local website port in the website project *(mywebapp\Properties\launchSettings.json)* and create:

    <details><summary>functionalTests.runsettings (expand to view code)</summary>

    ```xml
    <?xml version="1.0" encoding="utf-8" ?>
    <RunSettings>
        <TestRunParameters>
            <Parameter name="siteUrl" value="http://localhost:<PortToYourLocalWebsite>" />
        </TestRunParameters>
    </RunSettings>
    ```
    </details>

1. Configure Visual Studio to use the .runsettings file using:\
[Configure unit tests by using a .runsettings file](https://docs.microsoft.com/visualstudio/test/configure-unit-tests-by-using-a-dot-runsettings-file)

1. In the **FunctionalTests** project, add functional test classes for all pages.
Add a folder 'PageObjects' and add the following classes to it.
    <details><summary>BasePage.cs (expand to view code)</summary>

    ```csharp
    using OpenQA.Selenium;

    abstract class BasePage
    {
        protected readonly IWebDriver Driver;
        protected readonly string BaseUrl;

        protected BasePage(IWebDriver driver, string baseUrl)
        {
            Driver = driver;
            BaseUrl = baseUrl;
        }

        public HomePage GoToHomePage()
        {
            var home = Driver.FindElement(By.LinkText("Home"));
            home.Click();
            return new HomePage(Driver, BaseUrl);
        }

        public PrivacyPage GoToPrivacyPage()
        {
            var about = Driver.FindElement(By.LinkText("Privacy"));
            about.Click();
            return new PrivacyPage(Driver, BaseUrl);
        }
    }
    ```
    </details>

    <details><summary>HomePage.cs (expand to view code)</summary>

    ```csharp
    using OpenQA.Selenium;
        
    class HomePage : BasePage
    {
        public HomePage(IWebDriver driver, string baseUrl) : base(driver, baseUrl)
        {
        }

        public string Title { get; set; }

        public void GoToPage()
        {
            Driver.Navigate().GoToUrl($"{BaseUrl}");
        }
    }
    ```
    </details>

    <details><summary>PrivacyPage.cs (expand to view code)</summary>

    ```csharp
    using OpenQA.Selenium;

    class PrivacyPage : BasePage
    {
        public PrivacyPage(IWebDriver driver, string baseUrl) : base(driver, baseUrl)
        {
        }

        public void GoToPage()
        {
            Driver.Navigate().GoToUrl($"{BaseUrl}/Privacy");
        }

    }
    ```
    </details>

1. In the **FunctionalTests** project, create the following test class for the functional UI tests:
    <details><summary>UITests.cs (expand to view code)</summary>
   
    ```csharp  
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using OpenQA.Selenium;
    using OpenQA.Selenium.Chrome;
    using OpenQA.Selenium.Remote;
    using System;
    using System.Drawing;
    using System.IO;

    namespace aspnet_core_dotnet_core.FunctionalTests
    {
        [TestClass]
        public class UITests
        {
            private static TestContext _testContext;
            private RemoteWebDriver _driver;
            private string _siteUrl;

            [ClassInitialize]
            public static void Initialize(TestContext testContext)
            {
                _testContext = testContext;
            }

            [TestInitialize()]
            public void MyTestInitialize()
            {
                if (_testContext.Properties["siteUrl"] != null)
                {
                    _siteUrl = _testContext.Properties["siteUrl"].ToString();
                }

                // Chrome
                var options = new ChromeOptions();
                options.AddArguments("headless");
                _driver = new ChromeDriver(Directory.GetCurrentDirectory(), options);

                // Driver settings
                _driver.Manage().Window.Size = new Size(1920, 1080);
                _driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(20);
                _driver.Manage().Timeouts().ImplicitWait = TimeSpan.FromSeconds(20);
            }

            [TestMethod]
            [TestCategory("UI")]
            public void Test()
            {
                try
                {
                    var page = new HomePage(_driver, _siteUrl);
                    page.GoToPage();
                    SaveAsImage(_driver.GetScreenshot(), "Home.png");
                    page.GoToPrivacyPage();
                    SaveAsImage(_driver.GetScreenshot(), "Privacy.png");
                    var containerDiv = _driver.FindElement(By.ClassName("pb-3"));
                    var header = containerDiv.FindElement(By.TagName("h1"));
                    Assert.AreEqual("Privacy Policy", header.Text);
                }
                catch (NoSuchElementException)
                {
                    SaveAsImage(_driver.GetScreenshot(), "Error.png");
                    throw;
                }
            }

            [TestCleanup()]
            public void MyTestCleanup()
            {
                _driver.Close();
                _driver.Quit();
            }

            private void SaveAsImage(Screenshot screenshot, string name)
            {
                var timestamp = DateTime.UtcNow.ToString("yyyyMMdd-HHmmss.fff");
                var fileName = $"{timestamp} {name}";
                screenshot.SaveAsFile(fileName, ScreenshotImageFormat.Png);
            }
        }
    }
    ```
    </details>


1. Start your website once (using IIS Express settings) by debugging it, and then stop the debugger. This will ensure the website will be running in the local IIS Express instance, on the url specified in the .runsettings file.

1. Run the UI tests you just created and make sure that it succeeds.

## Configure automated UI Testing
1. Open the app-pipeline.yml to edit your app pipeline.

1. First the build of the Selenium project needs to be added to the **Build** stage by adding the following code above the job **Build_containers**
    ```
    - job: Build_functional_tests
    pool:
      vmImage: 'windows-latest'
    steps:
    - task: UseDotNet@2
      displayName: 'Use .NET Core sdk 2.2.301'
      inputs:
        packageType: 'sdk'
        version: '2.2.301'
    - task: DotNetCoreCLI@2
      displayName: 'Restore'
      inputs:
        command: 'restore'
        projects: '**/FunctionalTests.csproj'
        feedsToUse: 'select'
    - task: DotNetCoreCLI@2
      displayName: 'Publish'
      inputs:
        command: publish
        publishWebProjects: false
        projects: '**/FunctionalTests.csproj'
        arguments: '--configuration Release -o $(build.artifactstagingdirectory)/SeleniumTests'
        zipAfterPublish: false
        modifyOutputPath: false
    - task: PublishPipelineArtifact@1
      displayName: 'Publish Pipeline Artifact'
      inputs:
        targetPath: '$(Build.ArtifactStagingDirectory)'
        artifact: 'functionaltests'
        publishLocation: 'pipeline'
    ```

1. The automated Selenium tests will run against the public ip address of our deployed Pods. To assign the right IP address to the pipeline we will use variables. Add the next two variables:
    1. **Name:** testip **Value:** the public ip address of your test environment
    1. **Name:** prodip **Value:** the public ip address of your production environment

1. The next step is to add the automated Selenium tests to the Test deployment pipeline by adding the following code in stage **Release_Test** below the block **- deployment: Deploy_containers**:
    ```
    - deployment: Run_functional_tests
    dependsOn: "Deploy_containers"
    environment: test
    pool: 
      vmImage: 'windows-latest'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: VSTest@2
            inputs:
              testSelector: 'testAssemblies'
              testAssemblyVer2: |
                **\*FunctionalTests.dll
                !**\*TestAdapter.dll
                !**\obj\**
              searchFolder: '$(Pipeline.Workspace)/functionaltests/SeleniumTests'
              overrideTestrunParameters: '-siteUrl "$(testip)"'
    ```

1. The last step is to add the automated Selenium tests to the Production deployment pipeline by adding the following code in stage **Release_Prod** below the block **- deployment: Deploy_containers**:
    ```
    - deployment: Run_functional_tests
    dependsOn: "Deploy_containers"
    environment: prod
    pool: 
      vmImage: 'windows-latest'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: VSTest@2
            inputs:
              testSelector: 'testAssemblies'
              testAssemblyVer2: |
                **\*FunctionalTests.dll
                !**\*TestAdapter.dll
                !**\obj\**
              searchFolder: '$(Pipeline.Workspace)/functionaltests/SeleniumTests'
              overrideTestrunParameters: '-siteUrl "$(prodip)"'
    ```

1. Save your pipeline and run it. The Selenium will be automatically executed on the Test and Production environment. After the pipeline is completed you can find the test results in the tab **Tests**.

## Stretch goals

1. Introduce a failing test and verify that the deployment stops with the failed test.
1. Upload the Test screenshots to Azure DevOps. https://stackoverflow.com/questions/52823650/selenium-screenshots-in-vsts-azure-devops

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab