Apart from forking this repo, you need the following in Azure RM or Azure DevOps

# DevOps

## Pipelines

Grant open permissions to the variable groups you use for the `Library Variables` section

# Azure RM

## Service Principal
  - create and grant roles as described above

## Subscription
  - if not deploying to `testing`, create a subscription and grant the `Contributor` role on the subscription, to the SP created above
