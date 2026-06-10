//
//  FavoriteService.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import CoreData

struct FavoritesService {
    let context: NSManagedObjectContext
    
    func isFavorite(trackId: Int) -> Bool {
        let request = FavoriteTrack.fetchRequest()
        request.predicate = NSPredicate(format: "trackId == %lld", Int64(trackId))
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
    
    func toggle(track: Track) {
        let request = FavoriteTrack.fetchRequest()
        request.predicate = NSPredicate(format: "trackId == %lld", Int64(track.trackId))
        
        if let existing = try? context.fetch(request), let first = existing.first {
            context.delete(first)
        } else {
            let fav = FavoriteTrack(context: context)
            fav.trackId = Int64(track.trackId)
            fav.trackName = track.trackName
            fav.artistName = track.artistName
            fav.artworkUrl = track.artworkUrl100
            fav.previewUrl = track.previewUrl
            fav.dateAdded = Date()
        }
        try? context.save()
    }
}
