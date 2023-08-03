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
    
    init(for publisher: AnyPublisher<Slice<Track>, Error>) {
        self.init(publisher: .slice(publisher)) { $0 }
    }
    
    init(for arrayPublisher: AnyPublisher<[String], Error>,
         slice slicePublisher: @escaping ([String]) -> AnyPublisher<[Track], Error>) {
        self.init(publisher: .array(arrayPublisher, slicePublisher), transform: { $0 })
    }
    
    init(for playlistID: String) {
        let ids = SoundCloud.shared.get(.playlist(playlistID))
            .map { $0.trackIDs ?? [] }
            .eraseToAnyPublisher()
        let slice = { ids in
            return SoundCloud.shared.get(.tracks(ids))
        }
        self.init(for: ids, slice: slice)
    }
    
}

extension TrackList where Element == Like<Track> {
    
    init(for publisher: AnyPublisher<Slice<Like<Track>>, Error>) {
        self.init(publisher: .slice(publisher)) { $0.item }
    }
    
}

extension TrackList where Element == HistoryItem {
    
    init(for publisher: AnyPublisher<Slice<HistoryItem>, Error>) {
        self.init(publisher: .slice(publisher)) { $0.track }
    }
    
}

//struct TrackList_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackList(publisher: previewTrackPublisher.collect().eraseToAnyPublisher())
//    }
//}
