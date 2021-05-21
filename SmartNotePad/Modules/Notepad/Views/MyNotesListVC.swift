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
    func navigateToNotesDetailsScreen(note: NoteModel?)
    func navigateToLocation(delegate: LocationDelegate)
}

class MyNotesListVC: BaseViewController {
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var FirstNoteView: UIView!
    @IBOutlet weak var notesTableView: UITableView!
    
    var navigationDelegate: NoteNavigateDelegate?
    let viewModel = Injection.container.resolve(NotePadViewModel.self)!
    var addNoteSelector: Selector?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func ConfigureUI() {
        self.title = "Notes"
        bindViewModel()
        setupTableView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}



extension MyNotesListVC {
    
    func bindViewModel() {
        viewModel.liveNotes.bind { (data: [NoteModel]) in
            if data.count == 0 {
                self.notesTableView.isHidden = true
                self.FirstNoteView.isHidden = false
                self.navigationItem.rightBarButtonItem = nil
            } else {
                self.notesTableView.isHidden = false
                self.FirstNoteView.isHidden = true
                self.navigationbarAddNoteButton(selector: #selector(self.addNote))
            }
        }.disposed(by: self.viewModel.disposeBag)
        
        self.addBtn.rx.tap.bind { (_) in
            self.addNote()
        }.disposed(by: self.viewModel.disposeBag)
    }
    
    func setupTableView() {
        self.notesTableView.register(NoteCell.nib(), forCellReuseIdentifier: NoteCell.identifier)
        
        self.viewModel.liveNotes.observe(on: MainScheduler.instance).bind(to: self.notesTableView.rx.items) { [weak self] (tableView, row, element) -> UITableViewCell in
            guard let self = self else { return NoteCell()}
            
            return self.ConfigureNoteCell(tableView: tableView, indexPath: IndexPath(row: row, section: 0), model: element)
        }.disposed(by: self.viewModel.disposeBag)
        
        self.notesTableView.rx.itemSelected.bind { (index: IndexPath) in
            
            let data = try! self.viewModel.liveNotes.value()
            self.navigationDelegate?.navigateToNotesDetailsScreen(note: data[index.row])

        }.disposed(by: self.viewModel.disposeBag)
    }

    private func ConfigureNoteCell(tableView: UITableView, indexPath: IndexPath, model: NoteModel) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell else { return NoteCell()}
        var isNearest = false
        if indexPath.row == 0 && (model.distance.value != nil) {
            isNearest = true
        }
        let containsLocation = model.locationAddress != nil
        let containsImage = model.imagePath != nil
        cell.config(title: model.title ?? "", noteDescription: model.noteDescription ?? "", isNearest: isNearest, constainsLocation: containsLocation, containsImage: containsImage)
        return cell
    }
    
    @objc func addNote() {
        self.navigationDelegate?.navigateToNotesDetailsScreen(note: nil)
    }
    
    
}
