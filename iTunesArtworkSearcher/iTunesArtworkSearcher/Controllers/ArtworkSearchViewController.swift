//
//  ViewController.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 30.09.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ArtworkSearchViewController: UIViewController {
    // view for this controller
    @IBOutlet var artworkSearchView: ArtworkSearchView!
    //model for this app is array of albums
    private var searches = [Album]()
    //previousSearchTerm is used to distingush the same searching
    private var previousSearchTerm: String?
    
    //API iTunes supports count of item in result in range 1-200
    private let LIMIT_OF_SEARCHING_RESULTS: Int = 25
    
    //For supporting partial downloading
    private let OFFSET: Int = 25
    private var countOfRefreshing: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set this controller as delegate for searchBar
        artworkSearchView.artworkSearchBar.delegate = self
        
        //set this controller as DataSource for CollectionView
        artworkSearchView.artworkCollectionView.dataSource = self
        
        //set artworkSearchView as delegate for artworkCollectionView
        //this allow us to keep the code responsible for how view looks in view
        artworkSearchView.artworkCollectionView.delegate = artworkSearchView
        // Do any additional setup after loading the view, typically from a nib.
        
        //for partial downloading
        artworkSearchView.partialDataProviderDelegate = self
        
        //for autoresize album cells after rotation device
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumFullInformationViewController {
            if let cell = sender as? AlbumCollectionViewCell {
                destination.album = cell.album
                destination.navigationItem.title = cell.album?.collectionName
            }
        }
    }
}

//This extension for UISearchBar interaction code and calling function for searching
extension ArtworkSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        artworkSearchView.artworkSearchBar.endEditing(true)
        
        if isNewSearch() {
            cleanPreviuosResults()
            //search for albums
            artworkSearchView.albumsSearchingIndicator.startAnimating()
            performSearchForNextPartOfData()
        }
    }
    
    //This is the 'core' function which uses iTunes API to get albums by search term
    private func performSearchForNextPartOfData() {
        artworkSearchView.albumsSearchingIndicator.startAnimating()
        let term = self.artworkSearchView.artworkSearchBar.text!
        let queue = DispatchQueue.global(qos: .userInitiated)
        let offset = OFFSET * countOfRefreshing + countOfRefreshing
        queue.async {
            let searcher = iTunes(session: URLSession.shared)
            searcher.search(for: term,
                            country: nil,
                            media: nil,
                            entity: iTunes.Parameters.Entity.album,
                            attribute: nil,
                            limit: self.LIMIT_OF_SEARCHING_RESULTS,
                            offset: offset)
            {result, error in
                if error != "" {
                    self.showErrorAlert(with: "Error while trying to get albums \(error)", error: nil)
                } else {
                    
                    DispatchQueue.main.async {
                        var currentPartOfAlbums: [Album] = Album.getAlbumsWithoutImages(iTunesResult: result)
                        
                        if currentPartOfAlbums.isEmpty {
                            self.notifyUser()
                            self.artworkSearchView.albumsSearchingIndicator.stopAnimating()
                            return
                        }
                        currentPartOfAlbums.sort(by: { return $0.collectionName! < $1.collectionName!})
                        //make indexes for putting new albums in CollectionView
                        let indexes = self.makeIndexPathsForInsertionInAlbumCollection(countOfAlbumsInCurrentPart: currentPartOfAlbums.count)
                        //insert new Albums in searches
                        self.searches.insert(contentsOf: currentPartOfAlbums, at: self.searches.count)
                        //insert new albums into CollectionView
                        self.artworkSearchView.artworkCollectionView.insertItems(at: indexes)
                        self.artworkSearchView.albumsSearchingIndicator.stopAnimating()
                        self.updateResultsInfo()
                    }
                }
            }
        }
    }
    
    //This function creates IndexPaths for new part of Albums
    private func makeIndexPathsForInsertionInAlbumCollection(countOfAlbumsInCurrentPart: Int) -> [IndexPath] {
        var indexes = [IndexPath]()
        for albumNumberInCurrentPartOfAlbums in 0..<countOfAlbumsInCurrentPart {
            let row = self.searches.count + albumNumberInCurrentPartOfAlbums
            let index = IndexPath(row: row, section: 0)
            indexes.append(index)
        }
        return indexes
    }
    
    //Notifies user about search results
    private func notifyUser() {
        if self.searches.count > 0 {
            self.notifyUserThereIsNoMoreResult()
        } else {
            self.notifyUserThereIsNoResult()
        }
    }
}


//This extension implements required functions for UICollectionViewDataSource protocol
extension ArtworkSearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = artworkSearchView.artworkCollectionView.dequeueReusableCell(withReuseIdentifier: artworkSearchView.reuseCellIdentifier, for: indexPath)
        if let albumCell = cell as? AlbumCollectionViewCell {
            let album = searches[indexPath.row]
            albumCell.artistName.text = album.collectionName
            let url = URL(string: album.artworkUrl100!)
            albumCell.albumPreviewImage.af_setImage(withURL: url!,
                                                    placeholderImage: UIImage(named: artworkSearchView.cellImagePlaceholder),
                                                    filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: albumCell.frame.size, radius: 20.0),
                                                    //filter: nil,
                imageTransition: .crossDissolve(0.2))
            { response in
                if album.artworkImage100 == nil && response.result.isSuccess {
                    album.artworkImage100 = response.result.value
                }
            }
            albumCell.album = album
            return albumCell
        }
        return cell
    }
    
}

//This extension supports receiving calls for next downloading part of data from view
extension ArtworkSearchViewController: PartialDataProviderDelegate {
    func downloadNextPartOfData() {
        countOfRefreshing += 1
        performSearchForNextPartOfData()
    }
}

//This extension for supporting private functions
extension ArtworkSearchViewController {
    
    //This function is called when device was rotated (for autoresize album cells)
    @objc private func rotated() {
        artworkSearchView.artworkCollectionView.reloadData()
    }
    
    //This fuction checks whether is search new or not
    private func isNewSearch() -> Bool {
        if artworkSearchView.artworkSearchBar.text != nil, artworkSearchView.artworkSearchBar.text! != "" {
            if previousSearchTerm != nil {
                if previousSearchTerm! == artworkSearchView.artworkSearchBar.text! {
                    return false
                } else {
                    previousSearchTerm = artworkSearchView.artworkSearchBar.text!
                }
            }
        }
        return true
    }
    
    //This fuction clears previous result and reload collection of albums
    private func cleanPreviuosResults() {
        searches.removeAll()
        countOfRefreshing = 0
        artworkSearchView.artworkCollectionView.reloadData()
    }
    
    //This fuction notifies user if no results were founded or if there were results set title with count of results
    private func updateResultsInfo() {
        if searches.count > 0 {
            self.navigationItem.title = "\(self.searches.count) albums for \(self.artworkSearchView.artworkSearchBar.text!)"
        } else {
            notifyUserThereIsNoResult()
            self.navigationItem.title = ""
        }
    }
    
    //This fuction notificates users if errors appear 
    private func showErrorAlert(with message: String, error: NSError? = nil) {
        let alertController = UIAlertController(title: "Error", message: "\(message) \(String(describing: error?.localizedDescription)).", preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.default)
        alertController.addAction(closeAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //This fuction notificates users if no result was found
    private func notifyUserThereIsNoResult() {
        let alertController = UIAlertController(title: "No results", message: "There are no results with term \(artworkSearchView.artworkSearchBar.text ?? "") \n Try another one", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            (result: UIAlertAction) -> Void in
            self.previousSearchTerm = nil
            self.searches.removeAll()
            if let view = self.view as? ArtworkSearchView {
                view.artworkSearchBar.becomeFirstResponder()
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //This fuction notificates users if no result was found
    private func notifyUserThereIsNoMoreResult() {
        let alertController = UIAlertController(title: "No more results", message: "There are no more results with term \(artworkSearchView.artworkSearchBar.text ?? "")", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}


//DELAYED FUNCTIONALITY AND DEPRECATED FUNCTIONALITY WHICH IS NOT USED
extension ArtworkSearchViewController {
    //DELAYED FUNCTIONALITY - this function is not used in current version
    private func askUserToClearPreviousResult() {
        let alertController = UIAlertController(title: "Clear results?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            (result: UIAlertAction) -> Void in
            self.previousSearchTerm = nil
            self.searches.removeAll()
            if let view = self.view as? ArtworkSearchView {
                view.artworkCollectionView.reloadData()
            }
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //DELAYED FUNCTIONALITY - this function is not used in current version
    //this function responsible for cancel button
    //I wanted to add this to X button but fast and elegant way for it didn't find
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        askUserToClearPreviousResult()
    }
    ///DELAYED FUNCTIONALITY - this function is not used in current version
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    //DELAYED FUNCTIONALITY - this function is not used in current version
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    //DEPRECATED FUNCTIONALITY - this function is not used more
    @available(*, deprecated, message: "app is used performSearchForNextPartOfData")
    private func performSearch() {
        let term = self.artworkSearchView.artworkSearchBar.text!
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            let searcher = iTunes(session: URLSession.shared)
            searcher.search(for: term,
                            country: nil,
                            media: nil,
                            entity: iTunes.Parameters.Entity.album,
                            attribute: nil,
                            limit: self.LIMIT_OF_SEARCHING_RESULTS,
                            offset: self.OFFSET * self.countOfRefreshing) {result, error in
                                if error != "" {
                                    self.showErrorAlert(with: "Error while trying to get albums \(error)", error: nil)
                                } else {
                                    DispatchQueue.main.async {
                                        self.searches = Album.getAlbumsWithoutImages(iTunesResult: result)
                                        //let refToUpdate = self.updateAt
                                        //self.searches = Album.getAlbumsWithAsyncImagesDownloadingFrom(iTunesResult: result)
                                        //function sort alphabetically wasn't founded in iTunes API (only popularity and recent)
                                        self.searches.sort(by: { return $0.collectionName! < $1.collectionName!})
                                        self.artworkSearchView.albumsSearchingIndicator.stopAnimating()
                                        self.artworkSearchView.artworkCollectionView.reloadData()
                                        self.updateResultsInfo()
                                    }
                                }
            }
        }
    }
}




