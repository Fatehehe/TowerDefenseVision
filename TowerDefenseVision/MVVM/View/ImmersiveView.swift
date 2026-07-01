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
            SystemRegistry.registerAllSystems()
            
            if let medievalWorld = await MedievalSceneSpawner.spawnMedievalWorld(named: "MedievalScene") {
                if let targetBullsEye = medievalWorld.findEntity(named: "Tower") {
                    var towerData = TowerComponent()
                    towerData.hp = 100
                    targetBullsEye.components.set(towerData)
                    model.towerEntity = targetBullsEye
                }
                content.add(medievalWorld)
            }
            
//            if let portal = await MedievalSceneSpawner.spawnPortalAsync(){
//                content.add(portal)
//            }
            
            let hands = await GloveEntitySpawner.spawnHandGlovesAsync()

            for hand in hands {
                print("hand added to content \(hand.name)")
                content.add(hand)
            }
                
//            let rightHandAnchor = hands[0]
//            let leftHandAnchor = hands[1]

//            if let archeryManager = await ArcherySpawner.spawnArcheryManager(leftHand: leftHandAnchor, rightHand: rightHandAnchor) {
//                content.add(archeryManager)
//            }
            
            let handAnchor = Entity()
            handAnchor.components.set(ILHandAnchorComponent())
            content.add(handAnchor)
            
            let headAnchor = AnchorEntity(.head)
            if let hudEntity = attachments.entity(for: "gameplay_hud") {
                hudEntity.position = [0, 0.15, -0.6]
                headAnchor.addChild(hudEntity)
            }
            content.add(headAnchor)
            
//            Task {@MainActor in
            model.currentGameState = .playing
            dismissWindow(id: "MainWindow")
//            }
            
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
