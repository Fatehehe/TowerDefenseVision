//
//  AppModel.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import ILSHandTracking

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    
    // --- TAMBAHAN: Status Layar Utama ---
    enum GameState {
        case startScreen
        case tutorial
        case playing
    }
    var currentGameState: GameState = .startScreen
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    // Variabel untuk nyimpen status panah dari ECS
    var arrowState: ArcheryState = .idle
}
