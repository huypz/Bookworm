import SSZipArchive

class EPUBParser {
    
    func parse(at sourceURL: URL) -> EPUBDocument? {
        return parse(at: sourceURL, to: EPUBDocument.self)
    }
    
    func parse<T>(at sourceURL: URL, to type: T.Type) -> T? where T: EPUBDocument {
        let identifier = sourceURL.deletingPathExtension().lastPathComponent
        let baseURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(identifier)!
        
        if !FileManager.default.fileExists(atPath: baseURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: baseURL.path, withIntermediateDirectories: true, attributes: nil)
                SSZipArchive.unzipFile(atPath: sourceURL.path, toDestination: baseURL.path)
            }
            catch {
                print("Error extracting epub file: \(error)")
                return nil
            }
        }
        
        return T(identifier: identifier, contentsOf: baseURL)
    }
}
