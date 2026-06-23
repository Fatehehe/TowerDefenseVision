//
//  TowerDefenseVisionApp.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import ILSHandTracking

@main
struct TowerDefenseVisionApp: App {

    @State private var appModel = AppModel()
    
    init() {
        SystemRegistry.registerAllSystems()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
