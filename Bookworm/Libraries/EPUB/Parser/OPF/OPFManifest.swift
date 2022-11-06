import Kanna

public struct ManifestItem {
    
    public let id: String
    public let href: String
    public let mediaType: String
    public let properties: String?
    
    init?(_ item: XMLElement) {
        guard let itemId = item["id"] else { return nil }
        guard let itemHref = item["href"] else { return nil }
        guard let itemMediaType = item["media-type"] else { return nil }
        
        id = itemId
        href = itemHref
        mediaType = itemMediaType
        properties = item["properties"]
    }
}

public struct OPFManifest {
    
    public private(set) var items = [String: ManifestItem]()
    
    init?(package: XMLElement) {
        guard let manifest = package.at_xpath("opf:manifest", namespaces: XPath.opf.namespace) else { return nil }
        let itemElements = manifest.xpath("opf:item", namespaces: XPath.opf.namespace)
        for itemElement in itemElements {
            guard let item = ManifestItem(itemElement) else { continue }
            items[item.id] = item
        }
    }
}
