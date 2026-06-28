//
//  NSMFBaseAsset.h
//  nitoTV – ATV2/3 ビルド用生成ヘッダ
//
//  NSMFBaseAsset.xm の %subclass / %new 宣言から生成。
//  NSMFMoviePreviewController.xm の #import "NSMFBaseAsset.h" に対応する。
//

#import <Foundation/Foundation.h>

@interface NSMFBaseAsset : NSObject

+ (id)asset;

- (id)coverArtURL;
- (void)setCoverArtURL:(id)value;
- (id)meta;
- (id)image;
- (void)setMeta:(id)theMeta;
- (void)setImage:(id)theImage;
- (void)setTitle:(NSString *)title;
- (void)setSummary:(NSString *)summary;
- (void)setCustomKeys:(NSArray *)keys forObjects:(NSArray *)objects;
- (void)setCoverArt:(id)coverArt;
- (void)setCoverArtPath:(NSString *)path;
- (NSDictionary *)orderedDictionary;
- (id)coverArt;
- (id)mediaType;
- (id)assetID;
- (id)title;
- (id)summary;
- (BOOL)hasCoverArt;

@end
