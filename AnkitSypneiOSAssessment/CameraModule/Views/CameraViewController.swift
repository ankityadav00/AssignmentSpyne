//
//  CameraViewController.swift
//  AnkitSypneiOSAssessment
//
//  Created by Ankit yadav on 21/11/24.
//

import UIKit
import AVFoundation
import RealmSwift

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var galleryBtn: UIButton!
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        cameraPreviewView.addSubview(captureBtn)
        cameraPreviewView.addSubview(galleryBtn)

        captureBtn.layer.cornerRadius = captureBtn.frame.height / 2
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No back camera found")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = cameraPreviewView.bounds
            cameraPreviewView.layer.addSublayer(previewLayer)
            
            DispatchQueue.global(qos: .userInitiated).async{
                self.captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func showImageList(_ sender: UIButton) {
        let viewController = ImageListViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) else {
            print("Error capturing photo")
            return
        }
        let imageName = "Image-\(UUID().uuidString).jpg"
        RealmManager.shared.saveCapturedImage(image, name: imageName)
        print("Image saved to Realm with name: \(imageName)")
    }
    
}
