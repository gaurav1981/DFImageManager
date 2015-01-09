// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DFAssetsLibraryImageManagerConfiguration.h"
#import "DFCompositeImageManager.h"
#import "DFImageManager.h"
#import "DFImageProcessingManager.h"
#import "DFPHImageManagerConfiguration.h"
#import "DFProxyImageManager.h"
#import "DFURLImageManagerConfiguration.h"
#import <DFCache/DFCache.h>


@implementation DFImageManager (DefaultManager)

+ (id<DFImageManager>)defaultManager {
    static id<DFImageManager> defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [self _createDefaultManager];
    });
    return defaultManager;
}

+ (id<DFImageManager>)_createDefaultManager {
    DFImageProcessingManager *imageProcessor = [DFImageProcessingManager new];
    
    DFImageManager *URLImageManager = ({
        // Initialize DFCache without memory cache because DFImageManager has a higher level memory cache (see <DFImageCaching>.
        DFCache *cache = [[DFCache alloc] initWithName:[[NSUUID UUID] UUIDString] memoryCache:nil];
        
        // Disable image decompression because DFImageManager has builtin image decompression (see <DFImageProcessing>)
        [cache setAllowsImageDecompression:NO];
        
        DFURLImageManagerConfiguration *URLImageManagerConfiguration = [[DFURLImageManagerConfiguration alloc] initWithCache:cache];
        [[DFImageManager alloc] initWithConfiguration:URLImageManagerConfiguration imageProcessor:imageProcessor cache:imageProcessor];
    });
    
    DFImageManager *photosKitImageManager = ({
        DFPHImageManagerConfiguration *configuration = [DFPHImageManagerConfiguration new];
        
        // We don't need image decompression, because PHImageManager does it for us.
        [[DFImageManager alloc] initWithConfiguration:configuration imageProcessor:nil cache:imageProcessor];
    });
    
    DFImageManager *assetsLibraryImageManager = ({
        DFAssetsLibraryImageManagerConfiguration *configuration = [DFAssetsLibraryImageManagerConfiguration new];
        
        // We do need both image decompression and caching.
        [[DFImageManager alloc] initWithConfiguration:configuration imageProcessor:imageProcessor cache:imageProcessor];
    });
    
    DFCompositeImageManager *compositeImageManager = [[DFCompositeImageManager alloc] initWithImageManagers:@[ URLImageManager, photosKitImageManager, assetsLibraryImageManager ]];

    return compositeImageManager;
}

@end