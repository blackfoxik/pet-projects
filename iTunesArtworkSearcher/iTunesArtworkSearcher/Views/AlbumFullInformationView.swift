//
//  AlbumFullInformationView.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 30.09.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import UIKit

class AlbumFullInformationView: UIView {

    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var collectionName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var primaryGenreName: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var trackCount: UILabel!
    @IBOutlet weak var tracksTable: UITableView!
    @IBOutlet weak var trackDownloadingIndicator: UIActivityIndicatorView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
