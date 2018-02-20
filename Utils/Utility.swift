//
//  Utility.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class Utility: NSObject {
    public static func extractPath(_ fileName: String) -> String {
        return (fileName as NSString).deletingLastPathComponent
    }
    
    public static func concatPath(_ basePath: String?, pathToAdd: String) -> String {
        var rawPath = ""
        
        if basePath == nil || basePath!.isEmpty || pathToAdd.hasPrefix("/") {
            rawPath = pathToAdd
        } else {
            rawPath = String(format: "%@/%@", basePath!, pathToAdd)
        }
        
        return rawPath
    }
    
}

