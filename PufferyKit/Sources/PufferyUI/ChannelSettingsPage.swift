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

    @State var hasJustCopiedPrivateToken = false
    @State var hasJustCopiedPublicToken = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        List {
            Section(footer: Text("Share the Notify Key to allow others to BLARGH. If sufficient, just share the Receive Only Key to allow others to get BLARGHed.")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(channel.title)
                        .foregroundColor(.secondary)
                }

                channel.notifyKey.map { notifyKey in
                    CopyContentsCell(
                        title: "Notify Key",
                        teaser: notifyKey,
                        contents: notifyKey
                    )
                }
                
                CopyContentsCell(
                    title: "Receive Only Key",
                    teaser: channel.receiveOnlyKey,
                    contents: channel.receiveOnlyKey
                )
            }
            
            channel.notifyKey.map { notifyKey in
                Section(header: Text("How can I BLARGH!?")) {
                    CopyContentsCell(
                        title: "Using CURL",
                        teaser: "curl \(Current.config.apiURL.absoluteString)/notify/:notify-key",
                        contents: """
                        curl "\(Current.config.apiURL.absoluteString)/notify/\(notifyKey)" \\
                        --form-string "title=Hello from \(channel.title)" \\
                        --form-string "body=Some details" \\
                        --form-string "color=green"
                        """
                    )
                    
                    CopyContentsCell(
                        title: "Using E-Mail",
                        teaser: ":notify-key@parse.puffery.app",
                        contents: "\(notifyKey)@parse.puffery.app"
                    )
                    
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://www.icloud.com/shortcuts/3596f5d512404b2f9e19e488d4bbf3a0")!)
                    }) {
                        Text("Add to Shortcuts")
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
        .navigationBarTitle("\(channel.title)", displayMode: NavigationBarItem.TitleDisplayMode.inline)
        .navigationBarItems(
            leading: cancelNavigationItem,
            trailing: saveNavigationItem
        ).onAppear { Current.tracker.record("channels/:id/settings") }
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

    func save() {
        dismiss()
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct CopyContentsCell: View {
    @State var hasJustCopied = false
    
    var title: String
    var teaser: String
    var contents: String
    
    var body: some View {
        Button(action: copyToPasteboard) {
            HStack {
                Text(title).foregroundColor(.primary)
                Spacer()
                Text(hasJustCopied ? "Copied!" : teaser)
                        .lineLimit(1)
            }
        }
    }
    
    func copyToPasteboard() {
        UIPasteboard.general.string = contents
        hasJustCopied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hasJustCopied = false
        }
    }
}

#if DEBUG
    struct ChannelSettingsPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                ChannelSettingsPage(channel: .puffery)
            }
        }
    }
#endif
