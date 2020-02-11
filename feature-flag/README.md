# Feature Toggles

This lab contains instructions to use feature toggles in an application.
Feature toggles, or flags, provide the ability to selectively turn features on and off to expose functionality.
The instructions are based on the following documentation:

- [Simple, Reliable Feature Toggles in .NET](http://jason-roberts.github.io/FeatureToggle.Docs/)

## Prerequisites

- Complete lab: [Pipeline as code with K8s and Terraform](https://dev.azure.com/thx1139/_git/workshop1?path=%2FREADME.md)

## Add a feature toggle to the application

1. In the **mywebapp** project, add the feature toggle NuGet package:
    - FeatureToggle (by Jason Roberts)

1. In the **mywebapp** project, add a feature toggle:
    - Create a feature toggle class in a 'Feature' folder 
        <details><summary>Feature\ShowDate.cs (expand to view code)</summary>

        ```csharp
        using FeatureToggle;

        namespace mywebapp.Feature
        {
            public class ShowDate : SimpleFeatureToggle { }
        }
        ```
        </details>

    - Add the feature toggle configuration to the appsettings
        <details><summary>appsettings.json (expand to view code)</summary>

        ```json
        {
            "FeatureToggle": {
                "ShowDate": false
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
                var provider = new AppSettingsProvider { Configuration = (IConfigurationRoot)Configuration };

                // Add your feature here
                services.AddSingleton(new ShowDate { ToggleValueProvider = provider });
                ...
            }
            ```
        </details>

1. In the **mywebapp** project, implement the feature toggle on the Index page:
      - Add the FeatureToggle as property to the IndexModel and assigned it with Dependency Injection in the OnGet method.

        <details><summary>Pages\Index.cshtml.cs (expand to view code)</summary>

            ```csharp
            using FeatureToggle;
            using Microsoft.AspNetCore.Mvc.RazorPages;
            using Microsoft.Extensions.Logging;
            using mywebapp.Feature;

            namespace mywebapp.Pages
            {
                public class IndexModel : PageModel
                {
                    private readonly ILogger<IndexModel> _logger;
                    public IFeatureToggle ShowDate { get; set; }

                    public IndexModel(ILogger<IndexModel> logger)
                    {
                        _logger = logger;
                    }

                    public void OnGet(ShowDate showDate)
                    {
                        ShowDate = showDate;
                    }
                }
            }
            ```
        </details>

    - Add html to show the current DateTime in the form that will only display if the feature ShowDate is enabled.
        <details><summary>Pages\Index.cshtml (expand to view code)</summary>

            ```csharp
            @page
            @model IndexModel
            @{
                ViewData["Title"] = "Home page";
            }

            <div class="text-center">
                <h1 class="display-4">Welcome Avanadi!</h1>
                <p>Learn about <a href="https://docs.microsoft.com/aspnet/core">building Web apps with ASP.NET Core</a>.</p>
                @if(Model.ShowDate.FeatureEnabled)
                {
                    <div>
                        @Html.Label("Current DateTime is: " + DateTime.Now.ToString())
                    </div>
                }
            </div>
            ```
        </details>

1. Start the website locally and test the feature toggle on the Index page:
    - With the toggle set to **false** in config, on the Index page:
        * You won't see the current DateTime.
    - With the toggle set to **true** in config, on the Index page:
        * You will see the current DateTime.

## Configure the feature toggle in the release pipeline

1. Configure the feature toggle to be enabled on the **Test** environment:
   - Edit the Azure DevOps **app** pipeline
   - Go to Variables, and add the variables:

        |Name                  |Value|Scope|
        |:---------------------|:----|:----|
        |FeatureToggle.ShowDate|true |test |
        |FeatureToggle.ShowDate|false|prod |

   - In the **Deploy Azure App Service** task, under *Application and Configuration Settings*,\
     ensure the following setting:
     - *App settings:* ```-FEATURETOGGLE__SHOWDATE $(FeatureToggle.ShowDate)```

1. Commit your code to trigger the **app** pipeline

1. Approve the release to all environments, and inspect the results:\
The **test** environment should have the feature enabled, and the **prod** environment not.

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab