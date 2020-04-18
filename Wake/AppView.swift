//
//  ContentView.swift
//  Wake
//
//  Created by Valentin Knabel on 13.04.20.
//  Copyright © 2020 Valentin Knabel. All rights reserved.
//

import SwiftUI

struct Notification: Identifiable {
    var id: UUID = UUID()
    
    var title: String
    var sender: Sender
    var triggerDate: Date
    var color: Color // TODO: Later own type
}

enum Icon {
    case computer
}

extension Icon {
    var imageView: some View {
        switch self {
        case .computer:
            return Image(systemName: "desktopcomputer")
        }
    }
}

struct Sender: Identifiable {
    var id: UUID = UUID()
    
    var name: String
    var icon: Icon
}

let terminalSender = Sender(name: "My MacBook", icon: .computer)

struct AppView: View {
    @State var messages = [
        Notification(title: "Build completed", sender: terminalSender, triggerDate: .init(timeIntervalSinceNow: -100), color: .green),
        Notification(title: "Build completed", sender: terminalSender, triggerDate: .init(timeIntervalSinceNow: -100), color: .accentColor)
    ]
    @State var senders = [
        terminalSender
    ]
    
    var body: some View {
        TabView {
            NavigationView {
                NotificationsView(messages: messages)
            }.tabItem {
                Image(systemName: "bell.fill")
                Text("Notifications")
            }
            
            NavigationView {
                SendersView(senders: $senders)
                    .multilineTextAlignment(.center)
            }.tabItem {
                Image(systemName: "arrow.up.right.diamond.fill")
                Text("Senders")
            }
        }
    }
}

struct NotificationsView: View {
    let messages: [Notification]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                ForEach(messages) { message in
                    NotificationCellView(message: message)
                }
            }
            .padding()
            .navigationBarItems(trailing: Button(action: {}, label: {Image(systemName: "equal.circle")}))
            .navigationBarTitle("Inbox")
        }
    }
}

struct NotificationCellView: View {
    let message: Notification
    
    var body: some View {
        HStack {
            message.sender.icon.imageView
            VStack(alignment: .leading) {
                Text(message.title)
                    .font(.headline)
                Text(message.sender.name)
                    .font(.subheadline)
            }
        }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .background(message.color)
            .colorScheme(ColorScheme.dark)
            .cornerRadius(15)
            .shadow(radius: 8)
    }
}

struct SendersView: View {
    @Binding var senders: [Sender]
    
    @State var displaysNewSenderSheet: Bool = false
    
    var body: some View {
        List(senders) { sender in
            HStack {
                sender.icon.imageView
                VStack(alignment: .leading) {
                    Text(sender.name)
                }
            }
        }
        .navigationBarTitle("Senders")
        .navigationBarItems(
            trailing: Button(action: {
                self.displaysNewSenderSheet.toggle()
            },
            label: {
                Image(systemName: "plus.circle")
                    .sheet(isPresented: $displaysNewSenderSheet) {
                        CreateNewSenderView { sender in
                            self.senders.append(sender)
                            self.displaysNewSenderSheet = false
                        }
                }
            })
        )
    }
}

struct CreateNewSenderView: View {
    @State var name = ""
    
    let didCreateSender: (Sender) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Create new sender")
            TextField("Name", text: $name)
            
            Button(action: {
                self.didCreateSender(Sender(name: self.name, icon: .computer))
            }) {
                Image(systemName: "plus")
                Text("Create")
            }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }.padding()
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
