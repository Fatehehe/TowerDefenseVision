//
//  GameResultView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 25/06/26.
//

import SwiftUI

struct GameResultView: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.dismissWindow) var dismissWindow
    
    var isWin: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text(isWin ? "VICTORY!" : "GAME OVER")
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundColor(isWin ? .green : .red)
            
            Text(isWin ? "Kamu berhasil melindungi menara dari semua monster!" : "Menara hancur lebur... Dunia telah jatuh.")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    appModel.resetGame()
                    dismissWindow(id: "MainWindow")
                }
            }) {
                Text("Main Lagi")
                    .font(.title2)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding(50)
        .frame(width: 500)
    }
}
