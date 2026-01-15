@description('WAF policy name to create.')
param wafPolicyName string

@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
  'Classic_AzureFrontDoor'
])
@description('SKU for the WAF policy. For AFD Standard/Premium, use Standard_AzureFrontDoor or Premium_AzureFrontDoor.')
param wafSkuName string = 'Standard_AzureFrontDoor'

@allowed([
  'Detection'
  'Prevention'
])
@description('WAF mode.')
param wafMode string = 'Prevention'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Enable/disable WAF policy.')
param wafEnabledState string = 'Enabled'

@description('Optional: redirect URL for Redirect action (empty = omit).')
param redirectUrl string = ''

@description('Optional: custom block response body (base64) (empty = omit).')
param customBlockResponseBodyBase64 string = ''

@description('Optional: custom block response status code (e.g., 403). Null = omit.')
param customBlockResponseStatusCode int?

@allowed([
  'Enabled'
  'Disabled'
])
@description('Whether managed rules inspect request body content.')
param requestBodyCheck string = 'Enabled'

@minValue(5)
@maxValue(1440)
@description('Optional: Captcha cookie lifetime in minutes. Premium_AzureFrontDoor only. Null = omit.')
param captchaExpirationInMinutes int?

@minValue(5)
@maxValue(1440)
@description('Optional: JavaScript challenge cookie lifetime in minutes. Premium_AzureFrontDoor only. Null = omit.')
param javascriptChallengeExpirationInMinutes int?

@description('Optional: log scrubbing configuration. Null = omit.')
param logScrubbing object?

@description('Managed rule sets (Afd).')
param managedRuleSets array = []

@description('Custom rules (Afd).')
param customRules array = []

@description('Tags applied to the WAF policy.')
param tags object = {}

@description('Whether to attach the WAF policy to an existing Front Door profile via a security policy.')
param associateToFrontDoor bool = false

@description('Existing Front Door profile name. Required when associateToFrontDoor = true.')
param frontDoorProfileName string = ''

@description('Security policy name (child of the profile). Required when associateToFrontDoor = true.')
param securityPolicyName string = ''

@description('Domain resource IDs to associate (usually Microsoft.Cdn/profiles/customDomains IDs). Required when associateToFrontDoor = true.')
param domainResourceIds array = []

@description('URL path patterns to match for association.')
param patternsToMatch array = [
  '/*'
]

module wafPolicy 'modules/wafPolicy.bicep' = {
  name: 'wafPolicy'
  params: {
    policyName: wafPolicyName
    skuName: wafSkuName
    mode: wafMode
    enabledState: wafEnabledState
    redirectUrl: redirectUrl
    customBlockResponseBodyBase64: customBlockResponseBodyBase64
    customBlockResponseStatusCode: customBlockResponseStatusCode
    requestBodyCheck: requestBodyCheck
    captchaExpirationInMinutes: captchaExpirationInMinutes
    javascriptChallengeExpirationInMinutes: javascriptChallengeExpirationInMinutes
    logScrubbing: logScrubbing
    managedRuleSets: managedRuleSets
    customRules: customRules
    tags: tags
  }
}

module securityPolicy 'modules/securityPolicy.bicep' = if (associateToFrontDoor) {
  name: 'securityPolicy'
  params: {
    profileName: frontDoorProfileName
    securityPolicyName: securityPolicyName
    wafPolicyId: wafPolicy.outputs.wafPolicyId
    domainResourceIds: domainResourceIds
    patternsToMatch: patternsToMatch
  }
}

output wafPolicyId string = wafPolicy.outputs.wafPolicyId
output wafPolicyName string = wafPolicy.outputs.wafPolicyName
output securityPolicyId string = associateToFrontDoor ? resourceId('Microsoft.Cdn/profiles/securityPolicies', frontDoorProfileName, securityPolicyName) : ''
