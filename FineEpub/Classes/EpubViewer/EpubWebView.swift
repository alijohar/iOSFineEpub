//
//  EpubWebView.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit
import WebKit
public protocol LoadFinishDelegate: class {
    func pageLoadFinished()
}

public protocol VerticalLoadDelegate: class {
    func pagesAddedToBody()
    func toggleUI()
}

public class EpubWebView:  WKWebView {
    var JSTapDetector: String? = nil
    var resourceCache = [String : CachedURLResponse]()
    var book: JSEpub?
    
    weak var loadFinishDelegate: LoadFinishDelegate? = nil
    weak var verticalLoadDelegate: VerticalLoadDelegate? = nil
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        localInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        localInit()
    }
    
    public func localInit() {
        self.uiDelegate = self
        
        // disable Zoom
//        self.scalesPageToFit = true
        self.isMultipleTouchEnabled = false
        
        // hide Scrollbars
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
    }
    
    public func setBook(_ bookName: String) {
        if book == nil || book!.getBookName() != bookName {
            book = JSEpub(withBookPath: bookName)
        }
    }
    
    public func setBookWithObj(_ book: JSEpub) {
        if self.book == nil || self.book!.getBookName() != book.getBookName() {
            self.book = book
        }
    }
    
    public func fillJS() {
        guard let path = Bundle.main.path(forResource: "JS/TapDetector", ofType: "js") else {
            return
        }
        
        JSTapDetector = try? String(contentsOfFile: path, encoding: .utf8)
    }
    
    public func getResourcePath(from request: URLRequest) -> String {
        var requestURL = request.url
        // Strip out applewebdata://<UUID> prefix applied when HTML is loaded locally
        if (requestURL?.scheme == "applewebdata") {
            let requestURLString = requestURL?.absoluteString
            let trimmedRequestURLString = (requestURLString! as NSString).replacingOccurrences(of: "^(?:applewebdata://[0-9A-Z-]*/?)", with: "", options: .regularExpression, range: NSRange(location: 0, length: (requestURLString?.count ?? 0)))
            if trimmedRequestURLString.count > 0 {
                requestURL = URL(string: trimmedRequestURLString)
            }
        }
        return requestURL?.absoluteString ?? ""
    }
    
    public func getPath(_ uri:String) -> String? {
        let removeStr = String(format: "http://localhost:%d/", WEB_SERVER_PORT)
        guard let replaceRange = uri.range(of: removeStr) else {
            return nil
        }
        
        return uri.replacingCharacters(in: replaceRange, with: "")
    }
    
    @available(iOS 9.0, *)
    public func loadResource(_ data: Data, MIMEType: String, textEncodingName: String, baseURL: URL) {
        super.load(data, mimeType: MIMEType, characterEncodingName: textEncodingName, baseURL: baseURL)
    }
}

extension EpubWebView: WKUIDelegate {
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        evaluateJavaScript(JSTapDetector!) { (what, error) in
            self.loadFinishDelegate?.pageLoadFinished()
        }
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //TODO call delegate if clicked on local resource
        if request.url?.absoluteString.range(of: "MEHDOK_BRIDGE_verticalLoadFinished") != nil {
            verticalLoadDelegate?.pagesAddedToBody()
            return false
        }
        
        if request.url?.absoluteString.range(of: "undefined") != nil {
            verticalLoadDelegate?.toggleUI()
            return false
        }
        
        return true
    }
}

extension EpubWebView: EpubCacheDelegate {
    public func handleRequest(_ request: URLRequest) -> CachedURLResponse? {
        let requestUrl = request.url
        
        if requestUrl?.absoluteString.range(of: "Mosawi.ttf") != nil {
            if let res = resourceCache["Mosawi.ttf"] {
                return res
            } else {
                resourceCache["Mosawi.ttf"] = ResourceUtil.getResourceFromBundle("Mosawi", type: "ttf", MIMEType: MIMETYPE_FONT, requestUrl: requestUrl!)
                
                return resourceCache["Mosawi.ttf"]!
            }
        }
        
        if requestUrl?.absoluteString.range(of: "Style0001.css") != nil {
            if let res = resourceCache["Style0001.css"] {
                return res
            } else {
                resourceCache["Style0001.css"] = ResourceUtil.getResourceFromBundle("Style0001", type: "css", MIMEType: MIMETYPE_CSS, requestUrl: requestUrl!)
                
                return resourceCache["Style0001.css"]!
            }
        }
        
        if requestUrl?.absoluteString.range(of: "MehdokStyle.css") != nil {
            if let res = resourceCache["MehdokStyle.css"] {
                return res
            } else {
                resourceCache["MehdokStyle.css"] = ResourceUtil.getResourceFromBundle("MehdokStyle", type: "css", MIMEType: MIMETYPE_CSS, requestUrl: requestUrl!)
                
                return resourceCache["MehdokStyle.css"]!
            }
        }
        
        if requestUrl?.absoluteString.range(of: "MehdokBridge.js") != nil {
            if let res = resourceCache["MehdokBridge.js"] {
                return res
            } else {
                resourceCache["MehdokBridge.js"] = ResourceUtil.getResourceFromBundle("MehdokBridge", type: "js", MIMEType: MIMETYPE_JAVASCRIPT, requestUrl: requestUrl!)
                
                return resourceCache["MehdokBridge.js"]!
            }
        }
        
        if (requestUrl?.absoluteString.hasPrefix("http://localhost"))! {
            let resolver = HrefResolver(withParentFileName: (book?.opfFileName)!)
            var resourcePath = self.getPath((requestUrl?.absoluteString)!)
            resourcePath = resolver.ToAbsolute(resourcePath!)
            let requestUri = Uri(withHost: "localhost", scheme: "http", port: WEB_SERVER_PORT, path: resourcePath!)
            //TODO add classes
            let response = self.book?.fetchInternal(resourceUri: requestUri)
            
            let urlResponse = URLResponse(url: requestUrl!,
                                          mimeType: response?.mimeType,
                                          expectedContentLength: (response?.data?.count)!,
                                          textEncodingName: "UTF-8")
            
            return CachedURLResponse(response: urlResponse, data: (response?.data)!)
        }
        
        //TODO process non local resource, i.e web sites
        return nil
    }
}
