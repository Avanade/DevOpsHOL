# Avanade DevOps HOL - Define your multi-stage continuous deployment process with approvals and gates

In this lab, we setup our multi-stage continuous deployment process by adding approvals and gates.

## Prerequisites

- Complete [Create a CI/CD pipeline for .NET with the Azure DevOps Project](lab-1-azure-devops-project-pipeline.md).

## Tasks

First, let's define the QA environment:

1. Add QA environment in VSTS, configure for QA slot in the same App Service

1. Run a new Release

1. Review the new QA website is live on \<yourappservice\>-qa.azurewebsites.net

Use approvals and gates to control your deployment

1. Add pre deployment gates on work item count

1. Add pre/post deployment approvals to control promotion to next environments