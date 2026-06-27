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
//    @Environment(GameCoordinator.self) var coordinator
    
//    @State private var viewModel = GameViewModel()
//    @State private var updateSubscription: EventSubscription?
    
    var body: some View {
        // Hapus blok 'update' jika tidak digunakan agar kode lebih bersih
        RealityView { content, attachments in
            
            // 1. Map & Tower
            let worldAnchor = Entity()
            worldAnchor.name = "WorldAnchor"
            worldAnchor.components.set(GameStateComponent())
            content.add(worldAnchor)
            
            if let medievalWorld = await MedievalSceneSpawner.spawnMedievalWorld(named: "MedievalScene") {
                if let targetBullsEye = medievalWorld.findEntity(named: "Tower") {
                    var towerData = TowerComponent()
                    towerData.hp = 100
                    targetBullsEye.components.set(towerData)
                }
                content.add(medievalWorld)
            }
                    
            // 2. Portal
            if let portal = await MedievalSceneSpawner.spawnPortalAsync(){
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
            // Gunakan Task dan @MainActor untuk standar keamanan Swift modern
            Task { @MainActor in
                model.currentGameState = .tutorial
            }
            
        } attachments: {
            // 🎯 7. DEKLARASIKAN HUD SEBAGAI ATTACHMENT
            Attachment(id: "gameplay_hud") {
                // Render HUD kalau status game minimal sedang bermain
                if model.currentGameState == .playing {
                    GameplayHUDView()
                }
            }
        }
        .task {
            // Memulai pelacakan tangan secara asinkron
            try? await HandTrackingService.shared.start()
        }
        .upperLimbVisibility(.hidden)
        // ❌ HAPUS blok .onAppear yang mengikat ArcherySystem dengan model
        // ArcherySystem kini sepenuhnya mandiri menggunakan NotificationCenter
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
                
                // 🎯 PENTING: BUKA KEMBALI UI SAAT MENANG/KALAH
                .onChange(of: model.currentGameState) { _, newState in
                    if newState == .won || newState == .lost {
                        // Panggil kembali ContentView yang tadi ditutup!
                        model.stopGame()
                        openWindow(id: "MainWindow")
                    }
                }
                
                
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
