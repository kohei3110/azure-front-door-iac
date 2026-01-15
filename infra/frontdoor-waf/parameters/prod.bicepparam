using '../main.bicep'

// Production parameters (strict)

param wafPolicyName = 'policy001-prod'
param wafSkuName = 'Premium_AzureFrontDoor'
param wafMode = 'Prevention'
param wafEnabledState = 'Enabled'

param redirectUrl = ''
param customBlockResponseBodyBase64 = ''
param customBlockResponseStatusCode = null

param requestBodyCheck = 'Enabled'
param captchaExpirationInMinutes = 30
param javascriptChallengeExpirationInMinutes = 30
param logScrubbing = null

param managedRuleSets = [
  {
    exclusions: []
    ruleGroupOverrides: []
    ruleSetAction: 'Block'
    ruleSetType: 'Microsoft_DefaultRuleSet'
    ruleSetVersion: '2.1'
  }
  {
    exclusions: []
    ruleGroupOverrides: []
    ruleSetType: 'Microsoft_BotManagerRuleSet'
    ruleSetVersion: '1.0'
  }
]

param customRules = []

// For prod, you typically enable association, but keep it off by default until IDs/names are wired.
param associateToFrontDoor = false
param frontDoorProfileName = ''
param securityPolicyName = ''
param domainResourceIds = []
param patternsToMatch = [
  '/*'
]

param tags = {
  environment: 'prod'
}
