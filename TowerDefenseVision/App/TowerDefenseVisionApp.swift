//
//  TowerDefenseVisionApp.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI

@main
struct TowerDefenseVisionApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup(id: "MainWindow") {
            ContentView()
                .environment(appState)
        }

        ImmersiveSpace(id: appState.immersiveSpaceID) {
            ImmersiveView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
