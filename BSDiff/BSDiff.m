//
//  BSDiff.m
//  bsdiff_ios
//
//  Created by 顾海军 on 2020/6/12.
//

#import "BSDiff.h"

__attribute__(( visibility("hidden") ))
extern int __bsdiff(int argc,char *argv[],char **errmsg);
__attribute__(( visibility("hidden") ))
extern int __bspatch(int argc,char * argv[],char **errmsg);

static dispatch_queue_t bsdiff_processing_queue() {
    static dispatch_queue_t bsdiff_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bsdiff_processing_queue = dispatch_queue_create("com.nn.bsdiff.processing", DISPATCH_QUEUE_SERIAL);
    });
    
    return bsdiff_processing_queue;
}

static dispatch_group_t bsdiff_completion_group() {
    static dispatch_group_t bsdiff_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bsdiff_completion_group = dispatch_group_create();
    });
    
    return bsdiff_completion_group;
}

#define BSDiffErrorDomainDiff @"com.nn.bsdiff.diff"
#define BSDiffErrorDomainPatch @"com.nn.bsdiff.patch"

@implementation BSDiff

static NSLock* BSDiffDiffTasksLock() {
    static NSLock* lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [NSLock new];
    });
    return lock;
}

static NSMutableArray* BSDiffDiffTasks() {
    static NSMutableArray* tasks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tasks = [NSMutableArray new];
    });
    return tasks;
}

static NSLock* BSDiffPatchTasksLock() {
    static NSLock* lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [NSLock new];
    });
    return lock;
}

static NSMutableArray* BSDiffPatchTasks() {
    static NSMutableArray* tasks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tasks = [NSMutableArray new];
    });
    return tasks;
}

+ (void)diffWithOldFilePath:(NSString *)oldFilePath
                newFilePath:(NSString *)newFilePath
              patchFilePath:(NSString *)patchFilePath
                      error:(NSError **)error {
    
    NSError *_error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldFilePath]) {
        _error = [NSError errorWithDomain:BSDiffErrorDomainDiff code:-1 userInfo:@{NSLocalizedDescriptionKey:@"old file does not exist"}];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:newFilePath]) {
        _error = [NSError errorWithDomain:BSDiffErrorDomainDiff code:-1 userInfo:@{NSLocalizedDescriptionKey:@"new file does not exist"}];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:patchFilePath]) {
        NSError *_removeError;
        [[NSFileManager defaultManager] removeItemAtPath:patchFilePath error:&_removeError];
        if (_removeError) {
            NSString *errorDescription = [@"patch file exist and remove error:" stringByAppendingString:_removeError.userInfo[NSLocalizedDescriptionKey]];
            _error = [NSError errorWithDomain:BSDiffErrorDomainDiff code:-1 userInfo: @{NSLocalizedDescriptionKey:errorDescription}];
        }
    }
    if (_error) {
        return;
    }
    
    int argc = 4;
    char * argv[argc];
    char * errmsg = NULL;
    
    argv[0] = "bsdiff";
    argv[1] = (char *)[oldFilePath UTF8String];
    argv[2] = (char *)[newFilePath UTF8String];
    argv[3] = (char *)[patchFilePath UTF8String];
    
    int ret = __bsdiff(argc, argv, &errmsg);
    if (ret != 0) {
        NSString *_errmsg = (errmsg == NULL) ? @"diff fail" : @(errmsg);
        _errmsg = [@"bsdiff:" stringByAppendingString:_errmsg];
        _error = [NSError errorWithDomain:BSDiffErrorDomainDiff
                                     code:-1
                                 userInfo:@{NSLocalizedDescriptionKey:_errmsg}];
    }
    *error = _error;
    
    if (errmsg) free(errmsg);
    return;
}

+ (void)diffWithOldFilePath:(NSString *)oldFilePath
                newFilePath:(NSString *)newFilePath
              patchFilePath:(NSString *)patchFilePath
          completionHandler:(void (^)(NSString *patchFilePath,  NSError *error))completionHandler {
    
    if ([BSDiffDiffTasks() containsObject:patchFilePath]) {
        NSError *error = [NSError errorWithDomain:BSDiffErrorDomainDiff code:-1 userInfo:@{NSLocalizedDescriptionKey:@"diff is in processing"}];
        return completionHandler(nil, error);
    }
    
    dispatch_async(bsdiff_processing_queue(), ^{
        
        [BSDiffDiffTasksLock() lock];
        [BSDiffDiffTasks() addObject:patchFilePath];
        [BSDiffDiffTasksLock() unlock];
        
        NSError *_error;
        [self diffWithOldFilePath:oldFilePath
                      newFilePath:newFilePath
                    patchFilePath:patchFilePath
                            error:&_error];
        
        dispatch_group_async(bsdiff_completion_group(), dispatch_get_main_queue(), ^{
            
            [BSDiffDiffTasksLock() lock];
            [BSDiffDiffTasks() removeObject:patchFilePath];
            [BSDiffDiffTasksLock() unlock];
            
            completionHandler(patchFilePath, _error);
        });
    });
    
}

+ (void)patchWithOldFilePath:(NSString *)oldFilePath
                 newFilePath:(NSString *)newFilePath
               patchFilePath:(NSString *)patchFilePath
                       error:(NSError **)error {
    NSError *_error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldFilePath]) {
        _error = [NSError errorWithDomain:BSDiffErrorDomainPatch code:-1 userInfo:@{NSLocalizedDescriptionKey:@"old file does not exist"}];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:patchFilePath]) {
        _error = [NSError errorWithDomain:BSDiffErrorDomainPatch code:-1 userInfo:@{NSLocalizedDescriptionKey:@"patch file does not exist"}];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath]) {
        NSError *_removeError;
        [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&_removeError];
        if (_removeError) {
            NSString *errorDescription = [@"new file exist and remove error:" stringByAppendingString:_removeError.userInfo[NSLocalizedDescriptionKey]];
            _error = [NSError errorWithDomain:BSDiffErrorDomainPatch code:-1 userInfo: @{NSLocalizedDescriptionKey:errorDescription}];
        }
    }
    if (_error) {
        return;
    }
    
    int argc = 4;
    char * argv[argc];
    char * errmsg = NULL;
    
    argv[0] = "bspatch";
    argv[1] = (char *)[oldFilePath UTF8String];
    argv[2] = (char *)[newFilePath UTF8String];
    argv[3] = (char *)[patchFilePath UTF8String];
    
    int ret = __bspatch(argc, argv, &errmsg);
    if (ret != 0) {
        NSString *_errmsg = (errmsg == NULL) ? @"patch fail" : @(errmsg);
        _errmsg = [@"bspatch:" stringByAppendingString:_errmsg];
        _error = [NSError errorWithDomain:BSDiffErrorDomainPatch
                                     code:-1
                                 userInfo:@{NSLocalizedDescriptionKey:_errmsg}];
    }
    *error = _error;
    
    if (errmsg) free(errmsg);
    return;
}

+ (void)patchWithOldFilePath:(NSString *)oldFilePath
                 newFilePath:(NSString *)newFilePath
               patchFilePath:(NSString *)patchFilePath
           completionHandler:(void (^)(NSString *newFilePath,  NSError *error))completionHandler {
    
    if ([BSDiffPatchTasks() containsObject:newFilePath]) {
        NSError *error = [NSError errorWithDomain:BSDiffErrorDomainPatch code:-1 userInfo:@{NSLocalizedDescriptionKey:@"patch is in processing"}];
        return completionHandler(nil, error);
    }
    
    dispatch_async(bsdiff_processing_queue(), ^{
        
        [BSDiffPatchTasksLock() lock];
        [BSDiffPatchTasks() addObject:patchFilePath];
        [BSDiffPatchTasksLock() unlock];
        
        NSError *_error;
        [self patchWithOldFilePath:oldFilePath
                       newFilePath:newFilePath
                     patchFilePath:patchFilePath
                             error:&_error];
        
        dispatch_group_async(bsdiff_completion_group(), dispatch_get_main_queue(), ^{
            
            [BSDiffPatchTasksLock() lock];
            [BSDiffPatchTasks() removeObject:patchFilePath];
            [BSDiffPatchTasksLock() unlock];
            
            completionHandler(newFilePath, _error);
        });
    });
}

@end
