import Kanna

public struct SpineItemref {
    public let idref: String
    public let linear: String?
    
    public var isPrimary: Bool {
        guard let linear = self.linear else { return true }
        return linear == "yes"
    }
    
    init?(_ itemref: XMLElement) {
        guard let itemIdref = itemref["idref"] else { return nil }
        idref = itemIdref
        linear = itemref["linear"]
    }
}

public struct OPFSpine {
    
    public let toc: String?
    public private(set) var itemrefs = [SpineItemref]()
    
    init?(package: XMLElement) {
        guard let spine = package.at_xpath("opf:spine", namespaces: XPath.opf.namespace) else { return nil }
        toc = spine["toc"]
        let itemrefElements = spine.xpath("opf:itemref", namespaces: XPath.opf.namespace)
        for itemrefElement in itemrefElements {
            guard let itemref = SpineItemref(itemrefElement) else { continue }
            itemrefs.append(itemref)
        }
    }
}
