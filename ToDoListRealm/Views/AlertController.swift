//
//  AlertController.swift
//  ToDoListRealm
//
//  Created by Nikita on 7/4/20.
//  Copyright © 2020 Nikita Begletskiy. All rights reserved.
//

import UIKit

class AlertController: UIAlertController {
    
    func actionWithTaskList(for taskList: TaskList?, editingModeIsOn: Bool, completionHandler: @escaping (String) -> Void) {
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completionHandler(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(cancelAction)
        addAction(saveAction)
        addTextField { textField in
            textField.placeholder = editingModeIsOn ? "List name" : ""
            textField.text = taskList?.name
        }
    }
    
    func actionWithTask(for task: Task?, editingModeIsOn: Bool, completionHandler: @escaping(String, String) -> Void ) {
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            
            if let note = self.textFields?.last?.text, !note.isEmpty {
                completionHandler(newValue, note)
            } else {
                completionHandler(newValue, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(cancelAction)
        addAction(saveAction)
        
        addTextField { textField in
            textField.placeholder = editingModeIsOn ? "New task" : ""
            textField.text = task?.name
        }
        addTextField { textField in
            textField.placeholder = editingModeIsOn ? "Note" : ""
            textField.text = task?.note
        }
        
    }
    
}
