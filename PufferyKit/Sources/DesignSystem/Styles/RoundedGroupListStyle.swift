//
//  RoundedGroupListStyle.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

extension View {
    public func roundedListStyle() -> some View {
        #if canImport(AppKit)
            return listStyle(DefaultListStyle())
        #else
            return listStyle(GroupedListStyle())
        #endif
    }
}

#if DEBUG
    struct RoundedGroupListStyle_Previews: PreviewProvider {
        static var previews: some View {
            List {
                Section {
                    Text("Hello")
                    Text("World")
                }
            }
            .roundedListStyle()
        }
    }
#endif
