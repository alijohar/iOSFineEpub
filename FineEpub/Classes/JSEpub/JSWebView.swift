//
//  JSWebView.swift
//  FineEpub
//
//  Created by Mehdi Sohrabi on 6/18/18.
//

import UIKit

public class JSWebView: UIWebView, UIWebViewDelegate {
    public weak var webViewBridgeDelegate: WebViewBridgeDelegate? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        localInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        localInit()
    }
    
    private func localInit() {
        self.delegate = self
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

