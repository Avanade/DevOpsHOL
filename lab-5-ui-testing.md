# Avanade DevOps HOL - Lab 5 - UI Testing

In this lab, we add ui tests to our test project.

Based on the following tutorials:

- [Get started with Selenium testing in a CD pipeline](https://docs.microsoft.com/en-us/vsts/build-release/test/continuous-test-selenium)
- Documentation on [dotnet vstest](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-vstest)

## Prerequisites

- A Virtual Machine on Azure. Follow [prerequisites](prerequisites.md) to set it up.
- Complete [Lab 4 - Feature Toggle](lab-4-feature-toggle.md).
- Set up a private VSTS agent using [this Microsoft tutorial](https://docs.microsoft.com/en-us/vsts/build-release/actions/agents/v2-windows?view=vsts).

## Tasks for local UI Testing

1. Add a new Unit Test Project "Tests" (.NET Framework 4.7.1) and add the following NuGet packages:
   - Selenium.Support (Includes Selenium.WebDriver)
   - Selenium.WebDriver.PhantomJS
   - (optional)Selenium.WebDriver.IEDriver
   - (optional)Selenium.Chrome.WebDriver

1. Add new file local.runsettings
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

1. Add folder PageObjects and add classes for all the pages
   - <details><summary>Code for BasePage</summary>

        ```csharp
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


1. Add new class UITests
    <details><summary>Click here to view the code</summary>

    ```csharp
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using OpenQA.Selenium;
    using OpenQA.Selenium.PhantomJS;
    using OpenQA.Selenium.Remote;
    using System;
    using System.Drawing;
    using System.IO;
    using Tests.PageObjects;

    [TestClass]
    public class UITests
    {
        public TestContext TestContext { get; set; }

        private RemoteWebDriver _driver;
        private string _siteUrl;

        [TestInitialize()]
        public void MyTestInitialize()
        {
            if (TestContext.Properties.Contains("siteUrl"))
            {
                _siteUrl = TestContext.Properties["siteUrl"].ToString();
            }

            // PhantomJS
            _driver = new PhantomJSDriver(Directory.GetCurrentDirectory());

            // Chrome
            //var options =new ChromeOptions();
            //options.AddArguments("headless");
            //_driver = new ChromeDriver(Directory.GetCurrentDirectory(),options);

            // Internet Explorer
            //_driver = new InternetExplorerDriver(Directory.GetCurrentDirectory());

            // Shared driver settings
            _driver.Manage().Window.Size = new Size(1920, 1080);
            _driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(10);
        }

        [TestMethod]
        [TestCategory("UI")]
        [Priority(1)]
        [Owner("PhantomJS")]

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
            _driver.Quit();
        }

        private void SaveAsImage(OpenQA.Selenium.Screenshot screenshot, string name)
        {
            var timestamp = DateTime.UtcNow.ToString("yyyyMMdd-HHmmss.fff");
            var fileName = $"{timestamp} {name}";
            if (File.Exists(fileName)) File.Delete(fileName);

            using (var stream = new FileStream(fileName, FileMode.CreateNew))
            using (var w = new BinaryWriter(stream))
            {
                w.Write(screenshot.AsByteArray);
            }
            TestContext.AddResultFile(Path.Combine(Directory.GetCurrentDirectory(), fileName));
        }
    }
    ```
    </details>

1. Configure Visual Studio to [use the local.runsettings](https://docs.microsoft.com/en-us/visualstudio/test/configure-unit-tests-by-using-a-dot-runsettings-file) file

1. Run all unit tests and make sure that all succeed

## Tasks for UI Testing in the QA environment

1. Add new file vsts.runsettings with "Copy to Output directory" set to "Copy always". Notice the different value of the parameter. This is a token that will be replaced by an actual Url during the Release in VSTS.
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

1. Edit your Build Definition (save, do not queue)
    1. Add task "NuGet restore" after the "Restore" task:
        - Set the path to your Test project's packages.config
        - Under Advanced, set the destination to: ../packages
    1. Change the Test task by adding the following argument: --filter TestCategory!=UI
    1. Add task "Publish build artifact" after the other Publish task, with the following settings:
        - Path to publish: \<yourtestprojectfolder\>/bin/$(BuildConfiguration)
        - Artifact name: tests
        - Artifact publish location: VSTS

1. Edit your Release Definition, QA environment
    1. Add task: Replace Tokens (by Guillaume Rouchon)
        - Root directory: $(System.DefaultWorkingDirectory)/Drop/tests
        - Target files: **/*.runsettings
        - Token prefix: #{
        - Token suffix: }#
    1. Add task: Visual Studio Test
        - Search folder: $(System.DefaultWorkingDirectory)/Drop/tests
        - Test filter criteria: TestCategory=UI
        - Settings file: $(System.DefaultWorkingDirectory)/Drop/tests/vsts.runsettings
    1. Go to the Variables tab, add variable "SiteUrl" with Scope "QA" and url "https://\<yourappservice\>-qa.azurewebsites.net"

1. Commit your code to trigger a build and release

1. Upon Release completion, review the Test results and the uploaded screenshots

## Stretch goals

1. Run the same UI test with a different driver (Chrome, Internet Explorer)

## Next steps

Continue with [Lab 6 - Smoke Testing](lab-6-smoke-testing.md).