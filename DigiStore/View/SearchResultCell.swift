//
//  SearchResultCell.swift
//  DigiStore
//
//  Created by Milad Nourizade on 7/12/18.
//  Copyright © 2018 Milad Nourizade. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 87/255, green: 148/255, blue: 255/255, alpha: 0.5)
        
        selectedBackgroundView = selectedView
    }
    

    
}
