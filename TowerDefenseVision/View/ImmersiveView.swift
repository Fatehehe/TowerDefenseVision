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
        // 1. Tambahkan 'attachments' di sini
        RealityView { content, attachments in
                    
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
            if let portal = await MedievalSceneSpawner.spawnPortalAsync() {
                content.add(portal)
            }
                    
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
            
            // 🎯 5. BUAT ANCHOR KEPALA & TEMPELKAN HUD
            let headAnchor = AnchorEntity(.head)
            if let hudEntity = attachments.entity(for: "gameplay_hud") {
                // Posisikan: x=0 (tengah), y=0.15 (agak ke atas mata), z=-0.6 (60 cm di depan wajah)
                hudEntity.position = [0, 0.15, -0.6]
                headAnchor.addChild(hudEntity)
            }
            content.add(headAnchor)
            
            // 🎯 6. PROSES SELESAI, UBAH STATE KE TUTORIAL
            // Gunakan DispatchQueue.main.async agar perubahan state UI aman dan tidak memicu warning thread.
            DispatchQueue.main.async {
                model.currentGameState = .tutorial
            }
            
        } attachments: {
            // 🎯 7. DEKLARASIKAN HUD SEBAGAI ATTACHMENT
            Attachment(id: "gameplay_hud") {
                // Hanya render HUD kalau status game sudah playing
                if model.currentGameState == .playing {
                    GameplayHUDView()
                }
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
