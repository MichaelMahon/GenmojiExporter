//
//  Genmoji.swift
//  GenmojiExporter
//
//  Created by Mike Mahon on 10/30/24.
//

import Foundation
import UIKit
import SwiftData

@Model
class Genmoji {
    @Attribute(.unique) var id: String
    var genmojiDescription: String
    var createdAt: Date = Date()
    @Attribute(.externalStorage) private var imageData: Data
    
    init(id: String, genmojiDescription: String, image: UIImage) {
        self.id = id
        self.genmojiDescription = genmojiDescription
        self.imageData = image.pngData()!
    }
    
    var image: UIImage {
        UIImage(data: imageData)!
    }
}
