# MacClarity

**すべての容量を、明快に。すべての判断を、確かに。**

[英語](README.md) · [中国語](README.zh-CN.md) · [日本語サイト](docs/ja/index.html)

![ディスクフラワーと根拠に基づく性能診断](docs/assets/hero.svg)

MacClarity は、Mac の容量と動作状況をローカルで診断するオープンソースツールです。ディスクフラワーで容量の行方を見渡し、測定された推移から動作の重さを読み解きます。提案には根拠が示され、処理は必ず利用者が確認します。

## 特長

- **容量と遅さを一緒に分析：** ローカル割り当て容量、メモリ圧力、スワップ、性能推移を確認します。
- **一貫した結果：** コマンドライン、ネイティブ画面、ウェブレポートが同じ診断データを使用します。
- **根拠のある提案：** 判断材料を説明し、承認や削除を代行しません。
- **プライバシー優先：** 診断はオフラインで動作し、共有用出力は識別情報を決定的に匿名化します。
- **安全な操作：** 広範囲なルート、シンボリックリンク、変更済み対象、期限切れ承認を拒否します。

![収集から検証まで](docs/assets/diagnosis-flow.svg)

## インストールと使い方

macOS 14+ と Swift 6 が必要です。

```bash
git clone https://github.com/SichenTao/macclarity.git
cd macclarity
./install.sh
```

最初は実機を走査しない合成デモをおすすめします。

```bash
swift run macclarity demo --output macclarity-demo.html
open macclarity-demo.html
```

実機診断は `swift run macclarity diagnose --path "$HOME" --duration 30 --output report.html`。共有前に `--share-redacted` を追加してください。

## 最初に選ぶ機能

1. **ディスクフラワー：** 空き容量が少ない、または「システムデータ」が大きく見えるとき。
2. **性能推移：** Mac が重い、熱い、頻繁に止まるとき。
3. **総合診断：** 容量と動作状況のどちらが原因か分からないとき。

現在はソースプレビューです。Apple の署名と公証を通過した後に、直接ダウンロードできるアプリを提供します。

`./scripts/verify.sh` でビルド、テスト、プライバシースキャン、負荷予算、デモ生成を検証できます。詳細は [PRIVACY.md](PRIVACY.md)、[SECURITY.md](SECURITY.md)、[THREAT_MODEL.md](THREAT_MODEL.md) を参照してください。

Apache-2.0 ライセンスで公開しています。
