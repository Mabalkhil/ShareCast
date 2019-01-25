//
//  APIService.swift
//  Podcast
//
//  Created by MacBook on 03/11/2018.
//  Copyright © 2018 MacBook. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    // Signleton Object
    static let shared = APIService()
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()){
        
        let secureFeedURL = feedUrl.contains("https") ? feedUrl: feedUrl.replacingOccurrences(of: "http", with: "https")
        
        guard let url = URL(string: feedUrl) else { return }
        
        let parser = FeedParser(URL: url)
        
        parser.parseAsync { (result) in
            
            if let err = result.error{
                print("failed to parse XML", err)
                return
            }
            
            guard let feed = result.rssFeed else { return }
            let episodes = feed.toEpisodes()
            completionHandler(episodes)
            
            }
        }
    
    
    func downloadEpisode(episode: Episode){
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(episode.streamURL, to: downloadRequest).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            }.response { (resp) in
                print(resp.destinationURL?.absoluteString ?? "")
        
        
        var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
        
        guard let index = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author }) else{ return }
        
        downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
                
                do{
                    
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
                } catch let err{
                    print("failed to encode with file url update ",err)
                }
      
        }
    }
    
    
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
