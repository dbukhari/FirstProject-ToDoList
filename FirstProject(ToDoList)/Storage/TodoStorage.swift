//
//  TodoStorage.swift
//  FirstProject(ToDoList)
//
//  Created by Duaa Bukhari on 31/08/2022.
//

import Foundation
import UIKit
import CoreData

class TodoStorage {
    //MARK: Core Data
    //Send data to database
    static func storeTodo(todo : TodoStruct) {
        
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
    static func getTodo() -> [TodoStruct] {
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
    static func updateTodo(todo : TodoStruct, index : Int) {
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
    static func deleteTodo(index : Int) {
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
