//
//  MessageList.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct MessageList: View {
    let messages: [Message]
    let loadNextPage: (() -> Void)?

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 16) {
                ForEach(Array(messages.enumerated()), id: \.element.id) { (index, message) in
                    MessageCell(message: message)
                        .onAppear {
                            loadNextPageIfNeeded(index)
                        }
                }
            }
            .padding()
        }
    }
    
    private func loadNextPageIfNeeded(_ index: Int) {
        if index == messages.count - 1 {
            loadNextPage?()
        }
    }
}

#if DEBUG
    struct MessageList_Previews: PreviewProvider {
        static var previews: some View {
            MessageList(messages: [
                .testflight,
                .dockerImage,
            ], loadNextPage: nil)
        }
    }
#endif
