//
//  FavoritesViewController.swift
//  MarvelApp
//
//  Created by MAGH on 09/05/24.
//

import UIKit
import SDWebImage

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //CoreData context
    var favoritesManager: FavoritesManager?
    var selectedFavorite: DBCharacter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        
        favoritesManager = FavoritesManager(context: context)
        favoritesManager?.fetch()
        noFavoritesLabel.isHidden = ((favoritesManager?.count())! > 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        favoritesManager?.fetch()
        favoritesCollectionView.reloadData()
        noFavoritesLabel.isHidden = ((favoritesManager?.count())! > 0)
    }
    	
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if favoritesCollectionView.isEditing {
            setEditing(false, animated: true)
            sender.title = "Edit"
        }else{
            setEditing(true, animated: true)
            sender.title = "Done"
        }
    }
    
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        (favoritesManager?.count())!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CharacterCell
        let character = favoritesManager?.getCharacter(at: indexPath.row)
        cell.characterName.text = character?.name
        
        let url = URL(string: (character?.imageUrl)!)
        cell.characterImage.sd_setImage(with: url)
        	
        let delete = UICellAccessory.delete() {
            //Delete favorite
            let character = self.favoritesManager?.getCharacter(at: indexPath.row)
            self.context.delete(character!)
            
            do{
                try self.context.save()
            }catch let error {
                print("Error al eliminar.", error)
            }
            
            self.favoritesManager?.fetch()
            self.favoritesCollectionView.reloadData()
            self.noFavoritesLabel.isHidden = ((self.favoritesManager?.count())! > 0)
            if self.favoritesManager?.count() == 0 {
                self.setEditing(false, animated: true)
                self.editButton.title = "Edit"
            }
        }
        cell.accessories = [delete]
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        favoritesCollectionView.isEditing = editing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFavorite = favoritesManager?.getCharacter(at: indexPath.row)
        
        self.performSegue(withIdentifier: "favoriteDetailSegue", sender: Self.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CharacterDetailViewController
        destination.favorite = selectedFavorite
        destination.favoriteFlag = true
        selectedFavorite = nil
    }
    
}
