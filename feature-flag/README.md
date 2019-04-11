# Feature Toggles

This lab contains instructions to use feature toggles in an application.
Feature toggles, or flags, provide the ability to selectively turn features on and off to expose functionality.
The instructions are based on the following documentation:

- [Simple, Reliable Feature Toggles in .NET](http://jason-roberts.github.io/FeatureToggle.Docs/)

## Prerequisites

- Complete lab: [Continuous Integration with Azure DevOps](../azure-devops-project/README.md)
- Complete lab: [Multi-stage deployments with Azure DevOps](../multi-stage-deployments/README.md)

## Add a feature toggle to the application

1. In the **Website** project, add the feature toggle NuGet package:
    - FeatureToggle (by Jason Roberts)

1. In the **Website** project, add a feature toggle:
    - Create a feature toggle class in a 'Feature' folder 
        <details><summary>Feature\CheckPhoneNumber.cs (expand to view code)</summary>

        ```csharp
        using FeatureToggle;

        namespace aspnet_core_dotnet_core.Features
        {
            public class CheckPhoneNumber : SimpleFeatureToggle { }
        }
        ```
        </details>

    - Add the feature toggle configuration to the appsettings
        <details><summary>appsettings.json (expand to view code)</summary>

        ```json
        {
            "FeatureToggle": {
                "CheckPhoneNumber": false
            }
            ...
        }
        ```
        </details>

    - Initialize the feature toggle setting from the configuration during startup

        <details><summary>Startup.cs (expand to view code)</summary>

            ```csharp
            // This method gets called by the runtime. Use this method to add services to the container.
            public void ConfigureServices(IServiceCollection services)
            {
                // Set provider config so file is read from content root path
                var provider = new AppSettingsProvider { Configuration = Configuration };

                // Add your feature here
                services.AddSingleton(new CheckPhoneNumber { ToggleValueProvider = provider });
                ...
            }
            ```
        </details>

1. In the **Website** project, implement the feature toggle in a (new) phone number form on the contact page:
      - Create a view model for the contact page including the feature toggle

        <details><summary>Models\ContactViewModel.cs (expand to view code)</summary>

            ```csharp
            using FeatureToggle;

            namespace aspnet_core_dotnet_core.Models
            {
                public class ContactViewModel
                {
                    public IFeatureToggle CheckPhoneNumber { get; set; }

                    public string Name { get; set; }

                    public int? PhoneNumber { get; set; }
                }
            }
            ```
        </details>

    - Inject the feature toggle in the controller, and pass it to the contact page

        <details><summary>Controllers\HomeController.cs" (expand to view code)</summary>

            ```csharp
            public class HomeController : Controller
            {
                private readonly CheckPhoneNumber _checkPhoneNumber;
           
                protected HomeController()
                {
                }

                public HomeController(CheckPhoneNumber checkPhoneNumber)
                {
                    _checkPhoneNumber = checkPhoneNumber;
                }

                ...

                public IActionResult Contact()
                {
                    ...
                    // return a contact view model including the toggle setting
                    return View(new ContactViewModel { CheckPhoneNumber = _checkPhoneNumber });
                }

                ...
            }
            ```
        </details>

    - Add the form with a toggle for the phone number logic to the contact page
        <details><summary>Views\Home\Contact.cshtml (expand to view code)</summary>

            ```csharp
            @model aspnet_core_dotnet_core.Models.ContactViewModel

            ...

            <form asp-action="Contact">
                <div asp-validation-summary="ModelOnly" class="text-danger"></div>
                <div class="form-group">
                    <label asp-for="Name" class="control-label"></label>
                    <input asp-for="Name" class="form-control" />
                    <span asp-validation-for="Name" class="text-danger"></span>
                </div>
                <div class="form-group">
                    <label asp-for="PhoneNumber" class="control-label"></label>

                    @if (Model.CheckPhoneNumber.FeatureEnabled)
                    {
                        @Html.TextBoxFor(m => m.PhoneNumber, new { @class = "form-control", placeholder = "555-555-5555", type = "tel", pattern = "\\d{3}[\\-]\\d{3}[\\-]\\d{4}", id = "phone" })
                    }
                    else
                    {
                        @Html.TextBoxFor(m => m.PhoneNumber, new { @class = "form-control", placeholder = "Phone Number", id = "phone" })
                    }

                    <span asp-validation-for="PhoneNumber" class="text-danger"></span>
                </div>
                <div class="form-group">
                    <input id="submit" type="submit" value="Create" class="btn btn-default" />
                </div>
            </form>
            ```
        </details>

    - In the UnitTest project, adjust the unit tests to the feature toggle injection

        <details><summary>SampleUnitTests.cs (expand to view code)</summary>

            ```csharp
            public void IndexPageTest()
            {
                var controller = new HomeController(null);
            ...
            public void AboutPageTest()
            {
                var controller = new HomeController(null);
            ...
            public void ContactPageTest()
            {
                var controller = new HomeController(null);
            ```
        </details>

1. Start the website locally and test the feature toggle in the Contact form:
    - With the toggle set to **false** in config, on the Contact page form:
      1. Enter any phone number and hit submit. Notice how no validation error is given
    - With the toggle set to **true** in config, on the Contact page form:
        1. Enter phone number 0123456789, hit submit, and notice the validation error
        1. Enter phone number 123-123-5678, submit and notice the page refreshes without error

## Configure the feature toggle in the release pipeline

1. Configure the feature toggle to be enabled on the **qa** environment:
   - Edit the Azure DevOps **Release** pipeline
   - Go to Variables, and add the variables:

        |Name                          |Value|Scope|
        |:-----------------------------|:----|:----|
        |FeatureToggle.CheckPhoneNumber|true |qa   |
        |FeatureToggle.CheckPhoneNumber|false|dev  |

   - In the **Deploy Azure App Service** task, under *Application and Configuration Settings*,\
     ensure the following setting:
     - *App settings:* ```-FEATURETOGGLE__CHECKPHONENUMBER $(FeatureToggle.CheckPhoneNumber)```

1. Commit your code to trigger a **Build**, followed by a **Release**

1. Approve the release to all environments, and inspect the results:\
The **qa** environment should have the feature enabled, and the **dev** environment not.

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab