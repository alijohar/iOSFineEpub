//
//  EpubCache.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public protocol EpubCacheDelegate: class {
    func handleRequest(_ request: URLRequest) -> CachedURLResponse?
}

public class EpubCache: URLCache {
    public weak var delegate: EpubCacheDelegate? = nil
    
    public override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return delegate?.handleRequest(request)
    }
}

