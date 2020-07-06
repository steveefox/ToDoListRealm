//
//  TaskListViewController.swift
//  ToDoListRealm
//
//  Created by Nikita on 7/4/20.
//  Copyright © 2020 Nikita Begletskiy. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {
    
    var currentTaskLists: Results<TaskList>!
    var taskListsSortedByAZ: Results<TaskList>!
    var taskListSortedByDate: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskListsSortedByAZ = StorageManager.shared.realm.objects(TaskList.self).sorted(byKeyPath: "date", ascending: false)
        taskListSortedByDate = StorageManager.shared.realm.objects(TaskList.self).sorted(byKeyPath: "name", ascending: false)
        currentTaskLists = taskListsSortedByAZ
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        //  Для первой записи данных
//        let shoppingList = TaskList()
//        shoppingList.name = "ShoppingList"
//
//        let milk = Task()
//        milk.name = "Milk"
//        milk.note = "2L"
//
//        let bread = Task()
//        bread.name = "Bread"
//
//        let apples = Task(value: ["name": "Apples", "note": "1kg", "isComplete": false])
//
//        shoppingList.tasks.append(milk)
//        shoppingList.tasks.append(bread)
//        shoppingList.tasks.append(apples)
//
//        DispatchQueue.main.async {
//            StorageManager.shared.save(taskLists: [shoppingList])
//        }
//        let studyList = TaskList()
//        studyList.name = "Study list"
//
//        let swift = Task()
//        swift.name = "Swift"
//        swift.note = "closures"
//        let english = Task(value: ["name": "English", "note": "verbs", "isComplete": true])
//
//        studyList.tasks.append(swift)
//        studyList.tasks.append(english)
//
//        let sportList = TaskList()
//        sportList.name = "Sport"
//
//        let running = Task(value: ["name": "Running", "note": "3 km", "isComplete": true])
//        let jumping = Task(value: ["name": "Jumping", "note": "50 times"])
//
//        sportList.tasks.append(running)
//        sportList.tasks.append(jumping)
//
//        DispatchQueue.main.async {
//            StorageManager.shared.save(taskLists: [studyList, sportList])
//        }
//
//        let relaxList = TaskList()
//        relaxList.name = "Relax"
//
//        let someCinema = Task(value: ["name": "Some Cinema", "note": "at 17:30"])
//        let someRestaurant = Task(value: ["name": "Some Restaurant", "note": "dinner"])
//
//        relaxList.tasks.append(someRestaurant)
//        relaxList.tasks.append(someCinema)
//
//        DispatchQueue.main.async {
//            StorageManager.shared.save(taskLists: [relaxList])
//        }
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    
    //MARK: -IB Actions
    
    @IBAction func addTaskList(_ sender: UIBarButtonItem) {
        showAlert(for: nil, editingModeIsOn: false)
    }
    
    @IBAction func sortingLists(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentTaskLists = taskListsSortedByAZ
            tableView.reloadData()
        default:
            currentTaskLists = taskListSortedByDate
            tableView.reloadData()
        }
    }


    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentTaskLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        
        let currentList = currentTaskLists[indexPath.row]
        let currentTasksInCurrentList = currentTaskLists[indexPath.row].tasks.filter("isComplete = false").count
        cell.textLabel?.text = currentList.name
        if currentTasksInCurrentList > 0 {
            cell.detailTextLabel?.text = "\(currentTasksInCurrentList)"
            cell.detailTextLabel?.textColor = .black
        } else {
            cell.detailTextLabel?.text = "✓"
            cell.detailTextLabel?.textColor = .blue
        }
        return cell
    }
    
    //MARK: -Table view Delegate
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = currentTaskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {_, _ ,_ in
            StorageManager.shared.deleteTaskList(taskList)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _ ,_ in
            self.showAlert(for: taskList, editingModeIsOn: true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, _ in
            StorageManager.shared.editTaskList(taskList, newName: taskList.name, allIsComplete: true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        
        let currentList = currentTaskLists[indexPath.row]
        let tasksVC = segue.destination as! TasksViewController
        tasksVC.currentList = currentList
    }
    
}


//MARK: -Extensions
extension TaskListViewController {
    
    func showAlert(for taskList: TaskList?, editingModeIsOn: Bool) {
        
        var alert = AlertController()
        
        if !editingModeIsOn {
            alert = AlertController(title: "New list", message: "Please create new list of tasks", preferredStyle: .alert)
        } else {
            alert = AlertController(title: "Editing List", message: "Please edit list name", preferredStyle: .alert)
        }
        
        
        alert.actionWithTaskList(for: taskList, editingModeIsOn: editingModeIsOn) { newValue in
            
            if !editingModeIsOn {
                let newTaskList = TaskList(value: ["name": newValue])
                StorageManager.shared.addTaskList(taskList: newTaskList)
            } else {
                guard let taskList = taskList else { return }
                StorageManager.shared.editTaskList(taskList, newName: newValue)
            }
            self.tableView.reloadData()
        }
        
        present(alert, animated: true)
    }
    
}
