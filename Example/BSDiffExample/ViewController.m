//
//  ViewController.m
//  BSDiffExample
//
//  Created by 顾海军 on 2020/6/13.
//  Copyright © 2020 顾海军. All rights reserved.
//

#import "ViewController.h"
#import <FileMD5Hash/FileHash.h>
#import <BSDiff/BSDiff.h>

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [BSDiff diffWithOldFilePath:[self fileOld]
                    newFilePath:[self fileNew]
                  patchFilePath:[NSHomeDirectory() stringByAppendingPathComponent:@"tmp/patch.patch"]
              completionHandler:^(NSString * _Nonnull patchFilePath, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"%@", error.description);
            return;
        }
        NSString *md5a = [FileHash md5HashOfFileAtPath:[self filePatch]];
        NSString *md5b = [FileHash md5HashOfFileAtPath:patchFilePath];
        if ([md5a isEqualToString:md5b]) {
            NSLog(@"diff sucess");
        }
        else {
            NSLog(@"diff fail");
        }
    }];
    
    [BSDiff patchWithOldFilePath:[self fileOld]
                     newFilePath:[NSHomeDirectory() stringByAppendingPathComponent:@"tmp/new.txt"]
                   patchFilePath:[self filePatch]
               completionHandler:^(NSString * _Nonnull newFilePath, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"%@", error.description);
            return;
        }
        NSString *md5a = [FileHash md5HashOfFileAtPath:[self fileNew]];
        NSString *md5b = [FileHash md5HashOfFileAtPath:newFilePath];
        if ([md5a isEqualToString:md5b]) {
            NSLog(@"patch sucess");
        }
        else {
            NSLog(@"patch fail");
        }
    }];
}

- (NSString *)fileOld {
    NSString *path = [NSBundle mainBundle].bundlePath;
    path = [path stringByAppendingPathComponent:@"files/bsdiff_old.txt"];
    return path;
}

- (NSString *)fileNew {
    NSString *path = [NSBundle mainBundle].bundlePath;
    path = [path stringByAppendingPathComponent:@"files/bsdiff_new.txt"];
    return path;
}

- (NSString *)filePatch {
    NSString *path = [NSBundle mainBundle].bundlePath;
    path = [path stringByAppendingPathComponent:@"files/bsdiff_patch.patch"];
    return path;
}


@end
