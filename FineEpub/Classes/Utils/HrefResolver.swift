//
//  HrefResolver.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class HrefResolver: NSObject {
    private var parentPath: String
    
    public init(withParentFileName parentFileName: String) {
        parentPath = Utility.extractPath(parentFileName)
    }
    
    public func ToAbsolute(_ relativeHref: String) -> String {
        return Utility.concatPath(parentPath, pathToAdd: relativeHref)
    }
}

