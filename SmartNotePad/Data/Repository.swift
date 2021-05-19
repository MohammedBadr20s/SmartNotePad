//
//  Repository.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift


protocol RepositoryProtocol {
    func save <T: RealmBaseModel>(realm: Realm, _ items: [T]?)
    func load<T: RealmBaseModel>(realm: Realm, model: T.Type, filter: String?) -> Observable<Results<T>>
    func loadAndSubscribe<T: RealmBaseModel>(realm: Realm, model: T.Type) -> Observable<([T], RealmChangeset?)>
}


extension RepositoryProtocol {
    func save<T: RealmBaseModel> (realm: Realm, _ items: [T]?) {
        do {
            try realm.safeWrite {
                if let models = items {
                    realm.add(models, update: .modified)
                }
            }
        } catch let error{
            print(error)
        }
    }
    
    func load<T: RealmBaseModel>(realm: Realm, model: T.Type, filter: String?) -> Observable<Results<T>> {
        return Observable<Results<T>>.create { (observer) -> Disposable in
            
            if let filt = filter {
                let result = realm.objects(model.self).filter(filt)
                observer.onNext(result)
            } else {
                let result = realm.objects(model.self)
                observer.onNext(result)
            }
            return Disposables.create()
        }
    }
    
    func loadAndSubscribe<T: RealmBaseModel>(realm: Realm, model: T.Type) -> Observable<([T], RealmChangeset?)> {
        let object: Results<T> = realm.objects(model.self)
        return Observable.arrayWithChangeset(from: object)
    }
}

class LocalRepository: RepositoryProtocol {
    var appRealm: Realm? {
        get{
            do {
                return try Realm(configuration: Realm.Configuration(schemaVersion: 0))
            } catch let err {
                print(err)
            }
            return nil
        }
    }
    
    init() {
        print("LocalRepository")
    }
}
