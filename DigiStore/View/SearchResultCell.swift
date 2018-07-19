//
//  SearchResultCell.swift
//  DigiStore
//
//  Created by Milad Nourizade on 7/12/18.
//  Copyright © 2018 Milad Nourizade. All rights reserved.
//

import UIKit
var downloadTask:URLSessionDownloadTask?

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    func configure(for searchResult:SearchResult){
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty{
            artistNameLabel.text = "Unknown"
        }else{
            artistNameLabel.text = String(format:"%@ (%@)",searchResult.artistName,
                                          kindForDisplay(kind: searchResult.kind))
        }
        artworkImageView.image = UIImage(named: "placeholder")
        
        if let smallUrl = URL(string: searchResult.artworkSmallURL){
            downloadTask = artworkImageView.loadImage(url: smallUrl)
        }
        
        
    }
    

}
func kindForDisplay(kind:String) -> String {
    switch kind {
    case "album": return "Album"
    case "audiobook": return "Audio Book"
    case "book": return "Book"
    case "ebook": return "E-Book"
    case "feature-movie": return "Movie"
    case "music-video": return "Music Video"
    case "podcast": return "Podcast"
    case "software": return "App"
    case "song": return "Song"
    case "tv-episode": return "TV Episode"
    default: return kind
    }
}
