//
//  GameplayHUDView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import SwiftUI

struct GameplayHUDView: View {
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        HStack(spacing: 20) {
            
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text("PANAH :")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("\(appModel.arrowState.rawValue)")
                    .font(.headline)
                    .bold()
                    .textCase(.uppercase)
                    .frame(minWidth: 80, alignment: .leading)
            }
            
            Divider().frame(height: 20)
                        
            HStack(spacing: 8) {
                Image(systemName: "figure.boxing")
                    .font(.title3)
                
                Text("MUSUH :")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                            
                Text("\(appModel.enemiesDefeated) / \(appModel.totalEnemiesToWin)")
                    .font(.headline)
                    .bold()
                    .frame(minWidth: 60, alignment: .leading)
            }
            
            Divider()
                .frame(height: 20)
            
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundColor(appModel.towerHp <= 10 ? .red : .green)
                
                Text("HP TOWER :")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("\(appModel.towerHp)")
                    .font(.headline)
                    .bold()
                    .frame(minWidth: 40, alignment: .leading)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .glassBackgroundEffect(in: Capsule())
    }
}
