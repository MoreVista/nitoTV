## nitoTV – ATV2/3 向け修正済み Makefile
##
## 元の Makefile から以下を修正:
##  1. target=iphone:4.3:4.3 → target=iphone:4.3:7.0
##     (現行 ld は deployment target 4.3 未満を拒否するため :7.0 を指定)
##  2. ARCHS = armv7 を明示
##     (theos デフォルトが armv6 のため)
##  3. CFLAGS に MissingHeaders パスを追加
##     (BackRowDefines.h / Extensions.h / ATVVersionInfo.h を読めるようにする)
##  4. LDFLAGS から -lsubstrate を削除・-nodefaultlibs/-lobjc/-lSystem を追加
##     (mobilesubstrate 依存なしでビルド可能にする)
##  5. -framework SystemConfiguration を LDFLAGS に追加
##     (Reachability.m が SCNetworkReachability を使うため)
##  6. SMFramework.framework リンクを -FFrameworks で通す
##  7. DEBUG 出力を off にする（リリース向け）

GO_EASY_ON_ME = 1

TARGET     = iphone
ARCHS      = armv7
target     = iphone:4.3:7.0

export SDKVERSION = 4.3
export DEBUG      = 0

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/aggregate.mk

BUNDLE_NAME = nitoTV

nitoTV_FILES  = Classes/NSObject+AssociatedObjects.m
nitoTV_FILES += Classes/nitoTVAppliance.xm
nitoTV_FILES += Classes/APAttribute.m
nitoTV_FILES += Classes/APDocument.m
nitoTV_FILES += Classes/APElement.m
nitoTV_FILES += Classes/nitoMediaMenuController.xm
nitoTV_FILES += Classes/ntvMedia.xm
nitoTV_FILES += Classes/ntvUIClasses.xm
nitoTV_FILES += Classes/nitoMenuItem.xm
nitoTV_FILES += Classes/nitoDeadController.xm
nitoTV_FILES += Classes/ntvMediaPreview.xm
nitoTV_FILES += Classes/nitoManageMenu.xm
nitoTV_FILES += Classes/nitoInstalledPackageManager.xm
nitoTV_FILES += Classes/nitoWeather.m
nitoTV_FILES += Classes/nitoWeatherController.xm
nitoTV_FILES += Classes/nitoSourceController.xm
nitoTV_FILES += Classes/ntvWeatherManager.xm
nitoTV_FILES += Classes/ntvWeatherViewer.xm
nitoTV_FILES += Classes/NitoTheme.m
nitoTV_FILES += Classes/nitoRss.m
nitoTV_FILES += Classes/nitoRssController.xm
nitoTV_FILES += Classes/ntvRssBrowser.xm
nitoTV_FILES += Classes/ntvRSSViewer.xm
nitoTV_FILES += Classes/nitoSettingsController.xm
nitoTV_FILES += Classes/nitoInstallManager.xm
nitoTV_FILES += Classes/queryMenu.xm
nitoTV_FILES += Classes/Reachability.m
nitoTV_FILES += Classes/kbScrollingTextControl.xm
nitoTV_FILES += Classes/nitoDefaultManager.m
nitoTV_FILES += Classes/packageManagement.m
nitoTV_FILES += SMFClasses/NSMFCompatibility.m
nitoTV_FILES += Classes/nitoMockMenuItem.m
nitoTV_FILES += SMFClasses/NSMFDropShadowControl.xm
nitoTV_FILES += SMFClasses/NSMFBaseAsset.xm
nitoTV_FILES += SMFClasses/NSMFComplexDropShadowControl.xm
nitoTV_FILES += SMFClasses/NSMFComplexProcessDropShadowControl.xm
nitoTV_FILES += SMFClasses/NSMFListDropShadowControl.xm
nitoTV_FILES += SMFClasses/NSMFMoviePreviewController.xm
nitoTV_FILES += SMFClasses/NSMFPhotoMediaAsset.xm
nitoTV_FILES += SMFClasses/NSMFPopup.xm
nitoTV_FILES += SMFClasses/NSMFProgressBarControl.xm
nitoTV_FILES += SMFClasses/NSMFTextDropShadowControl.xm
nitoTV_FILES += SMFClasses/NSMFAnimation.m
nitoTV_FILES += SMFClasses/NSMFCommonTools.m
nitoTV_FILES += SMFClasses/NSMFMockMenuItem.m
nitoTV_FILES += SMFClasses/NSMFPreferences.m
nitoTV_FILES += SMFClasses/NSMFThemeInfo.m
nitoTV_FILES += Classes/PackageDataSource.xm
nitoTV_FILES += Classes/nitoMoreMenu.xm
nitoTV_FILES += Classes/ntvMediaShelfView.xm
nitoTV_FILES += Classes/ntvSettingsArrayController.xm

nitoTV_INSTALL_PATH    = /Applications/AppleTV.app/Appliances
nitoTV_BUNDLE_EXTENSION = frappliance

## ---- コンパイルフラグ ----
nitoTV_CFLAGS  = -isysroot $(THEOS)/sdks/iPhoneOS$(SDKVERSION).sdk
nitoTV_CFLAGS += -F$(THEOS)/sdks/iPhoneOS$(SDKVERSION).sdk/System/Library/PrivateFrameworks
## MissingHeaders (BackRowDefines.h / Extensions.h / ATVVersionInfo.h)
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/MissingHeaders
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/SMFClasses
## SMFramework.framework のヘッダも直接参照できるようにする
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/Frameworks/SMFramework.framework/Headers
## substrate.h をプロジェクトルートに置く場合
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)
nitoTV_CFLAGS += -I$(THEOS)/include
nitoTV_CFLAGS += -I$(THEOS_PROJECT_DIR)/nitoHelper/theos/include
nitoTV_CFLAGS += -include $(THEOS_PROJECT_DIR)/Classes/packageManagement.h
nitoTV_CFLAGS += -Wno-deprecated-declarations
nitoTV_CFLAGS += -Wno-objc-method-access
nitoTV_CFLAGS += -Wno-unused-variable

## ---- リンクフラグ ----
## -nodefaultlibs: iOS 4.3 SDK に libc++ がないため自動リンクを無効化
nitoTV_LDFLAGS  = -all_load
nitoTV_LDFLAGS += -undefined dynamic_lookup
nitoTV_LDFLAGS += -nodefaultlibs
nitoTV_LDFLAGS += -lobjc
nitoTV_LDFLAGS += -lSystem
nitoTV_LDFLAGS += -lz
nitoTV_LDFLAGS += -framework UIKit
nitoTV_LDFLAGS += -framework ImageIO
nitoTV_LDFLAGS += -framework Foundation
nitoTV_LDFLAGS += -framework CoreGraphics
nitoTV_LDFLAGS += -framework SystemConfiguration
nitoTV_LDFLAGS += -framework CoreFoundation
## SMFramework はリポジトリ内 Frameworks/ から読む
nitoTV_LDFLAGS += -FFrameworks
nitoTV_LDFLAGS += -framework SMFramework

include $(FW_MAKEDIR)/bundle.mk

NTV_PATH = $(FW_STAGING_DIR)$(nitoTV_INSTALL_PATH)/$(BUNDLE_NAME).$(nitoTV_BUNDLE_EXTENSION)/$(BUNDLE_NAME)

after-nitoTV-stage::
	$(FAKEROOT) chown -R root:wheel $(FW_STAGING_DIR)
	$(PREFIX)strip -x $(NTV_PATH)
	$(_THEOS_CODESIGN_COMMANDLINE) $(NTV_PATH)

after-install::
	install.exec "killall -9 AppleTV"
