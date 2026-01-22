//
//  ReviewTableViewCell.swift
//  MovieBank
//
//  Created by Rahma Agustina on 23/01/26.
//

import UIKit
import Kingfisher

class ReviewTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ReviewTableViewCell"

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with review: Review) {
        authorLabel.text = review.author
        reviewLabel.text = review.content
        if let url = review.authorDetails?.avatarURL {
            avatarImageView.kf.setImage(
                with: url,
                options: [.transition(.fade(0.2))]
            )
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
    }
}
