# Avanade DevOps HOL - Lab 3 - Analysis with SonarQube

In this lab, we enable SonarQube for analysis of our code.

Based on [this](https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Extension+for+VSTS-TFS) tutorial.

## Prerequisites

- Complete [Lab 2 - Define your multi-stage continuous deployment process with approvals and gates](lab-2-multi-stage-deployments.md).

## Tasks

1. Create a new project in SonarQube and save the project key

1. Edit build definition

1. Add task "Prepare analysis on SonarQube" before any Msbuild or VSBuild task
   - Install from marketplace if not already in your account

1. Enter the project key and other details

1. Add task "Run Code Analysis" and "Publish Analysis Results" to your build

1. Reorder the tasks to respect the following order:
   - Prepare Analysis Configuration task before any MSBuild or Visual Studio Build task.
   - Run Code Analysis task after the Visual Studio Test task.
   - Publish Analysis Result task after the Run Code Analysis task

1. Save and Queue the build

1. Log on to SonarQube and view the results

## Next steps

Continue with [Lab 4 - Feature Toggle](lab-4-feature-toggle.md).