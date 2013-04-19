//
//  NSUserDefaults+Nimbus.h
//
//  Created by Caleb Davenport on 4/18/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Nimbus)

/**
 Register user defaults by first loading from a local file then by populating
 with the contents of the remote URL.
 
 Completion and local URL are optional.
 
 Completion will NOT be called on the main queue.
 */
- (void)nimbus_registerDefaultsWithLocalURL:(NSURL *)localURL
                                  remoteURL:(NSURL *)remoteURL
                                 completion:(void (^) (NSDictionary *dictionary, NSError *error))completion;

/**
 Register user defaults by first loading from a local file then by populating
 with the contents returned by running the URL request.
 
 Completion and local URL are optional.
 
 Completion will NOT be called on the main queue.
 */
- (void)nimbus_registerDefaultsWithLocalURL:(NSURL *)URL
                           remoteURLRequest:(NSURLRequest *)request
                                 completion:(void (^) (NSDictionary *dictionary, NSError *error))completion;

@end
