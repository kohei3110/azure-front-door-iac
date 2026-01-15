@description('Name of the WAF policy (Microsoft.Cdn/cdnWebApplicationFirewallPolicies).')
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

@description('Default redirect URL when action is Redirect. Leave empty to omit.')
param defaultRedirectUrl string = ''

@description('Custom block response body (base64). Leave empty to omit.')
param customBlockResponseBodyBase64 string = ''

@minValue(100)
@maxValue(599)
@description('Custom block response status code (e.g., 403).')
param customBlockResponseStatusCode int = 403

@description('Managed rule sets (Afd). Example element: { ruleSetType: "Microsoft_DefaultRuleSet", ruleSetVersion: "2.1" }.')
param managedRuleSets array = []

@description('Custom rules (Afd). Example element: { name: "BlockBadBots", priority: 10, enabledState: "Enabled", action: "Block", matchConditions: [...] }.')
param customRules array = []

@description('Rate limit rules (Afd). Example element: { name: "RateLimitLogin", priority: 20, enabledState: "Enabled", action: "Block", rateLimitDurationInMinutes: 1, rateLimitThreshold: 100, matchConditions: [...] }.')
param rateLimitRules array = []

@description('Resource tags.')
param tags object = {}

@description('Location for the resource. WAF policies for AFD are typically deployed to global.')
param location string = 'global'

resource waf 'Microsoft.Cdn/cdnWebApplicationFirewallPolicies@2024-09-01' = {
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
    }, (!empty(defaultRedirectUrl) ? {
      defaultRedirectUrl: defaultRedirectUrl
    } : {}), (!empty(customBlockResponseBodyBase64) ? {
      defaultCustomBlockResponseBody: customBlockResponseBodyBase64
    } : {}), {
      defaultCustomBlockResponseStatusCode: customBlockResponseStatusCode
    })

    // These sections are optional in the RP. Supplying empty arrays keeps the template simple and deterministic.
    managedRules: {
      managedRuleSets: managedRuleSets
    }
    customRules: {
      rules: customRules
    }
    rateLimitRules: {
      rules: rateLimitRules
    }
  }
}

output wafPolicyId string = waf.id
output wafPolicyName string = waf.name
