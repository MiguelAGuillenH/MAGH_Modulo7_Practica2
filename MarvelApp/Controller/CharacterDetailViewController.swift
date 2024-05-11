//
//  CharacterDetailViewController.swift
//  MarvelApp
//
//  Created by MAGH on 08/05/24.
//

import UIKit
import SDWebImage

class CharacterDetailViewController: UIViewController {
    
    var character: Character?
    var favorite: DBCharacter?
    var favoriteFlag = false
    
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterDescription: UILabel!
    @IBOutlet weak var characterUrl: UILabel!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //CoreData context
    var favoritesManager: FavoritesManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if favoriteFlag {
            //Fill favorite data
            if favorite != nil {
                characterName.text = favorite?.name
                let url = URL(string: (favorite?.imageUrl)!)
                characterImage.sd_setImage(with: url)
                if favorite!.desc!.isEmpty {
                    characterDescription.text = "No description available."
                }else{
                    characterDescription.text = favorite!.desc
                }
                if favorite!.url!.isEmpty {
                    characterUrl.text =  "No URL available."
                }else{
                    characterUrl.text = favorite!.url
                }
            }
        }else{
            //Fill character data
            if character != nil {
                characterName.text = character?.name
                let url = URL(string: (character?.thumbnail.url)!)
                characterImage.sd_setImage(with: url)
                if (character?.description)!.isEmpty {
                    characterDescription.text = "No description available."
                }else{
                    characterDescription.text = character!.description
                }
                if character?.urls.first != nil {
                    characterUrl.text = (character?.urls.first!.url)!
                }else{
                    characterUrl.text =  "No URL available."
                }
            }
            
            //Check favorite button
            if favorite == nil {
                favoriteButton.image = UIImage(systemName: "star")
            }else{
                favoriteButton.image = UIImage(systemName: "star.fill")
            }
        }
        
        favoriteButton.isHidden = favoriteFlag
        
        favoritesManager = FavoritesManager(context: context)
        favoritesManager?.fetch()
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        
        if favorite == nil {
            
            //Save favorite
            let newFavorite = DBCharacter(context: context)
            newFavorite.id = Int64(character!.id)
            newFavorite.name = character?.name
            newFavorite.imageUrl = character?.thumbnail.url
            newFavorite.desc = character?.description
            if character?.urls.first != nil {
                newFavorite.url = (character?.urls.first!.url)!
            }else{
                newFavorite.url =  ""
            }
            
            do{
                try context.save()
                print("Save successful!")
                favorite = newFavorite
                favoriteButton.image = UIImage(systemName: "star.fill")
            }catch let error {
                print("Error al guardar. ", error)
            }
            
            self.favoritesManager?.fetch()
            
        }else{
            
            //Delete favorite
            let deleteFavorite = self.favoritesManager?.getCharacterById(id: Int64(character!.id))
            self.context.delete(deleteFavorite!)
            
            do{
                try self.context.save()
                print("Delete successful!")
                favorite = nil
                favoriteButton.image = UIImage(systemName: "star")
            }catch let error {
                print("Error al eliminar.", error)
            }
            
            self.favoritesManager?.fetch()
            
        }
        
    }

}
