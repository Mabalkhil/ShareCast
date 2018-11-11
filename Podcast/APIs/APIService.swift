//
//  APIService.swift
//  Podcast
//
//  Created by MacBook on 03/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation
import Alamofire
class APIService {
    // Signleton Object
    static let shared = APIService()
    
    func fetchPodcast(searchText: String, completionHandeler: @escaping ([Podcast]) -> ()) {
        print("searching for podcast")
        //iTunesAPI
        let url = "https://itunes.apple.com/search"
        //Parameters for the API
        let parameters = ["term":searchText, "media":"podcast"]
        
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("Failed to Connect to \(url)",err)
                return
            }
            guard let data = dataResponse.data else {return}
            do{
                let searchResult = try
                    JSONDecoder().decode(SearchResults.self, from:data)
                completionHandeler(searchResult.results)
            } catch let decodeErr {
                print("Faild to decode",decodeErr)
            }
        }
    }
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
