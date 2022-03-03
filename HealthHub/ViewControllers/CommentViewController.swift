//
//  CommentViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/21/22.
//

import UIKit

class CommentViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addCommentField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var fitPost: FitPost?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.verticalGradient()
        // self.view.backgroundColor = #colorLiteral()
        self.view.backgroundColor = #colorLiteral(red: 0.6522387862, green: 0.8243871331, blue: 0.9779358506, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        fetchComments()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchComments(){
        guard let fitPost = fitPost else { return }
        
        if fitPost.comments.isEmpty {
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
        } else {
            updateViews()
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let commentText = addCommentField.text, !commentText.isEmpty,
              let fitPost = self.fitPost else { return }

        FitPostController.shared.addComment(text: commentText, fitPost: fitPost, completion: { _ in
            self.updateViews()
        })
        addCommentField.text = "Comment added!"
        print("Comment added")
    }
    
    func presentCommentAlert() {
        let alert = UIAlertController(title: "Unable to delete!", message: "You can only delete your own comments!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fitPost?.comments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        guard let fitPost = fitPost else { return cell }
        let comment = fitPost.comments[indexPath.row]
        let header = "\(comment.username) at \(comment.timestamp.formatDate())"
        
        cell.textLabel?.text = header
        cell.detailTextLabel?.text = comment.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard fitPost?.comments[indexPath.row].username == UserController.shared.currentUser?.username else { presentCommentAlert() ; return }

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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
