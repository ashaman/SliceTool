//
// Created by Yaroslav Vorontsov on 15.04.15.
//

#import "ImageSlicer.h"
#import "util.h"
#import "NSImage+MGCropExtensions.h"
#import "SlicingOperation.h"


@implementation ImageSlicer
{

}

#pragma mark - Initialization and memory management

- (instancetype)init
{
    if ((self = [super init])) {
        NSUInteger activeCPUCount = [[NSProcessInfo processInfo] activeProcessorCount];
        self.fileManager = [[[NSFileManager alloc] init] autorelease];
        self.slicingQueue = [[[NSOperationQueue alloc] init] autorelease];
        self.slicingQueue.maxConcurrentOperationCount = activeCPUCount;
        self.slicingQueue.suspended = NO;
    }
    return self;
}


- (void)dealloc
{
    self.fileManager = nil;
    [self.slicingQueue cancelAllOperations];
    self.slicingQueue = nil;
    [super dealloc];
}

#pragma mark - Slicing

- (void)sliceImageAtPathInternal:(NSString *)imagePath
{
    BOOL isDirectory;
    BOOL exists = [self.fileManager fileExistsAtPath:imagePath isDirectory:&isDirectory];
    if (exists && !isDirectory)
    {
        output(@"  * %@", imagePath);
        NSError *error = nil;
        NSImage *originalImage = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
        NSBitmapImageRep *bitmapImageRep = [NSBitmapImageRep imageRepWithData:[originalImage TIFFRepresentation]];
        NSColorSpace *origColorSpace = [bitmapImageRep colorSpace];


        NSString *slicedPath = [[imagePath stringByDeletingPathExtension] stringByAppendingString:@"-tiles"];
        if (![self.fileManager createDirectoryAtPath:slicedPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            error_output(@"Failed to create directory at path %@: %@", slicedPath, error);
        }
        for (NSInteger i = self.sizes; i >= 0; i--)
        {
            int factor = (int) floorf(powf(2, i));
            float inverse_factor = powf(2, self.sizes - i);
            NSString *scalePath = [slicedPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", factor]];
            if (![self.fileManager createDirectoryAtPath:scalePath withIntermediateDirectories:YES attributes:nil error:&error]) {
                error_output(@"Failed to create directory at path %@: %@", slicedPath, error);
            }
            NSSize newSize = NSMakeSize(bitmapImageRep.pixelsWide / inverse_factor, bitmapImageRep.pixelsHigh / inverse_factor);
            NSOperation *slicingOperation = [SlicingOperation operationWithImage:[originalImage imageScaledToFitSize:newSize]
                                                                      colorSpace:origColorSpace
                                                                        tileSize:self.tileSize
                                                                 savingDirectory:scalePath];
            [self.slicingQueue addOperation:slicingOperation];
        }
    }
}

- (void)sliceImageAtPath:(NSString *)imagePath
{
    [self sliceImageAtPathInternal:imagePath];
    [self.slicingQueue waitUntilAllOperationsAreFinished];
}

- (void)sliceFilesAtPath:(NSString *)directoryPath ofType:(NSString *)extension
{
    NSError *error = nil;
    NSArray *itemList = [self.fileManager contentsOfDirectoryAtPath:directoryPath error:&error];

    if (!itemList) {
        error_output(@"Failed to get contents of directory %@: %@", directoryPath, error);
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *obj, NSDictionary *bindings) {
            return [obj.pathExtension isEqualToString:extension];
        }];
        NSArray *matchingItems = [itemList filteredArrayUsingPredicate:predicate];
        for (NSString *filename in matchingItems)
        {
            [self sliceImageAtPathInternal:filename];
        }
        [self.slicingQueue waitUntilAllOperationsAreFinished];
    }
}


@end