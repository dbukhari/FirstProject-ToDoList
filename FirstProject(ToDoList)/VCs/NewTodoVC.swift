//
//  NewTodoVC.swift
//  FirstProject(ToDoList)
//
//  Created by Duaa Bukhari on 29/08/2022.
//

import UIKit

class NewTodoVC: UIViewController {

    var isCreationScreen = true
    var editedTodo : TodoStruct?
    var editedTodoIndex : Int?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var todoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //changes when click Edit Button
        if isCreationScreen == false {
            mainButton.setTitle("Edit", for: .normal)
            navigationItem.title = "Edit task"
            if let todo = editedTodo {
                titleTextField.text = todo.title
                detailsTextView.text = todo.details
                todoImageView.image = todo.image
            }
        }
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        if isCreationScreen {
            let todo = TodoStruct(title: titleTextField.text!, image: todoImageView.image, details: detailsTextView.text!)
            
            //sending notification to TodoVC
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewTodoAdded"), object: nil, userInfo: ["AddedTodo": todo])
            
            //Alert and AlertAction
            let alert = UIAlertController(title: "Added", message: "New task has been added sucsessfuly.", preferredStyle: .alert)
            let closeActionButton = UIAlertAction(title: "Done", style: .default) { _ in
                self.tabBarController?.selectedIndex = 0
                self.titleTextField.text = ""
                self.detailsTextView.text = ""
            }
            alert.addAction(closeActionButton)
            present(alert, animated: true, completion: nil)
            //
          
        } else {
            //edit
            let todo = TodoStruct(title: titleTextField.text!, image: todoImageView.image, details: detailsTextView.text)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CurrentTodoEdited"), object: nil, userInfo: ["EditedTodo": todo, "EditedTodoIndex": editedTodoIndex])
            
            //Alert and AlertAction
            let alert = UIAlertController(title: "Edited", message: "Edited sucsessfuly.", preferredStyle: .alert)
            let closeActionButton = UIAlertAction(title: "Done", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
                self.titleTextField.text = ""
                self.detailsTextView.text = ""
            }
            alert.addAction(closeActionButton)
            present(alert, animated: true, completion: nil)
            //
        }
    }
    
    @IBAction func changeButtonClicked(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
}

extension NewTodoVC : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        dismiss(animated: true)
        todoImageView.image = image
    }
    
}
