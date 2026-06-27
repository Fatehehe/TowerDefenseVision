//
//  RootCoordinatorView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 26/06/26.
//

import SwiftUI

struct RootCoordinatorView: View {
    @Environment(GameCoordinator.self) private var coordinator
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        MainMenuView()
            .onChange(of: coordinator.currentRoute) { oldRoute, newRoute in
                Task{
                    if newRoute == .game{
                        await openImmersiveSpace(id: "ImmersiveSpace")
                        dismissWindow(id: "MainWindow")
                    }else if newRoute == .menu{
                        openWindow(id: "MainWindow")
                        await dismissImmersiveSpace()
                    }
                }
            }
    }
}
