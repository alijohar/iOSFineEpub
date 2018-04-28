//
//  JSEpub.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class JSEpub: Book {
    
    public let CSS_NAME = "../css/MehdokStyle.css"
    public let JS_NAME = "../js/MehdokBridge.js"
    
    var bookSize = -1
    
    public init(withBookPath bookPath: String) {
        super.init()
        super.initialize(bookPath)
    }
    
    public func fetchWithClasses(_ resourceUri: Uri, classes: String) -> ResourceResponse {
        let response = fetchInternal(resourceUri: resourceUri)
        let data = response?.data
        let injectedData = injectJsStyle(String(data: data!, encoding: .utf8)!, classes: classes)
        
        response?.data = injectedData.data(using: .utf8)
        
        return response!
    }
    
    public func injectJsStyle(_ resourceString: String, classes: String) -> String {
        let cssTag = String(format: "<link rel=\"stylesheet\" type=\"text/css\" href=\"%@\"></link>", CSS_NAME)
        let jsTag = String(format: "<script type=\"text/javascript\" src=\"%@\"></script>", JS_NAME)
        let toInject = String(format: "\n%@\n%@\n</head>", cssTag, jsTag)
        
        var result = resourceString.replacingOccurrences(of: "</head>", with: toInject)
        result = result.replacingOccurrences(of: "<html ", with: String(format: "<html class=\"%@\" ", classes))
        
        return result
    }
    
    public func getResourceString(_ resourceUri: Uri, classes: String) -> String {
        guard let address: String = resourceUri.getPath() else {
            return ""
        }
        
        let data = super.fetchFromZip(address)
        
        return injectJsStyle(String(data: data!, encoding: String.Encoding.utf8)!, classes: classes)
    }
    
    public func getBookSize() -> Int {
        if  bookSize < 0 {
            bookSize = SizeUtil.getAllByte(self)
        }
        
        return bookSize
    }
    
    public func getChapterPercent(_ resourceAddress: Uri) -> Float {
        return Float(SizeUtil.getChapterBytes(book: self, chapter: resourceAddress)) / Float(getBookSize()) * 100
    }
    
    public func getCurrentChapterSize(_ resourceAddress: Uri) -> Int {
        return SizeUtil.getCurrentChapterBytes(book: self, chapter: resourceAddress)
    }
    
    public func getNextChapterSize(_ resourceAddress: Uri) -> Int {
        guard let nextResource = self.nextResource(resourceAddress) else {
            return 1
        }
        
        return SizeUtil.getCurrentChapterBytes(book: self, chapter: nextResource)
    }
}
