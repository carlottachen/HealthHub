//
//  FoodCommentViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/28/22.
//

import UIKit

class FoodCommentViewController: UIViewController {

    @IBOutlet weak var addCommentField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var foodPost: FoodPost?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard let foodPost = foodPost else { return }
        
        if foodPost.comments.isEmpty{
            FoodPostController.shared.fetchComments(for: foodPost) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let comments):
                        foodPost.comments = comments ?? []
                        self.updateViews()
                        print(foodPost.comments.count)
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
              let foodPost = self.foodPost else { return }

        FoodPostController.shared.addComment(text: commentText, foodPost: foodPost, completion: { _ in
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

extension FoodCommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodPost?.comments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCommentCell", for: indexPath)
        
        guard let foodPost = foodPost else { return cell }
        let comment = foodPost.comments[indexPath.row]
        let username = comment.username
        
        cell.textLabel?.text = username
        cell.detailTextLabel?.text = comment.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard foodPost?.comments[indexPath.row].username == UserController.shared.currentUser?.username else { presentCommentAlert() ; return }

        if editingStyle == .delete {
            guard let foodPost = foodPost else { return }
            let commentToDelete = foodPost.comments[indexPath.row]
            guard let index = foodPost.comments.firstIndex(of: commentToDelete) else { return }

            FoodPostController.shared.deleteComment(commentToDelete) { success in
                if success {
                    foodPost.comments.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
}

