//
//  TrackTableViewCell.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 05.10.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet weak var trackNumber: UILabel!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var trackTime: UILabel!
    @IBOutlet weak var playButtom: UIButton!
    var delegate: PlayDemoMusicDelegate?
    @IBAction func playDemo(_ sender: UIButton) {
        delegate?.playDemoMusic(by: self.tag) 
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

//protocol for playing DEMO
protocol PlayDemoMusicDelegate {
    func playDemoMusic(by numberOfTrack: Int)
}



