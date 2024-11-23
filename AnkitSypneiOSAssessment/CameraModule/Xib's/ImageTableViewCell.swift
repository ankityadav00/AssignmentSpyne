//
//  ImageTableViewCell.swift
//  AnkitSypneiOSAssessment
//
//  Created by Ankit yadav on 21/11/24.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageLbl: UILabel!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    func configure(with model: ImageModel) {
         if let data = model.imageData {
             cameraImageView?.image = UIImage(data: data)
         }
        imageLbl.text = model.uploadStatus
        if model.uploadStatus == "Uploading" {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
     }
    
}
