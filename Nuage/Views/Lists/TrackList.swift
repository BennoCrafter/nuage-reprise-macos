//
//  TrackList.swift
//  Nuage
//
//  Created by Laurin Brandner on 23.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud

struct TrackList<Element: Decodable&SoundCloudIdentifiable&Filterable&Hashable>: View {
    
    private var publisher: InfinitePublisher<Element>
    private var transform: (Element) -> Track
    
    @EnvironmentObject private var player: StreamPlayer
    
    var body: some View {
        InfiniteList(publisher: publisher) { elem in
            let track = transform(elem)
            TrackRow(track: track)
                .playbackStart(at: elem) { [transform($0)] }
                .trackContextMenu(with: track)
        }
    }
    
}

extension TrackList where Element == Track {
    
    init(for publisher: AnyPublisher<Page<Track>, Error>) {
        self.init(publisher: .page(publisher)) { $0 }
    }
    
    init(for arrayPublisher: AnyPublisher<[String], Error>,
         page pagePublisher: @escaping ([String]) -> AnyPublisher<[Track], Error>) {
        self.init(publisher: .array(arrayPublisher, pagePublisher), transform: { $0 })
    }
    
    init(for playlistID: String) {
        let ids = SoundCloud.shared.get(.playlist(playlistID))
            .map { $0.trackIDs ?? [] }
            .eraseToAnyPublisher()
        let page = { ids in
            return SoundCloud.shared.get(.tracks(ids))
        }
        self.init(for: ids, page: page)
    }
    
}

extension TrackList where Element == Like<Track> {
    
    init(for publisher: AnyPublisher<Page<Like<Track>>, Error>) {
        self.init(publisher: .page(publisher)) { $0.item }
    }
    
}

extension TrackList where Element == HistoryItem {
    
    init(for publisher: AnyPublisher<Page<HistoryItem>, Error>) {
        self.init(publisher: .page(publisher)) { $0.track }
    }
    
}

//struct TrackList_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackList(publisher: previewTrackPublisher.collect().eraseToAnyPublisher())
//    }
//}
