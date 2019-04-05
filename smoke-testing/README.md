# Avanade DevOps HOL - Smoke Testing

In this lab, we add smoke tests to our test project.

## Prerequisites

- Complete [UI Testing](../ui-testing/README.md).

## Tasks

1. Edit your build definition. Let the Test task ignore both "UI" and "Smoke" categories
    - Change the filter argument to the following: --filter TestCategory!=UI&TestCategory!=Smoke

1. Edit your release definition, Production environment:
    1. Add task "Replace Tokens", similar to the one in QA
    1. Add task: Visual Studio Test
        - Search folder: $(System.DefaultWorkingDirectory)/Drop/tests
        - Test filter criteria: TestCategory=Smoke
        - Settings file: $(System.DefaultWorkingDirectory)/Drop/tests/vsts.runsettings
    1. Add variable "SiteUrl" with Scope "Production" and url "https://\<yourappservice\>.azurewebsites.net"

1. Add new class SmokeTests to your test project with the UITests
    <details><summary>Code for the SmokeTests class</summary>

    ```csharp
    [TestClass]
    public class SmokeTests
    {
        public TestContext TestContext { get; set; }

        private string _siteUrl;
        private int _timeout;

        [TestInitialize()]
        public void MyTestInitialize()
        {
            if (TestContext.Properties.Contains("siteUrl"))
            {
                _siteUrl = TestContext.Properties["siteUrl"].ToString();
            }

            _timeout = 60000;
        }

        [TestMethod]
        [TestCategory("Smoke")]
        public void ValidateSiteIsAvailable()
        {
            try
            {
                var request = WebRequest.CreateHttp(_siteUrl);
                request.Timeout = _timeout;
                request.ReadWriteTimeout = _timeout;
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
    ```
    </details>

1. Build your solution and run your Web App (F5). Run all your Tests locally and make sure they all succeed.

1. Commit your code change and make sure your build and release succeed. Both your QA and Production environment should be updated. QA should have run a Smoke and UI Test, with resulting screenshots from the UI Test. Production should have run a Smoke test only

## Stretch goals

1. Refactor all the hardcoded timeout values to a variable in the runsettings file. Make them tokenized for replacement during the Release

## Next steps
Return to [the lab index](../README.md) and continue with the next lab.