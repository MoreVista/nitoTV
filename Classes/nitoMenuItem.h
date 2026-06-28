//
//  nitoMenuItem.h
//  nitoTV – ATV2/3 ビルド用生成ヘッダ
//  nitoMenuItem.xm の %subclass / %new 宣言から生成
//
#pragma once

#import <Foundation/Foundation.h>

@interface nitoMenuItem : NSObject

+ (id)ntvMenuItem;
+ (id)ntvFolderMenuItem;
+ (id)ntvShuffleMenuItem;
+ (id)ntvRefreshMenuItem;
+ (id)ntvSyncMenuItem;
+ (id)ntvLockMenuItem;
+ (id)ntvProgressMenuItem;
+ (id)ntvDownloadMenuItem;
+ (id)ntvComputerMenuItem;
- (void)setCentered:(BOOL)value;
- (void)setTitle:(NSString *)title;
- (void)setRightText:(NSString *)txt;

@end
