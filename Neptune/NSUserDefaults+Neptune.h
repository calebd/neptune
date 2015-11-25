//
//  NSUserDefaults+Neptune.h
//
//  Created by Caleb Davenport on 4/18/13.
//  Copyright © 2013 Caleb Davenport. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NSUserDefaultsNeptuneErrorDomain;

@interface NSUserDefaults (Neptune)

/**
 Register user defaults by first loading from a local file then by populating
 with the contents of the remote URL.
 
 Completion and local URL are optional.
 
 Completion will NOT be called on the main queue.
 */
- (void)neptune_registerDefaultsWithLocalURL:(NSURL *)localURL
                                   remoteURL:(NSURL *)remoteURL
                                  completion:(void (^) (NSDictionary *dictionary, NSError *error))completion;

/**
 Register user defaults by first loading from a local file then by populating
 with the contents returned by running the URL request.
 
 Completion and local URL are optional.
 
 Completion will NOT be called on the main queue.
 */
- (void)neptune_registerDefaultsWithLocalURL:(NSURL *)URL
                            remoteURLRequest:(NSURLRequest *)request
                                  completion:(void (^) (NSDictionary *dictionary, NSError *error))completion;

@end
