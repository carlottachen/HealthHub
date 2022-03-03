//
//  FoodPostsCollectionViewCell.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/28/22.
//

import UIKit

protocol FoodPostCellDelegate: AnyObject {
    func commentButtonWasTapped(for foodPost: FoodPost)
    func shareButtonWasTapped(for foodPost: FoodPost)
    func reportButtonWasTapped(for foodPost: FoodPost)
}

class FoodPostsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var captionFieldLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    var foodPost: FoodPost? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    weak var delegate: FoodPostCellDelegate?
    
    func updateViews() {
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
        shareButton.clipsToBounds = true
        commentButton.layer.cornerRadius = commentButton.frame.height / 2
        commentButton.clipsToBounds = true
        reportButton.layer.cornerRadius = reportButton.frame.height / 2
        reportButton.clipsToBounds = true
        
        guard let foodPost = foodPost else { return }
        usernameLabel.text = "Posted By: \(foodPost.username) on \(foodPost.timestamp.formatDate())"
        captionFieldLabel.text = foodPost.body
        imageView.image = foodPost.foodPhoto
        
        guard let currentUser = UserController.shared.currentUser else { return }
        if foodPost.username == currentUser.username {
            reportButton.isHidden = true
        } else {
            reportButton.isHidden = false
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        guard let foodPost = foodPost else { return }
        delegate?.commentButtonWasTapped(for: foodPost)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let foodPost = foodPost else { return }
        delegate?.shareButtonWasTapped(for: foodPost)
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        guard let foodPost = foodPost else { return }
        delegate?.reportButtonWasTapped(for: foodPost)
    }
    
}
