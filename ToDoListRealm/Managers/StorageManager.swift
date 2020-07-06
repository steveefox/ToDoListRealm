//
//  StorageManager.swift
//  ToDoListRealm
//
//  Created by Nikita on 7/4/20.
//  Copyright © 2020 Nikita Begletskiy. All rights reserved.
//

import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    let realm = try! Realm()
    
    private init() {}
    
    func addTaskList(taskList: TaskList) {
        try! realm.write {
            realm.add(taskList)
        }
    }
    
    func addTask(in taskList: TaskList, newTask: Task) {
        try! realm.write {
            taskList.tasks.append(newTask)
        }
    }
    
    func deleteTaskList(_ taskList: TaskList) {
        try! realm.write {
            realm.delete(taskList)
        }
    }
    
    func deleteTask(_ task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }
    
    func editTaskList(_ taskList: TaskList, newName: String, allIsComplete: Bool = false) {
        if !allIsComplete {
            try! realm.write {
                taskList.name = newName
            }
        } else {
            try! realm.write {
                for task in taskList.tasks {
                    task.isComplete = true
                }
            }
        }
    }
    
    func editTask(_ task: Task, newName: String, newNote: String, isComplete: Bool? = nil ) {
        
        if isComplete == nil {
            try! realm.write {
                task.name = newName
                task.note = newNote
            }
        } else if isComplete != nil {
            try! realm.write {
                if task.isComplete {
                task.isComplete = false
                } else {
                    task.isComplete = true
                }
            }
        }
        
    }
    
    
    
}
