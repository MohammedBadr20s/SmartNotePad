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

    required init(dataFactory: DataFactory) {
        self.dataFactory = dataFactory
        super.init()
        
    }
    
    
    func loadAndListen() {
        dataFactory.loadAndSubscribe(model: NoteModel.self).bind(onNext: { (results: [NoteModel],changes:  RealmChangeset?) in
            let notes: [NoteModel] =  results.sorted(by: {$0.creationDate ?? Date() > $1.creationDate ?? Date()})
            self.liveNotes.onNext(notes)
        }).disposed(by: self.disposeBag)
    }
    
    
}
