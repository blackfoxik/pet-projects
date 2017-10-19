//
//  Track.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 04.10.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import Foundation
import UIKit

class Track {
    
    private(set) var kind: String?
    private(set) var artistId: String?
    private(set) var collectionId: String?
    private(set) var trackId: String?
    private(set) var artistName: String?
    private(set) var collectionName: String?
    private(set) var trackName: String?
    private(set) var collectionCensoredName: String?
    private(set) var trackCensoredName: String?
    private(set) var artistViewUrl: String?
    private(set) var collectionViewUrl: String?
    private(set) var trackViewUrl: String?
    private(set) var previewUrl: String?
    private(set) var artworkUrl60: String?
    private(set) var artworkUrl100: String?
    private(set) var collectionPrice: String?
    private(set) var trackPrice: String?
    private(set) var collectionExplicitness: String?
    private(set) var trackExplicitness: String?
    private(set) var discCount: String?
    private(set) var discNumber: String?
    private(set) var trackCount: String?
    private(set) var trackNumber: String?
    private(set) var trackTimeMillis: Double?
    private(set) var country: String?
    private(set) var currency: String?
    private(set) var primaryGenreName: String?
    private(set) var isStreamable: Bool?
    private(set) var artworkImage60: UIImage?
    private(set) var artworkImage100: UIImage?
    
    
    // MARK: - function getTracksFrom
    /// Creates array of Tracks with specific 'trackId'
    /// - Parameters:
    ///   - iTunesResult: An iTunes result array
    static func getTracksFrom(iTunesResult: [Any]) -> [Track] {
        var tracks = [Track]()
        print(iTunesResult)
        if iTunesResult.count > 0 {
            for curiTunesItem in iTunesResult {
                if let curiTunesItem = curiTunesItem as? Dictionary<String, Any>,
                    let wrapperType = curiTunesItem["wrapperType"] as? String {
                    if wrapperType == "track" {
                        if let kind = curiTunesItem["kind"] as? String,
                            let artistId = curiTunesItem["artistId"] as? Int,
                            let collectionId = curiTunesItem["collectionId"] as? Int,
                            let trackId = curiTunesItem["trackId"] as? Int,
                            let artistName = curiTunesItem["artistName"] as? String,
                            let collectionName = curiTunesItem["collectionName"] as? String,
                            let trackName = curiTunesItem["trackName"] as? String,
                            let collectionCensoredName = curiTunesItem["collectionCensoredName"] as? String,
                            let trackCensoredName = curiTunesItem["trackCensoredName"] as? String,
                            let artistViewUrl = curiTunesItem["artistViewUrl"] as? String,
                            let collectionViewUrl = curiTunesItem["collectionViewUrl"] as? String,
                            let trackViewUrl = curiTunesItem["trackViewUrl"] as? String,
                            let previewUrl = curiTunesItem["previewUrl"] as? String,
                            let artworkUrl60 = curiTunesItem["artworkUrl60"] as? String,
                            let artworkUrl100 = curiTunesItem["artworkUrl100"] as? String,
                            let collectionPrice = curiTunesItem["collectionPrice"] as? Double,
                            let trackPrice = curiTunesItem["trackPrice"] as? Double,
                            let collectionExplicitness = curiTunesItem["collectionExplicitness"] as? String,
                            let trackExplicitness = curiTunesItem["trackExplicitness"] as? String,
                            let discCount = curiTunesItem["discCount"] as? Int,
                            let discNumber = curiTunesItem["discNumber"] as? Int,
                            let trackCount = curiTunesItem["trackCount"] as? Int,
                            let trackNumber = curiTunesItem["trackNumber"] as? Int,
                            let trackTimeMillis = curiTunesItem["trackTimeMillis"] as? Double,
                            let country = curiTunesItem["country"] as? String,
                            let currency = curiTunesItem["currency"] as? String,
                            let primaryGenreName = curiTunesItem["primaryGenreName"] as? String,
                            let isStreamable = curiTunesItem["isStreamable"] as? Bool
                        {
                            let stringTrackId = String(trackId)
                            let track = Track(trackId: stringTrackId)
                            track.kind = kind
                            track.artistId = String(artistId)
                            track.collectionId = String(collectionId)
                            track.trackId = String(trackId)
                            track.artistName = artistName
                            track.collectionName = collectionName
                            track.trackName = trackName
                            track.collectionCensoredName = collectionCensoredName
                            track.trackCensoredName = trackCensoredName
                            track.artistViewUrl = artistViewUrl
                            track.collectionViewUrl = collectionViewUrl
                            track.trackViewUrl = trackViewUrl
                            track.previewUrl = previewUrl
                            track.artworkUrl60 = artworkUrl60
                            track.artworkUrl100 = artworkUrl100
                            track.collectionPrice = String(collectionPrice)
                            track.trackPrice = String(trackPrice)
                            track.collectionExplicitness = collectionExplicitness
                            track.trackExplicitness = trackExplicitness
                            track.discCount = String(discCount)
                            track.discNumber = String(discNumber)
                            track.trackCount = String(trackCount)
                            track.trackNumber = String(trackNumber)
                            track.trackTimeMillis = trackTimeMillis
                            track.country = country
                            track.currency = currency
                            track.primaryGenreName = primaryGenreName
                            track.isStreamable = isStreamable
                            tracks.append(track)
                        } else {
                            //print(curiTunesItem )
                            //error during creation track
                        }
                    }
                }
            }
        }
        return tracks
    }
    
    // MARK: - Init
    /// Creates an Track with specific 'trackId'
    /// - Parameters:
    ///   - trackId: An ID which used by iTunes for this track
    private init (trackId: String) {
        self.trackId = trackId
    }
    
}
