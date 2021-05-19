//
//  BaseModel.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import Foundation
import RealmSwift


protocol BaseModel: Codable {}
protocol RealmBaseModel: Object, BaseModel  {}
