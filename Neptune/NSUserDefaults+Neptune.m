//
//  NSUserDefaults+Neptune.m
//
//  Created by Caleb Davenport on 4/18/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

#import "NSUserDefaults+Neptune.m"

@implementation NSUserDefaults (Neptune)

+ (NSOperationQueue *)nimbus_queue {
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
     queue:[[self class] nimbus_queue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *requestError) {
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
