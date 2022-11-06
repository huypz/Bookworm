import Kanna

public struct DCIdentifier {
    public let text: String
    public let id: String?
    
    init(_ dc: XMLElement) {
        text = dc.text ?? ""
        id = dc["id"]
    }
}

public struct OPFMetadata {
    
    // DCMES required elements
    public private(set) var identifiers = [DCIdentifier]()
    public private(set) var titles = [String]()
    public private(set) var languages = [String]()
    // DCMES optional elements
    public private(set) var contributors = [String]()
    // let coverage
    public private(set) var creators = [String]()
    public private(set) var date: String?
    public private(set) var description: String?
    // let format
    public private(set) var publisher: String?
    // let relation
    public private(set) var rights: String?
    public private(set) var sources = [String]()
    public private(set) var subjects = [String]()
    // let type
    // META elements
    public private(set) var modifiedDate: String?
    public private(set) var coverImageID: String?
    
    init?(package: XMLElement) {
        guard let metadata = package.at_xpath("opf:metadata", namespaces: XPath.dc.namespace) else { return nil }
        
        let dcmes = metadata.xpath("dc:*", namespaces: XPath.dc.namespace)
        for dc in dcmes {
            guard let text = dc.text else { continue }
            switch dc.tagName {
            case "identifier":
                identifiers.append(DCIdentifier(dc))
            case "title":
                titles.append(text)
            case "language":
                languages.append(text)
            default:
                break
            }
        }
        
        let metas = metadata.xpath("opf:meta", namespaces: XPath.opf.namespace)
        for meta in metas {
            if meta["property"] == "dcterms:modified" {
                modifiedDate = meta.text
            }
            else if meta["name"] == "cover" {
                coverImageID = meta["content"]
            }
        }
    }
}
