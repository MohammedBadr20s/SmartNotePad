//
//  ImagePickerManager.swift
//  SmartNotePad
//
//  Created by GoKu on 21/05/2021.
//

import UIKit
import Photos

//ENUM of File Types
enum FileType: String {
    case image = "image/jpeg"
}

//Attach Delegate Protocol
protocol AttachDelegate {
    func fileAttached(fileName: String, file: Any, fileType: FileType, fileSize: Double?)
}

class ImagePickerManager {
    
    let imagePickerController: UIImagePickerController
    let viewController: UIViewController
    init(imagePickerController: UIImagePickerController, viewController: UIViewController, delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
        self.viewController = viewController
        self.imagePickerController = imagePickerController
        self.imagePickerController.delegate = delegate
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = ["public.image"]
    }
    //MARK:- Show Image Picker Function
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerController.sourceType = sourceType
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK:- Show Image Action Sheet
    private func showImageActionSheet(PhotoLibraryOnly: Bool) {
        let chooseFromLibraryAction = UIAlertAction(title: "Choose your image", style: .default) { (action) in
            self.showImagePicker( sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take a picture", style: .default) { (action) in
            self.showImagePicker( sourceType: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if PhotoLibraryOnly {
            AlertService.showAlert(style: .actionSheet, title: "Choose your image", message: nil, actions: [chooseFromLibraryAction, cancelAction], completion: nil)
        } else {
            AlertService.showAlert(style: .actionSheet, title: "Choose your image", message: nil, actions: [chooseFromLibraryAction, cameraAction, cancelAction], completion: nil)
        }
        
    }
    
    //MARK:- Save Image into Local Storage
    func saveToImagelocalStorage(image: UIImage, completion: (_ name: String, _ imagePath: URL,_ imageSize: Double) -> Void) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = path.appendingPathComponent("\(UUID().uuidString)").appendingPathExtension("jpeg")
        let name = imagePath.lastPathComponent
        let imageData = image.jpegData(compressionQuality: 0.5)
        let imageSize = Double(imageData?.count ?? 0) / 1000.0
        do{
            try imageData?.write(to: imagePath)
        } catch let error {
            print("addAttachFileVC Error =====>\(error)")
        }
        completion(name, imagePath, imageSize)
    }
    
    //MARK:- Check Photo Library Permission
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
        //handle authorized status
            self.showImageActionSheet(PhotoLibraryOnly: true)
        case .denied, .restricted :
        //handle denied status
            self.showOpenSettingsForImageAlerts(viewController: viewController)
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                // as above
                    self.showImageActionSheet(PhotoLibraryOnly: true)
                case .denied, .restricted:
                // as above
                    self.showOpenSettingsForImageAlerts(viewController: self.viewController)
                case .notDetermined:
                // won't happen but still
                    self.showOpenSettingsForImageAlerts(viewController: self.viewController)
                case .limited:
                    self.showImageActionSheet(PhotoLibraryOnly: true)
                @unknown default:
                    self.showOpenSettingsForImageAlerts(viewController: self.viewController)
                }
            }
        case .limited:
            self.showImageActionSheet(PhotoLibraryOnly: true)
        @unknown default:
            self.showOpenSettingsForImageAlerts(viewController: viewController)
        }
    }
    
    //MARK:- Open Setting For Image Permission
    private func showOpenSettingsForImageAlerts(viewController: UIViewController) {
        // Disabled Photo Library access
        let alert = UIAlertController(title: "Allow Photos Access", message: "Smart Note Pad needs access to show your Photos. so you can add Images to your notes", preferredStyle: UIAlertController.Style.alert)

        // Button to Open Settings
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
}
