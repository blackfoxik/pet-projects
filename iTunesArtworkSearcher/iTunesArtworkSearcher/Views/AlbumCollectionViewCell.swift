//
//  AlbumCollectionViewCell.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 30.09.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumPreviewImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    var album: Album?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        albumPreviewImage.af_cancelImageRequest()
        albumPreviewImage.layer.removeAllAnimations()
        albumPreviewImage.image = nil
    }
}

