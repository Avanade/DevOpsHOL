# UI Testing with Selenium and Azure DevOps

This lab contains instructions to create automated functional UI tests.\
The instructions are based on the following documentation:

- [UI test with Selenium](https://docs.microsoft.com/azure/devops/pipelines/test/continuous-test-selenium)
- [dotnet vstest](https://docs.microsoft.com/dotnet/core/tools/dotnet-vstest)

## Prerequisites

- Complete lab: [Continuous Integration with Azure DevOps](../azure-devops-project/README.md)
- Complete lab: [Multi-stage deployments with Azure DevOps](../multi-stage-deployments/README.md)

## Configure local UI Testing

1. In the **FunctionalTests** project, remove the sample test (SampleFunctionalTests.cs) if it exists

1. On the **FunctionalTests** project, add the following NuGet packages:
   - Selenium.Support
   - Selenium.WebDriver
   - Selenium.WebDriver.ChromeDriver

1. Ensure the Selenium Chrome driver executable is copied to the output during publish. On the **FunctionalTests** project, edit the project file and add the following:
    ```xml
    <PropertyGroup>
        <PublishChromeDriver>true</PublishChromeDriver>
    </PropertyGroup>
    ```

1. In the **FunctionalTests** project, (modify or) create a .runsettings file containing the siteUrl as parameter. Find the local website port in the website project *(aspnet-core-dotnet-core\Properties\launchSettings.json)* and create:

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

1. In the **FunctionalTests** project, add functional test classes for all pages.\
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

    <details><summary>AboutPage.cs (expand to view code)</summary>

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

    <details><summary>ContactPage.cs (expand to view code)</summary>

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


1. Start your website once (using IIS Express settings) by debugging it, and then stop the debugger. This will ensure the website will be running in the local IIS Express instance, on the url specified in the .runsettings file.

1. Run the UI tests you just created and make sure that it succeeds.

## Configure automated UI Testing (on the staging environment)

1. The UI Test tasks are Windows based, which requires a Windows agent.\
In the **Azure DevOps** project, in the **Build** and in the **Release - QA stage**, change the agent jobs to run on the agent **'Hosted Windows 2019 with VS2019'**

1. In the Azure DevOps **Release**, configure a variable for the website url on the staging environment.
Edit the release, go to Variables, and add the variable:
   - *Name:* SiteUrl
   - *Value:* [https://\<qa-stage-appservice-address\>.azurewebsites.net]
   - *Scope:* QA stage name

1. In the Azure DevOps **Release**, include a task to run the functional UI tests.\
Add a task of type Test - **Visual Studio Test**, and ensure it includes:
   - *Test files:* **\\*FunctionalTest\*.dll
   - *Settings file:* ../drop/../functionalTests.runsettings
   - *Override test run parameters:* -siteUrl $(SiteUrl)

1. Commit your code to trigger a **Build**, followed by a **Release**

1. Upon **Release** completion, review the Test results

## Stretch goals

1. Introduce a failing test and verify that the deployment stops with the failed test.
1. Upload the Test screenshots to Azure DevOps. https://stackoverflow.com/questions/52823650/selenium-screenshots-in-vsts-azure-devops

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab