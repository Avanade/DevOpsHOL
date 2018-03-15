# Avanade DevOps HOL - Lab 5 - UI Testing

In this lab, we add ui tests to our test project.

Based on the following tutorials:

- [Get started with Selenium testing in a CD pipeline](https://docs.microsoft.com/en-us/vsts/build-release/test/continuous-test-selenium)
- Documentation on [dotnet vstest](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-vstest)

## Prerequisites

- Complete [Lab 4 - Feature Toggle](lab-4-feature-toggle.md).

## Tasks for local UI Testing

1. Add NuGet packages to the test project:
   - Selenium.Support (Includes Selenium.WebDriver)
   - Selenium.WebDriver.PhantomJS

1. Add new class UITests. The test method FillContactInformation will fill out the form in a PhantomJS browser and take screenshots while doing so
    <details><summary>Click here to view the code</summary>

    ```csharp
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using OpenQA.Selenium.PhantomJS;
    using OpenQA.Selenium.Remote;
    using System;
    using System.IO;

    [TestClass]
    public class UITests
    {
        public TestContext TestContext { get; set; }

        private RemoteWebDriver _driver;
        private string _siteUrl;

        [TestInitialize()]
        public void MyTestInitialize()
        {
            if (TestContext.Properties.ContainsKey("siteUrl"))
            {
                _siteUrl = TestContext.Properties["siteUrl"].ToString();
            }

            _driver = new PhantomJSDriver(Directory.GetCurrentDirectory());
            _driver.Manage().Timeouts().ImplicitWait = TimeSpan.FromSeconds(30);
        }

        [TestMethod]
        [TestCategory("UI")]
        [Priority(1)]
        [Owner("PhantomJS")]

        public void FillContactInformation()
        {
            // Go to the website
            _driver.Navigate().GoToUrl(_siteUrl);
            _driver.FindElementById("phone").Clear();

            // Fill in a phone number
            _driver.FindElementById("phone").SendKeys("555-555-5555");
            SaveAsImage(_driver.GetScreenshot(), "FillContactInformation-filled.png");

            // Submit the form
            _driver.FindElementById("submit").Click();
            SaveAsImage(_driver.GetScreenshot(), "FillContactInformation-submitted.png");

            // Assert that the form has been reset to the default value
            Assert.AreEqual("0", _driver.FindElementById("phone").GetAttribute("value"));
        }

        [TestCleanup()]
        public void MyTestCleanup()
        {
            _driver.Quit();
        }

        private void SaveAsImage(OpenQA.Selenium.Screenshot screenshot, string fileName)
        {
            if (File.Exists(fileName)) File.Delete(fileName);

            using (var stream = new FileStream(fileName, FileMode.CreateNew))
            using (var w = new BinaryWriter(stream))
            {
                w.Write(screenshot.AsByteArray);
            }
        }
    }
    ```
    </details>

1. Add new file local.runsettings
    <details><summary>Click here to view the contents</summary>

    ```xml
    <?xml version="1.0" encoding="utf-8" ?>
    <RunSettings>
        <TestRunParameters>
            <Parameter name="siteUrl" value="http://localhost:50177/Home/Contact" />
        </TestRunParameters>
    </RunSettings>
    ```
    </details>

1. Configure Visual Studio to [use the runsettings](https://docs.microsoft.com/en-us/visualstudio/test/configure-unit-tests-by-using-a-dot-runsettings-file) file

1. Run all unit tests and make sure that all succeed

## Tasks for UI Testing in the QA environment

1. Edit your Build Definition (save, do not queue)
    1. Change the Test task by adding the following argument: --filter TestCategory!=UI
    1. Add task "Publish build artifact" with the following settings:
        - Path: MyUnitTests/bin/$(BuildConfiguration)/netcoreapp2.0
        - Artifact name: tests
        - Location: VSTS

1. Edit your Release Definition
    1. Add task: Visual Studio Test Platform Installer
    1. Add task: .Net Core, custom command
        - Command: vstest
        - Arguments: MyUnitTests.dll --Logger:trx --Settings:vsts.runsettings --ResultsDirectory:.. --TestCaseFilter:TestCategory=UI --Framework:NETCoreApp,Version=v2.0
        - Working directory: $(System.DefaultWorkingDirectory)/Drop/tests
    1. Add variable "SiteUrl" with Scope "QA" and url "\<yourappservice\>-qa.azurewebsites.net/Home/Contact"

1. Add new file vsts.runsettings with "Copy to Output directory" set to "Copy always"
    <details><summary>Click here to view the contents</summary>

    ```xml
    <?xml version="1.0" encoding="utf-8" ?>
    <RunSettings>
        <TestRunParameters>
            <Parameter name="siteUrl" value="__SiteUrl__" />
        </TestRunParameters>
    </RunSettings>
    ```
    </details>

1. dotnet vstest \<yourtestprojectname\>.dll --Logger:console;verbosity="normal" --Settings:vsts.runsettings --ResultsDirectory:.. --TestCaseFilter:TestCategory=UI --Framework:FrameworkCore10

## Stretch goals

1. Add the screenshots to the test results and upload it to VSTS

## Next steps

Continue with [Lab 6 - Smoke Testing](lab-6-smoke-testing.md).