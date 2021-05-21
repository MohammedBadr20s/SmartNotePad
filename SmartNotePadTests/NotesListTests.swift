//
//  NotesListTests.swift
//  SmartNotePadTests
//
//  Created by GoKu on 21/05/2021.
//

import Foundation
import XCTest
import RealmSwift

@testable import SmartNotePad

class NotesListTests: XCTestCase {
    
    let viewModel = Injection.container.resolve(NotePadViewModel.self)!
    
    override class func setUp() {
        
    }
    

    func testAddNote() {
        let note = NoteModel(title: "Add Note", noteDescription: "Description", locationAddress: nil, latitude: nil, longitude: nil, distance: nil, imagePath: nil, creationDate: Date(), updatedDate: nil)
        try? self.viewModel.appRealm?.safeWrite {
            self.viewModel.dataFactory.save([note])
        }
        self.viewModel.dataFactory.load(model: NoteModel.self, filter: nil).bind { (notes: Results<NoteModel>) in
            let notes = Array(notes)
            XCTAssertTrue(notes.count > 0)
        }.disposed(by: self.viewModel.disposeBag)
    }
    
    func testDeleteNote() {
        let note = NoteModel(title: "Add Note", noteDescription: "Description", locationAddress: nil, latitude: nil, longitude: nil, distance: nil, imagePath: nil, creationDate: Date(), updatedDate: nil)
        try? self.viewModel.appRealm?.safeWrite {
            self.viewModel.dataFactory.save([note])
            self.viewModel.dataFactory.remove(model: note)
        }
        self.viewModel.dataFactory.load(model: NoteModel.self, filter: nil).bind { (notes: Results<NoteModel>) in
            let notes = Array(notes)
            XCTAssertTrue(notes.contains(note) == false)
        }.disposed(by: self.viewModel.disposeBag)
    }
    
    
    func testNotesListEmpty() {
        try? self.viewModel.appRealm?.safeWrite {
            self.viewModel.dataFactory.appRealm?.deleteAll()
        }

        let isEmptyNotes = self.viewModel.appRealm?.isEmpty ?? false
        XCTAssertTrue(isEmptyNotes == true)
    }
    
    
    func testNotesListPerformance() throws {
        
        self.measure {
            testAddNote()
            testDeleteNote()
            testNotesListEmpty()
        }
    }
}
