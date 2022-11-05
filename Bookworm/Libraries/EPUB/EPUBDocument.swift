import Foundation

open class EPUBDocument {
    public let identifier: String
    public let baseURL: URL
    public let resourceBaseURL: URL
    public let container: ContainerDocument
    public let opf: OPFDocument
    
    public required init?(identifier: String? = nil, contentsOf baseURL: URL) {
        self.identifier = identifier ?? UUID().uuidString
        self.baseURL = baseURL
        
        let containerURL = baseURL.appendingPathComponent("META-INF/container.xml")
        guard let container = ContainerDocument(url: containerURL) else { return nil }
        self.container = container
        
        let opfURL = baseURL.appendingPathComponent(container.opfPath)
        resourceBaseURL = opfURL.deletingLastPathComponent()
        guard let opf = OPFDocument(url: opfURL) else { return nil }
        self.opf = opf
    }
}
