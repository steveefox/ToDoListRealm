//
//  TasksViewController.swift
//  ToDoListRealm
//
//  Created by Nikita on 7/4/20.
//  Copyright © 2020 Nikita Begletskiy. All rights reserved.
//

import UIKit
import RealmSwift


class TasksViewController: UITableViewController {
    
    var currentList: TaskList!
    var currentTasks: Results<Task>!
    var completedTasks: Results<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentTasks = currentList.tasks.filter("isComplete = false")
        completedTasks = currentList.tasks.filter("isComplete = true")
                
        title = currentList.name
        
        navigationItem.rightBarButtonItems?.append(editButtonItem)
    }

    //MARK: -IB Actions
    @IBAction func addNewTask(_ sender: UIBarButtonItem) {
        showAlert(for: nil, editingModeIsOn: false)
    }
  

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        
        return cell
    }
    
    //MARK: -Table view Delegate
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var task = Task()
        
        if indexPath.section == 0 {
            task = currentTasks[indexPath.row]
        } else {
            task = completedTasks[indexPath.row]
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {_, _ ,_ in
            StorageManager.shared.deleteTask(task)
            tableView.reloadData()
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _ ,_ in
            self.showAlert(for: task, editingModeIsOn: true)
            tableView.reloadData()
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, _ in
            StorageManager.shared.editTask(task, newName: task.name, newNote: task.note, isComplete: true)
            tableView.reloadData()
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        tableView.deselectRow(at: indexPath, animated: true)
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


//MARK: -Extensions
extension TasksViewController {
    
    private func showAlert(for task: Task?, editingModeIsOn: Bool) {
        
        var alert = AlertController()
        
        if !editingModeIsOn {
            alert = AlertController(title: "New Task", message: "What do you want to do?", preferredStyle: .alert)
        } else {
            alert = AlertController(title: "Editing task", message: "Edit your task", preferredStyle: .alert)
        }
        
        alert.actionWithTask(for: task, editingModeIsOn: editingModeIsOn) { newName, newNote in
            
            if !editingModeIsOn {
                let newTask = Task(value: ["name": newName, "note": newNote])
                StorageManager.shared.addTask(in: self.currentList, newTask: newTask)
            } else {
                guard let editingTask = task else { return }
                StorageManager.shared.editTask(editingTask, newName: newName, newNote: newNote)
            }
            self.tableView.reloadData()
        }
        
        present(alert, animated: true)
    }
}
