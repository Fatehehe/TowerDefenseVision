//
//  ContentView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        Group {
            switch appState.gameCurrentState {
            case .startScreen:
                StartScreenView()
            case .tutorial:
                TutorialView()
            case .loading:
                LoadingView()
            case .playing:
                EmptyView()
            case .won:
                GameResultView(isWin: true)
            case .lost:
                GameResultView(isWin: false)
            }
        }
    }
}
