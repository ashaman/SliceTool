//
// Created by Yaroslav Vorontsov on 15.04.15.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface SlicingOperation : NSOperation
@property (strong, nonatomic) NSImage *image;
@property (strong, nonatomic) NSColorSpace *colorSpace;
@property (copy, nonatomic) NSString *savingDirectory;
@property (assign, nonatomic) CGFloat tileSize;
- (instancetype)initWithImage:(NSImage *)image
                   colorSpace:(NSColorSpace *)colorSpace
                     tileSize:(CGFloat)tileSize
              savingDirectory:(NSString *)savingDirectory;
+ (instancetype)operationWithImage:(NSImage *)image
                        colorSpace:(NSColorSpace *)colorSpace
                          tileSize:(CGFloat)tileSize
                   savingDirectory:(NSString *)savingDirectory;
@end