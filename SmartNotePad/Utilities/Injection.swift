//
//  Injection.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import Foundation
import Swinject

class Injection {
    
    private static let baseContainer = Container()
    static let container = baseContainer.synchronize()
    
    private init() {}
    
    private static func registerDataFactory() {
        baseContainer.register(LocalRepository.self) { (_) in
            LocalRepository()
        }.inObjectScope(.container)
        
        baseContainer.register(DataFactory.self) { (r) in
            let local = r.resolve(LocalRepository.self)!
            
            print("Realm File Path: \(local.appRealm?.configuration.fileURL)")
            return DataFactory(localRepo: local)
        }.inObjectScope(.container)
    }

    
    private static func registerBaseVM() {
        baseContainer.register(BaseViewModel.self) { (_) in
            return BaseViewModel()
        }
    }
    
    private static func registerNotePadVM() {
        baseContainer.register(NotePadViewModel.self) { (r) in
            let dataFactory = r.resolve(DataFactory.self)!
            return NotePadViewModel(dataFactory: dataFactory)
        }
    }
    
    private static func registerNotePadDetailsVM() {
        
    }
    
    public static func register() {
        registerDataFactory()
        registerBaseVM()
        registerNotePadVM()
        registerNotePadDetailsVM()
    }
}
