//
//  FitPostListCollectionViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/17/22.
//

import UIKit

class FitPostListCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fitPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as? FitPostsCollectionViewCell else { return UICollectionViewCell() }

        cell.contentView.backgroundColor = #colorLiteral(red: 0.7900072932, green: 0.9101041555, blue: 0.9703480601, alpha: 1)
        
        let fitPost = self.fitPosts[indexPath.row]
        cell.fitPost = fitPost
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
    static let shared = FitPostListCollectionViewController()
    var fitPosts: [FitPost] = []
    
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
        FitPostController.shared.fetchPosts { result in
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
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        refresh.attributedTitle = NSAttributedString(string: "Refreshing Fitness Feed!")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        myCollectionView.addSubview(refresh)
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.myCollectionView.reloadData()
            self.refresh.endRefreshing()
        }
    }
}

extension FitPostListCollectionViewController: FitPostCellDelegate {
    
    func commentButtonWasTapped(for fitPost: FitPost) {
        guard let destination = UIStoryboard(name: "PostList", bundle: nil).instantiateViewController(withIdentifier: "commentsVC") as? CommentViewController else { return }
        
        destination.fitPost = fitPost
        destination.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func shareButtonWasTapped(for fitPost: FitPost) {
        guard let fitPhoto = fitPost.fitPhoto else { return }
        let caption = fitPost.body
        let shareSheet = UIActivityViewController(activityItems: [fitPhoto, caption], applicationActivities: nil)
        present(shareSheet, animated: true)
    }
    
    func reportButtonWasTapped(for fitPost: FitPost) {
        let alert = UIAlertController(title: "Report this post?", message: "Are you sure you want to report this post for inappropriate content?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let reportAction = UIAlertAction(title: "REPORT!", style: .default) { _ in
            if fitPost.reportCount < 5 {
                fitPost.reportCount += 1
                
                FitPostController.shared.update(fitPost) { result in
                    switch result {
                    case .success(_):
                        print("Reports on this post:\(fitPost.reportCount)")
                    case .failure(_):
                        print("Error reporting post")
                    }
                }
            } else {
                FitPostController.shared.delete(fitPost) { success in
                    if success {
                        self.loadData()
                    } else {
                        print("Error deleting post")
                    }
                }
                print("DELETED")
            }
            self.blockUser(for: fitPost)
        }
        alert.addAction(cancelAction)
        alert.addAction(reportAction)
        self.present(alert, animated: true)
    }
    
    func blockUser(for fitPost: FitPost) {
        let alert = UIAlertController(title: "Block User?", message: "Do you want to block this user?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let blockAction = UIAlertAction(title: "BLOCK!", style: .default) { _ in
            FitPostController.shared.blockUserOfPost(for: fitPost) { success in
                if success {
                    print("OK")
                    self.updateViews()
                } else {
                    print("NOT OK")
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(blockAction)
        self.present(alert, animated: true)
    }
}
