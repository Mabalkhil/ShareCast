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

extension NSNotification.Name{
    
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete ")
}

class APIService {
    
    typealias EpisodeDownloadCompleteTuple = (fileURL: String, episodeTitle: String)
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
    
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted ])
            
            }.response { (resp) in
                print(resp.destinationURL?.absoluteString ?? "")
        
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(resp.destinationURL?.absoluteString ?? "", episode.title )
                
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                
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
    
    
    func deleteEpisode(episode: Episode){
        let fileNameToDelete = episode.title
        var filePath = ""
        
        // Fine documents directory on device
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        
        if dirs.count > 0 {
            let dir = dirs[0] //documents directory
            filePath = dir.appendingFormat("/" + fileNameToDelete)
           // print("Local path = \(filePath)")
            
        } else {
            print("Could not find local directory to store file")
            return
        }
        let parsed = episode.fileUrl!.replacingOccurrences(of: "file://", with: "")
        let m = parsed.replacingOccurrences(of: ".mp3", with: "")
        print(m)
         print("------------------------------------")
        print(episode.fileUrl!)
        print("------------------------------------")
        print(filePath)
        
        do {
            let fileManager = FileManager.default
                // Delete file
                try fileManager.removeItem(atPath: m)
            try fileManager.removeItem(atPath: filePath)
            
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
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
