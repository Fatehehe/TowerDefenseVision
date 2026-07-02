//
//  GloveEntitySpawner.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import RealityKit
import ILSHandTracking
import RealityKitContent
import Foundation
import ARKit

public struct GloveEntitySpawner {
    public static func spawnHandGlovesAsync() async -> [Entity] {
        let rightHand = Entity()
        rightHand.name = "RightHandAnchor"
        rightHand.components.set(ILHandTrackingComponent())
        
        let leftHand = Entity()
        leftHand.name = "LeftHandAnchor"
        leftHand.components.set(ILHandTrackingComponent())
            
        if let rightModel = await spawnGlove(named: "RightGlove") {
            // 🔥 Cukup set chirality saja
            rightHand.components.set(HandVisualizationComponent(chirality: .right))
            rightHand.addChild(rightModel)
        }
        
        if let leftModel = await spawnGlove(named: "LeftGlove") {
            // 🔥 Cukup set chirality saja
            leftHand.components.set(HandVisualizationComponent(chirality: .left))
            leftHand.addChild(leftModel)
        }
        return [rightHand, leftHand]
    }
    
    public static func spawnGlove(named name: String) async -> Entity? {
        do {
            let glove = try await Entity(named: name, in: realityKitContentBundle)
            return glove
        } catch {
            print("[GloveEntitySpawner] Failed to load glove: \(error)")
        }
        return nil
    }
}
