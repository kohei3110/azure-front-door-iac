@description('Name of the WAF policy (Microsoft.Network/FrontDoorWebApplicationFirewallPolicies).')
param policyName string

@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
  'Classic_AzureFrontDoor'
])
@description('SKU for the WAF policy. For Azure Front Door Standard/Premium, use Standard_AzureFrontDoor or Premium_AzureFrontDoor.')
param skuName string = 'Standard_AzureFrontDoor'

@allowed([
  'Detection'
  'Prevention'
])
@description('WAF mode. Detection logs only; Prevention blocks.')
param mode string = 'Prevention'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Enable/disable the WAF policy.')
param enabledState string = 'Enabled'

@description('Redirect URL when action is Redirect. Leave empty to omit.')
param redirectUrl string = ''

@description('Custom block response body (base64). Leave empty to omit.')
param customBlockResponseBodyBase64 string = ''

@description('Custom block response status code (e.g., 403). Leave null to omit.')
param customBlockResponseStatusCode int?

@allowed([
  'Enabled'
  'Disabled'
])
@description('Whether managed rules inspect request body content.')
param requestBodyCheck string = 'Enabled'

@minValue(5)
@maxValue(1440)
@description('Captcha cookie lifetime in minutes. Premium_AzureFrontDoor only. Leave null to omit.')
param captchaExpirationInMinutes int?

@minValue(5)
@maxValue(1440)
@description('JavaScript challenge cookie lifetime in minutes. Premium_AzureFrontDoor only. Leave null to omit.')
param javascriptChallengeExpirationInMinutes int?

@description('Optional log scrubbing configuration. Provide null to omit.')
param logScrubbing object?

@description('Managed rule sets (Afd). Example element: { ruleSetType: "Microsoft_DefaultRuleSet", ruleSetVersion: "2.1" }.')
param managedRuleSets array = []

@description('Custom rules (Afd). Example element: { name: "BlockBadBots", priority: 10, enabledState: "Enabled", action: "Block", matchConditions: [...] }.')
param customRules array = []

@description('Resource tags.')
param tags object = {}

@description('Location for the resource. Front Door WAF policies are typically deployed to Global.')
param location string = 'Global'

resource waf 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2025-03-01' = {
  name: policyName
  location: location
  sku: {
    name: skuName
  }
  tags: tags
  properties: {
    policySettings: union({
      enabledState: enabledState
      mode: mode
      requestBodyCheck: requestBodyCheck
    }, (!empty(redirectUrl) ? {
      redirectUrl: redirectUrl
    } : {}), (!empty(customBlockResponseBodyBase64) ? {
      customBlockResponseBody: customBlockResponseBodyBase64
    } : {}), (customBlockResponseStatusCode != null ? {
      customBlockResponseStatusCode: customBlockResponseStatusCode
    } : {}), (captchaExpirationInMinutes != null ? {
      captchaExpirationInMinutes: captchaExpirationInMinutes
    } : {}), (javascriptChallengeExpirationInMinutes != null ? {
      javascriptChallengeExpirationInMinutes: javascriptChallengeExpirationInMinutes
    } : {}), (logScrubbing != null ? {
      logScrubbing: logScrubbing
    } : {}))

    managedRules: {
      managedRuleSets: managedRuleSets
    }
    customRules: {
      rules: customRules
    }
  }
}

output wafPolicyId string = waf.id
output wafPolicyName string = waf.name
