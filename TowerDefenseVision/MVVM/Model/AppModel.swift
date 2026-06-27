//
//  AppModel.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI

@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    
    enum GameState {
        case startScreen, loading, tutorial, playing
        case won
        case lost
    }
    var currentGameState: GameState = .startScreen
    
    enum ImmersiveSpaceState {
        case closed, inTransition, open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    var arrowState: ArcheryState = .idle
    
    var enemiesDefeated: Int = 0
    var totalEnemiesToWin: Int = 3
    
    func resetGame() {
            enemiesDefeated = 0
            arrowState = .idle // Kembalikan tangan ke kondisi awal
            currentGameState = .startScreen
            immersiveSpaceState = .closed // Sinkronkan state ruang 3D
        }
}
