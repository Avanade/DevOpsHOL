# Avanade DevOps HOL - Lab 6 - Smoke Testing

In this lab, we add smoke tests to our test project.

## Prerequisites

- Complete [Lab 5 - UI Testing](lab-5-ui-testing.md).

## Tasks

1. Add new class IntegrationTests to the test project

1. Implement an integration test that checks if your website is up and running
   - Hint: WebRequest.CreateHttp

1. Create a new xml file "local.runsettings" with a configurable website url

1. Create a new xml file "integration.runsettings" containing a VSTS variable token for the same website url variable
   - Set "Copy to output directory" on "Copy if newer"

## Next steps

Done!