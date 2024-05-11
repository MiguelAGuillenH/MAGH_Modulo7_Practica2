//
//  CharacterServiceManager.swift
//  MarvelApp
//
//  Created by DISMOV on 03/05/24.
//

import Foundation

class CharacterServiceManager {
    private var characters : [Character] = []
    var total : Int = 0
    var offset: Int = 0
    var limit: Int = 0
    var maxItemsLoaded = false
    var isLoading = false
    let session = URLSession(configuration: .default)
    var attribution = ""
        
    func countCharacter() -> Int{
        return characters.count
    }
    
    func getCharacter(at index : Int) -> Character {
        return characters[index]
    }
    
    func loadCharacterData(queryString : String, completion: @escaping ()->Void) {
        let url = URL(string: Constants.apiCharacterUrl+queryString)!
        var loadedCharacters : [Character] = []
        var httpResponse = HTTPURLResponse()
        let request = URLRequest(url: url)
        
        print("URL:",url)
        
        // Creates a data task with a URL request
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: ", error.localizedDescription)
                return
            }
            
            // Check response
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Invalid response")
                httpResponse = (response as? HTTPURLResponse)!
                print("statusCode: ", httpResponse.statusCode)
                return
            }
            
            // Check if there is any data
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Parse and use the data
            do {
                let decodedResponse = try JSONDecoder().decode(APIResponse<Character>.self, from: data)
                loadedCharacters = decodedResponse.data.results
                self.characters.append(contentsOf: loadedCharacters)
                self.total = decodedResponse.data.total
                self.limit = decodedResponse.data.limit
                self.offset = decodedResponse.data.offset
                self.attribution = decodedResponse.attributionHTML
                
                if self.countCharacter() >= self.total{
                    self.maxItemsLoaded = true
                }

            } catch let error{
                print("JSON parsing error: \(error)")
            }
            completion()
        }
        
        // Start the task
        task.resume()
    }
}
