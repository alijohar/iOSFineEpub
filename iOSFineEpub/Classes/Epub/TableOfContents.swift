//
//  TableOfContents.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit
import Fuzi

public class TableOfContents: NSObject {
    private let XML_NAMESPACE_TABLE_OF_CONTENTS = "http://www.daisy.org/z3986/2005/ncx/"
    private let XML_ELEMENT_NCX = "ncx"
    private let XML_ELEMENT_NAVMAP = "navMap"
    private let XML_ELEMENT_NAVPOINT = "navPoint"
    private let XML_ELEMENT_NAVLABEL = "navLabel"
    private let XML_ELEMENT_TEXT = "text"
    private let XML_ELEMENT_CONTENT = "content"
    private let XML_ATTRIBUTE_PLAYORDER = "playOrder"
    private let XML_ATTRIBUTE_SCR = "src"
    
    private var navPoints: [NavPoint]
    
    private let currentDepth = 0
    private let supportedDepth = 1
    private var hrefResolver: HrefResolver? = nil
    
    public override init() {
        navPoints = [NavPoint]()
    }
    
    public func add(_ navPoint: NavPoint) {
        navPoints.append(navPoint)
    }
    
    public func clear() {
        navPoints.removeAll()
    }
    
    public func getLatestPoint() -> NavPoint {
        return navPoints[navPoints.count - 1]
    }
    
    public func parseToc(_ data: Data?, resolver: HrefResolver) {
        hrefResolver = resolver
        
        guard let data = data else {
            return
        }
        
        let doc = try? XMLDocument(data: data)
        guard let root = doc?.root else {
            return
        }
        
        // define a shortcut for name space
        //        doc?.definePrefix("toc_ns", defaultNamespace: XML_NAMESPACE_TABLE_OF_CONTENTS)
        
        let ncx = root.firstChild(tag: XML_ELEMENT_NCX,
                                  inNamespace: XML_NAMESPACE_TABLE_OF_CONTENTS)
        let navMap = ncx?.firstChild(tag: XML_ELEMENT_NAVMAP,
                                     inNamespace: XML_NAMESPACE_TABLE_OF_CONTENTS)
        guard let navPoints = navMap?.children(tag: XML_ELEMENT_NAVPOINT,
                                               inNamespace: XML_NAMESPACE_TABLE_OF_CONTENTS) else {
                                                return
        }
        
        for navPoint in navPoints {
            parseNavPoint(navPoint)
        }
    }
    
    public func parseNavPoint(_ navPointElement: XMLElement) {
        let navLabel = navPointElement.firstChild(tag: XML_ELEMENT_NAVLABEL,
                                                  inNamespace: XML_NAMESPACE_TABLE_OF_CONTENTS)
        let text = navLabel?.firstChild(tag: XML_ELEMENT_TEXT,
                                        inNamespace: XML_NAMESPACE_TABLE_OF_CONTENTS)
        let content = navLabel?.firstChild(tag: XML_ELEMENT_CONTENT,
                                           inNamespace: XML_NAMESPACE_TABLE_OF_CONTENTS)
        
        //TODO do i need to mention namespace???
        
        guard let navLabelText = text?.stringValue,
            let contentSrc = content?.attr(XML_ATTRIBUTE_SCR) else {
                return
        }
        let playOrder = navLabel?.attr(XML_ATTRIBUTE_PLAYORDER)
        
        let navPoint = NavPoint(WithPlayOrder: playOrder,
                                navLabel: navLabelText,
                                content: (hrefResolver?.ToAbsolute(contentSrc))!)
        
        add(navPoint)
    }
}
