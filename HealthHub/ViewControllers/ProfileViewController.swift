//
//  ProfileViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/21/22.
//
// fetchedPost.userReference?.recordID == UserController.shared.currentUser?.recordID

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fitPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilePostCell", for: indexPath) as? ProfilePostCollectionViewCell else { return UICollectionViewCell() }
        
        let fitPost = self.fitPosts[indexPath.row]
        cell.fitPost = fitPost
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width / 3.2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    
    @IBOutlet weak var displayProfileImage: UIImageView!
    @IBOutlet weak var profileImageView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var profilePhoto: UIImage?
    
    static let shared = ProfileViewController()
    var fitPosts: [FitPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @objc func loadData() {
        FitPostController.shared.fetchMyPosts { result in
            switch result {
            case .success(let fitPosts):
                self.fitPosts = fitPosts ?? []
                self.updateViews()
            case .failure(_):
                print("Not loading data")
            }
        }
    }
    
    func setupViews() {
        displayProfileImage.layer.cornerRadius = displayProfileImage.frame.height / 2
        displayProfileImage.clipsToBounds = true
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true

        let username = UserController.shared.currentUser?.username
        let image = UserController.shared.currentUser?.profilePhoto
        displayProfileImage.image = image
        usernameLabel.text = username

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
        
        if segue.identifier == "toPostDetails" {
            guard let destination = segue.destination as? EditPostsViewController,
                  let cell = sender as? ProfilePostCollectionViewCell,
                  let indexPath = collectionView.indexPath(for: cell) else { return }
             let fitPost = self.fitPosts[indexPath.row]
             destination.fitPost = fitPost
         }
     }
}

extension ProfileViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.profilePhoto = image
    }
}
