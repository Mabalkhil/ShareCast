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
    static let bookmarkedEpisodeKey = "bookmarkedEpisodeKey"
    static let trackedEpisodeKey = "trackedEpisodeKey"
    
    
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
    
  
    // delete an episode inside a playlist
    func deletePlaylistEpisode(episode: Episode, name: String) {
        let savedEpisodes = playlistEpisodes(name: name)
        let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
            // you should use episode.collectionId to be safer with deletes
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: "savedArrayKey"+name)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    
    // delete a playlist
    func deletePlaylist(playlist: Playlist, name: String) {
        let savedPlaylists = playlistsArray()
        var savedEpisoodesInPlaylist = playlistEpisodes(name: "savedArrayKey"+name)
        let filteredEpisodes = savedPlaylists.filter { (p) -> Bool in
            // you should use episode.collectionId to be safer with deletes
            return p.playlistName != playlist.playlistName
        }

        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            let episodeData = try JSONEncoder().encode(savedEpisoodesInPlaylist)
            savedEpisoodesInPlaylist.removeAll()
            UserDefaults.standard.set(data, forKey: UserDefaults.playlistsKey)
            UserDefaults.standard.set(episodeData, forKey: "savedArrayKey"+name)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    
    
    // adding a new playlist inside the playlists array
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
    
    
     // adding a new episode inside a playlist
    func playlistEpisode(episode: Episode,name: String){
        
        do{
            var episodes = playlistEpisodes(name: name)
            
            if episodes.isEmpty {
                episodes.append(episode)
            } else {
                if !episodes.contains(where: { $0.title == episode.title && $0.author == episode.author }) {
                    episodes.insert(episode, at: 0)
                }
            }
            

            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: "savedArrayKey"+name)
            
        }catch let encodeErr {
            
            print("Failed to encode episode", encodeErr)
            
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
    
    func addBookmark(episode: Episode){
        do{
            var episodes = bookmarkedEpisodes()
            
            if episodes.isEmpty {
                episodes.append(episode)
            } else {
                if !episodes.contains(where: { $0.title == episode.title && $0.author == episode.author }) {
                    episodes.insert(episode, at: 0)
                }
            }
            
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.bookmarkedEpisodeKey)
            
        }catch let encodeErr {
            
            print("Failed to encode episode", encodeErr)
            
        }
        
    }
    func bookmarkedEpisodes() -> [Episode]{
        guard let episodesData = UserDefaults.standard.data(forKey: UserDefaults.bookmarkedEpisodeKey) else { return []}
        
        do{
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            
            return episodes
        }catch let decodeErr{
            print("failed to decode:",decodeErr)
        }
        
        return []
    }
    
    
    // array of playlists
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
    
    // episodes inside a playlist
    func  playlistEpisodes(name: String) -> [Episode]{
        
        guard let playlistEpisodesData = UserDefaults.standard.data(forKey: "savedArrayKey"+name) else { return []}
        
        do{
            let episodes = try JSONDecoder().decode([Episode].self, from: playlistEpisodesData)
            
            return episodes
        }catch let decodeErr{
            print("failed to decode:",decodeErr)
        }
        
        return []
    }
    
    // adding a new episode inside a playlist
    func trackedEpisode(episodeTitle: String, time: Double){
        do{
            var episodes = trackedEpisodes()
            
            if episodes.isEmpty {
                episodes[episodeTitle] = time
            } else {
                if (episodes[episodeTitle] != nil) {
                    episodes[episodeTitle] = time
                }
                else {
                     episodes[episodeTitle] = time
                }
            }
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.trackedEpisodeKey)
            
        }catch let encodeErr {
            print("Failed to encode episode", encodeErr)
            
        }
    }
    
    
    // episodes inside a playlist
    func  trackedEpisodes() -> [String: Double]{
        guard let trackedEpisodesData = UserDefaults.standard.data(forKey: UserDefaults.trackedEpisodeKey) else { return [:]}
        do{
            let episodes = try JSONDecoder().decode([String:Double].self, from: trackedEpisodesData)
            print(episodes)
            return episodes
        }catch let decodeErr{
            print("failed to decode:",decodeErr)
        }
        
        return [:]
    }
    
    func deleteBookmarkedEpisode(episode: Episode) {
        let savedEpisodes = bookmarkedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
            // you should use episode.collectionId to be safer with deletes
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.bookmarkedEpisodeKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
}
