//
//  NSMFListDropShadowControl.h
//  nitoTV – ATV2/3 ビルド用生成ヘッダ
//
//  NSMFListDropShadowControl.xm の %subclass / %new 宣言から生成。
//  NSMFMoviePreviewController.xm の #import "NSMFListDropShadowControl.h" に対応する。
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSMFListDropShadowControl : NSObject

- (id)list;
- (void)setList:(id)value;
- (id)cDelegate;
- (void)setCDelegate:(id)theDelegate;
- (id)cDatasource;
- (void)setCDatasource:(id)theDataSource;
- (id)sender;
- (void)setSender:(id)theSender;
- (void)setIsAnimated:(BOOL)animated;
- (BOOL)isAnimated;
- (BOOL)seventyPlus;
- (BOOL)sixtyPlus;
- (void)reloadList;
- (void)logFrame:(CGRect)frame;
- (void)logSize:(CGSize)size;
- (void)addToController:(id)ctrl;
- (float)heightForRow:(long)row;
- (BOOL)rowSelectable:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (id)titleForRow:(long)row;
- (long)defaultIndex;
- (void)itemSelected:(long)selected;
- (void)removeFromSuperviewAnimated;

@end
