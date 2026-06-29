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
    
    public static func spawnGloves(leftHand: Entity, rightHand: Entity) async {
        // Menggunakan TaskGroup agar kedua model dimuat secara paralel (lebih cepat)
        await withTaskGroup(of: (String, ModelEntity?).self) { group in
            group.addTask { ("left", await spawnGlove(named: "LeftGlove")) }
            group.addTask { ("right", await spawnGlove(named: "RightGlove")) }
            
            for await (side, model) in group {
                guard let model = model else { continue }
                
                if side == "left" {
                    leftHand.components.set(HandVisualizationComponent(modelEntity: model))
                    leftHand.addChild(model)
                } else if side == "right" {
                    rightHand.components.set(HandVisualizationComponent(modelEntity: model))
                    rightHand.addChild(model)
                }
            }
        }
    }
    
    public static func spawnHands() -> [Entity] {
            // 🎯 Gunakan AnchorEntity bawaan RealityKit agar otomatis menempel ke pergelangan tangan
            let rightHand = AnchorEntity(.hand(.right, location: .joint(for: .wrist)))
            rightHand.name = "RightHandAnchor"
            
            // Tetap pasang komponen custom kamu jika memang dibutuhkan oleh sistem lain
            rightHand.components.set(ILHandTrackingComponent())
            rightHand.components.set(ILHandAnchorComponent())
            
            // 🎯 Gunakan AnchorEntity untuk tangan kiri
            let leftHand = AnchorEntity(.hand(.left, location: .joint(for: .wrist)))
            leftHand.name = "LeftHandAnchor"
            
            leftHand.components.set(ILHandTrackingComponent())
            leftHand.components.set(ILHandAnchorComponent())
            
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
