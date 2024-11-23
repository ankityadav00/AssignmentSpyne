//
//  ImageListViewModel.swift
//  AnkitSypneiOSAssessment
//
//  Created by Ankit yadav on 21/11/24.
//

import Foundation
import RealmSwift

class ImageListViewModel {
    private let realm = try! Realm()
    var images: Results<ImageModel> { realm.objects(ImageModel.self) }

    func retryUpload(for image: ImageModel) {
        uploadImage(image)
    }

    private func uploadImage(_ image: ImageModel) {
        guard let imageData = image.imageData else { return }

         let url = URL(string: "https://www.clippr.ai/api/upload")!
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         
         let boundary = UUID().uuidString
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
         
         var body = Data()
         body.append("--\(boundary)\r\n".data(using: .utf8)!)
         body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(image.imageName)\"\r\n".data(using: .utf8)!)
         body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
         body.append(imageData)
         body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
         
         let session = URLSession(configuration: .default)
         let task = session.uploadTask(with: request, from: body) { data, response, error in
             let realm = try! Realm()
             try! realm.write {
                 image.uploadStatus = error == nil ? "Completed" : "Failed"
             }
         }
         task.resume()    }
}
