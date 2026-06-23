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

    var body: some View {
        RealityView { content in
            let hands = await GloveEntitySpawner.spawnHandGlovesAsync()
            for hand in hands {
                content.add(hand)
            }
        }
        .task {
            try? await HandTrackingService.shared.start()
        }
        .upperLimbVisibility(.hidden)
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
