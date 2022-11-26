import Foundation

open class EPUBDocument {
    public let identifier: String
    public let baseURL: URL
    public var resourceBaseURL: URL
    public let container: ContainerDocument
    public let opf: OPFDocument
    
    public lazy var coverURL: URL? = {
        let coverImageID = opf.metadata.coverImageID
        for item in opf.manifest.items.values where item.id == coverImageID {
            return resourceBaseURL.appendingPathComponent(item.href)
        }
        return nil
    }()
    
    public lazy var tocURL: URL? = {
        for item in opf.manifest.items.values where item.properties == "nav" {
            return resourceBaseURL.appendingPathComponent(item.href)
        }
        return nil
    }()
    
    public lazy var pages: [URL]? = {
        return opf.spine.itemrefs
            .filter { $0.isPrimary }
            .compactMap {
                guard let path = opf.manifest.items[$0.idref]?.href else { return nil }
                return resourceBaseURL.appendingPathComponent(path)
            }
    }()
    
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
