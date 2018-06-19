//
//  Manifest.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class Manifest: NSObject {
    public private(set) var items: [ManifestItem]
    public private(set) var idIndex: [String : ManifestItem]
    
    public override init() {
        items = [ManifestItem]()
        idIndex = [String : ManifestItem]()
    }
    
    public func add(item: ManifestItem) {
        items.append(item)
        idIndex[item.__id] = item
    }
    
    public func clear() {
        items.removeAll()
    }
    
    public func find(byItemId itemId: String) -> ManifestItem? {
        return idIndex[itemId]
    }
    
    public func find(byResourceName resourceName: String) -> ManifestItem? {
        for i in 0...(items.count - 1) {
            let item = items[i]
            if resourceName == item.href {
                return item
            }
        }
        
        return nil
    }
}

