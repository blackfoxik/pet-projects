//
//  Album.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 03.10.17.
//  Copyright © 2017 Anton. All rights reserved.
//
//

import Foundation
import UIKit

class Album {
    
    private(set) var collectionType: String?
    private(set) var artistId: String?
    private(set) var collectionId: String?
    private(set) var artistName: String?
    private(set) var collectionName: String?
    private(set) var collectionCensoredName: String?
    private(set) var collectionViewUrl: String?
    private(set) var artworkUrl60: String?
    private(set) var artworkUrl100: String?
    private(set) var collectionPrice: String?
    private(set) var collectionExplicitness: String?
    private(set) var trackCount: String?
    private(set) var copyright: String?
    private(set) var country: String?
    private(set) var currency: String?
    private(set) var releaseDate: String?
    private(set) var primaryGenreName: String?
    var artworkImage60: UIImage?
    var artworkImage100: UIImage?
    var tracks: [Track]?
    
    // MARK: - function getAlbumsWithoutImages
    /// Creates array of Albums without images, images download by AlamofireImage later 
    /// - Parameters:
    ///   - iTunesResult: An iTunes result array
    static func getAlbumsWithoutImages(iTunesResult: [Any]) -> [Album] {
        var albums = [Album]()
        if iTunesResult.count > 0 {
            for curiTunesItem in iTunesResult {
                if let curiTunesItem = curiTunesItem as? Dictionary<String, Any>,
                    let wrapperType = curiTunesItem["wrapperType"] as? String {
                    if wrapperType == "collection" {
                        if let artistId = curiTunesItem["artistId"] as? Int,
                            let collectionType = curiTunesItem["collectionType"] as? String,
                            let collectionId = curiTunesItem["collectionId"] as? Int,
                            let artistName = curiTunesItem["artistName"] as? String,
                            let collectionName = curiTunesItem["collectionName"] as? String,
                            let collectionCensoredName = curiTunesItem["collectionCensoredName"] as? String,
                            let collectionViewUrl = curiTunesItem["collectionViewUrl"] as? String,
                            let artworkUrl60 = curiTunesItem["artworkUrl60"] as? String,
                            let artworkUrl100 = curiTunesItem["artworkUrl100"] as? String,
                            let collectionPrice = curiTunesItem["collectionPrice"] as? Double,
                            let collectionExplicitness = curiTunesItem["collectionExplicitness"] as? String,
                            let trackCount = curiTunesItem["trackCount"] as? Int,
                            let copyright = curiTunesItem["copyright"] as? String,
                            let country = curiTunesItem["country"] as? String,
                            let currency = curiTunesItem["currency"] as? String,
                            let releaseDate = curiTunesItem["releaseDate"] as? String,
                            let primaryGenreName = curiTunesItem["primaryGenreName"] as? String {
                            
                            let stringAlbumId = String(collectionId)
                            let album = Album(albumId: stringAlbumId)
                            album.collectionType = collectionType
                            album.artistId = String(artistId)
                            album.artistName = artistName
                            album.collectionName = collectionName
                            album.collectionCensoredName = collectionCensoredName
                            album.collectionViewUrl = collectionViewUrl
                            album.artworkUrl60 = artworkUrl60
                            album.artworkUrl100 = artworkUrl100
                            album.collectionPrice = String(collectionPrice)
                            album.collectionExplicitness = collectionExplicitness
                            album.trackCount = String(trackCount)
                            album.copyright = copyright
                            album.country = country
                            album.currency = currency
                            album.releaseDate = releaseDate
                            album.primaryGenreName = primaryGenreName
                            albums.append(album)
                        } else {
                            //print(curiTunesItem )
                            //error during creation album
                        }
                    }
                }
            }
        }
        return albums
    }
    
    // MARK: - Init
    /// Creates an Album client with specific 'albumId'
    /// - Parameters:
    ///   - albumId: An ID which used by iTunes for this album
    private init (albumId: String) {
        self.collectionId = albumId
    }
    
}
