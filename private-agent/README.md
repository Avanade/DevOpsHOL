# Avanade DevOps HOL - Private Agent configuration with Azure DevOps
In this lab we configure a private agent for use in building the solution created in the [Continuous Integration](../continuous-integration/README.md) lab.
For more information on using private agents for Azure DevOps builds, see the [Build and Release Agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents) documentation.

### Pre-requisites:
- Complete [Getting Started](../getting-started/README.md) task.
-   An active Azure DevOps account.<br>
	 [Sign up for Azure DevOps](https://dev.azure.com/)
- In order to do the SonarQube lab, your Azure DevOps Agent Machine needs Java 8 installed, because the Azure DevOps SonarQube Extension has that requirement.


### I. Configure Private Build Agent

When choosing the Agent Queue for the build process (such as from the [Continuous Integration](../continuous-integration/README.md) lab), click on the **Manage** link above the **Agent queue** dropdown.
Otherwise, you can click on the Settings (gear) icon and choose **Agent Queues** to get to the Agent Queues page for the project.<br>
>Note: Private build agents need to be accessible from Azure DevOps so it is recommended to install them on a "build" VM within Azure.  For the HOL, if you are using an Azure VM for the development environment, then this same VM can be used for running the private build agent.
   1. Open your Azure DevOps portal (https://dev.azure.com/youralias) in another browser tab.
   2. Navigate to the DevOpsHOL project created earlier.
   3. Navigate to Personal access tokens (select your account picture, then Security, or navigate to https://dev.azure.com/youralias/_details/security/tokens)
   4. Create a new token with description **DevOpsTraining**, and copy the personal access token somewhere for use later.
   5. Return to the previous Agent Queue browser tab.  Click on **Download agent**.  
   Once the Agent zip file is downloaded, follow the instructions on the agent download page to unzip and configure the agent on the target machine using the configuration options below.
   >+ Enter server URL > https://dev.azure.com/youralias
   >+ Enter authentication type (press enter for PAT) >
   >+ Enter personal access token > *use the access token saved earlier*
   >+ Enter agent pool (press enter for default) >
   >+ Enter agent name > DevOpsBuildDeploy *(or use the default which is the computer name)*
   >+ Enter work folder (press enter for _work) >
   >+ Enter run agent as service? (Y/N) (press enter for N) > Y
   >+ Enter User account to use for the service (press enter for NT AUTHORITY\NETWORK SERVICE) > *admin account on target computer*
   >+ Enter Password for the account > *admin account password*
   6. Return to the build definition and choose the Default Agent Queue instead of Hosted VS2107.
   

   
