//
//  DataFactory.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift


class DataFactory {
    
    let localRepository: LocalRepository
    init(localRepo: LocalRepository) {
        self.localRepository = localRepo
    }
    
    
    func save <T: RealmBaseModel>(_ items: [T]) {
        localRepository.save(realm: localRepository.appRealm!, items)
    }
    
    func load <T: RealmBaseModel>(model: T.Type, filter: String?) -> Observable<Results<T>> {
        let realm = localRepository.appRealm

        let localResponse = localRepository.load(realm: realm!, model: model.self, filter: filter)
        return localResponse
    }
    
    func loadAndSubscribe <T: RealmBaseModel>(model: T.Type) -> Observable<([T], RealmChangeset?)> {
        let realm = localRepository.appRealm

        let localResponse = localRepository.loadAndSubscribe(realm: realm!, model: model)
        return localResponse
    }
    
    func remove<T: RealmBaseModel>(model: T){
        do {
            let realm = localRepository.appRealm
            try realm?.safeWrite {
                realm?.delete(model, cascading: true)
            }
        } catch let error {
            print(error)
        }
    }
}
