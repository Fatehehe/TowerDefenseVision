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
        //aman
        ILFeatureHandTrackingSetup.registerSystems()
        
        //aman
        HandVisualizationSystem.registerSystem()
        HandVisualizationComponent.registerComponent()
        
        //aman
        TowerComponent.registerComponent()
//        PortalComponent.registerComponent()
//        EnemyComponent.registerComponent()
        
        //aman
//        PortalSystem.registerSystem()
//        EnemySystem.registerSystem()
        
//        BowComponent.registerComponent()
//        ArrowComponent.registerComponent()
        
//        ArcheryPlayerComponent.registerComponent()
        
//        ArcherySystem.registerSystem()
//        ArrowSystem.registerSystem()
        
//        CombatSystem.registerSystem()
    }
}

