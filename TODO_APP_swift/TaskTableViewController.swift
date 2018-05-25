//
//  TaskTableViewController.swift
//  TODO_APP_swift
//
//  Created by Shohei Ihaya on 2018/05/21.
//  Copyright © 2018年 Shohei Ihaya. All rights reserved.
//

import UIKit
import os.log

class TaskTableViewController: UITableViewController {

    //MARK: Propeties
    @IBOutlet weak var createTaskButton: UIButton!


    var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedTasks = loadTasks() {
            tasks += savedTasks
        }
        //loadSampleTasks()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "createTask":
            os_log("New task is created.")
        case "editTask":
            guard let taskViewController = segue.destination as? TaskViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedTask = tasks[indexPath.row]
            taskViewController.task = selectedTask
        default:
            fatalError("Unexpected segue \(segue)")
        }

    }

    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TaskViewController, let task = sourceViewController.task {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tasks[selectedIndexPath.row] = task
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: tasks.count, section: 0)

                tasks.append(task)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveTasks()
        }
    }

    @IBAction func createNewTask(sender: UIButton) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TaskTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskTableViewCell else {
            fatalError("The dequeud cell is not an instance of TaskTableViewCell")
        }

        let task = tasks[indexPath.row]

        cell.taskTitle.text = task.title

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if let limit = task.limit {
            cell.taskLimit.text = dateFormatter.string(from: limit as Date)
        } else {
            cell.taskLimit.text = nil
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private Methods
    private func loadSampleTasks() {
        let date: NSDate = NSDate()
        guard let task = Task(title: "first", limit: date) else {
           fatalError("Instantize Task was failed")
        }

        tasks.append(task)
    }

    private func saveTasks() {
       let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(tasks, toFile: Task.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Tasks successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save tasks", log: OSLog.default, type: .debug)
        }
    }

    private func loadTasks() -> [Task]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Task.ArchiveURL.path) as? [Task]
    }
}
