//
//  NotesDetailsVC.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit
import Photos
enum FileType: String {
    case image = "image/jpeg"
    case file = "application/pdf"
}
protocol AttachDelegate {
    func fileAttached(fileName: String, file: Any, fileType: FileType, fileSize: Double?)
}

class NotesDetailsVC: BaseViewController {

    @IBOutlet weak var noteTitleTF: UITextField!
    @IBOutlet weak var noteDescriptionTV: UITextView!
    @IBOutlet weak var addLocationView: UIView!
    @IBOutlet weak var locationAddressLbl: UILabel!
    @IBOutlet weak var addImageView: UIView!
    @IBOutlet weak var addImageLbl: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var noteImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    var note: NoteModel? = nil
    var attachDelegate: AttachDelegate?
    let imagePickerController = UIImagePickerController()
    let viewModel = Injection.container.resolve(NotePadViewModel.self)!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.note != nil {
            self.noteTitleTF.text = self.note?.title
            if self.note?.noteDescription == nil {
                noteDescriptionTV.text = "Note Body Here"
                noteDescriptionTV.textColor = UIColor.lightGray
            } else {
                self.noteDescriptionTV.text = self.note?.noteDescription
                noteDescriptionTV.textColor = UIColor.black
            }
            self.locationAddressLbl.text = self.note?.locationAddress ?? "Add Location"
            if let path = note?.imagePath, let url = URL(string: path) {
                self.setupImage(url: url)
            }
            self.noteTitleTF.isUserInteractionEnabled = false
            self.noteDescriptionTV.isUserInteractionEnabled = false
            self.addImageView.isUserInteractionEnabled = false
            self.addLocationView.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if let note = self.note {
            try? self.viewModel.dataFactory.localRepository.appRealm?.safeWrite {
                self.viewModel.dataFactory.save([note])
            }
        }
    }
    override func ConfigureUI() {
        let tapAddLocationRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddLocation))
        self.addLocationView.addGestureRecognizer(tapAddLocationRecognizer)
        
        let tapAddImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddImage))
        self.addImageView.addGestureRecognizer(tapAddImageRecognizer)
        noteDescriptionTV.delegate = self
        self.attachDelegate = self
        addEditAndDeleteButtons()
        binding()
    }
    func binding() {
        self.noteTitleTF.rx.text.bind { (text: String?) in
            if text != nil && text != ""  {
                if self.note == nil {
                    self.note = NoteModel()
                    self.note?.creationDate = Date()
                }
                try? self.viewModel.dataFactory.localRepository.appRealm?.safeWrite {
                    
                    self.note?.title = text
                }
                
            }
        }.disposed(by: self.viewModel.disposeBag)
        
        self.noteDescriptionTV.rx.text.bind { (text: String?) in
            if text != nil && text != "" && text != "Note Body Here" {
                if self.note == nil {
                    self.note = NoteModel()
                    self.note?.creationDate = Date()
                }
                try? self.viewModel.dataFactory.localRepository.appRealm?.safeWrite {
                    self.note?.noteDescription = text
                }
                
            }
        }.disposed(by: self.viewModel.disposeBag)
        
        self.backBtn.rx.tap.bind { (_) in
//            self.backButtonAction()
        }.disposed(by: self.viewModel.disposeBag)
    }
    @objc func AddLocation() {
        
    }
    @objc func AddImage() {
        checkPhotoLibraryPermission()
    }
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
        //handle authorized status
            self.showImageActionSheet(PhotoLibraryOnly: true)
        case .denied, .restricted :
        //handle denied status
            self.showOpenSettingsForImageAlerts()
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                // as above
                    self.showImageActionSheet(PhotoLibraryOnly: true)
                case .denied, .restricted:
                // as above
                    self.showOpenSettingsForImageAlerts()
                case .notDetermined:
                // won't happen but still
                    self.showOpenSettingsForImageAlerts()
                case .limited:
                    self.showImageActionSheet(PhotoLibraryOnly: true)
                @unknown default:
                    self.showOpenSettingsForImageAlerts()
                }
            }
        case .limited:
            self.showImageActionSheet(PhotoLibraryOnly: true)
        @unknown default:
            self.showOpenSettingsForImageAlerts()
        }
    }
    
    private func showOpenSettingsForImageAlerts() {
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
        self.present(alert, animated: true, completion: nil)
    }
    
    func addEditAndDeleteButtons() {
        let deleteBtn = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteNote))
        deleteBtn.tintColor = .red
        let editBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editNote))
        editBtn.tag = 10
        editBtn.tintColor = .black
        navigationItem.rightBarButtonItems = [deleteBtn, editBtn]
    }
    

    @objc private func deleteNote() {
        if let note = self.note {
            self.viewModel.dataFactory.remove(model: note)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func editNote() {
        
        for item in self.navigationItem.rightBarButtonItems! {
            if item.tag == 10 {
                if item.title == "Edit" {
                    self.noteTitleTF.isUserInteractionEnabled = true
                    self.noteDescriptionTV.isUserInteractionEnabled = true
                    self.addImageView.isUserInteractionEnabled = true
                    self.addLocationView.isUserInteractionEnabled = true
                    item.title = "Done"
                } else {
                    self.noteTitleTF.isUserInteractionEnabled = false
                    self.noteDescriptionTV.isUserInteractionEnabled = false
                    self.addImageView.isUserInteractionEnabled = false
                    self.addLocationView.isUserInteractionEnabled = false
                    item.title = "Edit"
                }
                
            }
        }
    }
}


extension NotesDetailsVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text == "" {

            textView.text = "Note Body Here"
            textView.textColor = UIColor.lightGray
        }
    }
}
extension NotesDetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImageActionSheet(PhotoLibraryOnly: Bool) {
        let chooseFromLibraryAction = UIAlertAction(title: "Choose your image", style: .default) { (action) in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take a picture", style: .default) { (action) in
            self.showImagePicker(sourceType: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if PhotoLibraryOnly {
            AlertService.showAlert(style: .actionSheet, title: "Choose your image", message: nil, actions: [chooseFromLibraryAction, cancelAction], completion: nil)
        } else {
            AlertService.showAlert(style: .actionSheet, title: "Choose your image", message: nil, actions: [chooseFromLibraryAction, cameraAction, cancelAction], completion: nil)
        }
        
    }
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        imagePickerController.mediaTypes = ["public.image"]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            saveToImagelocalStorage(image: image)
            //dismiss(animated: true, completion: nil)
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        dismiss(animated: true, completion: nil)
    }

    func saveToImagelocalStorage(image: UIImage) {
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
        attachDelegate?.fileAttached(fileName: name, file: imagePath, fileType: .image, fileSize: imageSize)
    }
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension NotesDetailsVC: AttachDelegate {
    func fileAttached(fileName: String, file: Any, fileType: FileType, fileSize: Double?) {
        guard let url = file as? URL else { return }
        setupImage(url: url)
    }
    
    func setupImage(url: URL?){
        let size = CGSize(width: 140, height: 140)
        if self.note == nil {
            self.note = NoteModel()
            self.note?.creationDate = Date()
        }
        if let url = url {
            try? self.viewModel.dataFactory.localRepository.appRealm?.safeWrite {
                self.note?.imagePath = url.absoluteString
            }
            
        }
        let downsampleImage = UIImage().downsample(imageAt: url!, to: size, scale: 0.75)
        self.noteImageView.image = downsampleImage
        self.noteImageView.isHidden = false
        self.noteImageHeightConstraint.constant = 150
        self.addImageLbl.isHidden = true
        
    }
}
