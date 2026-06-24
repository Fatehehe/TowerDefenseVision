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
            
            if let medievalWorld = await MedievalSceneSpawner.spawnMedievalWorld(named: "MedievalScene") {
                content.add(medievalWorld)
            }
            
            let hands = await GloveEntitySpawner.spawnHandGlovesAsync()
            for hand in hands {
                content.add(hand)
            }
            
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
