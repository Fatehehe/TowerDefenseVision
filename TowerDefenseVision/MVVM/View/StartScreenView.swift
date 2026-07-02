//
//  StartScreenView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import SwiftUI

struct StartScreenView: View {
    @Environment(AppState.self) var appState
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
                appState.gameCurrentState = .tutorial
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
