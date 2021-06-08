//
//  MessageCreationPage.swift
//  
//
//  Created by Valentin Knabel on 18.05.21.
//

import SwiftUI
import Combine
import DesignSystem

@available(iOS 14.0, *)
struct MessageCreationPage: View {
    var channel: Channel
    @State var title = ""
    @State var text = ""
    @State var color: Message.Color? = .gray
    @State var isBusy = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Form {
            Section {
                TextField("CreateMessage.MessageTitle", text: $title)
                    .disabled(isBusy)
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("CreateMessage.MessageText")
                            .opacity(0.3)
                            .padding(.top, 3)
                    }
                    TextEditor(text: $text)
                        .frame(minHeight: 150)
                        .disabled(isBusy)
                        .padding([.leading, .trailing, .top], -5)
                }
                MessageColorPicker(selection: $color)
                    .disabled(isBusy)
            }
            Section { createButton }
        }
        .navigationBarTitle("CreateMessage.Title", displayMode: NavigationBarItem.TitleDisplayMode.inline)
        .navigationBarItems(
            leading: cancelNavigationItem,
            trailing: createButton
        )
    }
    
    var cancelNavigationItem: some View {
        Button("CreateMessage.Cancel", action: dismiss)
            .disabled(isBusy)
    }

    var createButton: some View {
        Button("CreateMessage.Create", action: createMessage)
            .disabled(isBusy || text.isEmpty || title.isEmpty)
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    func createMessage() {
        isBusy = true
        _ = Current.api.notify(
            key: channel.notifyKey!,
            CreateMessageRequest(
                title: title,
                body: text,
                color: color?.rawValue
            )
        ).task { response in
            isBusy = false
            dismiss()
        }
    }
}

#if DEBUG
    @available(iOS 14.0, *)
    struct MessageCreationPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                MessageCreationPage(channel: .plants)
            }
        }
    }
#endif

struct MessageColorPicker: View {
    @Binding var selection: Message.Color?
    var options = Message.Color.allCases
    
    var body: some View {
        HStack {
            ForEach(options) { messageColor in
                Button(action: { toggleSelection(messageColor) }, label: {
                    Circle()
                        .stroke(isSelected(messageColor) ? messageColor.color : .clear, lineWidth: 2)
                        .background(Circle().fill(messageColor.color).padding(4))
                }).buttonStyle(BorderlessButtonStyle())
            }
        }
    }

    func isSelected(_ color: Message.Color?) -> Bool {
        selection == color
    }

    func toggleSelection(_ value: Message.Color?) {
        if selection == value {
            selection = nil
        } else {
            selection = value
        }
    }
}

#if DEBUG
    struct MessageColorPicker_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                MessageColorPicker(selection: .constant(nil))
                MessageColorPicker(selection: .constant(Message.Color.green))
            }.padding()
        }
    }
#endif
