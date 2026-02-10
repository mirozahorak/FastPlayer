//
//  MenuActions.swift
//  FastPlayer
//
//  Created by Miroslav Zahorak on 2/10/26.
//

import SwiftUI

protocol MenuActions {
    func openFile()
    func playPause()
    func stop()
    func seekToStart()
    func rewind()
    func forward()
    func increaseSpeed()
    func decreaseSpeed()
    func resetSpeed()
}

struct MenuActionsKey: FocusedValueKey {
    typealias Value = MenuActions
}

extension FocusedValues {
    var menuActions: MenuActionsKey.Value? {
        get { self[MenuActionsKey.self] }
        set { self[MenuActionsKey.self] = newValue }
    }
}
