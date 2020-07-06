//
//  Task.swift
//  ToDoListRealm
//
//  Created by Nikita on 7/4/20.
//  Copyright © 2020 Nikita Begletskiy. All rights reserved.
//

import RealmSwift

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}

class TaskList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    var tasks = List<Task>()
}
