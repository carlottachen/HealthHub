//
//  ProfilePostCollectionViewCell.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/22/22.
//

import UIKit

class ProfilePostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var fitPost: FitPost? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    func updateViews() {
        guard let fitPost = fitPost else { return }
        imageView.image = fitPost.fitPhoto
    }
}
