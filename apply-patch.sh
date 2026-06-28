#!/bin/bash
# nitoTV ATV3 パッチ適用スクリプト
# 使い方: cd nitoTV && bash apply-patch.sh
#
# このスクリプトは nitotv-atv3-patch.tar.gz を展開して
# 修正ファイルをリポジトリに適用する。

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Makefile がある場所にいるか確認
if [ ! -f "Makefile" ] || ! grep -q "nitoTV" Makefile; then
    echo "エラー: nitoTV リポジトリのルートで実行してください"
    exit 1
fi

echo "=== nitoTV ATV3 パッチ適用 ==="

# バックアップ
echo "[1/4] バックアップ作成..."
for f in Makefile Resources/Info.plist layout/DEBIAN/control Classes/packageManagement.h packageManagement.h; do
    if [ -f "$f" ] && [ ! -f "${f}.orig" ]; then
        cp "$f" "${f}.orig"
        echo "  backed up: $f"
    fi
done

# 新規ファイルコピー
echo "[2/4] 新規ファイル追加..."
for f in \
    Classes/Reachability.h \
    Classes/Reachability.m \
    Classes/nitoMenuItem.h \
    SMFClasses/NSMFBaseAsset.h \
    SMFClasses/NSMFListDropShadowControl.h \
    Resources/Info.plist.atv3 \
    layout/DEBIAN/control.atv3 \
    Makefile.atv3 \
    CLAUDE.md \
    BUILD_ATV3.md; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
        cp "$SCRIPT_DIR/$f" "$f"
        echo "  added: $f"
    fi
done

# 変更ファイル上書き
echo "[3/4] 変更ファイル適用..."
for f in \
    Classes/packageManagement.h \
    packageManagement.h \
    Classes/nitoTVAppliance.xm \
    Classes/PackageDataSource.h \
    SMFClasses/NSMFListDropShadowControl.xm; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
        cp "$SCRIPT_DIR/$f" "$f"
        echo "  updated: $f"
    fi
done

# Makefile 差し替え
echo "[4/4] Makefile 差し替え..."
cp Makefile.atv3 Makefile
cp Resources/Info.plist.atv3 Resources/Info.plist
cp layout/DEBIAN/control.atv3 layout/DEBIAN/control

echo ""
echo "=== 完了 ==="
echo "ビルド: make clean && make && make package"
