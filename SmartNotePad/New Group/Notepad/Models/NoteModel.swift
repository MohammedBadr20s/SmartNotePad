//
//  NoteModel.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import Foundation
import RealmSwift


class NoteModel: Object, RealmBaseModel {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String?
    @objc dynamic var noteDescription: String?
    @objc dynamic var locationAddress: String?
    dynamic var latitude = RealmOptional<Double>()
    dynamic var longitude = RealmOptional<Double>()
    dynamic var distance = RealmOptional<Double>()
    @objc dynamic var imagePath: String?
    @objc dynamic var creationDate: Date?

    init(title: String?, noteDescription: String?, locationAddress: String?, latitude: Double, longitude: Double, distance: Double, imagePath: String, date: Date?) {
        self.title = title
        self.noteDescription = noteDescription
        self.locationAddress = locationAddress
        self.latitude.value = latitude
        self.longitude.value = longitude
        self.distance.value = distance
        self.imagePath = imagePath
        self.creationDate = date
    }
    required override init() {}
    override class func primaryKey() -> String? {
        return "id"
    }
}
