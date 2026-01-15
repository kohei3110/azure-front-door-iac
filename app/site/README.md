# Static Origin Site (Front Door 用)

このフォルダ（`site/`）は **ビルド無しで配備できる静的サイト** です。

- `index.html` … トップページ
- `404.html` … Not Found
- `health.html` … ヘルスチェック用（常に 200）
- `assets/` … CSS/JS

## ローカルでの確認

相対パスではなく **ルート基準のパス（`/assets/...`）** を使っているので、ローカルでも “サーバーで配信” して確認するのが確実です。

macOS の場合、Python が入っていれば以下で簡易サーバーを起動できます（任意）：

- `cd site`
- `python3 -m http.server 8080`
- `http://localhost:8080/` を開く

また、**App Service を想定した Node サーバー**（このリポジトリ直下の `server.js`）でも確認できます：

- リポジトリ直下で `npm install`
- `npm start`
- `http://localhost:3000/` を開く

Front Door のヘルスプローブ用に `GET /health` も 200 を返します。

## Front Door のオリジンとして置くときの目安

Front Door の具体的な設定画面/項目名はプランや世代で差があるため、ここでは **考え方** と **よくある落とし穴** に絞ります。

### 1) Health probe は “必ず 200 を返すパス” に

- 推奨: `GET /health.html`
- HTML の内容は何でも良いですが、**常に 200** が大事です。

Windows App Service（IIS）でこの `site/` をそのまま配信する場合も、
`health.html` は静的ファイルなので安定して 200 を返せます。

### 2) 404 の扱い（特に SPA にしない場合）

このサンプルは SPA ではなく、普通の静的サイトとして作っています。

- 直接アクセスされるパスが増える場合は、そのパスの HTML を増やすか
- Front Door 側で “存在しないパスは 404.html を返す/リライトする”

などを検討してください。

### 3) キャッシュ

Front Door でキャッシュを効かせる場合は、更新反映のために以下が重要です。

- ファイル名にハッシュを付ける（例: `styles.abc123.css`）
- もしくはこのサンプルのようにクエリでバージョンを付ける（例: `styles.css?v=20260115`）

本番運用ではハッシュ付きが鉄板ですが、まずはクエリでも十分運用できます。

### 4) オリジン側は “圧縮/Content-Type” が正しいこと

静的ホスティング先（オリジン）で、最低限以下が正しく返るのが理想です。

- `.css` → `text/css`
- `.js` → `text/javascript` または `application/javascript`
- `.svg` → `image/svg+xml`
- `sitemap.xml` → `application/xml` など

（どのホスティングに置くかで設定方法が変わります）

## 次にやること（必要なら）

- 会社/サービスのブランドに合わせて文言・色を調整
- 追加ページを作る（例: `/privacy.html`, `/terms.html`）
- `sitemap.xml` の URL を本番ドメインで埋める
- `security.txt` の連絡先を実際のものに置き換える

## Windows App Service（IIS）に置くときの補足

このフォルダには `web.config` を同梱しています。

- 既定ドキュメント: `index.html`
- 404: `404.html` を返す（ステータスは 404 のまま）
- `.svg` などの MIME を補強

デプロイ時は `site/` 配下の内容を App Service の `wwwroot` に配置してください。
