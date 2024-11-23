//
//  ImageListViewController.swift
//  AnkitSypneiOSAssessment
//
//  Created by Ankit yadav on 21/11/24.


import UIKit
import RealmSwift

class ImageListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var images: Results<ImageModel>?
    private var notificationToken: NotificationToken?
    private let backgroundQueue = DispatchQueue(label: "com.app.background")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRealmNotifications()
        fetchImages()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchImages), name: .imageSaved, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchImages()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageTableViewCell")
    }
    
    private func setupRealmNotifications() {
        let realm = try! Realm()
        let results = realm.objects(ImageModel.self).sorted(byKeyPath: "captureDate", ascending: false)
        
        notificationToken = results.observe { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.performBatchUpdates {
                    self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                }
            case .error(let error):
                print("Error with Realm notifications: \(error)")
            }
        }
    }
    
    @objc func fetchImages() {
        DispatchQueue.main.async {
            let realm = try! Realm()
            self.images = realm.objects(ImageModel.self).sorted(byKeyPath: "captureDate", ascending: false)
            self.tableView.reloadData()
        }
    }
    
    func uploadImage(_ image: ImageModel) {
        
        guard let imageData = image.imageData else { return }
        
        let imageName = image.imageName
        let imageId = image.id
        
        DispatchQueue.main.async {
            self.updateUploadStatus(for: imageId, status: "Uploading")
        }
        
        let uploadURL = URL(string: "https://www.clippr.ai/api/upload")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        let task = URLSession.shared.uploadTask(with: request, from: body) { [weak self] _, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Upload failed: \(error.localizedDescription)")
                    
                    DispatchQueue.main.async {
                        Utils.showToast(message: "\(imageName) upload failed.", on: self.view)
                       }
                    
                    self.updateUploadStatus(for: imageId, status: "Failed")
  
                    
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print("Upload successful")
                    
                    DispatchQueue.main.async {
                        Utils.showToast(message: "\(imageName) uploaded successfully!", on: self.view)
                      }
                    
                    self.updateUploadStatus(for: imageId, status: "Completed")
                    self.sendUploadCompletionNotification(imageName: imageName)
                    NotificationCenter.default.post(name: .imageSaved, object: nil)
                    
                } else {
                    print("Unexpected response")
                    self.updateUploadStatus(for: imageId, status: "Failed")
                }
            }
        }
        task.resume()
    }
    
    private func updateUploadStatus(for id: String, status: String) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            try! realm.write {
                if let image = realm.object(ofType: ImageModel.self, forPrimaryKey: id) {
                    image.uploadStatus = status
                }
            }
            self.tableView.reloadData()
        }
    }
    
    deinit {
        notificationToken?.invalidate()
        NotificationCenter.default.removeObserver(self, name: .imageSaved, object: nil)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: TableView extensions -
extension ImageListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell
        if let image = images?[indexPath.item] {
            cell.configure(with: image)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let image = images?[indexPath.item] {
            uploadImage(image)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: local notifications
extension ImageListViewController {
    
    func sendUploadCompletionNotification(imageName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Upload Complete"
        content.body = "\(imageName) has been successfully uploaded."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
