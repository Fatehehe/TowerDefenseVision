//
//  AppModel.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import RealityKit

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
    var totalEnemiesToWin: Int = 5
    
    var towerHp: Int = 100
    var towerMaxHp: Int = 100
    
    var towerEntity: Entity?
    
    func resetGame() {
        enemiesDefeated = 0
        arrowState = .idle
        currentGameState = .playing
            
        towerHp = 100
        
        if let entity = towerEntity, var towerComp = entity.components[TowerComponent.self] {
            towerComp.hp = 100
            entity.components.set(towerComp)
        }
        
        playGame()
    }
    
    func playGame() {
        GameStateTracker.isPlaying = true
    }
    
    func stopGame() {
        GameStateTracker.isPlaying = false
    }
}
