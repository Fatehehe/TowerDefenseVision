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
        Group {
            switch appModel.currentGameState {
            case .startScreen:
                StartScreenView()
            case .loading:
                LoadingView()
            case .tutorial:
                TutorialView()
            case .playing:
                Color.clear
            case .won:
                GameResultView(isWin: true)
            case .lost:
                GameResultView(isWin: false)
            }
        }
        .animation(.easeInOut, value: appModel.currentGameState)
    }
}
