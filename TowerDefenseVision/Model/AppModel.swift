//
//  AppModel.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import ILSHandTracking

@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    
    enum GameState {
        case startScreen
        case loading
        case tutorial
        case playing
        case won   // 🎉 Kondisi Menang
        case lost  // 💀 Kondisi Kalah
    }
    
    var currentGameState: GameState = .startScreen
    
    enum ImmersiveSpaceState {
        case closed, inTransition, open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    var arrowState: ArcheryState = .idle
    
    // --- TAMBAHAN TRACKING WIN/LOSE ---
    var enemiesDefeated: Int = 0
    var totalEnemiesToWin: Int = 3 // Sesuaikan dengan jumlah maxEnemies di Portal
}
