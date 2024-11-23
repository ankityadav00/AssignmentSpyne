//
//  ImageModel.swift
//  AnkitSypneiOSAssessment
//
//  Created by Ankit yadav on 21/11/24.
//

import Foundation
import RealmSwift

class ImageModel: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var imageName: String = ""
    @Persisted var imageData: Data?
    @Persisted var captureDate: Date = Date()
    @Persisted var uploadStatus: String = "Pending"
    @Persisted var uri: String?
    
    
}
