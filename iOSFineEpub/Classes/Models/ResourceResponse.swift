//
//  ResourceResponse.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class ResourceResponse: NSObject {
    var mimeType: String?
    var data: Data?
    var size: UInt64?
    
    public init(withMimeType mimeType: String?, data: Data?) {
        self.mimeType = mimeType
        self.data = data
    }
}

