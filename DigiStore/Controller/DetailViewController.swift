//
//  DetailViewController.swift
//  DigiStore
//
//  Created by Milad Nourizade on 7/19/18.
//  Copyright © 2018 Milad Nourizade. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    
    var searchResult:SearchResult!
    var downloadTask:URLSessionDownloadTask?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    deinit {
        print("Deinit\(self)")
        downloadTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if searchResult != nil {
            updateUI()
        }
        stretchablePiceButton()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        
        view.tintColor = UIColor(red: 85/255, green: 128/255, blue: 203/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        
        
    }
    
    func updateUI() {
        
        if let artWorkLargUrl = URL(string: searchResult.artworkLargeURL) {
            downloadTask = artworkImageView.loadImage(url: artWorkLargUrl)
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        var priceText:String
        if searchResult.price == 0 {
            priceText = "Free"
        }else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        }else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
            nameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        
        genreLabel.text = searchResult.genre
        kindLabel.text = searchResult.kindForDisplay()
    }
    
    func stretchablePiceButton() {
        
        let priceButtonImage = UIImage(named:"PriceButton")
        
        let insets = UIEdgeInsets(top: 0, left:5, bottom: 0, right: 5)
        let resizableImage = priceButtonImage?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        
        priceButton.setBackgroundImage(resizableImage, for: .normal)
        
    }
    
    @IBAction func openInStore(_ sender: UIButton) {
        if let storeUrl = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(storeUrl, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressHeart(_ sender: Any) {
        if heartButton.isSelected{
            heartButton.isSelected = false
    
            let blackHeart = UIImage(named:"BlackHeart")
            heartButton.setImage(blackHeart, for: .normal)
        }else{
            heartButton.isSelected = true
            
            let redHeart = UIImage(named:"RedHeart")
            heartButton.setImage(redHeart, for: .normal)
        }
    }
    
}

extension DetailViewController:UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension DetailViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
