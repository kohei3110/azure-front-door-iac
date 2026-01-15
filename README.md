# Front Door Origin（App Service）用 静的サイト + WAF（Bicep）

このリポジトリは、**Azure Front Door のオリジンとして配信する静的サイト**と、Front Door（Standard/Premium）向けの **WAF ポリシー（Bicep）** の最小構成サンプルです。

- アプリ（静的サイト + 最小 Node サーバー）: `app/`
- IaC（Front Door WAF）: `infra/frontdoor-waf/`

## できること

### 1) 静的サイトの配信（オリジン）

`app/site/` 配下の静的ファイルを配信します。

- **Windows App Service（IIS）**: `app/site/` をそのまま `wwwroot` に配置して静的配信（`web.config` 同梱）
- **Linux App Service + Node**: `app/server.js`（Node + Express）で静的ファイルを配信

ヘルスチェック用のエンドポイントも用意しています。

- Node サーバー: `GET /health`（常に 200）
- 静的ファイル: `GET /health.html`（常に 200）

### 2) Front Door（Standard/Premium）向け WAF の IaC

`infra/frontdoor-waf/` は、Front Door Standard/Premium 向けの **WAF ポリシー** と、（任意で）既存 Front Door への **Security Policy による関連付け** を Bicep で管理するためのテンプレートです。

詳細は `infra/frontdoor-waf/README.md` を参照してください。

## フォルダ構成

- `app/`
  - `site/` … 静的サイト（HTML/CSS/JS）
  - `server.js` … App Service（特に Linux）で確実に配信するための最小 Node サーバー
  - `README.md` … アプリ側の説明
- `infra/frontdoor-waf/`
  - `main.bicep` … WAF ポリシー作成（必要に応じて Front Door へ関連付け）
  - `modules/` … WAF/セキュリティポリシーの部品
  - `README.md` … IaC 側の説明

## ローカルで動かす（アプリ）

前提: Node.js 18 以上

1. `app/` に移動
2. 依存関係をインストール
3. サーバーを起動
4. ブラウザで `http://localhost:3000/` を開く

- ヘルスチェック: `http://localhost:3000/health`

具体的な手順は `app/README.md` を参照してください。

## デプロイの考え方（概要）

- **Front Door のヘルスプローブ**は、必ず 200 を返すパスに向けます。
  - 推奨: `GET /health.html`（静的で安定）
  - Node サーバー運用なら `GET /health` でも可
- キャッシュ（CDN/Front Door）を効かせる場合は、更新反映の設計（ファイル名ハッシュ or クエリ付与）を検討してください。