//
//  Neptune.swift
//  Neptune
//
//  Created by Caleb Davenport on 11/24/15.
//  Copyright © 2015 HODINKEE. All rights reserved.
//

import Foundation

extension NSUserDefaults {

    public typealias Completion = ([String: AnyObject]?, NSError?) -> ()

    public func registerDefaults(localURL localURL: NSURL, remoteURL: NSURL, completion: Completion? = nil) {
        let request = NSMutableURLRequest(URL: remoteURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        registerDefaults(fileURL: localURL, URLRequest: request, completion: completion)
    }

    public func registerDefaults(fileURL fileURL: NSURL, URLRequest request: NSURLRequest, completion: Completion? = nil) {
        guard let dictionary = NSDictionary(contentsOfURL: fileURL) as? [String: AnyObject] else {
            fatalError("The item at \(fileURL) is not a valid dictionary.")
        }

        for (key, value) in dictionary {
            self.setObject(value, forKey: key)
        }

        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
            guard
                let response = response as? NSHTTPURLResponse where (200...299).contains(response.statusCode),
                let data = data
            else {
                completion?(nil, error)
                return
            }

            let object: AnyObject
            do {
                object = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            }
            catch {
                completion?(nil, error as NSError)
                return
            }

            guard let dictionary = object as? [String: AnyObject] else {
                completion?(nil, nil)
                return
            }

            for (key, value) in dictionary {
                self.setObject(value, forKey: key)
            }

            completion?(dictionary, nil)
        })
    }
}
