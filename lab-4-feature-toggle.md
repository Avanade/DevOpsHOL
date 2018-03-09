# Avanade DevOps HOL - Lab 4 - Feature Toggle

In this lab, we build a Feature Toggle mechanism in our code.

Based on [this](https://microsoft.github.io/PartsUnlimited/apm/200.6x-APM-FeatureFlagforWebapps.html) article and [this](https://github.com/jason-roberts/FeatureToggle/tree/master/src/Examples/AspDotNetCoreExample) example.

## Prerequisites

- Complete [Lab 3 - Analysis with SonarQube](lab-3-analysis-with-sonarqube.md).

## Tasks

1. Add the following package to your Web Application:
    - FeatureToggle (by Jason Roberts)

1. Apply the following modifications to your Web Application:
    - Add feature class "CheckPhoneNumberFeature"
    - Add model class "Contact"

1. Use config to store feature toggle config

1. Add page to default MVC project to where you can submit contact information, submit doesn’t do anything.
   - Feature toggle is checking for phone number format using reg ex, see https://microsoft.github.io/PartsUnlimited/apm/200.6x-APM-FeatureFlagforWebapps.html

## Next steps

Continue with [Lab 5 - UI Testing](lab-5-ui-testing.md).