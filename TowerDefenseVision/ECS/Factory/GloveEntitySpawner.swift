//
//  HandEntitySpawner.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import RealityKit
import ILSHandTracking
import Foundation
import ARKit

public struct GloveEntitySpawner {
    
    public static func spawnHandGlovesAsync() async -> [Entity] {
        let rightHand = Entity()
        rightHand.name = "RightHandAnchor"
        rightHand.components.set(ILHandTrackingComponent())
        rightHand.components.set(ILHandAnchorComponent())
        
        let leftHand = Entity()
        leftHand.name = "LeftHandAnchor"
        leftHand.components.set(ILHandTrackingComponent())
        leftHand.components.set(ILHandAnchorComponent())
            
        if let rightModel = await spawnGlove(named: "RightGlove") {
            rightHand.components.set(HandVisualizationComponent(modelEntity: rightModel))
            rightHand.addChild(rightModel)
        }
        
        if let leftModel = await spawnGlove(named: "LeftGlove") {
            leftHand.components.set(HandVisualizationComponent(modelEntity: leftModel))
            leftHand.addChild(leftModel)
        }

        return [rightHand, leftHand]
    }
    

    public static func spawnGlove(named name: String) async -> ModelEntity? {
        if let url = Bundle.main.url(forResource: name, withExtension: "usdz") {
            do {
                let glove = try await ModelEntity(contentsOf: url)
                let gloveJointCount = glove.jointNames.count
                let expectedJointCount = HandSkeleton.JointName.allCases.count

                guard gloveJointCount == expectedJointCount else {
                    print("""
                        Joint count mismatch: USD model (\(name)) has \(gloveJointCount) joints, \
                        but ARKit hand skeleton has \(expectedJointCount) joints.
                        """)
                    return nil
                }
                
                return glove
            } catch {
                print("Failed to load \(name): \(error.localizedDescription).")
            }
        } else {
            print("Glove model not found in bundle: \(name).")
        }
        return nil
    }
}
