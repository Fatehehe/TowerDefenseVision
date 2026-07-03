//
//  ImmersiveView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import ILSHandTracking
import RealityKit

struct ImmersiveView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        RealityView { content in
            SystemRegistry.registerAllSystems()
        
            let hands = await GloveEntitySpawner.spawnHandGlovesAsync()

            for hand in hands {
                content.add(hand)
            }
            
            appState.gameCurrentState = .playing
//            dismissWindow(id: appState.windowGroupID)
        }

        .upperLimbVisibility(.hidden)
        .task {
            do{
                try await HandTrackingService.shared.start()
            }catch{
                print("ada error \(error.localizedDescription)")
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

//struct ImmersiveView: View {
//    @Environment(AppState.self) var appState
//    
//    var body: some View {
//        RealityView { content in
//            SystemRegistry.registerAllSystems()
//        
////            let hands = await GloveEntitySpawner.spawnHandGlovesAsync()
////
////            for hand in hands {
////                content.add(hand)
////            }
//            
//            let hands = HandEntitySpawner.spawnHands()
//            var leftHandAnchor: Entity? = nil
//            var rightHandAnchor: Entity? = nil
//            for hand in hands {
//                if hand.name == "LeftHandAnchor" {
//                    hand.components.set(HandVisualizationComponent(chirality: .left))
//                    leftHandAnchor = hand
//                } else if hand.name == "RightHandAnchor" {
//                    hand.components.set(HandVisualizationComponent(chirality: .right))
//                    rightHandAnchor = hand
//                }
//                content.add(hand)
//            }
//            
//            Task {
//                do {
//                    let leftGlove = try await Entity(named: "LeftGlove", in: realityKitContentBundle)
//                    let rightGlove = try await Entity(named: "RightGlove", in: realityKitContentBundle)
//                    
//                    if let leftAnchor = leftHandAnchor {
//                        leftAnchor.addChild(leftGlove)
//                        if var comp = leftAnchor.components[HandVisualizationComponent.self] {
//                            comp.gloveWrapper = leftGlove
//                            comp.gloveModel = nil
//                            leftAnchor.components.set(comp)
//                        }
//                    }
//                    
//                    if let rightAnchor = rightHandAnchor {
//                        rightAnchor.addChild(rightGlove)
//                        if var comp = rightAnchor.components[HandVisualizationComponent.self] {
//                            comp.gloveWrapper = rightGlove
//                            comp.gloveModel = nil
//                            rightAnchor.components.set(comp)
//                        }
//                    }
//                    print("[ImmersiveView] Glove entities loaded directly from RealityKitContent bundle!")
//                } catch {
//                    print("[ImmersiveView] Failed to load glove entities: \(error)")
//                }
//            }
//            
//            appState.gameCurrentState = .playing
//        }
//
//        .upperLimbVisibility(.hidden)
//        .task {
//            do{
//                try await HandTrackingService.shared.start()
//            }catch{
//                print("ada error \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//#Preview(immersionStyle: .mixed) {
//    ImmersiveView()
//        .environment(AppModel())
//}
