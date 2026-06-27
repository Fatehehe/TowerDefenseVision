//
//  MainMenuView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 26/06/26.
//

import SwiftUI

struct MainMenuView: View {
//    @Environment(GameCoordinator.self) private var coordinator
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Tower Defense")
                .font(.extraLargeTitle)
                .bold()
            
            Text("Selamatkan menara dari serangan monster!")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button(action: {
//                coordinator.startNewGame()
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

#Preview {
    MainMenuView()
}
