//
// Created by Yaroslav Vorontsov on 15.04.15.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface ImageSlicer : NSObject
@property (strong, nonatomic) NSOperationQueue *slicingQueue;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (assign, nonatomic) NSInteger sizes;
@property (assign, nonatomic) CGFloat tileSize;
- (void)sliceImageAtPath:(NSString *)imagePath;
- (void)sliceFilesAtPath:(NSString *)directoryPath ofType:(NSString *)extension;
@end