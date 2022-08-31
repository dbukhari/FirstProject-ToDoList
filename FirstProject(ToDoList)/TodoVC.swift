//
//  TodoVC.swift
//  FirstProject(ToDoList)
//
//  Created by Duaa Bukhari on 28/08/2022.
//

import UIKit
import CoreData

class TodoVC: UIViewController {

    var todoArray : [TodoStruct] = [
//        TodoStruct(title: "Code",image: UIImage(named: "CodeImage"), details: "Swift Bootcamp")
    ]
    
    @IBOutlet weak var todoTableView: UITableView!
    
    override func viewDidLoad() {
        self.todoArray = getTodo()
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
            storeTodo(todo: myTodo)
        }
    }
    
    @objc func currentTodoEdited(notification: Notification) {
        if let todo = notification.userInfo?["EditedTodo"] as? TodoStruct {
            if let index = notification.userInfo?["EditedTodoIndex"] as? Int {
                todoArray[index] = todo
                todoTableView.reloadData()
                updateTodo(todo: todo, index: index)
            }
        }
    }
    
    @objc func todoDeleted(notification: Notification) {
        if let index = notification.userInfo?["DeletedTodoIndex"] as? Int {
            todoArray.remove(at: index)
            todoTableView.reloadData()
            //delete todo from database
            deleteTodo(index: index)
        }
    
    }
    
    //MARK: Core Data
    //Send data to database
    func storeTodo(todo : TodoStruct) {
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let todoEntity = NSEntityDescription.entity(forEntityName: "TodoEntity", in: managedContext)!
        
        let todoObject = NSManagedObject.init(entity: todoEntity, insertInto: managedContext)
        
        todoObject.setValue(todo.title, forKey: "title")
        todoObject.setValue(todo.details, forKey: "details")
        
        if let image = todo.image {
            let imageData = image.pngData()
            todoObject.setValue(imageData, forKey: "image")
        }
        
        do {
            try managedContext.save()
        } catch {
            print("Error...")
        }
    }
    //retrieve data from database
    func getTodo() -> [TodoStruct] {
        var todos: [TodoStruct] = []
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoEntity")
        
        do {
            let result = try context.fetch(fetchRequest) as! [NSManagedObject]
            for managedTodo in result {
                let title = managedTodo.value(forKey: "title") as? String
                let details = managedTodo.value(forKey: "details") as? String
                
                var todoImage : UIImage? = nil
                if let imageFromContext = managedTodo.value(forKey: "image") as? Data {
                    todoImage = UIImage(data: imageFromContext)
                }
                
                let todo = TodoStruct(title: title ?? "", image: todoImage, details: details ?? "")
                todos.append(todo)
            }
        } catch {
            print("Error...")
        }
        return todos
    }
    //Update data
    func updateTodo(todo : TodoStruct, index : Int) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoEntity")
        
        do {
            let result = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            result[index].setValue(todo.title, forKey: "title")
            result[index].setValue(todo.details, forKey: "details")

            if let image = todo.image {
                let imageData = image.pngData()
                result[index].setValue(imageData, forKey: "image")
            }
            
            try context.save()
            
        } catch {
            print("Error...")
        }
    }
    //Delete data
    func deleteTodo(index : Int) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoEntity")
        
        do {
            let result = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            let todoToDelete = result[index]
            context.delete(todoToDelete)
            
            try context.save()
            
        } catch {
            print("Error...")
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
