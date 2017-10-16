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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.view.frame.size = self.sizeWithScaleFactor(for: size)
            //self.view.center = CGPoint(x: size.width / 2, y: size.height / 2)
            let sv = self.view.superview!
            self.view.center = (self.view.superview?.center)!
        }
    }
    
    //Function returns new size with scale factor
    private func sizeWithScaleFactor(for size: CGSize) -> CGSize {
        let heigth = size.height * heightScaleFactor
        let width = size.width * widthScaleFactor
        return CGSize(width: width, height: heigth)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
