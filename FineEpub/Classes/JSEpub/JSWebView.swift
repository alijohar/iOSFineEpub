//
//  JSWebView.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit
import WebKit

public protocol WebViewBridgeDelegate: class {
    func pageLoadFinished()
    func tapDetected()
}

public class JSWebView: WKWebView, WKUIDelegate {
    weak var webViewBridgeDelegate: WebViewBridgeDelegate? = nil
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        localInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localInit()
    }
    
    private func localInit() {
        self.uiDelegate = self
    }
    
    // MARK: - UIWebViewDelegate
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        webViewBridgeDelegate?.pageLoadFinished()
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.absoluteString.range(of: "undefined") != nil {
            webViewBridgeDelegate?.tapDetected()
            return false
        }
        
        return true
    }
}
