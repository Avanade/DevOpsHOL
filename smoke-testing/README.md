# Validating the release with automated Smoke Testing

This lab contains instructions to enable automated smoke testing in the release.

## Prerequisites

- Complete lab: [Continuous Integration with Azure DevOps](../azure-devops-project/README.md)
- Complete lab: [Multi-stage deployments with Azure DevOps](../multi-stage-deployments/README.md)
- Complete lab: [UI Testing with Selenium and Azure DevOps](../ui-testing/README.md)

## Configure local Smoke Testing

1. In the **FunctionalTest** project, add a smoke test to validate if the website is available:
    <details><summary>SmokeTests.cs (expand to view code)</summary>

    ```csharp
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using System;
    using System.Net;

    namespace aspnet_core_dotnet_core.FunctionalTests
    {
        [TestClass]
        public class SmokeTests
        {
            public TestContext TestContext { get; set; }

            private string _siteUrl;

            [TestInitialize()]
            public void MyTestInitialize()
            {
                if (TestContext.Properties.ContainsKey("siteUrl"))
                {
                    _siteUrl = TestContext.Properties["siteUrl"].ToString();
                }
            }

            [TestMethod]
            [TestCategory("Smoke")]
            public void ValidateSiteIsAvailable()
            {
                try
                {
                    var request = WebRequest.CreateHttp(_siteUrl);
                    request.Timeout = 60000;
                    request.ReadWriteTimeout = 60000;
                    using (var response = (HttpWebResponse)request.GetResponse())
                    {
                        // Assert
                        Assert.AreEqual(HttpStatusCode.OK, response.StatusCode);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Exception: {0}", ex.Message);
                    Assert.Fail(ex.Message);
                }
            }
        }
    }
    ```
    </details>

1. Validate if the test passes:\
Right-click the *ValidateSiteIsAvailable()* test method and select **Run Test(s)**

## Configure automated Smoke Testing in the release pipeline

1. Include a task to run the Smoke tests in the release pipeline:
   - Edit the Azure DevOps **Release** 
   - Clone the existing **Visual Studio Test** task
   - Rename the first test task to **Run Smoke Tests** and ensure it has this setting:
     - *Test filter criteria:* TestCategory=Smoke
   - Rename the second test task to **Run UI Tests** and ensure it has this setting:
     - *Test filter criteria:* TestCategory=UI

1. Commit your code to trigger a **Build**, followed by a **Release**.\
   Upon completion, inspect the release results and verify the Smoke test passed.

## Stretch goals

1. Refactor all the hardcoded timeout values to a variable in the runsettings file. Make them tokenized for replacement during the Release

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab