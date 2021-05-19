//
//  MyNotesListVC.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit
import RxSwift
import RxCocoa

protocol NoteNavigateDelegate {
    func navigateToNotesDetailsScreen()
}

class MyNotesListVC: BaseViewController {
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var FirstNoteView: UIView!
    @IBOutlet weak var notesTableView: UITableView!
    
    var navigationDelegate: NoteNavigateDelegate?
    let viewModel = Injection.container.resolve(NotePadViewModel.self)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func ConfigureUI() {
        self.title = "Notes"
        bindViewModel()
        setupTableView()
        self.navigationbarAddNoteButton()
    }
    
    func setupTableView() {
    }

}



extension MyNotesListVC {
    
    func bindViewModel() {
        viewModel.liveNotes.bind { (data: [NoteModel]) in
            if data.count == 0 {
                self.notesTableView.isHidden = true
                self.FirstNoteView.isHidden = false
            } else {
                self.notesTableView.isHidden = false
                self.FirstNoteView.isHidden = true
            }
        }.disposed(by: self.viewModel.disposeBag)
    }
}
