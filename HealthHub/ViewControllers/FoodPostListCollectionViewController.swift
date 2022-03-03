//
//  FoodPostListCollectionViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/28/22.
//

import UIKit

class FoodPostListCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FoodPostCellDelegate {
    
    func commentButtonWasTapped(for foodPost: FoodPost) {
        guard let destination = UIStoryboard(name: "PostList", bundle: nil).instantiateViewController(withIdentifier: "foodCommentsVC") as? FoodCommentViewController else { return }
        
        destination.foodPost = foodPost
        destination.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(destination, animated: true)

    }
    
    func shareButtonWasTapped(for foodPost: FoodPost) {
        guard let foodPhoto = foodPost.foodPhoto else { return }
        let caption = foodPost.body
        let shareSheet = UIActivityViewController(activityItems: [foodPhoto, caption], applicationActivities: nil)
        present(shareSheet, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.foodPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as? FoodPostsCollectionViewCell else { return UICollectionViewCell() }
        
        cell.contentView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.9691444831, blue: 0.7800412683, alpha: 1)
        
        let foodPost = self.foodPosts[indexPath.row]
        cell.foodPost = foodPost
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        let height = self.view.frame.height - 75
        return CGSize(width: width, height: height)
    }
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    var refresh: UIRefreshControl = UIRefreshControl()
    static let shared = FoodPostListCollectionViewController()
    var foodPosts: [FoodPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    @objc func loadData() {
        FoodPostController.shared.fetchPosts { result in
            switch result {
            case .success(let foodPosts):
                self.foodPosts = foodPosts ?? []
                self.updateViews()
            case .failure(_):
                print("Not loading data")
            }
        }
    }
    
    func setupViews() {
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        refresh.attributedTitle = NSAttributedString(string: "Refreshing Food Feed!")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        myCollectionView.addSubview(refresh)
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.myCollectionView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    func reportButtonWasTapped(for foodPost: FoodPost) {
        let alert = UIAlertController(title: "Report this post?", message: "Are you sure you want to report this post for inappropriate content?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let reportAction = UIAlertAction(title: "REPORT!", style: .default) { _ in
            if foodPost.reportCount < 5 {
                foodPost.reportCount += 1
                
                FoodPostController.shared.update(foodPost) { result in
                    switch result {
                    case .success(_):
                        print("Reports on this post:\(foodPost.reportCount)")
                    case .failure(_):
                        print("Error reporting post")
                    }
                }
            } else {
                FoodPostController.shared.delete(foodPost) { success in
                    if success {
                        self.loadData()
                    } else {
                        print("Error deleting post")
                    }
                }
                print("DELETED")
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(reportAction)
        self.present(alert, animated: true)
        
        blockUser(for: foodPost)
    }
    
    func blockUser(for foodPost: FoodPost) {
        let alert = UIAlertController(title: "Block User?", message: "Do you want to block this user?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let blockAction = UIAlertAction(title: "BLOCK!", style: .default) { _ in
            FoodPostController.shared.blockUserOfPost(for: foodPost) { success in
                if success {
                    /*
                     
        afsdfasdu[iopirpsdoi[fgp sdofkg psdfk'sd
                     
                     */
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(blockAction)
        self.present(alert, animated: true)
    }
}
