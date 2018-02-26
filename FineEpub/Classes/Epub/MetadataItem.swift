//
//  MetadataItem.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit
import Fuzi

public class MetadataItem: NSObject {
    private let XML_ATTRIBUTE_NAME = "name";
    private let XML_ATTRIBUTE_CONTENT = "content";
    
    public var name: String?
    public var content: String?
    
    public init(withElement element: XMLElement) {
        name = element.attr(XML_ATTRIBUTE_NAME)
        content = element.attr(XML_ATTRIBUTE_CONTENT)
    }
}

