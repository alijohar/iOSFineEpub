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
    
    public private(set) var navPoints: [NavPoint]
    public private(set) var unFoldedNavPoints: [NavPoint]
    public private(set) var navTree: Node<NavPoint>?
    
    private let currentDepth = 0
    private let supportedDepth = 1
    public var hrefResolver: HrefResolver? = nil
    
    public override init() {
        navPoints = [NavPoint]()
        unFoldedNavPoints = [NavPoint]()
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
        
        let navMap = root.firstChild(tag: XML_ELEMENT_NAVMAP)
        guard let navPoints = navMap?.children(tag: XML_ELEMENT_NAVPOINT) else {
            return
        }
        
        for navPoint in navPoints {
            if let nav = parseNavPoint(navPoint) {
                add(nav)
            }
        }
        
        navTree = Node<NavPoint>()
        findChilds(treeRoot: navTree!, childs: navPoints)
    }
    
    public func parseNavPoint(_ navPointElement: XMLElement) -> NavPoint? {
        let navLabel = navPointElement.firstChild(tag: XML_ELEMENT_NAVLABEL)
        
        let text = navLabel?.children[0]

        let content = navPointElement.firstChild(tag: XML_ELEMENT_CONTENT)
        
        guard let navLabelText = text?.stringValue,
            let contentSrc = content?.attr(XML_ATTRIBUTE_SCR) else {
                return nil
        }
        
        let playOrder = navPointElement.attr(XML_ATTRIBUTE_PLAYORDER)
        
        let navPoint = NavPoint(WithPlayOrder: playOrder,
                                navLabel: navLabelText,
                                content: (hrefResolver?.ToAbsolute(contentSrc))!)
        
        return navPoint
    }
    
    private func findChilds(treeRoot: Node<NavPoint>, childs: [XMLElement]) {
        for child in childs {
            if let parsedChild = parseNavPoint(child) {
                let childNode = Node<NavPoint>(data: parsedChild)
                treeRoot.addChild(child: childNode)
                unFoldedNavPoints.append(parsedChild)
                let childChilds = child.children(tag: XML_ELEMENT_NAVPOINT)
                if childChilds.count > 0 {
                    findChilds(treeRoot: childNode,
                               childs: childChilds)
                }
            }
        }
    }
    
    
//    private func parseNavTree(navRoot: XMLElement, treeRoot: Node<NavPoint>) -> Node<NavPoint> {
//        guard let parsedRoot = parseNavPoint(navRoot) else {
//            return treeRoot
//        }
//
//        let navChilds = navRoot.children(tag: XML_ELEMENT_NAVPOINT)
//        if navChilds.count == 0 {
//            // this is leaf
//            treeRoot.addChild(data: parsedRoot)
//        } else {
//            for ch in navChilds {
//                treeRoot.addChild(child: parseNavTree(navRoot: <#T##XMLElement#>, treeRoot: <#T##Node<NavPoint>#>))
//            }
//        }
//        return treeRoot
//    }
    
    
    
//    public func getNavTree() -> [Node<NavPoint>] {
//        if let navTree = navTree {
//            return navTree
//        }
//
//        navTree = [Node<NavPoint>]()
//
//        for nav in navPoints {
//            if (nav.getDepth() == 0) {
//    // it is top level
//    navTree.add(new Node<NavPoint>(nav));
//    } else {
//    int parentPlayOrder = nav.getDepth();
//    Node<NavPoint> parent = getLastElementWithPlayOrder(navTree.get(navTree.size() - 1),
//    parentPlayOrder);
//    parent.addChild(nav);
//    }
//    }
//
//    return navTree;
//    }
}
