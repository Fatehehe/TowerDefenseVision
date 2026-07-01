//
//  GameCoordinator.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 26/06/26.
//

import Foundation

public struct GameStateTracker {
    // Written on @MainActor, read from RealityKit background render threads.
    // nonisolated(unsafe) acknowledges the cross-isolation access; the worst
    // outcome is a one-frame stale read, which is acceptable for game state.
    nonisolated(unsafe) public static var isPlaying: Bool = false
    nonisolated(unsafe) public static var enemiesDefeated: Int = 0
}
