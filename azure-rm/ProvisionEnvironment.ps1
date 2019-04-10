$ErrorActionPreference = "stop"

# Change these settings to your needs
$subscriptionName = "Services"  # Change to the name of your azure subscription
$ResourceGroupName = "adp2019"  # Change if you want to name the resource group differently

# Login and select subscription
if (Get-AzureRmContext | ForEach-Object { $_.Name -eq "Default" }) {
    Connect-AzureRmAccount | Out-Null
}
else {
    Get-AzureRmContext | Out-Null
}
Select-AzureRmSubscription -SubscriptionName $subscriptionName

# Set the region for the Resource Group
# East US is chosen because the bigger "F" and "G" VM sizes are cheaper in this region
$ResourceGroupLocation = "East US"

"Creating new resource group for the lab..."
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Force

"Deploy the lab using an ARM template"
New-AzureRmResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile .\json\devtestlab.json `
    -TemplateParameterFile .\json\devtestlab.parameters.json `
    -Verbose

# "Deploy the lab VM using an ARM template"
New-AzureRmResourceGroupDeployment `
    -Name "development-vm" `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile .\json\vm.json `
    -TemplateParameterFile .\json\vm.parameters.json `
    -Verbose