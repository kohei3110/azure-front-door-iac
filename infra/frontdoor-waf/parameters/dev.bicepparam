using '../main.bicep'

// Dev parameters (safe defaults)

param wafPolicyName = 'policy001-dev'
param wafSkuName = 'Standard_AzureFrontDoor'
param wafMode = 'Detection'
param wafEnabledState = 'Enabled'

param redirectUrl = ''
param customBlockResponseBodyBase64 = ''
param customBlockResponseStatusCode = null

param requestBodyCheck = 'Enabled'
param captchaExpirationInMinutes = null
param javascriptChallengeExpirationInMinutes = null
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

// Keep association off by default for dev.
param associateToFrontDoor = false
param frontDoorProfileName = ''
param securityPolicyName = ''
param domainResourceIds = []
param patternsToMatch = [
  '/*'
]

param tags = {
  environment: 'dev'
}
