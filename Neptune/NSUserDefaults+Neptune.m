//
//  NSUserDefaults+Neptune.m
//
//  Created by Caleb Davenport on 4/18/13.
//  Copyright © 2013 Caleb Davenport. All rights reserved.
//

#import "NSUserDefaults+Neptune.h"

NSString * const NSUserDefaultsNeptuneErrorDomain = @"NSUserDefaultsNeptuneErrorDomain";

@implementation NSUserDefaults (Neptune)

+ (NSOperationQueue *)neptune_queue {
    static NSOperationQueue *queue;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        queue = [[NSOperationQueue alloc] init];
        [queue setName:@"me.calebd.Neptune.RequestQueue"];
    });
    return queue;
}


- (void)neptune_registerDefaultsWithLocalURL:(NSURL *)localURL
                                   remoteURL:(NSURL *)remoteURL
                                  completion:(void (^) (NSDictionary *dictionary, NSError *error))completion {
    NSParameterAssert(remoteURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:remoteURL];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request setValue:@"application/x-plist" forHTTPHeaderField:@"Accept"];
    [self neptune_registerDefaultsWithLocalURL:localURL remoteURLRequest:request completion:completion];
}


- (void)neptune_registerDefaultsWithLocalURL:(NSURL *)URL
                            remoteURLRequest:(NSURLRequest *)request
                                  completion:(void (^) (NSDictionary *dictionary, NSError *error))completion {
    NSParameterAssert(request);
    if (URL) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:URL];
        [self registerDefaults:dictionary];
    }
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[self class] neptune_queue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *requestError) {
         if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
             NSInteger status = [(NSHTTPURLResponse *)response statusCode];
             NSIndexSet *codes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
             if (![codes containsIndex:status]) {
                 NSError *error = [[NSError alloc]
                                   initWithDomain:NSUserDefaultsNeptuneErrorDomain
                                   code:status
                                   userInfo:nil];
                 completion(nil, error);
                 return;
             }
         }
         if (data) {
             NSError *propertyListError;
             NSDictionary *dictionary = [NSPropertyListSerialization
                                         propertyListWithData:data
                                         options:NSPropertyListImmutable
                                         format:NULL
                                         error:&propertyListError];
             if (dictionary) {
                 [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                     [self setObject:obj forKey:key];
                 }];
                 if (completion) {
                     completion(dictionary, nil);
                 }
             }
             else {
                 if (completion) {
                     completion(nil, propertyListError);
                 }
             }
         }
         else {
             if (completion) {
                 completion(nil, requestError);
             }
         }
     }];
}


@end
