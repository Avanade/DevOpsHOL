Avanade DevOps HOL - Continuous Deployment with Visual Studio Release Management
====================================================================================
In this lab, you have an example MVC application, committed to a Git repository in Visual Studio Team Services (VSTS) and a Continuous Integration build that builds the app and runs unit tests whenever code is pushed to the master branch. Now you want to set up Release Management (a feature of Visual Studio Team Services) to be able continuously deploy the application to an Azure Web App. Initially the app will be deployed to a dev deployment slot. The staging slot will require and approver before the app is deployed into it. Once an approver approves the staging slot, the app will be deployed to the production site.

### Pre-requisites: ###
- Complete [Continuous Integration](../continuous-integration/README.md) hands on lab.


### Tasks Overview: ###

**1. Create Continuous Integration Build:** In this step, you will create a build definition that will be triggered every time a commit is pushed to your repository in Visual Studio Team Services.

**2. Test the CI Trigger in Visual Studio Team Services:** In this step, test the Continuous Integration build (CI) build we created by changing code in the Parts Unlimited project with Visual Studio Team Services.


### I. Create Continuous Integration Build
