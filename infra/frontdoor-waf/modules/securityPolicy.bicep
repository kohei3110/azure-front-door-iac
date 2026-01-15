@description('Existing Azure Front Door (Standard/Premium) profile name (Microsoft.Cdn/profiles).')
param profileName string

@description('Name of the security policy under the profile (Microsoft.Cdn/profiles/securityPolicies).')
param securityPolicyName string

@description('Resource ID of the WAF policy (Microsoft.Cdn/cdnWebApplicationFirewallPolicies).')
param wafPolicyId string

@description('Resource IDs of domains to associate with the WAF (typically Microsoft.Cdn/profiles/customDomains resource IDs).')
param domainResourceIds array

@description('List of URL path patterns to match, e.g. ["/*"].')
param patternsToMatch array = [
  '/*'
]

resource profile 'Microsoft.Cdn/profiles@2024-09-01' existing = {
  name: profileName
}

resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2024-09-01' = {
  parent: profile
  name: securityPolicyName
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicyId
      }
      associations: [
        {
          domains: [
            for domainId in domainResourceIds: {
              id: domainId
            }
          ]
          patternsToMatch: patternsToMatch
        }
      ]
    }
  }
}

output securityPolicyId string = securityPolicy.id
output securityPolicyName string = securityPolicy.name
