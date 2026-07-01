//
//  MedievalSceneSpawner.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit
import RealityKitContent

public struct MedievalSceneSpawner {
    public static func spawnMedievalWorld(named sceneName: String = "MedievalScene") async -> Entity? {
        do {
            let rootWorld = try await Entity(named: sceneName, in: realityKitContentBundle)
            rootWorld.position = SIMD3<Float>(10.5, -5, -6)
            rootWorld.scale = SIMD3<Float>(repeating: 1.0)
            
            print("[MedievalSceneSpawner] Sukses memuat dunia: \(sceneName)")
            
            if let targetBullsEye = rootWorld.findEntity(named: "Tower") {
                print("[MedievalSceneSpawner] Tower entity found: \(targetBullsEye.name)")
                // TowerComponent is set by ImmersiveView after this returns.
                // Setting it here too would overwrite the value set by the caller.
            } else {
                print("no tower")
            }

            return rootWorld
            
        } catch {
            print("[MedievalSceneSpawner] Gagal memuat scene '\(sceneName)': \(error)")
            return nil
        }
    }
    
    public static func spawnPortalAsync(named entityName: String = "BlackHole") async -> Entity? {
        do {
            let portalEntity = try await Entity(named: entityName, in: realityKitContentBundle)
            let enemy = try await Entity(named: "GoblonV2", in: realityKitContentBundle)
            
            var portalData = PortalComponent()
            portalData.spawnInterval = 3.0
            portalEntity.components.set(portalData)
            
            // Add the enemy template to the scene graph as a hidden child.
            // This ensures RealityKit's NetworkAssetManager fully loads all its
            // internal assets before we ever call .clone(recursive: true).
            // We give it a stable name so PortalSystem can find it via findEntity(named:).
            enemy.name = "EnemyTemplate"
            enemy.isEnabled = false
            portalEntity.addChild(enemy)
            
            let portalScale: Float = 10.0
            portalEntity.transform.scale = SIMD3<Float>(repeating: portalScale)
        
            portalEntity.position = SIMD3<Float>(-20, -5, -7)
            let portalAngle: Float = .pi / 2
            let portalAxis = SIMD3<Float>(0, 1, 0)
            portalEntity.transform.rotation = simd_quatf(angle: portalAngle, axis: portalAxis)
                
            print("[PortalSpawner] Sukses memuat Portal dari RCP!")
            return portalEntity
                
        } catch {
            print("[PortalSpawner] Gagal memuat Portal dari RCP: \(error)")
            return nil
        }
    }
}
