//
//  packageManagement.h
//  nitoTV
//
//  Created by Kevin Bradley on 10/29/10.
//  Copyright 2010 nito, LLC. All rights reserved.
//
#pragma once

/* ==================================================================
 * Prefix.pch から移植したマクロ定義
 * theos ビルドでは PCH が使われないため、ここで定義する
 * ================================================================== */

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define NB [NSBundle mainBundle]
#define UD [NSUserDefaults standardUserDefaults]
#define FM [NSFileManager defaultManager]

#define CLASS(cls) objc_getClass(#cls)

/* BRLocalizedStringManager はランタイムで BackRow.framework から取得する */
@interface BRLocalizedStringManager : NSObject
+ (id)appliance:(id)appliance localizedStringForKey:(NSString *)key inFile:(NSString *)file;
@end

#define BRLocalizedString(key, comment) \
	[BRLocalizedStringManager appliance:self localizedStringForKey:(key) inFile:nil]
#define BRLocalizedStringFromTable(key, tbl, comment) \
	[BRLocalizedStringManager appliance:self localizedStringForKey:(key) inFile:(tbl)]
#define BRLocalizedStringFromTableInBundle(key, tbl, obj, comment) \
	[BRLocalizedStringManager appliance:(obj) localizedStringForKey:(key) inFile:(tbl)]

#ifdef DEBUG
	#define __DEBUG__
#endif

#ifdef __DEBUG__
	#define CMLog(format, ...) NSLog(@"(%s) in [%s:%d] ::: %@", __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])
	#define MARK	CMLog(@"%s", __PRETTY_FUNCTION__);
	#define START_TIMER NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	#define END_TIMER(msg) 	NSTimeInterval stop = [NSDate timeIntervalSinceReferenceDate]; CMLog([NSString stringWithFormat:@"%@ Time = %f", msg, stop-start])
#else
	#define CMLog(format, ...)
	#define MARK
	#define START_TIMER
	#define END_TIMER(msg)
#endif

/* ==================================================================
 * ATV2/3 ビルド用 umbrella imports
 * 各 .xm は packageManagement.h のみをインクルードするため、
 * ここで全クラスヘッダを一括インクルードする。
 * (元々 Prefix.pch 経由でやっていた設計を theos 用に移植)
 * ================================================================== */
#import "NitoTheme.h"
#import "nitoDefaultManager.h"
#import "nitoMediaMenuController.h"
#import "nitoMenuItem.h"
#import "nitoMockMenuItem.h"
#import "kbScrollingTextControl.h"
#import "ntvMedia.h"
#import "ntvMediaPreview.h"
#import "nitoMoreMenu.h"
#import "queryMenu.h"
#import "PackageDataSource.h"
#import "nitoInstallManager.h"
#import "nitoInstalledPackageManager.h"
#import "nitoSourceController.h"

/* ==================================================================
 * Domain 定義
 * ================================================================== */

#define AWK_DOMAIN				@"apt.awkwardtv.org"
#define MODMYI_DOMAIN			@"apt.modmyi.com"
#define SAURIK_DOMAIN			@"apt.saurik.com"
#define BIGBOSS_DOMAIN			@"apt.thebigboss.org"
#define XBMC_DOMAIN				@"mirrors.xbmc.org"
#define NITO_SOURCE_DOMAIN		@"nitosoft.com"
#define ZODTTD_DOMAIN			@"cydia.zodttd.com"

/* ==================================================================
 * packageManagement クラス宣言
 * ================================================================== */

@interface packageManagement : NSObject {

}
+ (BOOL)internetAvailable;
+ (id)_imageWithPath:(NSString *)imagePath;
+ (id)_imageWithURL:(NSURL *)urlPath;
+ (BOOL)ntvSevenPointOhPLus;
+ (BOOL)ntvSixPointOhPLus;
+ (BOOL)ntvFivePointOnePlus;
+ (BOOL)ntvFivePointZeroPlus;
+ (NSString *)properVersion;
+ (NSArray *)defaultDomains;
+ (int)sourceIntegerForRepo:(NSString *)theRepo;
+ (NSArray *)missingDefaultDomains;
+ (NSArray *)parsedPackageArray;
+ (NSArray *)repoReleaseDictionaries;
+ (int)addSource:(NSString *)theSource;
+ (BOOL)addLine:(NSString *)theLine toFile:(NSString *)theFile;
+ (NSString *)displayDependentsForPackage:(NSString *)thePackage;
+ (NSArray *)dependentsForPackage:(NSString *)thePackage;
+ (void)PMRunConfigure;
+ (void)PMRunAutoremove;
+ (NSArray *)basicAppleTVUpdatesAvailable;
+ (NSString *)XBMCLocation;
+ (NSString *)installedLocation;
- (BOOL)packageInstalled:(NSString *)currentPackage;
+(id)sharedManager;
+ (int)aptUpdate;
- (NSString *)packageVersion:(NSString *)currentPackage;
- (void)_updateDateCheck;
- (NSString *)_lastCheckDate;
-(BOOL)_shouldCheckUpdate;
- (void)checkForUpdate;
+ (NSArray *)essentialUpdatesAvailable;
+ (BOOL)essentialUpdatesExist;
+ (NSString *)essentialDisplayStringFromArray:(NSArray *)essentialArray;
+ (NSArray *)basicEssentialUpdatesAvailable;
+ (NSArray *)filteredListArray;
+ (NSString *)listLocationFromString:(NSString *)predicateString;
+ (NSDictionary *)parsedPackageListForRepo:(NSString *)theRepo;
+ (NSDictionary *)parsedPackageList;
- (NSDictionary *)parsedPackageList;
- (NSArray *)untoucables;
- (BOOL)canRemove:(NSString *)theItem;
+ (void)updatePackageList;
+ (NSString *)sauriksListLocation;
+ (NSString *)awkListLocation;
+ (NSString *)nitoListLocation;
+ (NSArray *)parsedPackageArrayForRepo:(NSString *)theRepo;
+ (NSArray *)sourcesFromFile:(NSString *)theSourceFile;
+ (NSArray *)repoDomainList;
+ (NSString *)releaseLocationFromString:(NSString *)predicateString;
+ (NSArray *)filteredReleaseArray;
+ (NSDictionary *)parsedReleaseForRepo:(NSString *)theRepo;
- (NSArray *)depedenciesForPackage:(NSString *)currentPackage;
+ (NSDictionary *)easyLazyIHateYouParsedPackageList;
+ (NSArray *)newParsedPackageArrayForRepo:(NSString *)theRepo;
+ (NSArray *)fullSectionList;
+ (NSArray *)kosherSections;
+ (int)aptUpdateQuiet;
+ (NSArray *)detailedRepoDomainList;
+ (NSArray *)dependencyArrayFromString:(NSString *)depends;
@end
