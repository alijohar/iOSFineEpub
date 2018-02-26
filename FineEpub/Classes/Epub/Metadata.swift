//
//  Metadata.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class Metadata: NSObject {
    private static let XML_ATTRIBUTE_COVER_IMAGE = "cover"
    
    public var items: [MetadataItem]
    public var title: String?
    public var creator: String?
    public var publisher: String?
    public var language: String?
    public var identifier: String?
    
    public override init() {
        items = [MetadataItem]()
    }
    
    public func getCoverImageAddress() -> String? {
        for item in items {
            if (item.name != nil &&
                item.name?.caseInsensitiveCompare(Metadata.XML_ATTRIBUTE_COVER_IMAGE) == ComparisonResult.orderedSame) {
                return item.content
            }
        }
        
        return nil
    }
    
    public func clear() {
        items.removeAll()
        title = nil
        creator = nil
        publisher = nil
        language = nil
        identifier = nil
    }
    
    func toString() -> String {
        return "title: \(String(describing: title))\n" +
            "creator: \(String(describing: creator))" +
            "publisher: \(String(describing: publisher))" +
            "language: \(String(describing: language))"
    }
}
