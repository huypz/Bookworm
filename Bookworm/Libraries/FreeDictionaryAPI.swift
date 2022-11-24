import Foundation

struct FreeDictionaryPhonetic: Codable {
    let text: String?
    let audio: String?
}

struct FreeDictionaryDefinition: Codable {
    let definition: String?
    let example: String?
    let synonyms: [String]
    let antonyms: [String]
}

struct FreeDictionaryMeaning: Codable {
    let partOfSpeech: String?
    let definitions: [FreeDictionaryDefinition]
    let synonyms: [String]
    let antonyms: [String]
}

struct FreeDictionaryEntry: Codable {
    let word: String?
    let phonetics: [FreeDictionaryPhonetic]
    let meanings: [FreeDictionaryMeaning]
}

struct FreeDictionaryAPI {
    
    private static let entriesURLString = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    static func entryInfoURL(for term: String) -> URL? {
        let entryInfoURLString = entriesURLString + term
        return URL(string: entryInfoURLString)
    }
    
    static func entries(fromJSON data: Data) -> Result<[FreeDictionaryEntry], Error> {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode([FreeDictionaryEntry].self, from: data)
            return .success(response)
        }
        catch {
            return .failure(error)
        }
    }
}
