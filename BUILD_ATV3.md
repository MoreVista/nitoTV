# nitoTV – ATV3向けビルドガイド (修正版)

最終更新: 2026-06-25

---

## 0. 前提環境

| 項目 | 値 |
|---|---|
| ビルドホスト | macOS (Intel or Apple Silicon) または Linux x86_64 |
| theos | [theos/theos](https://github.com/theos/theos) 最新版 |
| SDK | iPhoneOS **4.3** SDK (ATV2/3 向け必須) |
| ターゲット | Apple TV 2 (ATV2) / Apple TV 3 (ATV3) — 脱獄済み |
| Logos | theos 付属 `logos` プリプロセッサ (`.xm` → `.m` 変換) |

> **注意**: `iPhoneOS4.3.sdk` は現行 Xcode に同梱されていません。
> [phrackage/sdks](https://github.com/theos/sdks) または
> 古い Xcode (4.x) から取得してください。

---

## 1. 特定された問題と修正内容

### 問題 1 — `Classes/Reachability.m` が存在しない 【致命的】

**原因**: Makefile が `Classes/Reachability.m` を参照しているが、
リポジトリに含まれていない。Apple のサンプルコード (非オープンソース) の
`Reachability` クラスに依存していた。

**修正**: `SCNetworkReachability` API を直接使った最小実装を
`Classes/Reachability.h` / `Classes/Reachability.m` として追加した。

```
Classes/Reachability.h  ← 追加
Classes/Reachability.m  ← 追加
```

---

### 問題 2 — `target=iphone:4.3:4.3` でビルドエラー 【致命的】

**原因**: 現行 ld (Xcode 14+) は deployment target が iOS 7.0 未満のバイナリを
拒否する:

```
ld: warning: building for iOS with 4.3 minimum deployment target is no longer supported
```

**修正**: Makefile の `target` を変更:

```diff
-target=iphone:4.3:4.3
+target=iphone:4.3:7.0
```

`SDKVERSION=4.3` (コンパイル時 SDK) は変えない。

---

### 問題 3 — `ARCHS = armv7` が未指定 【致命的】

**原因**: theos のデフォルトアーキテクチャは `armv6` 。
ATV2/3 は ARMv7 (Cortex-A8/A9) 。

**修正**: Makefile の先頭に追加:

```makefile
ARCHS = armv7
```

---

### 問題 4 — `-lsubstrate` でリンクエラー (iOS 4.3 SDK 環境) 【重要】

**原因**: iOS 4.3 SDK には `libc++.dylib` が存在しない。
theos が clang++ でリンクしようとすると `library not found for -lc++` が出る。

**修正**: Makefile の LDFLAGS を変更:

```diff
-nitoTV_LDFLAGS = -all_load -undefined dynamic_lookup -framework UIKit ...  -lsubstrate ...
+nitoTV_LDFLAGS  = -all_load
+nitoTV_LDFLAGS += -undefined dynamic_lookup
+nitoTV_LDFLAGS += -nodefaultlibs
+nitoTV_LDFLAGS += -lobjc
+nitoTV_LDFLAGS += -lSystem
+# ... フレームワーク群 ...
```

`-lsubstrate` は実機で必要だが、コンパイル時は `-undefined dynamic_lookup`
で代替できる (実機に mobilesubstrate が入っていれば実行時に解決される)。

---

### 問題 5 — `MissingHeaders/` がインクルードパスに入っていない 【重要】

**原因**: `Extensions.h` / `BackRowDefines.h` / `ATVVersionInfo.h` が
`MissingHeaders/` に存在するが、Makefile に `-I` が指定されていない。

**修正**:

```makefile
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/MissingHeaders
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)
```

---

### 問題 6 — `-framework SystemConfiguration` が抜けている 【重要】

**原因**: 追加した `Reachability.m` が `<SystemConfiguration/SystemConfiguration.h>`
を使うため。

**修正**: LDFLAGS に追加:

```makefile
nitoTV_LDFLAGS += -framework SystemConfiguration
```

---

### 問題 7 — `Resources/Info.plist` の内容が不完全 【ATV3 で起動しない】

**原因**:
- `NSPrincipalClass` が `nitoTVAppliance` になっているが、
  Logos (`%subclass`) が動的にクラスを登録するため、
  Frontrow が `principalClass` を呼ぶタイミングによっては未登録になりうる。
- `FRApplianceName` が含まれていない。
- `MinimumOSVersion` が `3.0` (実際は 4.2+)。

**修正**: `Resources/Info.plist.atv3` を用意した (→ セクション 2 参照)。

---

### 問題 8 — `layout/DEBIAN/control` の Depends が厳しすぎる 【パッケージインストール失敗】

**原因**: `beigelist(>=2.2.5-10)`, `com.nito.tssagent(>=1.3-18)`,
`com.firecore.freemem-watcher` 等は ATV3 の Cydia リポジトリに存在しないか
バージョン不一致で install が失敗する。

**修正**: `layout/DEBIAN/control.atv3` を最小 Depends に変更:

```
Depends: mobilesubstrate, cydia(>=1.1.1)
```

---

### 問題 9 — `ntvSettingsArrayController.xm` がビルドリストに含まれていない 【実行時クラス不在】

**原因**: `nitoManageMenu.xm` が `objc_getClass("ntvSettingsArrayController")` で
ランタイムにクラスを参照するが、`Makefile.atv3` のビルドリストに
`ntvSettingsArrayController.xm` が含まれていなかった。
コンパイル時にエラーは出ないが、実行時に "Manage" メニューの "Sections" 選択で
`nil` コントローラが返りクラッシュする。

**修正**: `Makefile.atv3` に追加:

```makefile
nitoTV_FILES += Classes/ntvSettingsArrayController.xm
```

---

### 問題 10 — ルートに空の `packageManagement.h` が存在する 【全コンパイルユニットで定義欠如】

**原因**: リポジトリルートに空の `packageManagement.h` と `packageManagement.m` が存在する。
`-I$(THEOS_PROJECT_DIR)` が先にあると、`Classes/packageManagement.h` の代わりに
空ファイルが読まれ、`packageManagement` クラスのすべてのメソッド宣言が見えなくなる。

**修正**: `Classes/` を先に追加 + ルートの `packageManagement.h` を転送ラッパーに変更:

```makefile
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes  # ← この行を先に
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)
```

```c
// nitoTV/packageManagement.h (ルート) の内容
#import "Classes/packageManagement.h"
```

---

### 問題 11 — `-I$(THEOS_PROJECT_DIR)/SMFClasses` がなかった 【SMFClasses 内ヘッダ未解決】

**原因**: `SMFClasses/` のソースが相互に `"NSMFAnimation.h"` 等をインクルードするが、
theos のインクルードパスに `SMFClasses/` が含まれていなかった。

**修正**: `Makefile.atv3` に追加:

```makefile
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/SMFClasses
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/Frameworks/SMFramework.framework/Headers
```

---

### 問題 12 — `NSMFBaseAsset.h` / `NSMFListDropShadowControl.h` が存在しない 【コンパイルエラー】

**原因**: `NSMFMoviePreviewController.xm` がこれら2つをインクルードしているが、
`.h` ファイルが存在しなかった（`.xm` のみ）。

**修正**: `.xm` の `%subclass` / `%new` 宣言から逆生成:

```
SMFClasses/NSMFBaseAsset.h           ← 新規生成
SMFClasses/NSMFListDropShadowControl.h  ← 新規生成
```

---

### 問題 13 — `Prefix.pch` のマクロ・import が theos ビルドで欠如 【致命的・根本原因】

**原因**: Xcode ビルドでは `Prefix.pch` が全ソースファイルに自動注入されていたが、
theos ビルドでは PCH が使われない。以下が全て未定義になっていた:

- `FM` → `[NSFileManager defaultManager]`
- `BRLocalizedString()` → `BRLocalizedStringManager` 呼び出しマクロ
- `NitoTheme` / `nitoDefaultManager` 等のクラス → umbrella import
- `CMLog` / `CLASS()` 等のデバッグ/ユーティリティマクロ

**修正**: `Classes/packageManagement.h` を **theos 用 PCH 代替** として全面改修:

1. `Prefix.pch` の全マクロ定義を移植
2. `BRLocalizedStringManager` の `@interface` 前方宣言を追加
3. 全クラスヘッダの umbrella import を追加
4. `packageManagement` クラスの不足メソッド宣言を追加 (`kosherSections`, `ntvFivePointZeroPlus`, `detailedRepoDomainList` 等)

---

## 2. 修正済みファイルの適用手順

```bash
cd nitoTV/

# 1. Makefile を差し替え
cp Makefile Makefile.orig
cp Makefile.atv3 Makefile

# 2. Info.plist を差し替え
cp Resources/Info.plist Resources/Info.plist.orig
cp Resources/Info.plist.atv3 Resources/Info.plist

# 3. DEBIAN/control を差し替え
cp layout/DEBIAN/control layout/DEBIAN/control.orig
cp layout/DEBIAN/control.atv3 layout/DEBIAN/control

# 4. Reachability.h/.m は既に Classes/ に追加済み
```

---

## 3. ビルド

```bash
export THEOS=/opt/theos
export THEOS_DEVICE_IP=192.168.x.x   # ATV の IP
export THEOS_DEVICE_PORT=22

# 必ずクリーンビルドから
make clean && make 2>&1 | tee build.log

# エラーがなければパッケージ化
make package

# インストール
make install
```

---

## 4. よくある残留エラーと対処

### `property 'alertViewStyle' not found on object of type 'UIAlertView *'`

iOS 4.x には `alertViewStyle` プロパティが存在しない。
該当行を削除するか `#ifdef __IPHONE_5_0` でガードする。

```objc
// NG (iOS 5+)
[alertView setAlertViewStyle:UIAlertViewStyleDefault];

// 対処: その行を削除するか以下のようにガード
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
[alertView setAlertViewStyle:UIAlertViewStyleDefault];
#endif
```

### `property 'tintColor' not found on UITextView`

iOS 7+ の API。削除する。

### `unused variable [-Werror]`

`-Wno-unused-variable` を CFLAGS に追加済みだが、`GO_EASY_ON_ME=1` が
効いていれば `-Werror` は無効になっているはず。

### `dyld: Library not loaded: /usr/lib/libsubstrate.dylib`

実機に mobilesubstrate (Cydia Substrate) がインストールされていない。
Cydia から `MobileSubstrate` をインストールする。

---

## 5. ATV3 特有の注意点

### iOS 7.x (ATV3 最終) での動作確認項目

ATV3 の最終ファームウェアは iOS **6.2.8** (一部報告では 7.x 相当)。
以下を確認する:

1. **`initWithApplianceInfo:` が呼ばれる**  
   `init` が呼ばれない。`nitoTVAppliance.xm` には両方実装済みなので問題なし。

2. **`NTVApplianceInfo` の `ntvFivePointOnePlus` 分岐**  
   `packageManagement.ntvFivePointOnePlus` は iOS 5+ を返すはず。
   ATV3 では `NTVApplianceInfo` 経由の `applianceInfo` が呼ばれる。

3. **`beigelist` 不要**  
   ATV3 向け脱獄 (aquila) では beigelist は必要ない。
   DEBIAN/control から外した修正版を使うこと。

---

## 6. ログ確認

```bash
# ATV に SSH で入ってログを見る
ssh root@192.168.x.x "killall -9 AppleTV; sleep 2; \
  syslog | grep -i nitotv | tail -50"

# または /tmp にファイルログを仕込む場合
ssh root@192.168.x.x "tail -f /tmp/nitotv.log"
```

---

## 7. 参照リポジトリ

| リポジトリ | 用途 |
|---|---|
| [lechium/nitoTV](https://github.com/lechium/nitoTV) | 本体ソースコード |
| [xbmc/xbmc (14.2-Helix)](https://github.com/xbmc/xbmc/tree/14.2-Helix/xbmc/osx/atv2/) | frappliance 実装の参考 |
| [theos/sdks](https://github.com/theos/sdks) | iPhoneOS 4.3 SDK 入手先 |
