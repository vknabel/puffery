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
            Section(footer: Text("ChannelSettings.Basic.Explanation")) {
                HStack {
                    Text("ChannelSettings.Basic.Name")
                    Spacer()
                    Text(channel.title)
                        .foregroundColor(.secondary)
                }

                channel.notifyKey.map { notifyKey in
                    CopyContentsCell(
                        title: "ChannelSettings.Basic.NotifyKey",
                        teaser: "\(notifyKey)",
                        contents: "\(notifyKey)"
                    )
                }
                
                CopyContentsCell(
                    title: "ChannelSettings.Basic.ReceiveOnlyKey",
                    teaser: "\(channel.receiveOnlyKey)",
                    contents: "\(channel.receiveOnlyKey)"
                )
            }
            
            channel.notifyKey.map { notifyKey in
                Section(header: Text("ChannelSettings.HowTo.SectionTitle")) {
                    CopyContentsCell(
                        title: "ChannelSettings.HowTo.CURL.Title",
                        teaser: "ChannelSettings.HowTo.CURL.Teaser url:\(Current.config.apiURL.absoluteString)",
                        contents: "ChannelSettings.HowTo.CURL.Contents url:\(Current.config.apiURL.absoluteString) notify:\(notifyKey) title:\(channel.title)"
                    )
                    
                    CopyContentsCell(
                        title: "ChannelSettings.HowTo.Email.Title",
                        teaser: "ChannelSettings.HowTo.Email.Teaser",
                        contents: "ChannelSettings.HowTo.Email.Contents notify:\(notifyKey)"
                    )
                    
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://www.icloud.com/shortcuts/3596f5d512404b2f9e19e488d4bbf3a0")!)
                    }) {
                        Text("ChannelSettings.HowTo.Shortcuts.Action")
                    }
                }
            }
            
            Section {
                Button(action: {}) {
                    Text("ChannelSettings.Actions.Unsubscribe")
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
            Text("ChannelSettings.Actions.Save").fontWeight(.bold)
        }
    }

    var cancelNavigationItem: some View {
        Button(action: dismiss) {
            Text("ChannelSettings.Actions.Cancel")
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
    
    var title: LocalizedStringKey
    var teaser: LocalizedStringKey
    var contents: LocalizedStringKey
    
    var body: some View {
        Button(action: copyToPasteboard) {
            HStack {
                Text(title).foregroundColor(.primary)
                Spacer()
                Text(hasJustCopied ? "ChannelSettings.HowTo.Copied" : teaser)
                        .lineLimit(1)
            }
        }
    }
    
    func copyToPasteboard() {
        UIPasteboard.general.string = String(describing: contents)
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
