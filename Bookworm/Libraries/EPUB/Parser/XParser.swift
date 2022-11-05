import Foundation

public enum XPath {
    case opf
    case dc
    case ncx
    case container
    
    public var namespace: [String: String] {
        switch self {
        case .opf:
            return ["opf": "http://www.idpf.org/2007/opf"]
        case .dc:
            return ["dc": "http://purl.org/dc/elements/1.1/"]
        case .ncx:
            return ["ncx": "http://www.daisy.org/z3986/2005/ncx/"]
        case .container:
            return ["container": "urn:oasis:names:tc:opendocument:xmlns:container"]
        }
    }
}
