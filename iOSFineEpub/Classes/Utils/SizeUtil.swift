//
//  SizeUtil.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit

public class SizeUtil: NSObject {
    public static func getAllByte(_ book: Book) -> Int {
        var all = 0;
        var curr = book.firstChapter()
        all += getInputSize(book: book, address: curr!)
        curr = book.nextResource(curr!)
        
        while (curr != nil) {
            all += getInputSize(book: book, address: curr!)
            curr = book.nextResource(curr!)
        }
        
        return all;
    }
    
    public static func getChapterBytes(book: Book, chapter: Uri) -> Int {
        var size = 0;
        var curr = book.firstChapter()
        while !(curr?.getPath() == chapter.getPath()) {
            size += getInputSize(book: book, address: curr!)
            curr = book.nextResource(curr!)
            if curr == nil {
                break
            }
        }
        
        return size;
    }
    
    public static func getCurrentChapterBytes(book: Book, chapter: Uri) -> Int {
        return getInputSize(book:book, address:chapter)
    }
    
    static private func getInputSize(book: Book, address: Uri) -> Int {
        return getBytes(data: book.fetchFromZip(address.getString()))
    }
    
    static private func getBytes(data: Data?) -> Int {
        guard let data = data else {
            return  0
        }
        
        return data.count
    }
}
