# Front Door (Standard/Premium) WAF policy - Bicep

このフォルダは、Azure Front Door (Standard/Premium) 向けの **WAF ポリシー** を Bicep で IaC 化するための最小テンプレートです。

- WAF ポリシー: `Microsoft.Network/FrontDoorWebApplicationFirewallPolicies`
- (任意) 既存 Front Door への紐付け: `Microsoft.Cdn/profiles/securityPolicies`

> 実環境で `az resource show` すると、WAF ポリシーが `Microsoft.Network/frontdoorwebapplicationfirewallpolicies` として見えるケースがあります。
> このテンプレートはその型に合わせています。

## 何が作られるか

- `main.bicep`
  - WAF ポリシーを作成
  - `associateToFrontDoor = true` の場合、既存 Front Door Profile 配下に Security Policy を作り、WAF をドメインへ関連付け

## 使い方

- WAF ポリシーだけ作る: `associateToFrontDoor = false`
- 既存 Front Door に関連付ける: `associateToFrontDoor = true` にして、次を設定
  - `frontDoorProfileName`
  - `securityPolicyName`
  - `domainResourceIds` (通常は `Microsoft.Cdn/profiles/customDomains` のリソースID)

パラメータ例は `main.parameters.json` を参照してください。

## メモ

- WAF ポリシーは通常 `location = Global` です。
- `managedRuleSets` の例として Microsoft 管理ルールセットを入れています。要件に合わせてカスタムルール/除外(Exclusion)を追加してください。
- 参考として `Microsoft.Cdn/cdnWebApplicationFirewallPolicies` 版も `modules/wafPolicyCdn.bicep` として残しています（環境により使い分け）。

## 参考 (スキーマ)

- `Microsoft.Network/FrontDoorWebApplicationFirewallPolicies`
  - https://learn.microsoft.com/en-us/azure/templates/microsoft.network/frontdoorwebapplicationfirewallpolicies
- `Microsoft.Cdn/cdnWebApplicationFirewallPolicies` (参考)
  - https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/cdnwebapplicationfirewallpolicies
- `Microsoft.Cdn/profiles/securityPolicies`
  - https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/securitypolicies
