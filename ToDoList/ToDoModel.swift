//
//  ToDoModel.swift
//  ToDoList
//
//  Created by Gleb Osotov on 3/27/22.
//

import Foundation
import UIKit

struct ToDo: Equatable, Codable {
    let id = UUID()
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    var imageData: Data?
    var link: String?
    
    init(title: String, isComplete: Bool, dueDate: Date, notes: String?, link: String?, image: UIImage?) {
//        self.id = UUID()
        self.title = title
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.notes = notes
        self.imageData = image?.pngData()
        self.link = link
    }
    
    static func ==(lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func loadSampleToDos() -> [ToDo] {
        let todo1 = ToDo(title: "Submit Assignment", isComplete: true, dueDate: Date(), notes: "I love Swift", link: "moodle.innopolis.university", image: nil)
        
        return [todo1]
    }
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static let archiveUrl = documentsDirectory.appendingPathComponent("toDos")
        .appendingPathExtension("plist")
    
    static func loadToDos() -> [ToDo]? {
        guard let codedToDos = try? Data(contentsOf: archiveUrl) else { return nil }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<ToDo>.self, from: codedToDos)
    }
    
    static func saveToDos(_ toDos: [ToDo]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedToDos = try? propertyListEncoder.encode(toDos)
        try? codedToDos?.write(to: archiveUrl, options: .noFileProtection)
    }
}
