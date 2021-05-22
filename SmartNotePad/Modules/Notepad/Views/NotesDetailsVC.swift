//
//  NotesDetailsVC.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit
import Photos





class NotesDetailsVC: BaseViewController {
    //MARK:- Outlets
    @IBOutlet weak var noteTitleTF: UITextField!
    @IBOutlet weak var noteDescriptionTV: UITextView!
    @IBOutlet weak var addLocationView: UIView!
    @IBOutlet weak var locationAddressLbl: UILabel!
    @IBOutlet weak var addImageView: UIView!
    @IBOutlet weak var addImageLbl: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var noteImageHeightConstraint: NSLayoutConstraint!
    //MARK:- Properties
    var note: NoteModel? = nil
    var navigationDelegate: NoteNavigateDelegate?
    var attachDelegate: AttachDelegate?
    var backDelegate: BackDelegate?
    let viewModel = Injection.container.resolve(NotePadViewModel.self)!
    let locationManager = CLLocationManager()
    var imagePickerManager: ImagePickerManager?
    //MARK:- UIView Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getNoteInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if let note = self.note {
            try? self.viewModel.appRealm?.safeWrite {
                self.viewModel.dataFactory.save([note])
            }
        }
    }
    
    //MARK:- Handling UI Elements
    //Get Note Data if exists
    func getNoteInfo() {
        if self.note != nil {
            self.noteTitleTF.isUserInteractionEnabled = false
            self.noteDescriptionTV.isUserInteractionEnabled = false
            self.addImageView.isUserInteractionEnabled = false
            self.addLocationView.isUserInteractionEnabled = false
            self.addEditAndDeleteButtons(deleteBtnSelector: #selector(deleteNote), editBtnSelector: #selector(editNote))
            self.noteTitleTF.text = self.note?.title
            if self.note?.noteDescription == nil {
                noteDescriptionTV.text = "Note Body Here"
                noteDescriptionTV.textColor = UIColor.lightGray
            } else {
                self.noteDescriptionTV.text = self.note?.noteDescription
                noteDescriptionTV.textColor = .AccentColor
            }
            self.locationAddressLbl.text = self.note?.locationAddress ?? "Add Location"
            if self.note?.locationAddress != nil {
                self.locationAddressLbl.textColor = .AccentColor
                self.KeepTheDoneButton()
            }
            if let path = note?.imagePath, let url = URL(string: path) {
                self.setupImageUI(url: url)
            }
            
        }
    }
    //Configuring UI of the View
    override func ConfigureUI() {
        let tapAddLocationRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddLocation))
        self.addLocationView.addGestureRecognizer(tapAddLocationRecognizer)
        
        let tapAddImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddImage))
        self.addImageView.addGestureRecognizer(tapAddImageRecognizer)
        noteDescriptionTV.delegate = self
        self.attachDelegate = self
        self.imagePickerManager = ImagePickerManager(imagePickerController: UIImagePickerController(), viewController: self, delegate: self)
        binding()
    }
    
    //MARK:- Binding Data from UI to the note in this case and other cases it will be to View Model
    func binding() {
        //Binding Note Title Text Field
        self.noteTitleTF.rx.text.bind { (text: String?) in
            if text != nil && text != ""  {
                if self.note == nil {
                    self.note = NoteModel()
                    self.note?.creationDate = Date()
                }
                try? self.viewModel.appRealm?.safeWrite {
                    
                    self.note?.title = text
                }
                
            }
        }.disposed(by: self.viewModel.disposeBag)
        
        //Binding Note Description Text View
        self.noteDescriptionTV.rx.text.bind { (text: String?) in
            if text != nil && text != "" && text != "Note Body Here" {
                if self.note == nil {
                    self.note = NoteModel()
                    self.note?.creationDate = Date()
                }
                try? self.viewModel.appRealm?.safeWrite {
                    self.note?.noteDescription = text
                }
                
            }
        }.disposed(by: self.viewModel.disposeBag)
    }
    
    //MARK:- UIView Actions
    //Add Location Action
    @objc func AddLocation() {
        self.checkLocationAuthorization(manager: locationManager, viewController: self) { (success: Bool?) in
            if let _ = success {
                self.navigationDelegate?.navigateToLocation(delegate: self)
            }
        }
        
    }
    //Add Image Action
    @objc func AddImage() {
        self.imagePickerManager?.checkPhotoLibraryPermission()
    }
    
    //Delete The Note and go back
    @objc private func deleteNote() {
        if let note = self.note {
            self.viewModel.dataFactory.remove(model: note)
            self.note = nil
            self.backDelegate?.back()
        }
    }
    
    @objc private func editNote() {
        //Finding The Edit Button from NavigationItem's Right Bar Buttons
        if let item = self.navigationItem.rightBarButtonItems?.first(where: {$0.tag == 10}) {
            if item.title == "Edit" {
                self.KeepTheDoneButton()
            } else {
                self.noteTitleTF.isUserInteractionEnabled = false
                self.noteDescriptionTV.isUserInteractionEnabled = false
                self.addImageView.isUserInteractionEnabled = false
                self.addLocationView.isUserInteractionEnabled = false
                item.title = "Edit"
                if let note = self.note {
                    try? self.viewModel.appRealm?.safeWrite {
                        self.viewModel.dataFactory.save([note])
                    }
                }
            }
        }
    }//END of Edit Note Function
    
    func KeepTheDoneButton() {
        if let item = self.navigationItem.rightBarButtonItems?.first(where: {$0.tag == 10}) {
            self.noteTitleTF.isUserInteractionEnabled = true
            self.noteDescriptionTV.isUserInteractionEnabled = true
            self.addImageView.isUserInteractionEnabled = true
            self.addLocationView.isUserInteractionEnabled = true
            item.title = "Done"
        }
    }
    
}

//MARK:- UITextView Delegate Functions
extension NotesDetailsVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = .AccentColor
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = "Note Body Here"
            textView.textColor = UIColor.lightGray
        }
    }
}

//MARK:- UIImageViewPicker Delegate Functions
extension NotesDetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imagePickerManager?.saveToImagelocalStorage(image: image) { (imageName: String, imageURL: URL, imageSize: Double) in

                attachDelegate?.fileAttached(fileName: imageName, file: imageURL, fileType: .image, fileSize: imageSize)
                self.KeepTheDoneButton()
            }
            //dismiss(animated: true, completion: nil)
            picker.dismiss(animated: true, completion: nil)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- Attach Delegate Functions
extension NotesDetailsVC: AttachDelegate {
    func fileAttached(fileName: String, file: Any, fileType: FileType, fileSize: Double?) {
        guard let url = file as? URL else { return }
        setupImageUI(url: url)
    }
    //MARK:- Setup Image UI Function
    func setupImageUI(url: URL?){
        if self.note == nil {
            self.note = NoteModel()
            self.note?.creationDate = Date()
        }
        if let url = url {
            let imagePath = url.absoluteString
            //Getting Image Name
            let imageName = imagePath.components(separatedBy: "/").last ?? ""
            
            //Converting the RealmFile Path into Array of String to get the Path where realm file being saved in
            if let realmPathFile = self.viewModel.appRealm?.configuration.fileURL?.absoluteString.components(separatedBy: "/") {
                //Getting The Path without the realm file and append the image name so image wont be deleted during rebuild the app from Xcode
                let realmImagePath = Array(realmPathFile[0...realmPathFile.count - 2]).joined(separator: "/")
                
                try? self.viewModel.appRealm?.safeWrite {
                    self.note?.imagePath = "\(realmImagePath)/\(imageName)"
                    print("Image Path: \(self.note?.imagePath ?? "")")
                }
            }
            
            let size = CGSize(width: 200, height: 200)
            guard let imageURL = URL(string: self.note?.imagePath ?? "") else { return }
            let downsampleImage = UIImage().downsample(imageAt: imageURL, to: size, scale: 1)
            self.noteImageView.image = downsampleImage
            self.noteImageView.isHidden = false
            self.noteImageHeightConstraint.constant = 150
            self.addImageLbl.isHidden = true
        }
    }
}

//MARK:- Handling Location Data coming from LocationViewController
extension NotesDetailsVC: LocationDelegate {
    func getLocationInfo(selectedLocation: CLLocationCoordinate2D, distance: Double, address: String) {
        if self.note == nil {
            self.note = NoteModel()
            self.note?.creationDate = Date()
        }
        try? self.viewModel.appRealm?.safeWrite {
            self.note?.distance.value = distance.round(places: 2)
            self.note?.latitude.value = selectedLocation.latitude
            self.note?.longitude.value = selectedLocation.longitude
            self.note?.locationAddress = address
        }
        
    }
    
    
}
