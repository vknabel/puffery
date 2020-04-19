//
//  PufferyApp.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

enum AppMode: Equatable {
    case gettingStarted
    case mainApp
    case blank
}

struct SelectPufferyApp: View {
    @State var mode = AppMode.blank
    
    var body: some View {
        ZStack {
            PufferyApp().show(when: mode == .mainApp)
            GettingStarted().show(when: mode == .gettingStarted)
            
            VStack {
                Button(action: { self.mode = .mainApp }) {
                    Text("New app")
                }
                Button(action: { self.mode = .gettingStarted }) {
                    Text("Getting Started")
                }
            }.show(when: mode == .blank)
        }
    }
}

struct PufferyApp: View {
    var body: some View {
        NavigationView {
            ChannelListView(channels: [.plants, .puffery])
        }
    }
}

extension View {
    func show(when predicate: Bool) -> some View {
        Group {
            if predicate {
                self
            } else {
                hidden()
            }
        }
    }
}



struct PufferyApp_Previews: PreviewProvider {
    static var previews: some View {
        SelectPufferyApp()
    }
}
