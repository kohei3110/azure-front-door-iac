# Front Door Origin (App Service) - Static Site

このリポジトリは、**Azure App Service をオリジン** として静的サイトを配信するための最小構成です。

- 静的ファイル: `site/`
- 配信用サーバー: `server.js`（Node + Express）

> App Service は「静的ファイルを置いただけ」で配信できない構成が多いため、
> 確実に配信できるように *最小の Node サーバー* を同梱しています。

## 使い方（ローカル）

- 依存関係をインストール
- サーバー起動
- ブラウザで確認

`/health` も 200 を返します。

## App Service への配置イメージ

### Windows App Service (IIS) の場合（静的サイトとして配信）

Windows App Service は IIS が前段にあるため、**静的ファイルだけ**を配信するなら
`site/` 配下のファイルをそのまま `wwwroot` に配置するのが一番シンプルです。

- このリポジトリでは IIS 向けに `site/web.config` を同梱しています
	- `index.html` を既定ドキュメントにする
	- `404` を `404.html` に割り当てる
	- `.svg` などの MIME を補強

Front Door のヘルスプローブは **`GET /health.html`** を推奨します。

### 参考: Linux App Service + Node (18 以上)

- ランタイム: Node.js 18 LTS 以上
- 起動: `npm start`
- ポート: `process.env.PORT`（無い場合は 3000）

### Front Door の probe

- Windows (IIS / 静的): `GET /health.html`
- Node サーバー利用時: `GET /health` または `GET /health.html`

## ファイル

- `site/index.html` … トップページ
- `site/404.html` … 404
- `site/health.html` … 静的ヘルス

詳しい静的サイト側の説明は `site/README.md` を参照してください。
