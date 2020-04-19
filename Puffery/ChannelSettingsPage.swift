//
//  ChannelSettingsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct ChannelSettingsPage: View {
    var channel: Channel
    
    @State var hasJustCopiedToken = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(channel.name)
                        .foregroundColor(.secondary)
                }
                
                Button(action: copyTokenToPasteboard) {
                    HStack {
                        Text("Copy Token")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(hasJustCopiedToken ? "Copied!" : channel.token)
                            .lineLimit(1)
                    }
                }
            }
            
            Section {
                Button(action: {}) {
                    Text("Unsubscribe from channel")
                }.accentColor(.red)
            }
        }
        .roundedListStyle()
        .navigationBarTitle("\(channel.name)", displayMode: NavigationBarItem.TitleDisplayMode.inline)
        .navigationBarItems(
            leading: cancelNavigationItem,
            trailing: saveNavigationItem
        )
    }
    
    var saveNavigationItem: some View {
        Button(action: dismiss) {
            Text("Save").fontWeight(.bold)
        }
    }
    
    var cancelNavigationItem: some View {
        Button(action: dismiss) {
            Text("Cancel")
        }
    }
    
    func copyTokenToPasteboard() {
        UIPasteboard.general.string = channel.token
        hasJustCopiedToken = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hasJustCopiedToken = false
        }
    }
    
    func save() {
        dismiss()
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct ChannelSettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelSettingsPage(channel: .puffery)
        }
    }
}
