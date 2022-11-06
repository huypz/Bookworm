import Kanna

public struct OPFDocument {
    
    public let uniqueIdentifierID: String
    public let metadata: OPFMetadata
    public let manifest: OPFManifest
    public let spine: OPFSpine
    
    public let document: XMLDocument
    
    init?(url: URL) {
        do {
            document = try Kanna.XML(url: url, encoding: .utf8)
            guard let package = document.at_xpath("/opf:package", namespaces: XPath.opf.namespace) else { return nil }
            guard let uid = package["unique-identifier"] else { return nil }
            guard let metadata = OPFMetadata(package: package) else { return nil }
            guard let manifest = OPFManifest(package: package) else { return nil }
            guard let spine = OPFSpine(package: package) else { return nil }
            uniqueIdentifierID = uid
            self.metadata = metadata
            self.manifest = manifest
            self.spine = spine
        }
        catch {
            print("Error parsing xml file at \(url): \(error)")
            return nil
        }
    }
}
