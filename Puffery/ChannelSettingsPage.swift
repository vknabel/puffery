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
            Section {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(channel.title)
                        .foregroundColor(.secondary)
                }

                Button(action: copyPrivateTokenToPasteboard) {
                    HStack {
                        Text("Private Token")
                            .foregroundColor(.primary)
                        Spacer()
                        channel.token.map { token in
                            Text(hasJustCopiedPrivateToken ? "Copied!" : token)
                                .lineLimit(1)
                        }
                    }
                }

                Button(action: copyPublicTokenToPasteboard) {
                    HStack {
                        Text("Public Token")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(hasJustCopiedPublicToken ? "Copied!" : channel.publicId)
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
        .navigationBarTitle("\(channel.title)", displayMode: NavigationBarItem.TitleDisplayMode.inline)
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

    func copyPrivateTokenToPasteboard() {
        UIPasteboard.general.string = channel.token
        hasJustCopiedPrivateToken = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hasJustCopiedPrivateToken = false
        }
    }

    func copyPublicTokenToPasteboard() {
        UIPasteboard.general.string = channel.publicId
        hasJustCopiedPublicToken = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hasJustCopiedPublicToken = false
        }
    }

    func save() {
        dismiss()
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
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
