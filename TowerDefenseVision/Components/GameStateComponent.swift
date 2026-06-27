//
//  GameStateComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 26/06/26.
//

import RealityKit
import Foundation

public struct GameStateComponent: Component {
    public var isPlaying: Bool = false
    public var arrowState: ArcheryState = .idle
    
    // Variabel bawaan kamu sebelumnya
    public var isGameOver: Bool = false
    public var timeSinceLastPipe: TimeInterval = 0
    public var basePipeSpawnInterval: TimeInterval = 5.0
    
    public init() {}
}
