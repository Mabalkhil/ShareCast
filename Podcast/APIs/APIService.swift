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
    var categories = [Category]()
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()){
        
        
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
        print("------------------------------------")
        //print(episode.fileUrl!)
        print("------------------------------------")
       // print(filePath)
        
        do {
            let fileManager = FileManager.default
            // Delete file
            //try fileManager.removeItem(atPath: m)
            try fileManager.removeItem(atPath: filePath)
          // try fileManager.removeItem(atPath: episode.fileUrl!)
            //try fileManager.removeItem(at: URL.init(fileURLWithPath: m))
            //try fileManager.removeItem(at: URL.init(fileURLWithPath: parsed))
            //let url1 = URL(string: episode.fileUrl!)
           // let url2 = URL(string: filePath)
//           print(fileManager.fileExists(atPath: episode.fileUrl!))
//           print(fileManager.fileExists(atPath: m))
//            print(fileManager.fileExists(atPath: parsed))
//            print(fileManager.fileExists(atPath: filePath))
            //print(fileManager.fileExists(atPath: (url1?.path)!))

            
            
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
    }
    
    
    func fetchPodcast(searchText: String, attribute : String = "None", completionHandeler: @escaping ([Podcast]) -> ()) {
        print("searching for podcast, term = " + searchText )
        //iTunesAPI
        let url = "https://itunes.apple.com/search"
        //Parameters for the API
        var parameters = ["term":searchText, "media":"podcast"]
        if(attribute != "None"){
            parameters["attribute"] = attribute
        }
        
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
    
    //    func fetchDiscover(completionHandeler: @escaping ([Category]) -> ()) {
    //        //iTunesAPI
    //        // The golbal variable categories is for this method, it was defined there to be used in line1 125
    //        // Ideally the variable should be defiende inside the function, but there's a referencing problem
    //        //This is a dictiory that will be used to link the genreId/Category ID, with the its name
    //        let categoriesDict = ["News & Politices": "1311", "Comedy": "1303", "Science & Medicine": "1315",
    //                          "Technology": "1318", "Business": "1321", "Games & Hubbies": "1323", "Society & Culture": "1324"]
    //        // This list of categories will be sent to the DiscoverController to be displayed overthere
    //
    //        for (name, id) in categoriesDict {
    //            // This list of categories will be sent to the DiscoverController to be displayed overthere
    //            //Here we specify that the search attribute is for the genreIndex
    //            //So we can use the ids in the categories dict to look for podcasts
    //            fetchPodcast(searchText: name) { (podcasts) in
    //
    //                // After getting a list of podcasts from the search of the genreIndex, we constuct
    //                // a catogry with the name of the catorgry that we searched for and the returned searhc resluts
    //                let cate = Category(title: name, podcasts:podcasts)
    //                print(name)
    //                // we append all the categories in the loop to the golbal varibal categories
    //                self.categories += [cate]
    //
    //            }
    //        }
    //        //fetchPodcast(searchText: id, attribute : "genreIndex")
    //        print(self.categories.count)
    //        completionHandeler(self.categories)
    //
    //
    //
    //    }
    
    
    func fetchDiscover(completionHandeler: @escaping ([Category]) -> ()) {
        //iTunesAPI
        // The golbal variable categories is for this method, it was defined there to be used in line1 125
        // Ideally the variable should be defiende inside the function, but there's a referencing problem
        //This is a dictiory that will be used to link the genreId/Category ID, with the its name
        let categoriesDict = ["News": "1311", "Comedy": "1303", "Science & Medicine": "1315",
                              "Technology": "1318", "Business": "1321", "Games": "1323", "Society & Culture": "1324"]
        // This list of categories will be sent to the DiscoverController to be displayed overthere
        
        //In every itration in the following loop, an ITunes API search call will be sent with
        //The terms in categoriesDict.
        // After the last iteration completetion handelr will be called
        var count = categoriesDict.count //This will count the number of iterations
        for (name, id) in categoriesDict {
            count = count - 1  // count decremint
            // This list of categories will be sent to the DiscoverController to be displayed overthere
            //Here we specify that the search attribute is for the genreIndex
            //So we can use the ids in the categories dict to look for podcasts
            print("searching for podcast, term = " + name )
            //iTunesAPI
            let url = "https://itunes.apple.com/search"
            //Parameters for the API
            let parameters = ["term":name, "media":"podcast"]
            
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
                
                if let err = dataResponse.error {
                    print("Failed to Connect to \(url)",err)
                    return
                }
                guard let data = dataResponse.data else {return}
                do{
                    let searchResult = try
                        JSONDecoder().decode(SearchResults.self, from:data)
                    let cate = Category(title: name, podcasts:searchResult.results)
                    print(name+" has \(searchResult.results.count) results")
                    
                    // we append all the categories in the loop to the golbal varibal categories
                    self.categories.append(cate)
                    //Check if this the last iteration to call the completionHandeler
                    if(count == 0){
                        completionHandeler(self.categories)
                    }
                    
                } catch let decodeErr {
                    print("Faild to decode",decodeErr)
                    
                }
            }
        }
        //fetchPodcast(searchText: id, attribute : "genreIndex")
        completionHandeler(self.categories)
        
        
        
    }
    
}
