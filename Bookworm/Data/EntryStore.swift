import UIKit

class EntryStore {
    
    var entries = [FreeDictionaryEntry]()
    var definitions = [FreeDictionaryDefinition]()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func processEntriesRequest(data: Data?, error: Error?) -> Result<[FreeDictionaryEntry], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return FreeDictionaryAPI.entries(fromJSON: jsonData)
    }
    
    func fetchEntries(for term: String, completion: @escaping (Result<[FreeDictionaryEntry], Error>) -> Void) {
        let url = FreeDictionaryAPI.entryInfoURL(for: term)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = self.processEntriesRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
}
