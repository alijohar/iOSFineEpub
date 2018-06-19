//
//  JSEpubCache.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public protocol JSCacheDelegate: class {
    func handleRequest(_ request: URLRequest) -> CachedURLResponse?
}



open class JSEpubCache: URLCache {
    public weak var cacheDelegate: JSCacheDelegate? = nil
}
