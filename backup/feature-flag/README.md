Avanade DevOps HOL - Feature Flag for Web Application
====================================================================================
Feature flags provide the ability to turn features of your application on and off at a moments notice, no code deployments required. In this lab, we will add code to the project to demonstrate the use of feature flags to allow selectively turning on and off features to expose functionality. 

## Pre-requisites: ##
- Complete [Getting Started](../getting-started/README.md) hands on lab.

## Tasks Overview ##
**1. Add the backend code required for feature flags** - in this task we will add in the required code to enable feature flags for our application.

**2. Create a new page to enable/disable features** - in this task we will add a page for users to opt in for specific features.

**3. Update the website to use the feature flags** - in this task we will add new features to the website and leverage the feature flags

**4. Try it out!** - in this task we will try out our feature flag to ensure it's working as expected.

## I: Add the backend code required for feature flags ###

**1.** Open the DevOpsHOL solution created previously from [Getting Started](../getting-started/README.md) hands on lab.

**2.** Create a folder for feature flag related classes. Right click **DevOpsHOL project** -> **Add** -> **New Folder**, named **'FeatureFlag'**.

![](<media/add-feature-manager-folder.png>)

**3.** Create a feature flag class, this will represent a feature flag in the application. Right click on the newly created **FeatureFlag** folder -> **'Add'** -> **'Class...'**, name the new class **'Feature.cs'**

![](<media/add-feature-class.png>)

Add the following properties for the Feature.cs class

```csharp
public class Feature
{
    public string Key { get; set; }
    public string Description { get; set; }
    public bool Active { get; set; }
}
```
- **Key** is the unique identifier for that particular feature flag.
- **Description** is a brief description of what the feature flag is for.
- **Active** is the current state for the feature flag. 

**4** Create a simple feature manager class. This will be used later on to toggle features on and off. Under the same **FeatureFlag** folder create a new class called **FeatureManager.cs**

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DevOpsHOL.FeatureFlag
{
    public class FeatureFlag
    {
        public const string ContactMap = "Contact-Map";
        public const string FeatureX = "FeatureX";
    }
    public class FeatureManager
    {
        public static IEnumerable<Feature> Features = new List<Feature>
        {
            new Feature
            {
                Description = "Hide/Show Map on Contact Page",
                Key = FeatureFlag.ContactMap,
                Active = true
            },
            new Feature
            {
                Description = "Hide/Show Feature X",
                Key = FeatureFlag.FeatureX,
                Active = false
            }
        };

        public static bool GetStatusByKey(string key)
        {
            if (string.IsNullOrEmpty(key))
                throw new ArgumentNullException(nameof(key));

            Feature feature = Features.First<Feature>(f => f.Key == key);

            if (feature == null)
                throw new MissingFieldException(nameof(key));

            return feature.Active;
        }

        public static async Task ChangeFeatureToggles(string[] selectedItems)
        {
            if (selectedItems == null)
                throw new ArgumentNullException(nameof(selectedItems));

            foreach (Feature feature in Features)
            {
                feature.Active = selectedItems.Contains<string>(feature.Key);
            }        
        }

    }
}
```
- **Features** is a list of features used with the application. In this case, to Hide/Show Map on Contact Page
- **GetStatusByKey** is a method used to get the current status for a given user for a particular feature key.
- **ChangeFeatureToggles** takes in a list of selected feature toggles. If the key presents that status will be turned on.

*Note: In a real world implementation, these flags will be stored in a database. For simplicity's sake these are stored in memory. This also gives the ability to extenalize the on/off switch for features*

## II. Create a new page to enable/disable features ##
Now we need to create an administration view to toggle these features on and off from the site.

**1.** In order to create a new page on the site, we need to create a ViewModel that will represent the data used on that page.

Under the **Models** folder, create a new class called **FeaturesViewModel.cs**

![](<media/add-features-view-model-class.PNG>)

```csharp
using DevOpsHOL.FeatureFlag;
using System.Collections.Generic;

namespace DevOpsHOL.Models
{
    public class FeaturesViewModel
    {
        public IEnumerable<Feature> AvailableFeatures { get; set; }
    }
}
```
- **AvailableFeatures** is the list of features used with the application.

**2.** Right click **Controllers** folder -> click **Add** -> click **Controller...** -> select **MVC Controller - Empty** -> enter Controller Name: **FeaturesController** then click **Add**
```csharp
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using DevOpsHOL.Models;
using DevOpsHOL.FeatureFlag;

namespace DevOpsHOL.Controllers
{
    public class FeaturesController : Controller
    {
        public IActionResult Index()
        {
            return View(new FeaturesViewModel { AvailableFeatures = FeatureManager.Features });
        }

        [ValidateAntiForgeryToken]
        [HttpPost]
        public async Task<ActionResult> SaveFeatureToggles(string[] selectedItems)
        {
            await FeatureManager.ChangeFeatureToggles(selectedItems);

            return RedirectToAction("Features", "Home");
        }
    }
}
```

**3:** Under **'Views'** folder, create a new folder called **'Features'**

![](<media/add-view-features-folder.PNG>)

**4:** Create a new View under **'Features'** , named **'Index'**, specify Template, Model class, and layout page.

![](<media/add-features-index-view.PNG>)

**5.** Update the newly created Views->Features->Index.cshtml file with the following content.

```csharp
@model DevOpsHOL.Models.FeaturesViewModel

@{
    ViewData["Title"] = "Features";
    Layout = "~/Views/Shared/_Layout.cshtml";
}

<h2>Features</h2>

<hr />

@using (Html.BeginForm("SaveFeatureToggles", "Features", FormMethod.Post))
{
    <table class="table table-striped table-hover table-responsive table-condensed">
        <tr>
            <th>
                <h4><span style="font-weight: bolder">Description</span></h4>
            </th>
            <th>
                <h4><span style="font-weight: bolder">Key</span></h4>
            </th>
            <th>
                <h4><span style="font-weight: bolder">Active</span></h4>
            </th>
            <th></th>
        </tr>

        @foreach (var item in Model.AvailableFeatures)
        {
            <tr>
                <td class="col-lg-4">
                    <span style="font-size: 17px;">@item.Description</span>
                </td>
                <td class="col-lg-4">
                    <span style="font-size: 17px;">@item.Key</span>
                </td>
                <td class="col-lg-4">
                    <div>
                        @Html.AntiForgeryToken()
                        <input type="checkbox" name="selectedItems" value="@item.Key" checked="@item.Active">
                    </div>
                </td>
            </tr>
        }
    </table>

    <div><input type="submit" value="Save" style="float: right;" /></div>
}

<br/>

@section Scripts {
    @{await Html.RenderPartialAsync("_ValidationScriptsPartial");}
}
```

**6.** Write unit tests to validate the newly added Features functionality.

**7.** Build and test the solution and verify that it compiles without error.<br>


## III. Update the website to use the feature flags ##
Now that we have the basics of feature management. Let's add a new feature to display a map section on Contact page, and using the feature flag to control the display.

**1:** Create a ViewModel that will represent the data used on the Contact page.

Under the **'Models'** folder, create a new class called **'ContactViewModel.cs'**

![](<media/add-contact-view-model.PNG>)

```csharp
namespace DevOpsHOL.Models
{
    public class ContactViewModel
    {
        public bool IsMapFeatureActive { get; set; }
    }
}
```
- **IsMapFeatureActive** is the feature flag used to control display of the new feature.

**2:** Open **HomeController.cs** under **'Controllers'** folder, add a using statement for **DevOpsHOL.FeatureFlag** and update the **Contact()** method to pass **ContactViewModel** to the view

```csharp
using DevOpsHOL.FeatureFlag;


        public IActionResult Contact()
        {
            ViewData["Message"] = "Your contact page.";

            return View(new ContactViewModel { IsMapFeatureActive = FeatureManager.GetStatusByKey(FeatureFlag.FeatureFlag.ContactMap) });
        }
```

**3:** Open **'Contact.cshtml'** under folder **'Views'** -> **'Home'**, add new features to the page with flag for toggling.

```csharp
@model ContactViewModel
@{
    ViewData["Title"] = "Contact";
}
<h2>@ViewData["Title"]</h2>
<h3>@ViewData["Message"]</h3>

<address>
    One Microsoft Way<br />
    Redmond, WA 98052-6399<br />
    <abbr title="Phone">P:</abbr>
    425.555.0100
</address>
@if (Model.IsMapFeatureActive)
{
    <p>
        <strong>Map</strong>
    </p>
    <div id="map" style="width:400px;height:400px;background:yellow"></div>

    <script>
function myMap() {
var mapOptions = {
    center: new google.maps.LatLng(51.5, -0.12),
    zoom: 10,
    mapTypeId: google.maps.MapTypeId.HYBRID
}
var map = new google.maps.Map(document.getElementById("map"), mapOptions);
}
    </script>

    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBu-916DdpKAjTmJNIgngS6HL_kDIKU0aU&callback=myMap"></script>
}
<address>
    <strong>Support:</strong> <a href="mailto:Support@example.com">Support@example.com</a><br />
    <strong>Marketing:</strong> <a href="mailto:Marketing@example.com">Marketing@example.com</a>
</address>


<a asp-area="" asp-controller="Features" asp-action="Index">Toggle Features</a>
```
- It adds the newly created **ContactViewModel** to make the feature flag accessible in the view
- Uses the **Model.IsMapFeatureActive** to toggle the display of the map
- Adds a link to the Features page for demonstration purpose. In a real world implementation, this is usually part of the admin function.


### IV. Try it out! ###

The scenario demonstrates a broken change introduced by the new map feature. This would often require code rollback in production. Thanks to the feature flag, we can simply go to the features page to turn off the feature, to minimize the impact to end user, and the turn it back once fixed.

**1:** Now launch the site. You can do this but pressing F5 or hitting the button shown below in Visual Studio.

![](<media/launch-site.png>)

**2:** Navigate to Contact page, to observe newly added Map feature, and a error in display the map.  

![](<media/contact-page-with-map.PNG>)

**3:** Navigate to Features page by click on the **Toggle Features** link on **Contact** page, and switch off the 

![](<media/switch-feature.png>)

Note: This would be part of admin function in real life.

**4:** Navigate back to Contact page, and refresh the page to observe the map is no longer displayed on the page.

![](<media/contact-page-without-map.png>)





