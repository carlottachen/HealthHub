//
//  FitPostsCollectionViewCell.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/22/22.
//

import UIKit

protocol FitPostCellDelegate: AnyObject {
    func commentButtonWasTapped(for fitPost: FitPost)
    func shareButtonWasTapped(for fitPost: FitPost)
    func reportButtonWasTapped(for fitPost: FitPost)
}

class FitPostsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var captionFieldLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    var fitPost: FitPost? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    weak var delegate: FitPostCellDelegate?
    
    func updateViews() {        
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
        shareButton.clipsToBounds = true
        commentButton.layer.cornerRadius = commentButton.frame.height / 2
        commentButton.clipsToBounds = true
        reportButton.layer.cornerRadius = reportButton.frame.height / 2
        reportButton.clipsToBounds = true
        
        guard let fitPost = fitPost else { return }
        usernameLabel.text = "Posted By: \(fitPost.username) on \(fitPost.timestamp.formatDate())"
        captionFieldLabel.text = fitPost.body
        imageView.image = fitPost.fitPhoto
        
        guard let currentUser = UserController.shared.currentUser else { return }
        if fitPost.username == currentUser.username {
            reportButton.isHidden = true
        } else {
            reportButton.isHidden = false
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        guard let fitPost = fitPost else { return }
        delegate?.commentButtonWasTapped(for: fitPost)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let fitPost = fitPost else { return }
        delegate?.shareButtonWasTapped(for: fitPost)
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        guard let fitPost = fitPost else { return }
        delegate?.reportButtonWasTapped(for: fitPost)
    }
    
}
