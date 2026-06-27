//
//  GameSimulationBuilder.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 26/06/26.
//

import Foundation
import RealityKit
import ILSHandTracking
import _RealityKit_SwiftUI

@MainActor
public enum GameSimulationBuilder {
    public static func setupWorld(content: RealityViewContent, viewModel: GameViewModel) async -> EventSubscription{
        ILFeatureHandTrackingSetup.registerSystems()
        
        HandVisualizationComponent.registerComponent()
        HandVisualizationSystem.registerSystem()
        
        BowComponent.registerComponent()
        ArrowComponent.registerComponent()
        
        ArcheryPlayerComponent.registerComponent()
        
        ArcherySystem.registerSystem()
        ArrowSystem.registerSystem()
        
        TowerComponent.registerComponent()
        PortalComponent.registerComponent()
        EnemyComponent.registerComponent()
        
        PortalSystem.registerSystem()
        EnemySystem.registerSystem()
        
        CombatSystem.registerSystem()
        GameStateComponent.registerComponent()
        
        let worldAnchor = await MedievalSceneSpawner.createWorld(named: "MedievalScene")
        content.add(worldAnchor)
        
        let portal = await MedievalSceneSpawner.createPortal()
        content.add(portal)
        
        let hands = await GloveEntitySpawner.spawnHandGlovesAsync()
        for hand in hands {
            content.add(hand)
        }
            
        let rightHandAnchor = hands[0]
        let leftHandAnchor = hands[1]
                
        if let archeryManager = await ArcherySpawner.spawnArcheryManager(leftHand: leftHandAnchor, rightHand: rightHandAnchor) {
            content.add(archeryManager)
        }
        
        let subscription = content.subscribe(to: SceneEvents.Update.self) { event in
            if let gameState = worldAnchor.components[GameStateComponent.self] {
                viewModel.isGameOver = gameState.isGameOver
            }
        }

        return subscription
    }
    
    
}
