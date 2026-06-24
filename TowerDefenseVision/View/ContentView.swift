//
//  ContentView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        // Mengubah tampilan window berdasarkan status game saat ini
        Group {
            switch appModel.currentGameState {
            case .startScreen:
                StartScreenView()
            case .tutorial:
                TutorialView()
            case .playing:
                GameplayHUDView()
            }
        }
        .animation(.easeInOut, value: appModel.currentGameState)
    }
}
