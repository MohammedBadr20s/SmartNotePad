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
    var liveNotes = BehaviorSubject<[NoteModel]>(value: [])
    
    let dataFactory: DataFactory
    let appRealm: Realm?
    required init(dataFactory: DataFactory) {
        self.dataFactory = dataFactory
        self.appRealm = self.dataFactory.appRealm
        super.init()
        
    }
    
    
    func loadAndListen() {
        dataFactory.loadAndSubscribe(model: NoteModel.self).bind(onNext: { (results: [NoteModel],changes:  RealmChangeset?) in
            var noteResults = results
            var notes: [NoteModel] = []
            if let nearestNote = results.sorted(by: {$0.distance.value ?? Constants.distance.getDefaultDistance() < $1.distance.value ?? Constants.distance.getDefaultDistance()}).first {
                notes.append(nearestNote)
                noteResults.removeAll(where: {$0.id == nearestNote.id})
            }
            let notesSortedByDate = noteResults.sorted(by: {$0.creationDate ?? Date() > $1.creationDate ?? Date()})
            notes.append(contentsOf: notesSortedByDate)
            self.liveNotes.onNext(notes)
        }).disposed(by: self.disposeBag)
    }
    
    
}
