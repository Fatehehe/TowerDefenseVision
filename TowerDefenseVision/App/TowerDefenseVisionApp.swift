//
//  TowerDefenseVisionApp.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI

@main
struct TowerDefenseVisionApp: App {

    @State private var appModel = AppModel()
    @State private var coordinator = GameCoordinator()
    
    init() {
        SystemRegistry.registerAllSystems()
    }

    var body: some Scene {
        WindowGroup(id: "MainWindow") {
//            ContentView()
//                .environment(appModel)
            RootCoordinatorView()
                .environment(coordinator)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(coordinator)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
     }
}
