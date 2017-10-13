//
//  iTunes.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 02.10.17.
//  Copyright © 2017 Anton. All rights reserved.
//
// *************************
//This class does not provide all functionality
//only for test requirements



import Foundation
class iTunes {
    private let session: URLSession?
    private var dataTask: URLSessionTask?
    private var errorMessage: String = ""
    private var searches = [Any]()
    
    typealias QueryResult = ([Any], String) -> ()
    typealias JSONDictionary = [String: Any]
    
    // MARK: - Init
    /// Creates an iTunes client with specific 'URLSession'
    /// - Parameters:
    ///   - session: A session which is used for download content
    init (session: URLSession) {
        self.session = session
    }
    
    //MARK: - Search Fuction
    /// Creates a search request
    /// - Parameters:
    ///   - query: the search query
    ///   - completion: into this function will send result (array of Any objects) and string of errors if there were. Function signature is  ([Any], string) -> ()
    /// Full description for parameters see at https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#searching
    func search(for term: String,
                country: Parameters.Country? = nil,
                media: Parameters.Media? = nil,
                entity: Parameters.Entity? = nil,
                attribute: Parameters.Attribute? = nil,
                limit: Int? = nil,
                offset: Int? = nil,
                completion: @escaping QueryResult ) {
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: Settings.baseURLString + Settings.searchPath) {
            urlComponents.query = buildQuery(term: term,
                                             country: country,
                                             media: media,
                                             entity: entity,
                                             attribute: attribute,
                                             limit: limit,
                                             offset: offset)
           
            guard let url = urlComponents.url else { return }
            performRequest(by: url, completion: completion)
        }
    }
    
    //MARK: - lookup Fuction
    /// Creates a lookup request
    /// - Parameters:
    ///   - id: the ID by which look for
    ///   - completion: into this function will send result (array of Any objects) and string of errors if there were. Function signature is  ([Any], string) -> ()
    /// Full description for parameters see at https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#searching

    func lookup(by id: String,
                typeId: Parameters.LookupIDs,
                entity: Parameters.Entity? = nil,
                completion: @escaping QueryResult ) {
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: Settings.baseURLString + Settings.lookupPath) {
            urlComponents.query = buildQueryForLookup(id: id, typeId: typeId, entity: entity)
            guard let url = urlComponents.url else { return }
            performRequest(by: url, completion: completion)
        }
    }
    
}

//This extension contains private functions which aren't public API
extension iTunes {
    
    private func performRequest(by url: URL, completion: @escaping QueryResult ) {
        dataTask = session?.dataTask(with: url) { data, response, error in
            defer { self.dataTask = nil }
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                self.updateResults(data)
                completion(self.searches, self.errorMessage)
            }
        }
        dataTask?.resume()
    }
    
    private func buildQuery(term: String, country: Parameters.Country? = nil, media: Parameters.Media? = nil, entity: Parameters.Entity? = nil, attribute: Parameters.Attribute? = nil, limit: Int?, offset: Int?) -> String {
        var result = Settings.termPath + term
        
        if country != nil {
            result += Settings.countryPath + (country?.code)!
        }
        if media != nil {
            result += Settings.mediaPath + (media?.code)!
        }
        if entity != nil {
            result += Settings.entityPath + (entity?.code)!
        }
        if attribute != nil {
            result += Settings.attributePath + (attribute?.code)!
        }
        if limit != nil {
            var curLimit = limit!
            if curLimit < 0 {
                curLimit = 1
            }
            if curLimit > 200 {
                curLimit = 200
            }
            result += Settings.limitPath + String(curLimit)
        }
        if offset != nil {
            result += Settings.offsetPath + String(offset!)
        }
        
        return result
    }
    
    private func buildQueryForLookup(id: String, typeId: Parameters.LookupIDs, entity: Parameters.Entity? = nil) -> String {
        var result = typeId.code + id
        if entity != nil {
            result += Settings.entityPath + (entity?.code)!
        }

        return result
    }
    
    private func updateResults(_ data: Data) {
        var response: JSONDictionary?
        searches.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            self.errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let array = response!["results"] as? [Any] else {
            self.errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        for result in array {
            if let result = result as? JSONDictionary {
                searches.append(result)
            }
        }
    }
}

//This extension contains parameters which can move to separate files in full implementation
extension iTunes {
     struct Parameters {
        enum Country: String {
            case RU = "RU"
            case US = "US"
            //...FULL VERSION REQUIRE TO ADD
            public var code: String {
                return rawValue
            }
        }
        
        enum Media: String {
            case movie = "movie"
            case music = "music"
            case all = "all"
            //...FULL VERSION REQUIRE TO ADD
            public var code: String {
                return rawValue
            }
        }
        
        enum Entity: String {
            case album = "album"
            case movie = "movie"
            case movieArtist = "movieArtist"
            case song = "song"
            //...FULL VERSION REQUIRE TO ADD
            public var code: String {
                return rawValue
            }
        }
        
        enum Attribute: String {
            case artistTerm = "artistTerm"
            case genreIndex = "genreIndex"
            case albumTerm = "albumTerm"
            //...FULL VERSION REQUIRE TO ADD
            public var code: String {
                return rawValue
            }
        }
        
        enum LookupIDs: String {
            case iTunesId = "id="
            case UPCId = "upc="
            case AMGAlbumId = "amgAlbumId="
            case AMGVideoId = "amgVideoId="
            case AMGArtistId = "amgArtistId="
            case ISBNId = "isbn="
            public var code: String {
                return rawValue
            }
        }
        
    }
    struct Settings {
        static let baseURLString = "https://itunes.apple.com/"
        static let searchPath = "search"
        static let lookupPath = "lookup"
        static let termPath = "term="
        static let countryPath = "&country="
        static let mediaPath = "&media="
        static let entityPath = "&entity="
        static let attributePath = "&attribute="
        static let limitPath = "&limit="
        static let offsetPath = "&offset="
    }
}
