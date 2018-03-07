# Avanade DevOps HOL - Lab 2 - Define your multi-stage continuous deployment process with approvals and gates

In this lab, we setup our multi-stage continuous deployment process by adding approvals and gates.

Based on [this](https://docs.microsoft.com/en-us/vsts/build-release/actions/define-multistage-release-process) tutorial.

## Prerequisites

- Complete [Lab 1 - Create a CI/CD pipeline for .NET with the Azure DevOps Project](lab-1-azure-devops-project-pipeline.md).

## Tasks

First, let's define the QA environment:

1. Add QA environment in VSTS, configure for QA slot in the same App Service

1. Run a new Release

1. Review the new QA website is live on \<yourappservice\>-qa.azurewebsites.net

Use approvals and gates to control your deployment

1. Add pre deployment approval to control promotion from QA to Production

1. Add gate on 'Active Bugs' = 0

## Next steps

Continue with [Lab 3 - Analysis with SonarQube](lab-3-analysis-with-sonarqube.md).