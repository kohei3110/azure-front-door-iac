using '../main.bicep'

// Staging parameters (pre-prod validation)

param wafPolicyName = 'policy001-staging'
param wafSkuName = 'Premium_AzureFrontDoor'
param wafMode = 'Detection'
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

param associateToFrontDoor = false
param frontDoorProfileName = ''
param securityPolicyName = ''
param domainResourceIds = []
param patternsToMatch = [
  '/*'
]

param tags = {
  environment: 'staging'
}
