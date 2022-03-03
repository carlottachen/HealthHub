//
//  NewPostViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/19/22.
//

import UIKit

class NewPostViewController: UIViewController {

    var image: UIImage?
    
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var bodyTextField: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        setupViews()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let body = bodyTextField.text, !body.isEmpty,
              let image = image else { return }
        
        FitPostController.shared.savePost(with: body, photo: image) { success in
            if success {
                self.dismissView()
            }
        }
    }
    
    func setupViews() {
        guard let photoContainerView = photoContainerView else { return }
        photoContainerView.clipsToBounds = true
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
    
}

extension NewPostViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
}
