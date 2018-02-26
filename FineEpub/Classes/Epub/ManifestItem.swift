//
//  ManifestItem.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit
import Fuzi

public class ManifestItem: NSObject {
    private let XML_ATTRIBUTE_ID = "id"
    private let XML_ATTRIBUTE_HREF = "href"
    private let XML_ATTRIBUTE_MEDIA_TYPE = "media-type"
    
    public var href: String!
    public var __id: String!
    public var mediaType: String!
    
    public init(withElement element: XMLElement, resolver: HrefResolver) {
        href = resolver.ToAbsolute(element.attr(XML_ATTRIBUTE_HREF)!)
        __id = element.attr(XML_ATTRIBUTE_ID)
        mediaType = element.attr(XML_ATTRIBUTE_MEDIA_TYPE)
    }
}

