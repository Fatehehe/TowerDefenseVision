//
//  StartScreenView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import SwiftUI

struct StartScreenView: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Tower Defense")
                .font(.extraLargeTitle)
                .bold()
            
            Text("Selamatkan menara dari serangan monster!")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button(action: {
                // 1. Ubah UI ke mode tutorial
                appModel.currentGameState = .tutorial
                
                // 2. Buka dunia 3D di background (jadi pemain bisa baca tutorial sambil lihat dunianya muncul)
                Task {
                    await openImmersiveSpace(id: appModel.immersiveSpaceID)
                }
            }) {
                Text("Start Game")
                    .font(.title2)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding(50)
    }
}
