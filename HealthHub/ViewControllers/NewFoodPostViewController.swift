//
//  NewFoodPostViewController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/28/22.
//

import UIKit

class NewFoodPostViewController: UIViewController, PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
    
    var image: UIImage?
    
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var bodyTextField: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        setupViews()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let body = bodyTextField.text, !body.isEmpty,
              let image = image else { return }
        
        FoodPostController.shared.savePost(with: body, photo: image) { success in
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
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
}
