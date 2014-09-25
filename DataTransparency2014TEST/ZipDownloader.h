//
//  ZipDownloader.h
//  DataTransparencyConference
//
//  Created by Weien on 8/5/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZipDownloader : NSObject

+ (void) downloadZipAtURL:(NSURL*)url WithCompletion:(void (^)(void))completion;

@end
