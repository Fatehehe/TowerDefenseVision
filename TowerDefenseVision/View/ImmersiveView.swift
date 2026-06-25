//
//  ImmersiveView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import ILSHandTracking
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) private var model
    
    var body: some View {
        RealityView { content in
                    
                    // 1. Map & Tower
                    if let medievalWorld = await MedievalSceneSpawner.spawnMedievalWorld(named: "MedievalScene") {
                        if let targetBullsEye = medievalWorld.findEntity(named: "Tower") {
                            var towerData = TowerComponent()
                            towerData.hp = 100
                            targetBullsEye.components.set(towerData)
                        }
                        content.add(medievalWorld)
                    }
                    
                    // 2. Portal
//                    if let portal = await MedievalSceneSpawner.spawnPortalAsync() {
//                        content.add(portal)
//                    }
                    
                    // 3. Tangan
                    let hands = await GloveEntitySpawner.spawnHandGlovesAsync()
                    for hand in hands {
                        content.add(hand)
                    }
                    
                    // 4. Senjata
                    let rightHandAnchor = hands[0]
                    let leftHandAnchor = hands[1]
                    
                    if let archeryManager = await ArcherySpawner.spawnArcheryManager(leftHand: leftHandAnchor, rightHand: rightHandAnchor) {
                        content.add(archeryManager)
                    }
                }
        .task {
            try? await HandTrackingService.shared.start()
        }
        .upperLimbVisibility(.hidden)
        .onAppear {
            ArcherySystem.appModel = model
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
