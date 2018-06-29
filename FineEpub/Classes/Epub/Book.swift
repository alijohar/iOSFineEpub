//
//  Book.swift
//  iOSFineEpub
//
//  Created by Mehdi Sohrabi on 2/20/18.
//

import UIKit
import objective_zip
import Fuzi
import SwiftSoup

public class Book: NSObject {
    private let HTTP_SCHEME = "http";
    
    // the container XML
    private let XML_NAMESPACE_CONTAINER = "urn:oasis:names:tc:opendocument:xmlns:container";
    private let XML_ELEMENT_CONTAINER = "container";
    private let XML_ELEMENT_ROOTFILES = "rootfiles";
    private let XML_ELEMENT_ROOTFILE = "rootfile";
    private let XML_ATTRIBUTE_FULLPATH = "full-path";
    private let XML_ATTRIBUTE_MEDIATYPE = "media-type";
    
    // the .opf XML
    private let XML_NAMESPACE_PACKAGE = "http://www.idpf.org/2007/opf";
    private let XML_ELEMENT_PACKAGE = "package";
    private let XML_ELEMENT_MANIFEST = "manifest";
    private let XML_ELEMENT_MANIFESTITEM = "item";
    private let XML_ELEMENT_SPINE = "spine";
    private let XML_ATTRIBUTE_TOC = "toc";
    private let XML_ELEMENT_ITEMREF = "itemref";
    private let XML_ATTRIBUTE_IDREF = "idref";
    private let XML_ELEMENT_METADATA = "metadata";
    private let XML_METADATA_NAMESPACE = "http://purl.org/dc/elements/1.1/";
    private let XML_METADATA_PREFIX = "dc"
    private let XML_ELEMENT_TITLE = "title"
    private let XML_ELEMENT_PUBLISHER = "publisher";
    private let XML_ELEMENT_CREATOR = "creator";
    private let XML_ELEMENT_LANGUAGE = "language";
    private let XML_ELEMENT_IDENTIFIER = "identifier";
    private let XML_METADATA_META = "meta";
    
    
    public private(set) var zip: OZZipFile?
    public private(set) var mTocID: String?
    public private(set) var metadata: Metadata
    public private(set) var spine: [ManifestItem]
    public private(set) var manifest: Manifest
    public private(set) var tableOfContents: TableOfContents
    public private(set) var bookPath: String?
    public private(set) var tocID: String?
    public private(set) var opfFileName: String?
    
    public override init() {
        self.spine = [ManifestItem]()
        self.manifest = Manifest()
        self.tableOfContents = TableOfContents()
        self.metadata = Metadata()
    }
    
    public convenience init(withBookPath bookPath: String) {
        self.init()
        
        initialize(bookPath)
    }
    
    internal func initialize(_ bookPath: String) {
        self.bookPath = bookPath
        
        self.zip = try? OZZipFile(fileName: bookPath, mode: .unzip, error: ())
        self.parseEpub()
    }
    
    /////////// static methods
    
    public static func url2ResourceName(_ uri: Uri) -> String? {
        guard var resourceName = uri.getPath() else {
            return nil
        }
        
        if resourceName.hasPrefix("/") {
            resourceName = String(resourceName.dropFirst())
        }
        
        return resourceName
    }
    
    public static func resourceName2Url(resourceName: String) -> Uri {
        let encodedResourceName = resourceName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        return Uri(withHost: LOCAL_HOST, scheme: EPUB_SCHEME, port: WEB_SERVER_PORT, path: encodedResourceName!)
    }
    
    ///////////
    
    public func getFileName() -> String? {
        guard let zip = self.zip else {
            return nil
        }
        
        return zip.fileName
    }
    
    // fetch an entry in zip file as data
    public func fetchFromZip(_ fileName: String) -> Data? {
        guard let _ = zip?.locateFile(inZip: fileName) else {
            return nil
        }
        
        guard let fileStream = try? zip?.readCurrentFileInZipWithError() else {
            return nil
        }
        
        let BUFFER_SIZE = 4 * 1024 // 4 KB
        
        let fileData = NSMutableData()
        fileData.length = BUFFER_SIZE//Int(fileSize!)
        var allData = Data()
        
        repeat {
            // Reset buffer length
            fileData.length = BUFFER_SIZE

            // Read bytes and check for end of file
            let bytesRead = fileStream?.readData(withBuffer: fileData)
            if (bytesRead! <= 0) {
                break
            }

            fileData.length = Int(bytesRead!)

            // Do something with data
            allData.append(fileData as Data)

        } while true
        
        fileStream?.finishedReading()
        
        return allData//fileData as Data;
    }
    
    public func fetchInternal(resourceUri: Uri) -> ResourceResponse? {
        guard var resourceName = Book.url2ResourceName(resourceUri) else {
            return nil
        }
        
        let item = self.manifest.find(byResourceName: resourceName)
        
        if(item != nil) {
            let response = ResourceResponse(withMimeType: item?.mediaType, data: fetchFromZip(resourceName))
            
            if response.data == nil {
                resourceName = resourceName.replacingOccurrences(of: "%20", with: " ")
                response.data = fetchFromZip(resourceName)
                
                if response.data == nil {
                    // Can not find resource
                    return nil;
                } else {
                    response.size = getSizeInZip(resourceName)
                    return response;
                }
            } else {
                response.size = getSizeInZip(resourceName)
                return response;
            }
        } else {
            resourceName = resourceName.replacingOccurrences(of: "%20", with: " ")
            let item = self.manifest.find(byResourceName: resourceName)
            if(item != nil) {
                let response = ResourceResponse(withMimeType: item?.mediaType, data: fetchFromZip(resourceName))
                response.size = getSizeInZip(resourceName)
                return response;
            }
        }
        
        return nil
    }
    
    public func getSizeInZip(_ fileName: String) -> UInt64? {
        zip?.locateFile(inZip: fileName)
        return zip?.getCurrentFileInZipInfo().size
    }
    
    public func firstChapter() -> Uri? {
        if spine.count > 0 {
            return Book.resourceName2Url(resourceName: (spine.first?.href)!)
        }
        
        return nil
    }
    
    public func nextResource(_ resourceUri: Uri) -> Uri? {
        let resourceName = Book.url2ResourceName(resourceUri)
        for i in 0...spine.count {
            if spine[i].href == resourceName {
                return Book.resourceName2Url(resourceName: spine[i + 1].href)
            }
        }
        
        return nil;
    }
    
    public func previousResource(_ resourceUri: Uri) -> Uri? {
        let resourceName = Book.url2ResourceName(resourceUri)
        for i in 0...spine.count {
            if spine[i].href == resourceName {
                return Book.resourceName2Url(resourceName: spine[i - 1].href)
            }
        }
        
        return nil;
    }
    
    public func parseEpub() {
        // clear everything
        
        self.opfFileName = nil
        self.tocID = nil
        self.spine.removeAll()
        self.manifest.clear()
        self.tableOfContents.clear()
        self.metadata.clear()
        
        let containerData = fetchFromZip("META-INF/container.xml")
        parseContainerData(containerData!)
        
        if self.opfFileName != nil {
            let opfData = fetchFromZip(self.opfFileName!)
            parseOpfFile(opfData!)
        }
        
        if self.tocID != nil {
            let tocManifestItem = self.manifest.find(byItemId: self.tocID!)
            if tocManifestItem != nil {
                let tocFileName = tocManifestItem?.href
                let resolver = HrefResolver(withParentFileName: tocFileName!)
                let tocData = fetchFromZip(tocFileName!)
                self.tableOfContents.parseToc(tocData, resolver: resolver)
            }
        }
    }
    
    private func parseContainerData(_ data: Data) {
        let doc = try? XMLDocument(data: data)
        guard let root = doc?.root else {
            return
        }
        
        let rootFiles = root.firstChild(tag: XML_ELEMENT_ROOTFILES)
        
        for rootFile in (rootFiles?.children(tag: XML_ELEMENT_ROOTFILE))! {
            let value = rootFile.attr(XML_ATTRIBUTE_MEDIATYPE)
            if value == "application/oebps-package+xml" {
                self.opfFileName = rootFile.attr(XML_ATTRIBUTE_FULLPATH)
                return
            }
        }
    }
    
    private func parseOpfFile(_ data: Data) {
        let doc = try? XMLDocument(data: data)
        guard let root = doc?.root else {
            return
        }
        
        doc?.definePrefix(XML_METADATA_PREFIX, defaultNamespace: XML_METADATA_NAMESPACE)
        
        let meta = root.firstChild(tag: XML_ELEMENT_METADATA)
        parseMetadata(meta)
        
        let manifest = root.firstChild(tag: XML_ELEMENT_MANIFEST)
        parseManifest(manifest)
        
        let spineElm = root.firstChild(tag: XML_ELEMENT_SPINE)
        parseSpine(spineElement: spineElm)
    }
    
    private func parseMetadata(_ meta: XMLElement?) {
        metadata.title = meta?.firstChild(tag: XML_ELEMENT_TITLE, inNamespace: XML_METADATA_PREFIX)?.stringValue
        metadata.creator = meta?.firstChild(tag: XML_ELEMENT_CREATOR, inNamespace: XML_METADATA_PREFIX)?.stringValue
        metadata.publisher = meta?.firstChild(tag: XML_ELEMENT_PUBLISHER, inNamespace: XML_METADATA_PREFIX)?.stringValue
        metadata.language = meta?.firstChild(tag: XML_ELEMENT_LANGUAGE, inNamespace: XML_METADATA_PREFIX)?.stringValue
        metadata.identifier = meta?.firstChild(tag: XML_ELEMENT_IDENTIFIER, inNamespace: XML_METADATA_PREFIX)?.stringValue
        
        guard let metaChilds = meta?.children(tag: XML_METADATA_META) else {
            return
        }
        
        for metaChild in metaChilds {
            metadata.items.append(MetadataItem(withElement: metaChild))
        }
    }
    
    private func parseManifest(_ manifestElement: XMLElement?) {
        guard let manifestChilds = manifestElement?.children(tag: XML_ELEMENT_MANIFESTITEM) else {
            return
        }
        
        let resolver = HrefResolver(withParentFileName: self.opfFileName!)
        
        for item in manifestChilds {
            let manifestItem = ManifestItem(withElement: item, resolver: resolver)
            self.manifest.add(item: manifestItem)
        }
    }
    
    private func parseSpine(spineElement: XMLElement?) {
        tocID = spineElement?.attr(XML_ATTRIBUTE_TOC)
        
        guard let spineItems = spineElement?.children(tag: XML_ELEMENT_ITEMREF) else {
            return
        }
        
        for spineItem in spineItems {
            let idRef = spineItem.attr(XML_ATTRIBUTE_IDREF)
            let manifestItem = self.manifest.find(byItemId: idRef!)
            if manifestItem != nil {
                self.spine.append(manifestItem!)
            }
        }
    }
    
    public func getBookName() -> String? {
        return metadata.title
    }
    
    public func getBookAuthor() -> String? {
        return metadata.creator
    }
    
    public func getBookPublisher() -> String? {
        return metadata.publisher
    }
    
    public func getBookLanguage() -> String? {
        return metadata.language
    }
    
    public func getBookIdentifier() -> String? {
        return metadata.identifier
    }
    
    public func getCoverImage() -> Uri? {
        guard let coverAddress = metadata.getCoverImageAddress() else {
            return nil
        }
        
        guard let mi = manifest.find(byItemId: coverAddress) else {
            return nil
        }
        
        return Book.resourceName2Url(resourceName: mi.href)
    }
    
    public func getPageNumber() -> Int {
        return spine.count
    }
    
    public func getResourceNumber(_ resource: Uri) -> Int {
        let resourceName = Book.url2ResourceName(resource)
        for i in 0...(spine.count - 1) {
            if resourceName == spine[i].href {
                return i
            }
        }
        
        return -1;
    }
    
    public func getResourceAt(_ index: Int) -> Uri? {
        if index > spine.count {
            return nil
        } else {
            return Book.resourceName2Url(resourceName: spine[index].href)
        }
    }
    
    public func getPageBody(_ address: Uri?) -> String? {
        guard let address = address else {
            return nil
        }
        
        let data = fetchFromZip(Book.url2ResourceName(address)!)
        do {
            let html = String(data: data!, encoding: .utf8)
            let doc: Document = try SwiftSoup.parse(html!)
            guard let body = try doc.body()?.text() else {
                return nil
            }
            
            return getCleanString(body)
        } catch Exception.Error(let type, let message) {
            print(type, message)
            return nil
        } catch {
            return nil
        }
    }
    
    public func getCleanString(_ input: String) -> String {
        var result = input.replacingOccurrences(of: "'", with: "\\'")
        result = input.replacingOccurrences(of: "&laquo;", with: "«")
        result = input.replacingOccurrences(of: "&raquo;", with: "»")
        result = input.replacingOccurrences(of: "&quot;", with: "\\'")
        result = input.replacingOccurrences(of: "&nbsp;", with: "")
        result = input.replacingOccurrences(of: "&amp;", with: "")
        result = result.components(separatedBy: .newlines).joined(separator: " ")
        
        return result
    }
}
