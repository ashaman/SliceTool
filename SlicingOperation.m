//
// Created by Yaroslav Vorontsov on 15.04.15.
//

#import "SlicingOperation.h"
#import "NSImage+MGCropExtensions.h"
#import "util.h"


@implementation SlicingOperation
{

}

#pragma mark - Initialization and memory management

- (instancetype)initWithImage:(NSImage *)image
                   colorSpace:(NSColorSpace *)colorSpace
                     tileSize:(CGFloat)tileSize
              savingDirectory:(NSString *)savingDirectory
{
    if ((self = [super init]))
    {
        self.image = image;
        self.colorSpace = colorSpace;
        self.tileSize = tileSize;
        self.savingDirectory = savingDirectory;
    }
    return self;
}

+ (instancetype)operationWithImage:(NSImage *)image
                        colorSpace:(NSColorSpace *)colorSpace
                          tileSize:(CGFloat)tileSize
                   savingDirectory:(NSString *)savingDirectory
{
    return [[[self alloc] initWithImage:image
                             colorSpace:colorSpace
                               tileSize:tileSize
                        savingDirectory:savingDirectory] autorelease];
}

- (void)dealloc
{
    self.image = nil;
    self.colorSpace = nil;
    self.savingDirectory = nil;
    [super dealloc];
}

#pragma mark - Main operation routine

- (void)main
{
    @autoreleasepool
    {
        NSUInteger row = 0;
        CGFloat imageHeight = self.image.size.height;
        CGFloat imageWidth = self.image.size.width;
        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        for (CGFloat y = 0.0f; y < imageHeight; y += self.tileSize)
        {
            @autoreleasepool {
                NSUInteger col = 0;
                NSError *error = nil;
                BOOL isDirectory;
                NSString *directory = [self.savingDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%tu", row]];
                if (![fileManager fileExistsAtPath:directory isDirectory:&isDirectory]) {
                    if (![fileManager createDirectoryAtPath:directory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error]) {
                        error_output(@"Failed to create directory %@: %@", directory, error.localizedDescription);
                    }
                }
                for (CGFloat x = 0.0f; x < imageWidth; x += self.tileSize) {
                    CGFloat width = fmin(self.tileSize, imageWidth - x);
                    CGFloat height = fmin(self.tileSize, imageHeight - y);

                    NSRect cropRect = NSMakeRect(x, fmax(0.0f, imageHeight - (y + self.tileSize)), width, height);
                    NSImage *cropped = [self.image imageCroppedInRect:cropRect];
                    NSString *outputFile = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%tu.png", col]];
                    NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep imageRepWithData:[cropped TIFFRepresentation]]
                            bitmapImageRepByConvertingToColorSpace:self.colorSpace renderingIntent:NSColorRenderingIntentDefault];
                    [[bitmapImageRep representationUsingType:NSPNGFileType properties:nil] writeToFile:outputFile atomically:YES];
                    col++;
                }
            }
            row++;
        }

    }
}


@end