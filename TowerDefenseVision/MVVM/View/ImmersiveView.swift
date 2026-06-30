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
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @State var towerEntity: Entity?
    
    var body: some View {
        RealityView { content, attachments in
            
            if let medievalWorld = await MedievalSceneSpawner.spawnMedievalWorld(named: "MedievalScene") {
                if let targetBullsEye = medievalWorld.findEntity(named: "Tower") {
                    var towerData = TowerComponent()
                    towerData.hp = 100
                    targetBullsEye.components.set(towerData)
                    Task { @MainActor in
                        model.towerEntity = targetBullsEye
                    }
                }
                content.add(medievalWorld)
            }
            
            if let portal = await MedievalSceneSpawner.spawnPortalAsync(){
                content.add(portal)
            }
            
            //rawan crash
            let hands = await GloveEntitySpawner.spawnHandGlovesAsync()
//            let hands = HandEntitySpawner.spawnHands()
            
//            if(!hands.isEmpty){
                for hand in hands {
                    print("hand added to content \(hand.name)")
                    content.add(hand)
                }
                
                let rightHandAnchor = hands[0]
                let leftHandAnchor = hands[1]

                if let archeryManager = await ArcherySpawner.spawnArcheryManager(leftHand: leftHandAnchor, rightHand: rightHandAnchor) {
                    content.add(archeryManager)
                }
//            }
            // sampe sini
            
            let headAnchor = AnchorEntity(.head)
            if let hudEntity = attachments.entity(for: "gameplay_hud") {
                hudEntity.position = [0, 0.15, -0.6]
                headAnchor.addChild(hudEntity)
            }
            content.add(headAnchor)
            
            Task {@MainActor in
                model.currentGameState = .playing
                dismissWindow(id: "MainWindow")
            }
            
        } attachments: {
            Attachment(id: "gameplay_hud") {
                    GameplayHUDView()
            }
        }
        .upperLimbVisibility(.hidden)
        .onReceive(NotificationCenter.default.publisher(for: .enemyDefeated)) { _ in
            model.enemiesDefeated += 1
            print("Musuh mati: \(model.enemiesDefeated) / \(model.totalEnemiesToWin)")
                    
            if model.enemiesDefeated >= model.totalEnemiesToWin {
                model.currentGameState = .won
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .towerDestroyed)) { _ in
            model.currentGameState = .lost
            print("Tower Hancur ditangkap oleh ImmersiveView!")
        }
        .onChange(of: model.currentGameState) { _, newState in
            if newState == .won || newState == .lost {
                model.stopGame()
                openWindow(id: "MainWindow")
            }
        }
        .task {
            try? await HandTrackingService.shared.start()
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

//import SwiftUI
//import ILSHandTracking
//import RealityKit
//import RealityKitContent
//import ARKit
//
//struct ImmersiveView: View {
//    @Environment(AppModel.self) private var model
//    @Environment(\.openWindow) var openWindow
//    
//    var body: some View {
//        RealityView { content, attachments in
//            
//            let hands = HandEntitySpawner.spawnHands()
//            var leftHandAnchor: Entity? = nil
//            var rightHandAnchor: Entity? = nil
//            for hand in hands {
//                if hand.name == "LeftHandAnchor" {
//                    hand.components.set(HandOverlayComponent(chirality: .left))
//                    leftHandAnchor = hand
//                } else if hand.name == "RightHandAnchor" {
//                    hand.components.set(HandOverlayComponent(chirality: .right))
//                    rightHandAnchor = hand
//                }
//                content.add(hand)
//            }
//            
//            Task {
//                
//                    let leftGlove = await GloveEntitySpawner.spawnGlove(named: "LeftGlove")
//                    let rightGlove = await GloveEntitySpawner.spawnGlove(named: "RightGlove")
//                    
//                    if let leftGlove, let rightGlove {
//                        makeMaterialsOpaque(in: leftGlove)
//                        makeMaterialsOpaque(in: rightGlove)
//                        
//                        if let leftAnchor = leftHandAnchor {
//                            leftAnchor.addChild(leftGlove)
//                            if var comp = leftAnchor.components[HandOverlayComponent.self] {
//                                comp.gloveWrapper = leftGlove
//                                comp.gloveModel = nil
//                                leftAnchor.components.set(comp)
//                            }
//                        }
//                        
//                        if let rightAnchor = rightHandAnchor {
//                            rightAnchor.addChild(rightGlove)
//                            if var comp = rightAnchor.components[HandOverlayComponent.self] {
//                                comp.gloveWrapper = rightGlove
//                                comp.gloveModel = nil
//                                rightAnchor.components.set(comp)
//                            }
//                        }
//                    }
//            }
//            
//        } attachments: {
//            Attachment(id: "gameplay_hud") {
//                if model.currentGameState == .playing {
//                    GameplayHUDView()
//                }
//            }
//        }
//        .onReceive(NotificationCenter.default.publisher(for: .enemyDefeated)) { _ in
//                    model.enemiesDefeated += 1
//                    print("Musuh mati: \(model.enemiesDefeated) / \(model.totalEnemiesToWin)")
//                    
//                    if model.enemiesDefeated >= model.totalEnemiesToWin {
//                        model.currentGameState = .won
//                    }
//                }
//                
//                .onReceive(NotificationCenter.default.publisher(for: .towerDestroyed)) { _ in
//                    model.currentGameState = .lost
//                    print("Tower Hancur ditangkap oleh ImmersiveView!")
//                }
//                .onChange(of: model.currentGameState) { _, newState in
//                    if newState == .won || newState == .lost {
//                        model.stopGame()
//                        openWindow(id: "MainWindow")
//                    }
//                }
//                .task {
//                    try? await HandTrackingService.shared.start()
//                }
//                
//                
//    }
//    
//    @MainActor
//    private func makeMaterialsOpaque(in entity: Entity) {
//        if var modelComp = entity.components[ModelComponent.self] {
//            modelComp.materials = modelComp.materials.map { material in
//                if var pbr = material as? PhysicallyBasedMaterial {
//                    pbr.blending = .opaque
//                    return pbr
//                } else if var unlit = material as? UnlitMaterial {
//                    unlit.blending = .opaque
//                    return unlit
//                }
//                return material
//            }
//            entity.components.set(modelComp)
//        }
//        for child in entity.children {
//            makeMaterialsOpaque(in: child)
//        }
//    }
//}
//
//#Preview(immersionStyle: .mixed) {
//    ImmersiveView()
//        .environment(AppModel())
//}
