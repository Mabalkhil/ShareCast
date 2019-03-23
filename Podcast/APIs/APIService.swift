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
    var request: Alamofire.Request?
    var requests = [Alamofire.Request]()
    var downloadProgress = 0.0
    
    typealias EpisodeDownloadCompleteTuple = (fileURL: String, episodeTitle: String)
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
    
    
    func fetchChannels(feedUrls: [String], completionHandler: @escaping ([Podcast]) -> ()){
        var podcasts = [Podcast]()
        for feedUrl in feedUrls{
            guard let url = URL(string: feedUrl) else { return }
            let parser = FeedParser(URL: url)
            parser.parseAsync { (result) in
                
                if let err = result.error{
                    print("failed to parse XML", err)
                    return
                }
                
                guard let feed = result.rssFeed else { return }
                
                var podcast = feed.toChannle()
                podcast.feedUrl = feedUrl
                
                podcasts.append(podcast)
                
                if(podcasts.count == feedUrls.count){
                    completionHandler(podcasts)
                }
                
                
            }
        }
        
    }
    
    
    
    func downloadEpisode(episode: Episode){
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        
       self.request = Alamofire.download(episode.streamURL, to: downloadRequest).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            self.downloadProgress = progress.fractionCompleted
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
        self.requests.append(request!)
    }
    
    
    
    
    
    func deleteEpisode(episode: Episode){
        var filePath:URL
        var count = 0
        if self.downloadProgress < 1{
            
            for req in self.requests {
                if req.description.contains(episode.streamURL) {
                    self.requests[count].cancel()
                    self.requests.remove(at: count)
                }
                count = count + 1
            }

        }else{
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,includingPropertiesForKeys: nil,options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            
            if fileURLs.count > 0 {
                
                filePath = URL(string: episode.fileUrl!)!

            } else {
                print("Could not find local directory to store file")
                return
            }

                try FileManager.default.removeItem(at:filePath)
          
            } catch  { print(error) }
        
        }
    }
    
    
    
    func fetchPodcast(searchText: String, completionHandeler: @escaping ([Podcast]) -> ()) {
        print("searching for podcast, term = " + searchText )
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
