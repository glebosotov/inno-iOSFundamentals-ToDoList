//
//  ImageView.swift
//  ToDoList
//
//  Created by Gleb Osotov on 3/28/22.
//

import Foundation
import SwiftUI

struct ImageView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .ignoresSafeArea()
    }
}
