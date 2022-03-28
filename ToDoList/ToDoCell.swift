//
//  ToDoCell.swift
//  ToDoList
//
//  Created by Gleb Osotov on 3/28/22.
//

import Foundation
import UIKit

class ToDoCell: UITableViewCell {
    @IBOutlet var isCompleteButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageButton: UIButton!
    @IBOutlet var linkButton: UIButton!
    var link: String?
    var image: UIImage?
//    @IBOutlet var shareButton: UIButton!
    weak var delegate: ToDoCellDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        delegate?.checkmarkTapped(sender: self)
    }
    
    @IBAction func linkButtonTapped(_ sender: UIButton) {
        delegate?.linkTapped(sender: self)
    }
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        delegate?.ImageTapped(sender: self)
    }
}

protocol ToDoCellDelegate: AnyObject {
    func checkmarkTapped(sender: ToDoCell)
    func linkTapped(sender: ToDoCell)
    func ImageTapped(sender: ToDoCell)
}
