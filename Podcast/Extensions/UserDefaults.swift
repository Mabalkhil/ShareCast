//
//  UserDefaults.swift
//  Podcast
//
//  Created by assem hakami on 18/05/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let downloadedEpisodeKey = "downloadedEpisodeKey"
    static let playlistsKey = "playlistsKey"
    
    func downloadEpisode(episode: Episode){
        
        do{
            var episodes = downloadedEpisodes()
            
            if episodes.isEmpty {
                episodes.append(episode)
            } else {
                if !episodes.contains(where: { $0.title == episode.title && $0.author == episode.author }) {
                    episodes.insert(episode, at: 0)
                }
            }
            
           // episodes.append(episode)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
            
        }catch let encodeErr {
            
            print("Failed to encode episode", encodeErr)
            
        }
    }
    
    
    func deleteEpisode(episode: Episode) {
        let savedEpisodes = downloadedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
            // you should use episode.collectionId to be safer with deletes
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    
    
    func playlistArray(playlist: Playlist) {
   
        do{
            var playlists = playlistsArray()
            
            if playlists.isEmpty {
                playlists.append(playlist)
            } else {
                if !playlists.contains(where: { $0.playlistName == playlist.playlistName}) {
                    playlists.insert(playlist, at: 0)
                }
            }
            
            let data = try JSONEncoder().encode(playlists)
            UserDefaults.standard.set(data, forKey: UserDefaults.playlistsKey)
            
        }catch let encodeErr {
            
            print("Failed to encode playlist", encodeErr)
            
        }
      
    }
    
    
    
    
    func  downloadedEpisodes() -> [Episode]{
        
        guard let episodesData = UserDefaults.standard.data(forKey: UserDefaults.downloadedEpisodeKey) else { return []}
        
        do{
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            
            return episodes
        }catch let decodeErr{
            print("failed to decode:",decodeErr)
        }
        
        return []
    }
    
    
    
    func  playlistsArray() -> [Playlist]{
        
        guard let playlistsData = UserDefaults.standard.data(forKey: UserDefaults.playlistsKey) else { return []}
        
        do{
            let playlists = try JSONDecoder().decode([Playlist].self, from: playlistsData)
            
            return playlists
        }catch let decodeErr{
            print("failed to decode:",decodeErr)
        }
        
        return []
    }
    
    
    
    
    
}
