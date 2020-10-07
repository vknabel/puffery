//
//  ChannelSettingsPage.swift
//  Puffery
//
//  Created by Valentin Knabel on 19.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI
import PlatformSupport

struct ChannelSettingsPage: View {
    @State var channel: Channel

    @State var hasJustCopiedPrivateToken = false
    @State var hasJustCopiedPublicToken = false
    @State var displaysUnsubscribePrompt = false
    @State var subscriptionToken: String?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        List {
            Section {
                HStack {
                    Text("ChannelSettings.Basic.Name")
                    Spacer()
                    Text(channel.title)
                        .foregroundColor(.secondary)
                }

                Toggle("ChannelSettings.Basic.ReceiveNotifications", isOn: Binding(get: { !self.channel.isSilent }, set: self.registerAndSetReceiveNotifications))
            }

            Section(header: Text("ChannelSettings.Share.SectionTitle"), footer: Text("ChannelSettings.Share.Explanation")) {
                channel.notifyKey.map { notifyKey in
                    CopyContentsCell(
                        title: "ChannelSettings.Share.NotifyKey",
                        teaser: "\(String(notifyKey.prefix(8)))…",
                        contents: "\(notifyKey)"
                    )
                }
                channel.notifyKey.map { notifyKey in
                    Button(action: { self.subscriptionToken = notifyKey }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                            Text("ChannelSettings.Share.InvitePublishers")
                        }
                    }
                }

                CopyContentsCell(
                    title: "ChannelSettings.Share.ReceiveOnlyKey",
                    teaser: "\(String(channel.receiveOnlyKey.prefix(8)))…",
                    contents: "\(channel.receiveOnlyKey)"
                )
                Button(action: { self.subscriptionToken = self.channel.receiveOnlyKey }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                        Text("ChannelSettings.Share.InviteSubscribers")
                    }
                }
            }

            channel.notifyKey.map { notifyKey in
                Section(header: Text("ChannelSettings.HowTo.SectionTitle")) {
                    CopyContentsCell(
                        title: "ChannelSettings.HowTo.CURL.Title",
                        teaser: "ChannelSettings.HowTo.CURL.Teaser url:\(Current.config.apiURL.absoluteString)",
                        contents: String(format: NSLocalizedString("ChannelSettings.HowTo.CURL.Contents url:%@ notify:%@ title:%@", comment: ""), Current.config.apiURL.absoluteString, notifyKey, channel.title)
                    )

                    CopyContentsCell(
                        title: "ChannelSettings.HowTo.Email.Title",
                        teaser: "ChannelSettings.HowTo.Email.Teaser",
                        contents: String(format: NSLocalizedString("ChannelSettings.HowTo.Email.Contents notify:%@", comment: ""), notifyKey)
                    )

                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://www.icloud.com/shortcuts/3596f5d512404b2f9e19e488d4bbf3a0")!)
                    }) {
                        Text("ChannelSettings.HowTo.Shortcuts.Action")
                    }
                }
            }

            Section {
                Button(action: requestUnsubscribe) {
                    Text("ChannelSettings.Actions.Unsubscribe")
                }
                .accentColor(.red)
                .alert(isPresented: $displaysUnsubscribePrompt) { () -> Alert in
                    Alert(
                        title: Text("ChannelSettings.ConfirmUnsubscribe.Title"),
                        message: Text("ChannelSettings.ConfirmUnsubscribe.Message"),
                        primaryButton: Alert.Button.cancel(),
                        secondaryButton: Alert.Button.destructive(
                            Text("ChannelSettings.ConfirmUnsubscribe.Unsubscribe"),
                            action: performUnsubscribe
                        )
                    )
                }
            }
        }
        .roundedListStyle()
        .sheet(string: $subscriptionToken) { subscriptionToken in
            ShareSheet(
                activityItems: [
                    "puffery://puffery.app/channels/subscribe/\(subscriptionToken)",
                ],
                applicationActivities: nil,
                completionWithItemsHandler: nil
            )
        }
        .navigationBarTitle("\(channel.title)", displayMode: NavigationBarItem.TitleDisplayMode.inline)
        .navigationBarItems(trailing: saveNavigationItem)
        .trackAppearence("channels/:id/settings", using: Current.tracker)
    }

    var saveNavigationItem: some View {
        Button(action: dismiss) {
            Text("ChannelSettings.Actions.Done").fontWeight(.bold)
        }
    }

    func requestUnsubscribe() {
        displaysUnsubscribePrompt = true
    }

    func performUnsubscribe() {
        presentationMode.wrappedValue.dismiss()

        Current.api.unsubscribe(channel).task { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(Notification(name: .didUnsubscribeFromChannel))
            }
        }
    }

    func registerAndSetReceiveNotifications(_ newValue: Bool) {
        if newValue == true, !PushNotifications.hasBeenRequested {
            PushNotifications.register {
                self.channel.isSilent = !newValue
            }
        } else {
            channel.isSilent = !newValue
        }

        Current.api.update(subscription: channel, updateSubscription: UpdateSubscriptionRequest(isSilent: channel.isSilent))
            .task { _ in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .didChangeChannel, object: nil)
                }
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
    var contents: String

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
