//
//  MovieCollectionViewCell.swift
//  MovieBank
//
//  Created by Rahma Agustina on 23/01/26.
//

import UIKit
import Kingfisher

class MovieCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieCollectionViewCell"
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        ratingLabel.text = "⭐️ \(String(format: "%.1f", movie.voteAverage))"
        
        if let url = movie.posterURL {
            posterImageView.kf.setImage(
                with: url,
                options: [.transition(.fade(0.2))]
            )
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
    }
}
