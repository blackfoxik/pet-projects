//
//  TipsViewController.swift
//  iTunesArtworkSearcher
//
//  Created by Anton on 13.10.17.
//  Copyright © 2017 Anton. All rights reserved.
//

import UIKit

class TipsViewController: UIViewController {
    
    @IBOutlet weak var showTipsWindowAgain: UISwitch!
    let widthScaleFactor: CGFloat = 0.8
    let heightScaleFactor: CGFloat = 0.33
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame.size = sizeWithScaleFactor(for: self.view.frame.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.view.frame.size = self.sizeWithScaleFactor(for: size)
            self.view.center = (self.view.superview?.center)!
        }
    }
    
    //Function returns new size with scale factor
    private func sizeWithScaleFactor(for size: CGSize) -> CGSize {
        let heigth = size.height * heightScaleFactor
        let width = size.width * widthScaleFactor
        return CGSize(width: width, height: heigth)
    }
    
}
