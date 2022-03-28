//
//  ToDoDetailViewController.swift
//  ToDoList
//
//  Created by Gleb Osotov on 3/27/22.
//

import Foundation
import UIKit
import JustPhotoPicker

class TodoDetailViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var toDo: ToDo?
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var isCompletedButton: UIButton!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var dueDateDatePicker: UIDatePicker!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var addLinkButton: UIButton!
    @IBOutlet var addImageButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    var link: String? = nil
    
    var datePickerIsHidden = true
    let dateLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    let notesIndexPath = IndexPath(row: 0, section: 2)
    let additionalInfoIndexPath = IndexPath(row: 0, section: 3)
    
    func updateSaveButtonState() {
        let shouldEnableSaveButton = titleTextField.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDueDate: Date
        if let toDo = toDo {
            navigationItem.title = "To-Do"
            titleTextField.text = toDo.title
            isCompletedButton.isSelected = toDo.isComplete
            currentDueDate = toDo.dueDate
            notesTextView.text = toDo.notes
            if toDo.imageData != nil {
            imageView.image = UIImage(data: toDo.imageData!) ?? UIImage()
            }
            link = toDo.link
        } else {
            currentDueDate = Date().addingTimeInterval(24*60*60)
        }
        
        updateSaveButtonState()
        dueDateDatePicker.date = currentDueDate
        updateDueDateLabel(date: currentDueDate)
    }
    
    @IBAction func textEditingChanged(_ sender: Any) {
        updateSaveButtonState()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func isCompleteButtonTapped(_ sender: UIButton) {
        isCompletedButton.isSelected.toggle()
    }
    
    func updateDueDateLabel(date: Date) {
        dueDateLabel.text = date.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits).hour().minute())
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: sender.date)
    }
    
    @IBAction func addPhotobuttonTapped(_ sender: UIButton) {
        var config = JustPhotoPickerConfiguration()
        config.selectionLimit = 1
        config.isSelectionRequired = true
        let photoPicker = JustPhotoPicker(configuration: config)
        photoPicker.photoPickerDelegate = self
        self.present(photoPicker, animated: true)
    }
    
    @IBAction func addLinkButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add Link", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter the link"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            self.link = textField.text
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        
        let title = titleTextField.text!
        let isComplete = isCompletedButton.isSelected
        let dueDate = dueDateDatePicker.date
        let notes = notesTextView.text
        let image = imageView.image
        let link = link
        
        if toDo != nil {
            toDo?.title = title
            toDo?.link = link
            toDo?.imageData = image?.pngData()
            toDo?.dueDate = dueDate
            toDo?.notes = notes
            toDo?.isComplete = isComplete
        } else {
            toDo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes, link: link, image: image)
        }
    }
    
}

extension TodoDetailViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath where datePickerIsHidden == true:
            return 0
        case notesIndexPath:
            return 200
        case additionalInfoIndexPath:
            return 150
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath:
            return 216
        case notesIndexPath:
            return 200
        case additionalInfoIndexPath:
            return 150
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == dateLabelIndexPath {
            datePickerIsHidden.toggle()
            updateDueDateLabel(date: dueDateDatePicker.date)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

extension TodoDetailViewController: JustPhotoPickerDelegate {
    func didSelect(with photoPicker: JustPhotoPicker, images: [UIImage]) {
        imageView.image = images.first
    }
    
    func didNotSelect(with photoPicker: JustPhotoPicker) {
        imageView.image = nil
    }
}
