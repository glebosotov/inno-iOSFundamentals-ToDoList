//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Gleb Osotov on 3/27/22.
//

import Foundation
import UIKit
import SafariServices
import SwiftUI


class TodoTableViewController: UITableViewController, ToDoCellDelegate, SFSafariViewControllerDelegate {
    
    var toDos = [ToDo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedToDos = ToDo.loadToDos() {
            toDos = savedToDos
        } else {
            toDos = ToDo.loadSampleToDos()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    @IBAction func unwindToDoList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! TodoDetailViewController
        
        if let toDo = sourceViewController.toDo {
            if let indexOfExistingToDo = toDos.firstIndex(of: toDo) {
                toDos[indexOfExistingToDo] = toDo
                tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
            } else {
            
            let newIndexPath = IndexPath(row: toDos.count, section: 0)
            
            toDos.append(toDo)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        ToDo.saveToDos(toDos)
    }
    
    @IBSegueAction func editTodo(_ coder: NSCoder, sender: Any?) -> TodoDetailViewController? {
        let detailController = TodoDetailViewController(coder: coder)
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return detailController
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        detailController?.toDo = toDos[indexPath.row]
        
        return detailController
    }
}

extension TodoTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toDos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell
        
        let toDo = toDos[indexPath.row]
        cell.isCompleteButton.isSelected = toDo.isComplete
        cell.titleLabel?.text = toDo.title
        cell.link = toDo.link
        if toDo.imageData != nil {
            cell.image = UIImage(data: toDo.imageData!) ?? UIImage()
        }
        cell.linkButton.isHidden = toDo.link == nil
        cell.imageButton.isHidden = toDo.imageData == nil
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Share") { [weak self] (action, view, completionHandler) in
            self?.shareToDo(self!.toDos[indexPath.row])
                                            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension TodoTableViewController {
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var toDo = toDos[indexPath.row]
            toDo.isComplete.toggle()
            toDos[indexPath.row] = toDo
            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }
    
    func ImageTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let toDo = toDos[indexPath.row]
            guard toDo.imageData != nil else { return }
            let vc = UIHostingController(rootView: ImageView(image: UIImage(data: toDo.imageData!) ?? UIImage()))
            present(vc, animated: true)
        }
    }
    
    func linkTapped(sender: ToDoCell) {
        
        if let indexPath = tableView.indexPath(for: sender) {
            let toDo = toDos[indexPath.row]
            
            if let link = toDo.link {
                var urlString: String = ""
                if link.contains("http") {
                    urlString = link
                } else {
                    urlString = "https://" + link
                }
                                
                if let url = URL(string: urlString) {
                    let vc = SFSafariViewController(url: url)
                    vc.delegate = self
                    
                    present(vc, animated: true)
                }
            }
        }
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
    
    func shareToDo(_ toDo: ToDo) {
        let items = ["Do not forget to \(toDo.title) before \(toDo.dueDate.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits).hour().minute()))"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}
