//
//  AlbumFullInformationViewController.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 30.09.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import UIKit
import AVFoundation

class AlbumFullInformationViewController: UIViewController, UITableViewDelegate {
    //Album which this controller represents
    var album: Album? {
        didSet{
            getAlbumTracks()
        }
    }
    
    //player for playing Demos
    private var player: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        // Do any additional setup after loading the view.
    }
        
}

//This extension implements UITableViewDataSource protocol for table of tracks (UIViewTable)
extension AlbumFullInformationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = album?.tracks?.count ?? 0 > 1 ? "\(album!.tracks!.count) tracks" : "Track"
        return title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return album?.copyright
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album?.tracks?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)
        if let trackCell = cell as? TrackTableViewCell {
            let track = album?.tracks?[indexPath.row]
            trackCell.trackNumber.text = track?.trackNumber
            trackCell.trackName.text = track?.trackName
            trackCell.artistName.text = track?.artistName
            trackCell.trackTime.text = Date.getDurationString(from: track?.trackTimeMillis)
            trackCell.delegate = self
            trackCell.tag = indexPath.row
            if track?.isStreamable! == false {
                trackCell.playButtom.isHidden = true
            }
            return trackCell
        }
        return cell
    }
    
}

//This extension contains main functionality
extension AlbumFullInformationViewController {
    
    private func setProperties() {
        if let view = self.view as? AlbumFullInformationView {
            if album?.artworkImage100 != nil {
                view.albumCover.image = album?.artworkImage100
                view.artistName.text = album?.artistName
                view.collectionName.text = album?.collectionName
                view.primaryGenreName.text = album?.primaryGenreName
                view.releaseDate.text = Date.getStringDate(with: album?.releaseDate, inFormat: nil, fromFormat: nil)
                view.tracksTable.dataSource = self
            }
        }
    }
    
    private func getAlbumTracks() {
        if album?.tracks == nil {
            if let view = self.view as? AlbumFullInformationView {
                view.trackDownloadingIndicator.startAnimating()
            }
            
            let queue = DispatchQueue.global(qos: .userInitiated)
            queue.async {
                //to get album tracks we should call something like this
                // https://itunes.apple.com/lookup?id=318675016&entity=song
                let searcher = iTunes(session: URLSession.shared)
                searcher.lookup(by: (self.album?.collectionId)!,
                                typeId: iTunes.Parameters.LookupIDs.iTunesId,
                                entity: iTunes.Parameters.Entity.song) { result, error in
                                    if error != "" {
                                        self.showErrorAlert(with: "Error while trying to get tracks \(error)", error: nil)
                                    } else {
                                        DispatchQueue.main.async {
                                            self.album?.tracks = Track.getTracksFrom(iTunesResult: result)
                                            
                                            if let view = self.view as? AlbumFullInformationView {
                                                view.tracksTable.reloadData()
                                                view.trackDownloadingIndicator.stopAnimating()
                                            }
                                        }
                                    }
                }
            }
        }
    }
}

//This extension for playing Demo functionality
//There is room for future improvements (animation play button, pause, progress bar for loading Demo etc.)
extension AlbumFullInformationViewController: PlayDemoMusicDelegate, AVAudioPlayerDelegate {
    func playDemoMusic(by numberOfTrack: Int) {
        if let view = self.view as? AlbumFullInformationView {
            view.trackDownloadingIndicator.startAnimating()
        }
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            do {
                if let track = self.album?.tracks?[numberOfTrack],
                    let url = URL(string: track.previewUrl!){
                    let data = try Data(contentsOf: url)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    try AVAudioSession.sharedInstance().setActive(true)
                    self.player = try AVAudioPlayer(data: data)
                    self.player?.delegate = self
                    self.player!.play()
                }
            } catch let error as NSError {
                self.showErrorAlert(with: "Error while playing track", error: error)
                if let view = self.view as? AlbumFullInformationView {
                    view.trackDownloadingIndicator.stopAnimating()
                }
            }
        }
    }
    
    //This function calls when player finish playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let view = self.view as? AlbumFullInformationView {
            view.trackDownloadingIndicator.stopAnimating()
        }
    }
}

//This extension implements supporting functions like showing errors
extension AlbumFullInformationViewController {
    
    private func showErrorAlert(with message: String, error: NSError? = nil) {
        let alertController = UIAlertController(title: "Error", message: "\(message) \(String(describing: error?.localizedDescription)).", preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.default)
        alertController.addAction(closeAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

//This extension for convinience when work with Track Durations and Album release date
extension Date {
    static func getDurationString(from millis: Double?) -> String {
        if millis != nil {
            let countOfSeconds = millis! / 1000
            let end = Date(timeIntervalSince1970: countOfSeconds )
            var format = ""
            //we can use date components and Calendar but it too expensive
            switch countOfSeconds {
            case 3600..<86400:
                format = "H.mm:ss"
            default:
                format = "m:ss"
            }
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = format
            return formatter.string(from: end)
        }
        return "0:00"
    }
    
    static func getStringDate(with originalStringDate: String?, inFormat targetFormat: String?, fromFormat originalFormat: String?) -> String {
        if originalStringDate != nil {
            let formatter = DateFormatter()
            //"yyyy-MM-ddTHH:mm:ssZ"
            formatter.dateFormat = originalFormat ?? "yyyy-MM-dd'T'HH:mm:ssZ"
            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            let date = formatter.date(from: originalStringDate!)
            if date != nil {
                formatter.dateFormat = targetFormat ?? "MMM d, yyyy"
                let newStringDate = formatter.string(from: date!)
                return newStringDate
            }
        }
        return ""
    }
}

