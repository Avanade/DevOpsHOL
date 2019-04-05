# Avanade DevOps HOL - Add QA environment and define your multi-stage continuous deployment process with approvals and gates

In this lab, we introduce a QA environment and setup our multi-stage continuous deployment process by adding approvals and gates.

Based on the following tutorials:
- [Set up staging environments in Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots)
- [Define your multi-stage continuous deployment (CD) process](https://docs.microsoft.com/en-us/azure/devops/pipelines/release/define-multistage-release-process)

## Prerequisites

- Complete lab [Create a CI/CD pipeline for .NET with the Azure DevOps Project](../azure-devops-project/README.md).

## Tasks

Let's define the QA environment:

1. Add a QA Deployment Slot to your App Service in Azure

1. Add a QA environment to your Release Definiton in VSTS

1. Configure the deployment step for the QA slot in the same App Service

1. Add pre deployment approval to control promotion from QA to Production

1. Run a new Release

1. Review the new QA website is live on \<yourappservice\>-qa.azurewebsites.net

## Next steps
Return to [the lab index](../README.md) and continue with the next lab.