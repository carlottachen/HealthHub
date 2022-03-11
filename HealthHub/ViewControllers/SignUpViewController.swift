//
//  SignUpViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/14/22.
//

import UIKit

class SignUpViewController: UIViewController {

    var profilePhoto: UIImage?
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var photoContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.verticalGradient()
        setupViews()
        fetchUser()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        
        UserController.shared.fetchUsername(with: username) { result in
            switch result {
            case .success(let users):
                if users.count > 0 {
                    self.usernameTakenAlert()
                } else {
                    UserController.shared.createUser(with: username, profilePhoto: self.profilePhoto) { success in
                        if success {
                            self.presentPostsVC()
                        }
                    }
                }
            case .failure(_):
                print("Error")
            }
        }
    }
    
    func setupViews() {
        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 2
        photoContainerView.clipsToBounds = true
    }
    
    func fetchUser() {
        UserController.shared.fetchUser { success in
            if success {
                self.presentPostsVC() // mark as self when in closure
            }
        }
    }
    
    func usernameTakenAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Username unavailable!", message: "Sorry, that username is taken! Please try another one.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    
    func presentPostsVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "PostList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }

}

extension SignUpViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.profilePhoto = image
    }
}
