//
//  AppState.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 01/07/26.
//

import SwiftUI

@MainActor
@Observable
class AppState {
    let immersiveSpaceID = "ImmersiveSpace"
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    let windowGroupID = "MainWindow"
    
    enum GameState {
        case startScreen
        case loading
        case tutorial
        case playing
        case won
        case lost
    }
    
    var gameCurrentState = GameState.startScreen
}
