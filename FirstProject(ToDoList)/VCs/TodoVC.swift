//
//  TodoVC.swift
//  FirstProject(ToDoList)
//
//  Created by Duaa Bukhari on 28/08/2022.
//

import UIKit

class TodoVC: UIViewController {

    var todoArray : [TodoStruct] = [
//        TodoStruct(title: "Code",image: UIImage(named: "CodeImage"), details: "Swift Bootcamp")
    ]
    
    @IBOutlet weak var todoTableView: UITableView!
    
    override func viewDidLoad() {
        self.todoArray = TodoStorage.getTodo()
        super.viewDidLoad()
        //MARK: Notifications
        //recieving notification from NewTodoVC
        NotificationCenter.default.addObserver(self, selector: #selector(newTodoAdded), name: NSNotification.Name(rawValue: "NewTodoAdded"), object: nil)
        //edit
        NotificationCenter.default.addObserver(self, selector: #selector(currentTodoEdited), name: NSNotification.Name(rawValue: "CurrentTodoEdited"), object: nil)
        //delete
        NotificationCenter.default.addObserver(self, selector: #selector(todoDeleted), name: NSNotification.Name(rawValue: "TodoDeleted"), object: nil)
        
        todoTableView.dataSource = self
        todoTableView.delegate = self
    }
    
    //when recieving notification
    @objc func newTodoAdded(notification: Notification) {
        //add the object to the array
        if let myTodo = notification.userInfo?["AddedTodo"] as? TodoStruct {
            todoArray.append(myTodo)
            //update TableView
            todoTableView.reloadData()
            //store in database
            TodoStorage.storeTodo(todo: myTodo)
        }
    }
    
    @objc func currentTodoEdited(notification: Notification) {
        if let todo = notification.userInfo?["EditedTodo"] as? TodoStruct {
            if let index = notification.userInfo?["EditedTodoIndex"] as? Int {
                todoArray[index] = todo
                todoTableView.reloadData()
                TodoStorage.updateTodo(todo: todo, index: index)
            }
        }
    }
    
    @objc func todoDeleted(notification: Notification) {
        if let index = notification.userInfo?["DeletedTodoIndex"] as? Int {
            todoArray.remove(at: index)
            todoTableView.reloadData()
            //delete todo from database
            TodoStorage.deleteTodo(index: index)
        }
    
    }
    
    
    
}

extension TodoVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as! TodoCell
        cell.todoTitleLable.text = todoArray[indexPath.row].title
        if todoArray[indexPath.row].image != nil {
            cell.todoImageView.image = todoArray[indexPath.row].image
        } else {
            cell.todoImageView.image = UIImage(systemName: "plus")
        }
        
//        cell.todoImageView.layer.cornerRadius = cell.todoImageView.frame.width / 2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let todo = todoArray[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as? TodoDetailsVC
        if let viewController = vc {
            viewController.todo = todo
            viewController.index = indexPath.row 
            navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
}
