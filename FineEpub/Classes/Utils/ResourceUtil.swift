//
//  ResourceUtil.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class ResourceUtil: NSObject {
    public static func getResourceFromBundle(_ resourceName: String, type: String, MIMEType: String, requestUrl: URL) -> CachedURLResponse {
        let path = Bundle.main.url(forResource: resourceName, withExtension: type)
        let fileData = try! Data(contentsOf: path!)
        let urlResponse = URLResponse(url: requestUrl, mimeType: MIMEType, expectedContentLength: fileData.count, textEncodingName: "UTF-8")
        
        return CachedURLResponse(response: urlResponse, data: fileData)
    }
}

