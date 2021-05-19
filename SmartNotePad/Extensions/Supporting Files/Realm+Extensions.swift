//
//  Realm+Extensions.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import RealmSwift
import Realm

protocol CascadeDeleting {
    func delete<Entity: Object>(_ list: List<Entity>, cascading: Bool)
    func delete<Entity: Object>(_ results: Results<Entity>, cascading: Bool)
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool)
}

extension Realm: CascadeDeleting {
    
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
    
    func delete<Entity: Object>(_ list: List<Entity>, cascading: Bool) {
        list.forEach {
            delete($0, cascading: cascading)
        }
    }

    func delete<Entity: Object>(_ results: Results<Entity>, cascading: Bool) {
        results.forEach {
            delete($0, cascading: cascading)
        }
    }
    func delete<Entity: Object>(_ array: [Entity], cascading: Bool) {
        array.forEach {
            delete($0, cascading: cascading)
        }
    }

    func delete<Entity: Object>(_ entity: Entity, cascading: Bool) {
        if cascading {
            cascadeDelete(entity)
        } else {
            delete(entity)
        }
    }
}

private extension Realm {
    private func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }
        var toBeDeleted = Set<RLMObjectBase>()
        toBeDeleted.insert(entity)
        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object,
                !element.isInvalidated else { continue }
            resolve(element: element, toBeDeleted: &toBeDeleted)
        }
    }

    private func resolve(element: Object, toBeDeleted: inout Set<RLMObjectBase>) {
        element.objectSchema.properties.forEach {
            guard let value = element.value(forKey: $0.name) else { return }
            if let entity = value as? RLMObjectBase {
                toBeDeleted.insert(entity)
            } else if let list = value as? RealmSwift.ListBase {
                for index in 0..<list._rlmArray.count {
                    if let list = list._rlmArray.object(at: index) as? RLMObjectBase {
                        toBeDeleted.insert(list)
                    }
                }
            }
        }
        delete(element)
    }
    func deleteRealm() {
        do {
            try self.safeWrite {
                self.deleteAll()
            }
        } catch let error {
            print("Failed to delete realm:", error)
        }
    }
}
