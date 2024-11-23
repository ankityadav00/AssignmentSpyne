//
//  RealmManager.swift
//  AnkitSypneiOSAssessment
//
//  Created by Ankit yadav on 21/11/24.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()

    private init() {
        // Set up the Realm configuration with schema version and migration block
        let config = Realm.Configuration(
            schemaVersion: 1, // Increment this each time you change the schema
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Handle migration if necessary
                    // Example: Set default values for any new properties
                    migration.enumerateObjects(ofType: ImageModel.className()) { oldObject, newObject in
                        newObject!["uri"] = "" // Default value for the 'uri' property
                    }
                }
            }
        )
        // Set the default Realm configuration
        Realm.Configuration.defaultConfiguration = config
    }

    // Get Realm instance for the main thread
    func getMainRealm() -> Realm {
        return try! Realm()
    }

    // Get Realm instance for background thread
    func getBackgroundRealm() -> Realm {
        var realm: Realm!
        let queue = DispatchQueue(label: "com.app.realm.queue", qos: .background)
        queue.sync {
            realm = try! Realm()
        }
        return realm
    }

    // Save captured image to Realm
    func saveCapturedImage(_ image: UIImage, name: String) {
        let realm = getBackgroundRealm()

        let imageModel = ImageModel()
        imageModel.imageName = name
        imageModel.imageData = image.jpegData(compressionQuality: 0.8)
        imageModel.captureDate = Date()

        try! realm.write {
            realm.add(imageModel)
        }

    }
}

extension Notification.Name {
    static let imageSaved = Notification.Name("imageSaved")
}
