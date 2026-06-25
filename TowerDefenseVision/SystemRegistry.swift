//
//  SystemRegistry.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import Foundation
import RealityKit
import ILSHandTracking

public struct SystemRegistry {
    public static func registerAllSystems() {
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
    }
}
