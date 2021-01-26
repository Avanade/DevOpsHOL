# Validating the release with automated Smoke Testing

This lab contains instructions to enable automated smoke testing in the release.

## Prerequisites

- Complete lab: [Pipeline as code with K8s and Terraform](https://dev.azure.com/thx1139/_git/workshop1?path=%2FREADME.md)
- Complete lab: [UI Testing with Selenium and Azure DevOps](../ui-testing/README.md)

## Configure local Smoke Testing

1. In the **FunctionalTests** project, add a smoke test to validate if the website is available:
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
                if (TestContext.Properties["siteUrl"] != null)
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

1. Include Smoke tests in the app pipeline:
    - Edit the Azure DevOps **app** pipeline
    - In the stage **Release_Test**, edit the deployment **Run_functional_tests**
        - Rename the deployment name to **Run_tests**
        - Clone the existing **VSTest@2** and place it right below the current task
        - Give the first test task the displayname **Run Smoke Tests** and ensure it has this setting:
            - *testFiltercriteria:* TestCategory=Smoke
        - Give the second test task the displayname **Run UI Tests** and ensure it has this setting:
            - *testFiltercriteria:* TestCategory=UI

1. Commit your code to trigger the **App pipeline**.\
   Upon completion, inspect the release results and verify the Smoke test passed.

## Stretch goals

1. Refactor all the hardcoded timeout values to a variable in the runsettings file. Make them tokenized for replacement during the Release

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab