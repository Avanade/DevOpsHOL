# UI Testing with Selenium and Azure DevOps

This lab contains instructions to create automated functional UI tests.
The instructions are based on the following documentation:

- [UI test with Selenium](https://docs.microsoft.com/azure/devops/pipelines/test/continuous-test-selenium)
- [dotnet vstest](https://docs.microsoft.com/dotnet/core/tools/dotnet-vstest)

## Prerequisites

- Complete lab: [Pipeline as code with K8s and Terraform](https://dev.azure.com/thx1139/_git/workshop1?path=%2FREADME.md)

## Configure local UI Testing
1. Open the mywebapp.sln (TRAIN/azdotraining1/app) in Visual Studio.

1. Add a new project to the solution with the following settings:
    - **Project Type:** xUnit Test Project (.NET Core) Visual C#
    - **Name:** FunctionalTests 

1. In the **FunctionalTests** project, remove the sample test (UnitTest1.cs) if it exists

1. On the **FunctionalTests** project, add the following NuGet packages:
   - MSTest.TestFramework
   - MSTest.TestAdapter
   - Selenium.Support
   - Selenium.WebDriver
   - Selenium.WebDriver.ChromeDriver **Version: (87.0.4280.8800)**
   - System.Configuration.ConfigurationManager

1. Ensure the Selenium Chrome driver executable is copied to the output during publish. To do this: double click on the **FunctionalTests** and the FunctionalTests.csproj will be opened:
    - Add the following PropertyGroup:
        ```xml
        <PropertyGroup>
            <PublishChromeDriver>true</PublishChromeDriver>
        </PropertyGroup>
        ```

1. In the **FunctionalTests** project, create the **functionalTests.runsettings** file. And replace the content with the following content:

    <details><summary>functionalTests.runsettings (expand to view code)</summary>

    ```xml
    <?xml version="1.0" encoding="utf-8" ?>
    <RunSettings>
        <TestRunParameters>
            <Parameter name="siteUrl" value="http://localhost:39394" />
        </TestRunParameters>
    </RunSettings>
    ```
    </details>

1. In the **functionalTests.runsettings** file make sure that the port of the siteUrl is the same as the webapp is using. This port can be found in the **launSettings.json** *(mywebapp\Properties\launchSettings.json)* of the **mywebapp** project. 


1. Configure Visual Studio to use the .runsettings file you just created. In Visual Studio go to *Test-->Configure Run Settings-->Select Solution Wide runsettings File*. In the explorer window select the **functionalTests.runsettings** file located in the folder *FunctionalTests*.

1. In the **FunctionalTests** project add functional test classes for all pages.
Add the following classes to it:

    <details><summary>HomePage.cs (expand to view code)</summary>

    ```csharp
    using FunctionalTests;
    using OpenQA.Selenium;

    public class HomePage : BasePage
    {
        public HomePage(IWebDriver driver, string baseUrl) : base(driver, baseUrl)
        {
        }

        public string Title { get; set; }

        public void GoToPage()
        {
            _driver.Navigate().GoToUrl($"{_baseUrl}");
        }
    }
    ```
    </details>

    <details><summary>PrivacyPage.cs (expand to view code)</summary>

    ```csharp
    using FunctionalTests;
    using OpenQA.Selenium;

    public class PrivacyPage : BasePage
    {
        public PrivacyPage(IWebDriver driver, string baseUrl) : base(driver, baseUrl)
        {
        }

        public void GoToPage()
        {
            _driver.Navigate().GoToUrl($"{_baseUrl}/Privacy");
        }

    }
    ```
    </details>

    <details><summary>BasePage.cs (expand to view code)</summary>

    ```csharp
    using OpenQA.Selenium;

    namespace FunctionalTests
    {
        public abstract class BasePage
        {
            protected readonly IWebDriver _driver;
            protected readonly string _baseUrl;

            protected BasePage(IWebDriver driver, string baseUrl)
            {
                _driver = driver;
                _baseUrl = baseUrl;
            }

            public HomePage GoToHomePage()
            {
                var home = _driver.FindElement(By.LinkText("Home"));
                home.Click();
                return new HomePage(_driver, _baseUrl);
            }

            public PrivacyPage GoToPrivacyPage()
            {
                var about = _driver.FindElement(By.LinkText("Privacy"));
                about.Click();
                return new PrivacyPage(_driver, _baseUrl);
            }
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
                    var homePage = new HomePage(_driver, _siteUrl);
                    homePage.GoToPage();
                    SaveAsImage(_driver.GetScreenshot(), "Home.png");
                    
                    var privacyPage = new PrivacyPage(_driver, _siteUrl);
                    privacyPage.GoToPrivacyPage();
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

1. Start your website without debugging. This will ensure the website will be running in the local IIS Express instance, on the url specified in the .runsettings file.

1. Run the UI tests you just created in the Test Explorer and make sure that it succeeds.

1. When the tests are completed go in the File explorer to build folder of the FunctionalTests project *(C://TRAIN/azdotraining1/app/FunctionalTests/bin/Debug/netcoreapp3.1)*. Here you will find some screenshots that were made during the test run, which can be used as Test evidence.

## Configure automated UI Testing
1. Open the **app** pipeline *(Azure DevOps/Pipelines/Pipelines/app)* and press on **Edit**.

1. The automated Selenium tests will run against the public ip address of our deployed Pods. To assign the right ip address to the pipeline we will use variables. The ip addressess can be found in the PowerShell window you used in lab 1. Add the next two variables:
    1. **Name:** testip **Value:** http://*\<public ip address of the test environment>*
    1. **Name:** prodip **Value:** http://*\<public ip address of the production environment>* 

1. The next thing we need to do is adding build steps for the Selenium project. Make sure that you add the following code in the **Build** stage above the **Build_containers** job. Please be aware that the identation of the code is correct.
    ```
    - job: Build_functional_tests
      pool:
        vmImage: 'windows-latest'
      steps:
        - task: DotNetCoreCLI@2
          displayName: 'Restore'
          inputs:
            command: 'restore'
            projects: '**/FunctionalTests.csproj'
            feedsToUse: 'select'
        - task: DotNetCoreCLI@2
          displayName: 'Publish'
          inputs:
            command: 'publish'
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

1. The next step is to add the automated Selenium tests to the Test deployment pipeline by adding the following code in stage **Release_Test** below the block **- deployment: Deploy_containers**. Make sure that the identation is correct.
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
                  displayName: 'Run UI Tests'
                  inputs:
                  testSelector: 'testAssemblies' 
                  testAssemblyVer2: |
                    **\*FunctionalTests.dll
                    !**\*TestAdapter.dll
                    !**\obj\**
                  searchFolder: '$(Pipeline.Workspace)/functionaltests/SeleniumTests'
                  overrideTestrunParameters: '-siteUrl "$(testip)"'
    ```

1. The last step is to add the automated Selenium tests to the Production deployment pipeline by adding the following code in stage **Release_Prod** below the block **- deployment: Deploy_containers**. Make sure that the identation is correct.
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
                      displayName: Run UI Tests
                      inputs:
                        testSelector: 'testAssemblies' 
                        testAssemblyVer2: |
                            **\*FunctionalTests.dll
                            !**\*TestAdapter.dll
                            !**\obj\**
                        searchFolder: '$(Pipeline.Workspace)/functionaltests/SeleniumTests'
                        overrideTestrunParameters: '-siteUrl "$(prodip)"'
    ```

1. Save your pipeline but don't run it yet. Commit the code changes you made in Visual Studio and push those. This will trigger the **app** pipeline. The Selenium will be automatically executed on the Test and Production environment. After the pipeline is completed you can find the test results in the tab **Tests**.

## Stretch goals

1. Introduce a failing test and verify that the deployment stops with the failed test.
1. Upload the Test screenshots to Azure DevOps. https://stackoverflow.com/questions/52823650/selenium-screenshots-in-vsts-azure-devops

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab