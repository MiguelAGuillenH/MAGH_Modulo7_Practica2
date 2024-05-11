//
//  ViewController.swift
//  MarvelApp
//
//  Created by Rafael González on 30/04/24.
//

import UIKit
import SDWebImage

class CharactersViewController: UIViewController {
    
    @IBOutlet weak var characterCollectionView: UICollectionView!
    @IBOutlet weak var attributionLabel: UITextView!
    
    var keyLoader = KeyLoader.shared
    var characterManager: CharacterServiceManager?
    var selectedCharacter: Character?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //CoreData context
    var favoritesManager: FavoritesManager?
    var selectedFavorite: DBCharacter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //print(keyLoader.getAPIParams())
        //print(keyLoader.getQueryString())
        
        characterCollectionView.delegate = self
        characterCollectionView.dataSource = self
        
        characterManager = CharacterServiceManager()
        
        characterManager?.loadCharacterData(queryString: keyLoader.getQueryString(limit: Constants.numberOfItemsRequested, offset: 0)){
            DispatchQueue.main.async {
                print("Completion executed!!!")
                self.characterCollectionView.reloadData()
                self.characterManager?.offset = (self.characterManager?.countCharacter())!
                let attrString = self.characterManager?.attribution.htmlAttributedString()
                self.attributionLabel.linkTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont(name: "American Typewriter", size: CGFloat(15))!
                ]
                self.attributionLabel.attributedText = attrString
                self.attributionLabel.textAlignment = .center
            }
        }
        
        favoritesManager = FavoritesManager(context: context)
        favoritesManager?.fetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        favoritesManager?.fetch()
    }
    
}

extension CharactersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (characterManager?.countCharacter())!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CharacterCell
        let character = characterManager?.getCharacter(at: indexPath.row)
        cell.characterName.text = character?.name
        
        let url = URL(string: (character?.thumbnail.url)!)
        cell.characterImage.sd_setImage(with: url)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCharacter = characterManager?.getCharacter(at: indexPath.row)
        selectedFavorite = favoritesManager?.getCharacterById(id: Int64(selectedCharacter!.id))
        
        self.performSegue(withIdentifier: "characterDetailSegue", sender: Self.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CharacterDetailViewController
        destination.character = selectedCharacter
        destination.favorite = selectedFavorite
        selectedCharacter = nil
        selectedFavorite = nil
    }
    
}

extension CharactersViewController : UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Size of scrollview content
        //print("contentSize.height", scrollView.contentSize.height)

        //Screen's available space for scrollview element
        //print("bounds.height:", scrollView.bounds.height)
        
        //contentOffset y = contentSize.height - bounds.height
        //print("contentOffset y:", scrollView.contentOffset.y)
                
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollviewHeight = scrollView.bounds.height
        
        if (offsetY > (contentHeight - scrollviewHeight)) && (!(characterManager?.maxItemsLoaded)! && !(characterManager!.isLoading) ){
            print("calling API...")
            self.characterManager?.isLoading = true
            let queryString = keyLoader.getQueryString(limit: Constants.numberOfItemsRequested, offset: self.characterManager!.offset)
            //print("qs:",queryString)
        
            self.characterManager?.loadCharacterData(queryString: queryString){
                DispatchQueue.main.async {
                    self.characterCollectionView.reloadData()
                    print("char com:",(self.characterManager?.countCharacter())!)
                    print("actual offset: ", (self.characterManager?.offset)!)
                    self.characterManager?.offset = (self.characterManager?.countCharacter())!
                    print("new offset: ", (self.characterManager?.offset)!)
                    self.characterManager?.isLoading = false
                }
            }
        }
        else{
            //print("Don't call API...")
        }
    }
    
}
