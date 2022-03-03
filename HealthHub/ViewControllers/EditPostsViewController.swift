//
//  EditPostsViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/22/22.
//

import UIKit

class EditPostsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextView!
    
    var selectedImage: UIImage?

    var fitPost: FitPost? {
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.6522387862, green: 0.8243871331, blue: 0.9779358506, alpha: 1)
        self.hideKeyboardWhenTappedAround()
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let fitPost = fitPost else { return }
        
        FitPostController.shared.fetchComments(for: fitPost) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let comments):
                    fitPost.comments = comments ?? []
                    self.updateViews()
                    print(fitPost.comments.count)
                case .failure(_):
                    print("Error fetching comments")
                }
            }
        }
    }
    
    func updateViews() {
        guard let fitPost = fitPost else { return }
        
        DispatchQueue.main.async {
            self.photoImageView.image = fitPost.fitPhoto
            self.captionTextField.text = fitPost.body
            self.tableView.reloadData()
        }
    }
    
    @IBAction func updatePostButtonTapped(_ sender: Any) {
        guard let text = captionTextField.text, !text.isEmpty else { return }
        if let fitPost = fitPost {
            fitPost.body = text
            FitPostController.shared.update(fitPost) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                    self.updateViews()
                    print("Post updated")
                case .failure(_):
                    print("Issue updating post")
                }
            }
        }
    }
    
    @IBAction func deletePostButtonTapped(_ sender: Any) {
        if let fitPost = fitPost {
            FitPostController.shared.delete(fitPost) { success in
                if success {
                    DispatchQueue.main.async {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Error deleting post")
                }
            }
        }
    }
}

extension EditPostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fitPost?.comments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath)
        
        guard let fitPost = fitPost else { return cell }
        let comment = fitPost.comments[indexPath.row]
        let username = comment.username
        
        cell.textLabel?.text = username
        cell.detailTextLabel?.text = comment.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let fitPost = fitPost else { return }
            let commentToDelete = fitPost.comments[indexPath.row]
            guard let index = fitPost.comments.firstIndex(of: commentToDelete) else { return }
            
            FitPostController.shared.deleteComment(commentToDelete) { success in
                if success {
                    fitPost.comments.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
}
