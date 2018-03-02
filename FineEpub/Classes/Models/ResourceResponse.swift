//
//  ResourceResponse.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class ResourceResponse: NSObject {
    public var mimeType: String?
    public var data: Data?
    public var size: UInt64?
    
    public init(withMimeType mimeType: String?, data: Data?) {
        self.mimeType = mimeType
        self.data = data
    }
}

