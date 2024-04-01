unset TF_VAR_env
unset env

unset ARM_TENANT_ID
unset ARM_SUBSCRIPTION_ID
unset ARM_CLIENT_ID
unset ARM_CLIENT_SECRET

az logout
az account clear
az account list --refresh
