//
//  DBCharacter+CoreDataProperties.swift
//  MarvelApp
//
//  Created by DISMOV on 09/05/24.
//
//

import Foundation
import CoreData


extension DBCharacter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBCharacter> {
        return NSFetchRequest<DBCharacter>(entityName: "DBCharacter")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var url: String?
    @NSManaged public var imageUrl: String?

}

extension DBCharacter : Identifiable {

}
