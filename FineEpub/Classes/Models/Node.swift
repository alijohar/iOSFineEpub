//
//  Node.swift
//  FineEpub
//
//  Created by Mehdi Sohrabi on 7/11/18.
//

import UIKit

public class Node<T>: NSObject {
    public var data: T? = nil
    public private(set) var children: [Node] = [Node]()
    public var parent: Node? = nil

    public init(data: T) {
        self.data = data
    }
    
    public override init() {
        
    }
    
    public func addChild(child: Node) {
        child.parent = self
        self.children.append(child)
    }
   
    public func addChild(data: T) {
        let newChild = Node(data: data)
        newChild.parent = self
        children.append(newChild)
    }
   
    public func addChildren(children: [Node]) {
        for t in children {
            t.parent = self
        }
        self.children.append(contentsOf: children)
    }
}
