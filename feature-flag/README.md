# Feature Toggles

This lab contains instructions to use feature toggles in an application.
Feature toggles, or flags, provide the ability to selectively turn features on and off to expose functionality.
The instructions are based on the following documentation:

- [Use feature flags in an ASP.NET Core app](https://docs.microsoft.com/en-us/azure/azure-app-configuration/use-feature-flags-dotnet-core)

- [Overriding ASP Net Core settings with Environment Variables in a container](https://medium.com/swlh/overriding-aspnetcore-settings-with-environment-variables-in-docker-e8bc4df61f7f)

## Prerequisites

- Complete lab: [Pipeline as code with K8s and Terraform](https://dev.azure.com/thx1139/_git/workshop1?path=%2FREADME.md)

## Add a feature toggle to the application

1. In the **mywebapp** project, add the feature toggle NuGet package:
    - Microsoft.FeatureManagement               (v2.2.0)
    - Microsoft.FeatureManagement.AspNetCore    (v2.2.0)

1. Configure the FeatureManagement as .Net Core service
    - In the ConfigureServices method of the Startup.cs file add the following line: \
    ```services.AddFeatureManagement()```

1. Add FeatureManagement configuration to the appsettings.json: 
    ```json
    "FeatureManagement": {
        "TimeFeature": true
    }
    ```

1. Create a new enum FeatureFlags
    - Add new file: FeatureFlags.cs
    - Fill FeatureFlags.cs with the following content:
    ```Csharp
    public enum FeatureFlags
    {
        TimeFeature
    }
    ```

1. Create a new date showing feature which can be toggled with a feature toggle:
    - In Index.cshtml:
        - add: \
         ```@addTagHelper *, Microsoft.FeatureManagement.AspNetCore```
        - add:  
        ```html
        <feature name="@FeatureFlags.TimeFeature">
            <p>@DateTime.Now.ToShortTimeString()</p>
        </feature>
        ```
1. Run the application and you will see the time on the homepage.
1. Turn off the TimeFeature in appsettings.json and restart the application, the time will not be showed on the home page.

## Add a feature toggle in backend code with dependency injection
1. Configure a new feature toggle inside the appsettings.json with the name: **NewPrivacyText**.

1. In the enum FeatureToggles add a new feature toggle: **NewPrivacyText**.

1. Modify **Privacy.cshtml.cs** and add the following code:
    ```Csharp
    using Microsoft.FeatureManagement;
    ```
    
    ```Csharp
    private readonly IFeatureManager _featureManager;
    ```

    ```Csharp
    public string PrivacyText {get; set; }
    ```

    Modify the constructor as follows:
    ```Csharp
    public PrivacyModel(ILogger<PrivacyModel> logger, IFeatureManager featureManager)
    {
        _logger = logger;
        _featureManager = featureManager;
    }
    ```

    In the OnGet method add the following code:
    ```Csharp
    PrivacyText = await _featureManager.IsEnabledAsync(nameof(FeatureFlags.NewPrivacyText)) ? "New privacy text" : "Old privacy text";
    ```

1. Modify **Privacy.cshtml** and the following code at the bottom:
```html
<div>
    <p>@Html.Raw(Model.PrivacyText)
</div>
```

1. Commit the code changes you have made and push it to the remote.

## Configure the feature toggle in CI/CD

1. In Azure DevOps edit the file **deploy\myapp\templates\mywebapp.yaml**:
    - Below spec\template\spec\containers\name add the following code:
    ```
    env:
        - name: FeatureManagement__DateFeature
          value: {{ .Values.DateFeature | quote }}

        - name: FeatureManagement__NewPrivacyText
          value: {{ .Values.NewPrivacyText | quote }}
    ```

    Save the file, so your changes won't get lost.

1. Next thing you need to do is add the feature toggle to our deploy pipeline, this can be achieved by editing the ```app``` pipeline.
    - Here you need to add different configurations for Test and Prod so you can see if the feature toggles work. 
    
        Try to configure the following feature toggle configuration:
        |Name Feature|TST|PROD|
        |:-------------|:----|:----|
        |DateFeature|false|true|
        |NewPrivacyText|true|false|

    - You can add these values inside the ```Deploy Helm Chart``` task within the property ```overrideValues```. Here below you find to examples how can assign the values:
        1. DateFeature="false"
        1. DateFeature=$(testdatefeature), when you choose this option you should define the variable ```testdatefeature``` in your pipeline with the correct value.

    Don't forget to save the file!

1. Run the app pipeline and when the deployment is done, verify your configuration on the Test and Prod site.

## Stretch goals
- Implement a custom filters, for example a percentage filter
- Create a feature toggle which will show an alternate content when its disabled.

Information for both stretch goals can be found here: [Use feature flags in an ASP.NET Core app](https://docs.microsoft.com/en-us/azure/azure-app-configuration/use-feature-flags-dotnet-core).

## Next steps
Return to the [Lab index](../README.md) and continue with the next lab