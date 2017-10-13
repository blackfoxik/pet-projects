//
//  ArtworkSearchView.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 30.09.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import UIKit

class ArtworkSearchView: UIView, UICollectionViewDelegate {
    @IBOutlet weak var artworkSearchBar: UISearchBar! 
    
    @IBOutlet weak var albumsSearchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var artworkCollectionView: UICollectionView!
    
    let reuseCellIdentifier = Settings.reuseCellIdentifier
    let cellImagePlaceholder = Settings.cellImagePlaceholder
    var partialDataProviderDelegate: PartialDataProviderDelegate?
    
    private let sectionInsets = UIEdgeInsets(top: Settings.EdgeInsets.top, left: Settings.EdgeInsets.left, bottom: Settings.EdgeInsets.bottom, right: Settings.EdgeInsets.right)
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension ArtworkSearchView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (Settings.itemsPerRow + 1)
        let availableWidth = self.frame.width - paddingSpace
        let widthPerItem = availableWidth / Settings.itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) + Settings.OFFSET_THRESHOLD {
            partialDataProviderDelegate?.downloadNextPartOfData()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
        //            let h = self.frame.size.height
        //            albumsSearchingIndicator.bottomAnchor.constraint(
        //                equalTo: self.topAnchor,
        //                constant: 2 * h - h / 4).isActive = true
        //            albumsSearchingIndicator.startAnimating()
        //        }
    }
    
}

// MARK: - Protocol for partial downloading data
/// by this protocol view notify controller that
/// user reach bottom edge and need to get next part of data
///
protocol PartialDataProviderDelegate {
    func downloadNextPartOfData()
}

extension ArtworkSearchView {
    struct Settings {
        static let reuseCellIdentifier: String = "AlbumCell"
        static let cellImagePlaceholder: String = "placeholder.png"
        static var itemsPerRow: CGFloat {
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                return 5
            }
            return 3
        }
        static let OFFSET_THRESHOLD: CGFloat = 30
        struct EdgeInsets {
            static let top: CGFloat = 50.0
            static let left: CGFloat = 20.0
            static let bottom: CGFloat = 50.0
            static let right: CGFloat = 20.0
        }
    }
}
