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
            rootWorld.position = SIMD3<Float>(12, 0, -6)
            rootWorld.scale = SIMD3<Float>(repeating: 1.0)
            
            print("[MedievalSceneSpawner] Sukses memuat dunia: \(sceneName)")
            return rootWorld
            
        } catch {
            print("[MedievalSceneSpawner] Gagal memuat scene '\(sceneName)': \(error)")
            return nil
        }
    }
}
