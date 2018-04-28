//
//  JSEpubCache.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

protocol JSCacheDelegate: class {
    func handleRequest(_ request: URLRequest) -> CachedURLResponse
}

public class LocalResource {
    public var name: String
    public var ext: String
    public var mimeType: String
    
    init(name: String, ext: String, mimeType: String) {
        self.name = name
        self.ext = ext
        self.mimeType = mimeType
    }
}

public class FONT: LocalResource {}
public class CSS: LocalResource {}
public class JS: LocalResource {}

public class JSEpubCache: URLCache {
    weak var cacheDelegate: JSCacheDelegate? = nil
    
    public var cachedFonts = [String : CachedURLResponse]()
    public var cachedCss = [String : CachedURLResponse]()
    public var cachedJs = [String : CachedURLResponse]()
    
    let fonts: [FONT] = [FONT(name: "Mosawi", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "nazanin", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Vazir", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "IRANSansMobile", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Druidkufi", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "HeadingAR", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "HeadingFA", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "NormalAR", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "NormalFA", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Tahiat1", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Tahiat2", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Qoran", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Hadith", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Special1", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Special2", ext: "ttf", mimeType: "application/x-font-ttf"),
                         FONT(name: "Special3", ext: "ttf", mimeType: "application/x-font-ttf")]
    
    let cssS : [CSS] = [CSS(name: "Style0001", ext: "css", mimeType: "text/css"),
                        CSS(name: "MehdokStyle", ext: "css", mimeType: "text/css")]
    
    let jsS : [JS] = [JS(name: "MehdokBridge", ext: "js", mimeType: "text/javascript"),
                      JS(name: "TapDetector", ext: "js", mimeType: "text/javascript")]
    
    public override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard let url = request.url else {
            return nil
        }
        
        if let css = urlHasCss(url) {
            return css
        } else if let js = urlHasJs(url) {
            return js
        } else if let font = urlHasFont(url) {
            return font
        } else if url.absoluteString.range(of: "http://localhost") != nil {
            return cacheDelegate?.handleRequest(request)
        }
        
        return nil
    }
    
    private func urlHasFont(_ url: URL) -> CachedURLResponse? {
        for font in fonts {
            let fontName = "\(font.name).\(font.ext)"
            if url.absoluteString.range(of: fontName) != nil {
                if cachedFonts[fontName] != nil {
                    return cachedFonts[fontName]
                } else {
                    guard let fontResource = getLocalResource(font, requestUrl: url) else {
                        return nil
                    }
                    
                    cachedFonts[fontName] = fontResource
                    
                    return fontResource
                }
            }
        }
        
        return nil
    }
    
    private func urlHasCss(_ url: URL) -> CachedURLResponse? {
        for css in cssS {
            let cssName = "\(css.name).\(css.ext)"
            if url.absoluteString.range(of: cssName) != nil {
                if cachedCss[cssName] != nil {
                    return cachedCss[cssName]
                } else {
                    guard let cssResource = getLocalResource(css, requestUrl: url) else {
                        return nil
                    }
                    
                    cachedCss[cssName] = cssResource
                    
                    return cssResource
                }
            }
        }
        
        return nil
    }
    
    private func urlHasJs(_ url: URL) -> CachedURLResponse? {
        for js in jsS {
            let jsName = "\(js.name).\(js.ext)"
            if url.absoluteString.range(of: jsName) != nil {
                if cachedJs[jsName] != nil {
                    return cachedJs[jsName]
                } else {
                    guard let jsResource = getLocalResource(js, requestUrl: url) else {
                        return nil
                    }
                    
                    cachedJs[jsName] = jsResource
                    
                    return jsResource
                }
            }
        }
        
        return nil
    }
}

extension JSEpubCache {
    fileprivate func getLocalResource(_ resource: LocalResource, requestUrl: URL) -> CachedURLResponse? {
        guard let url = Bundle.main.url(forResource: resource.name, withExtension: resource.ext),
            let resourceData = try? Data(contentsOf: url) else {
                return nil
        }
        
        let urlResponse = URLResponse(url: requestUrl,
                                      mimeType: resource.mimeType,
                                      expectedContentLength: resourceData.count,
                                      textEncodingName: "UTF-8")
        return CachedURLResponse(response: urlResponse, data: resourceData)
    }
}
