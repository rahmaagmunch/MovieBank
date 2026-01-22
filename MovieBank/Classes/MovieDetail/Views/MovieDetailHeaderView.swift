//
//  MovieDetailHeaderView.swift
//  MovieBank
//
//  Created by Rahma Agustina on 23/01/26.
//

import UIKit
import youtube_ios_player_helper
class MovieDetailHeaderView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var ytVideoPlayerView: YTPlayerView!
    
    static func loadFromNib() -> MovieDetailHeaderView {
        let nib = UINib(nibName: "MovieDetailHeaderView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? MovieDetailHeaderView else {
            fatalError("Cannot load MovieDetailHeaderView from nib")
        }
        return view
    }
}
