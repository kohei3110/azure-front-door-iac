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

## GitHub Actions（CI / CD）

WAF policy 更新のために、以下のワークフローを追加しています。

- PR チェック: `.github/workflows/frontdoor-waf-pr.yml`
  - `infra/frontdoor-waf/**` の変更がある PR で自動実行
  - Bicep の build / lint を実施
  - fork ではない PR かつ必要な Secrets/Vars が揃っている場合、`az deployment group what-if` を実行し、結果を PR コメント + Job Summary + artifact に出力
- デプロイ（手動承認ゲート付き）: `.github/workflows/frontdoor-waf-deploy.yml`
  - `workflow_dispatch` のみ（手動実行）
  - GitHub Environments の required reviewers を使って承認ゲートを作成
  - prod は `environment = waf-prod` を使用（厳格運用想定）

### パラメータ管理（bicepparam）

環境ごとのパラメータは次に置きます。

- `infra/frontdoor-waf/parameters/dev.bicepparam`
- `infra/frontdoor-waf/parameters/staging.bicepparam`
- `infra/frontdoor-waf/parameters/prod.bicepparam`

※ `associateToFrontDoor` は、IDs/名前が揃うまで **false のまま**にしてあります。Front Door へ関連付ける場合は、`frontDoorProfileName` / `securityPolicyName` / `domainResourceIds` を設定してください。

### ローカル検証

Azure CLI が入っていれば、次で build/lint と bicepparam のコンパイルをまとめて検証できます。

- `infra/frontdoor-waf/scripts/validate.sh`

### 必要な GitHub 設定（Secrets / Vars / Environments）

#### GitHub Environments（承認ゲート）

以下の Environment を GitHub 上で作成し、required reviewers を設定してください。

- `waf-dev`
- `waf-staging`
- `waf-prod`（prod 用。必ず required reviewers を設定）

#### Secrets（Azure login 用）

このリポジトリでは `azure/login@v2` の `creds:` 方式（Service Principal JSON）を利用します。

推奨（共通）

- `AZURE_CREDENTIALS`（全環境共通にできる場合）

フォールバック（環境別）

- `AZURE_CRED_DEV`
- `AZURE_CRED_STAGING`
- `AZURE_CRED_PROD`

PR の what-if は、fork PR では secrets が使えないため自動的にスキップされます。また、secrets/vars が未設定の場合も、PR チェックを落とし続けないように what-if をスキップして Job Summary に注意を書きます。

#### Vars（what-if / deploy で参照する Resource Group）

以下の repository variables を設定してください。

- `AZURE_WAF_RESOURCE_GROUP_DEV`
- `AZURE_WAF_RESOURCE_GROUP_STAGING`
- `AZURE_WAF_RESOURCE_GROUP_PROD`

（互換のため、ワークフロー内では `AZURE_RESOURCE_GROUP_WAF_*` / `WAF_RESOURCE_GROUP_*` もフォールバックとして参照しますが、上記の `AZURE_WAF_RESOURCE_GROUP_*` を推奨します）

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
