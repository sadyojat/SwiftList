//
//  AbstractModel.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Foundation

protocol DataModelProtocol: Identifiable, Equatable, Codable, Hashable {
    var id: Int { get }
}
