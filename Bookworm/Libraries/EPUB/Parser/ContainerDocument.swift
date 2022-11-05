import Kanna

public struct ContainerDocument {
    public let opfPath: String
    
    public let document: XMLDocument
    
    init?(url: URL) {
        do {
            document = try Kanna.XML(url: url, encoding: .utf8)
            let xpath = "//container:rootfile[@full-path]/@full-path"
            guard let path = document.at_xpath(xpath, namespaces: XPath.container.namespace)?.text else { return nil }
            opfPath = path
        }
        catch {
            print("Error parsing xml file at \(url): \(error)")
            return nil
        }
    }
}
