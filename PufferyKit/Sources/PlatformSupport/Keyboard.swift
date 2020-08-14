//
//  Keyboard.swift
//
//
//  Created by Valentin Knabel on 07.05.20.
//

import SwiftUI

public final class Keyboard: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published public private(set) var currentHeight: CGFloat = 0
    @Published public private(set) var isActive: Bool = false

    public init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
            isActive = true
        }
    }

    @objc func keyBoardWillHide(notification _: Notification) {
        currentHeight = 0
        isActive = false
    }
}
