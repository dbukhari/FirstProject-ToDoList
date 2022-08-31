//
//  TodoDetailsVC.swift
//  FirstProject(ToDoList)
//
//  Created by Duaa Bukhari on 29/08/2022.
//

import UIKit

class TodoDetailsVC: UIViewController {

    var todo: TodoStruct!
    var index : Int!
    
    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var todoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if todo.image != nil {
            todoImageView.image = todo.image
        } else {
            todoImageView.image = UIImage(systemName: "plus")
        }
        
//        detailsLabel.text = todo.details
//        todoTitleLabel.text = todo.title
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentTodoEdited), name: NSNotification.Name(rawValue: "CurrentTodoEdited"), object: nil)
    }
    
    @objc func currentTodoEdited(notification: Notification) {
        if let todo = notification.userInfo?["EditedTodo"] as? TodoStruct {
            self.todo = todo
//            detailsLabel.text = todo.details
//            todoTitleLabel.text = todo.title
            setupUI()
        }
    }
    
    func setupUI() {
        detailsLabel.text = todo.details
        todoTitleLabel.text = todo.title
        todoImageView.image = todo.image
    }

    @IBAction func editTodoButtonClicked(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "NewTodoVC") as? NewTodoVC {
            viewController.isCreationScreen = false
            viewController.editedTodo = todo
            viewController.editedTodoIndex = index
            navigationController?.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        //confirm deletion
        let confirmDeletion = UIAlertController(title: "Confirm", message: "Do you want to delete task?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { alert in
            //
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TodoDeleted"), object: nil, userInfo: ["DeletedTodoIndex": self.index])
            
            let alert = UIAlertController(title: "Deleted", message: "Task has been deleted sucsessfully", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Done", style: .default) { alert in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(closeAction)
            self.present(alert, animated: true)
        }
        confirmDeletion.addAction(confirmAction)
        //canel
        let cancelDeletion = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        confirmDeletion.addAction(cancelDeletion)
        
        present(confirmDeletion, animated: true)
        
        
        
    }
}
