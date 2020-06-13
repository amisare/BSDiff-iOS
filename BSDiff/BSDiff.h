//
//  BSDiff.h
//  BSDiff
//
//  Created by 顾海军 on 2020/6/13.
//  Copyright © 2020 顾海军. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for BSDiff.
FOUNDATION_EXPORT double BSDiffVersionNumber;

//! Project version string for BSDiff.
FOUNDATION_EXPORT const unsigned char BSDiffVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BSDiff/PublicHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface BSDiff : NSObject

+ (void)diffWithOldFilePath:(NSString *)oldFilePath
                newFilePath:(NSString *)newFilePath
              patchFilePath:(NSString *)patchFilePath
                      error:(NSError **)error;

+ (void)patchWithOldFilePath:(NSString *)oldFilePath
                 newFilePath:(NSString *)newFilePath
               patchFilePath:(NSString *)patchFilePath
                       error:(NSError **)error;

+ (void)diffWithOldFilePath:(NSString *)oldFilePath
                newFilePath:(NSString *)newFilePath
              patchFilePath:(NSString *)patchFilePath
          completionHandler:(void (^)(NSString *patchFilePath,  NSError *error))completionHandler;

+ (void)patchWithOldFilePath:(NSString *)oldFilePath
                 newFilePath:(NSString *)newFilePath
               patchFilePath:(NSString *)patchFilePath
           completionHandler:(void (^)(NSString *newFilePath,  NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
