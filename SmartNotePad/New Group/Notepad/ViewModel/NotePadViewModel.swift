//
//  NotePadViewModel.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import Foundation
import RxSwift
import RxRealm
import RealmSwift

class NotePadViewModel: BaseViewModel {
    var liveNotes = PublishSubject<[NoteModel]>()
    
    let dataFactory: DataFactory

    required init(dataFactory: DataFactory) {
        self.dataFactory = dataFactory
        super.init()
        self.loadAndListen()
    }
    
    
    func loadAndListen() {
        dataFactory.loadAndSubscribe(model: NoteModel.self).subscribe { (results: [NoteModel],changes:  RealmChangeset?) in
            var notes: [NoteModel] = results
            if let firstNote: NoteModel = results.sorted(by: {$0.creationDate ?? Date() > $1.creationDate ?? Date()}).first {
                notes.removeAll(where: {$0.title == firstNote.title})
                notes.insert(firstNote, at: 0)
                
            }
            
            self.liveNotes.onNext(notes)
        } onError: { (error: Error) in
            print("Error: \(error.localizedDescription)")
        }.disposed(by: self.disposeBag)
    }
}
