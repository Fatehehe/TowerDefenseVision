//
//  GameModel.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 01/07/26.
//

import SwiftUI

@MainActor
@Observable
class GameModel {
    let immersiveSpaceID = "ImmersiveSpace"
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
