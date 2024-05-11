//
//  FavoritesManager.swift
//  MarvelApp
//
//  Created by MAGH on 09/05/24.
//

import Foundation
import CoreData

class FavoritesManager{
    
    private var favorites: [DBCharacter] = []
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func count() -> Int {
        return favorites.count
    }
    
    func getCharacter(at index: Int) -> DBCharacter {
        return favorites[index]
    }
    
    func getCharacterById(id: Int64) -> DBCharacter? {
        for character in favorites {
            if character.id == id {
                return character
            }
        }
        return nil
    }
    
    func fetch() {
        do {
            let fetchRequest = NSFetchRequest<DBCharacter>(entityName: "DBCharacter")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            self.favorites = try self.context.fetch(fetchRequest)
        }catch let error {
            print("Error on fetch! ", error)
        }
    }
    
}


