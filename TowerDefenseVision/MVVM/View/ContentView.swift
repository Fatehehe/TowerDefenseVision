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
    @Environment(GameCoordinator.self) var coordinator
    
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
        .onReceive(NotificationCenter.default.publisher(for: .enemyDefeated)) { _ in
            appModel.enemiesDefeated += 1
            print("Musuh mati: \(appModel.enemiesDefeated) / \(appModel.totalEnemiesToWin)")
            
            if appModel.enemiesDefeated >= appModel.totalEnemiesToWin {
                appModel.currentGameState = .won
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .towerDestroyed)) { _ in
            appModel.currentGameState = .lost
        }
    }
}
