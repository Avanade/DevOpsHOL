# Avanade DevOps HOL - UI Testing

In this lab, we will add ui tests to our test project. 

Based on the following tutorials:

- [Get started with Selenium testing in a CD pipeline](https://docs.microsoft.com/en-us/vsts/build-release/test/continuous-test-selenium)
- Documentation on [dotnet vstest](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-vstest)

## Prerequisites

- The [Azure Devops Project](../azure-devops-project/README.md) lab.
- A Virtual Machine on Azure. Follow [prerequisites](../getting-started/README.md) to set it up.
- Set up a private VSTS agent using [this tutorial](../private-agent/README.md).
- Optional: complete [Feature Flag](../feature-flag/README.md) lab.

## Tasks for local UI Testing

1. Add the following NuGet packages to the **FunctionalTests** project:
   - Selenium.Support
   - Selenium.WebDriver
   - Selenium.Chrome.WebDriver

1. Modify the .runsettings file if it already exists, or add a new .runsettings file with the following content:
    <details><summary>Click here to view the contents</summary>

    ```xml
    <?xml version="1.0" encoding="utf-8" ?>
    <RunSettings>
        <TestRunParameters>
            <Parameter name="siteUrl" value="http://localhost:<porttoyourlocalwebsite>" />
        </TestRunParameters>
    </RunSettings>
    ```
    </details>

1. Add folder PageObjects and add classes for all the pages to the **FunctionalTests** project.
   - <details><summary>Code for BasePage</summary>

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

            public AboutPage GoToAboutPage()
            {
                var about = Driver.FindElement(By.LinkText("About"));
                about.Click();
                return new AboutPage(Driver, BaseUrl);
            }

            public ContactPage GoToContactPage()
            {
                var contact = Driver.FindElement(By.LinkText("Contact"));
                contact.Click();
                return new ContactPage(Driver, BaseUrl);
            }
        }
        ```
   </details>

   - <details><summary>Code for Home page</summary>

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

   - <details><summary>Code for About page</summary>

        ```csharp
        using OpenQA.Selenium;
        using OpenQA.Selenium.Support.PageObjects;

        class AboutPage : BasePage
        {
            public AboutPage(IWebDriver driver, string baseUrl) : base(driver, baseUrl)
            {
            }

            [FindsBy(How = How.ClassName, Using = "fusion-main-menu-icon")]
            private IWebElement searchIcon;

            public void GoToPage()
            {
                Driver.Navigate().GoToUrl($"{BaseUrl}/Home/About");
            }
        }
        ```
   </details>

   - <details><summary>Code for Contact page</summary>

        ```csharp
        using OpenQA.Selenium;
        using OpenQA.Selenium.Support.PageObjects;
        
        class ContactPage : BasePage
        {
            public ContactPage(IWebDriver driver, string baseUrl) : base(driver, baseUrl)
            {
            }

            [FindsBy(How = How.ClassName, Using = "fusion-main-menu-icon")]
            private IWebElement searchIcon;

            public void GoToPage()
            {
                Driver.Navigate().GoToUrl($"{BaseUrl}/Home/Contact");
            }
        }
        ```
   </details>

1. Remove SampleFunctionalTests from the project if it exists, and add a new class UITests to the **FunctionalTests** project.
    <details><summary>Click here to view the code</summary>

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
                    page.GoToContactPage();
                    SaveAsImage(_driver.GetScreenshot(), "Contact.png");
                    page.GoToAboutPage();
                    SaveAsImage(_driver.GetScreenshot(), "About.png");
                    var containerDiv = _driver.FindElement(By.ClassName("body-content"));
                    var header = containerDiv.FindElement(By.TagName("h3"));
                    Assert.AreEqual("Your application description page.", header.Text);
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

1. Configure Visual Studio to [use the .runsettings](https://docs.microsoft.com/en-us/visualstudio/test/configure-unit-tests-by-using-a-dot-runsettings-file) file

1. Start your website, so that it's running on the url that you specified in the .runsettings file

1. Run the UI test and make sure that it succeeds

## Tasks for UI Testing in the Staging environment

1. Edit your Build Definition, to use a different Agent Pool:

    - Change the Agent Pool to "Hosted Windows 2019 with VS2019". The default Linux Agent does not seem to handle .exe files, as the extension is stripped from those files during publishing.

1. Edit your Release Definition, QA environment

    - Change the Agent Pool to "Hosted Windows 2019 with VS2019". We need a windows agent here in order to use ChromeDriver.exe

    - Add task: [Replace Tokens (by Guillaume Rouchon)](https://marketplace.visualstudio.com/items?itemName=qetza.replacetokens&targetId=af3daf82-7dfb-457e-a101-fb27736d03ca) (You'll need to add this to your organization, then re-open the Editor to add this task type)
        - Root directory: $(System.DefaultWorkingDirectory)/Drop/drop/FunctionalTests
        - Target files: **/*.runsettings

    - Add task: .NET Core
        - Command: custom
        - Custom command: vstest
        - Arguments (Replace the .dll with your own, if the project was named otherwise):
            ```
            aspnet-core-dotnet-core.FunctionalTests.dll --logger:"trx;LogFileName=functionalTestsResults.trx" --Settings:$(System.DefaultWorkingDirectory)/Drop/drop/FunctionalTests/release.runsettings --ResultsDirectory:.
            ```
            
    - Add task: Publish Test Results
        - Test result format: VSTest
        - Test results files: **/*.trx
        - Search folder: $(System.DefaultWorkingDirectory)/Drop/drop/FunctionalTests
        - 
    - Go to the Variables tab, add variable "SiteUrl" with Scope "Staging" and url "https://\<yourappservice\>-staging.azurewebsites.net"

1. Add new file release.runsettings to the **FunctionalTests** project, with "Copy to Output directory" set to "Copy always". Notice the different value of the parameter. This is a token that will be replaced by an actual Url during the Release in Azure DevOps.
    <details><summary>Click here to view the contents</summary>

    ```xml
    <?xml version="1.0" encoding="utf-8" ?>
    <RunSettings>
        <TestRunParameters>
            <Parameter name="siteUrl" value="#{SiteUrl}#" />
        </TestRunParameters>
    </RunSettings>
    ```
    </details>

1. We need to ensure that the Selenium Chrome driver executable will be copied to the output during publishing. Edit your **FunctionalTests** project file and add the following:
    ```xml
    <PropertyGroup>
        <PublishChromeDriver>true</PublishChromeDriver>
    </PropertyGroup>
    ```

1. Commit your code to trigger a build and release

1. Upon Release completion, review the Test results and the uploaded screenshots

## Stretch goals

1. Introduce a failing test and verify that the deployment stops with the failed test.
1. Upload the Test screenshots to Azure DevOps. https://stackoverflow.com/questions/52823650/selenium-screenshots-in-vsts-azure-devops

## Next steps
Return to [the lab index](../README.md) and continue with the next lab.