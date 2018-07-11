//
//  ViewController.swift
//  FineEpub
//
//  Created by mehdok on 02/26/2018.
//  Copyright (c) 2018 mehdok. All rights reserved.
//

import UIKit
import FineEpub

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let path = Bundle.main.path(forResource: "wahid0", ofType: "epub")
        let book = JSEpub(withBookPath: path!)
        
        print(book.getBookName())
        
//        for nav in book.tableOfContents.navPoints {
//            print(nav.navLabel)
//        }
        print("nav point count: \(book.tableOfContents.navPoints.count)")
        print("nav tree count: \(book.tableOfContents.navTree!.children.count)")
        
        traverseTree(root: book.tableOfContents.navTree!, depth: 0)
        
        
    }
    
    func traverseTree(root: Node<NavPoint>, depth: Int) {
    
        let intent = depth * 4;
        let space = String(repeating: " ", count: intent)
        print("\(space) \(root.data?.content ?? "")")
    
        if root.children.count > 0 {
            for child in root.children {
                traverseTree(root: child, depth: depth + 1)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

