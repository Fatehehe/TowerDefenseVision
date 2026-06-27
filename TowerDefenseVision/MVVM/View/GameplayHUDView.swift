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
        HStack(spacing: 12) {
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
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassBackgroundEffect(in: Capsule())
        .onReceive(NotificationCenter.default.publisher(for: .archeryStateDidChange)) { notification in
            // Keluarkan data dari notifikasi
            if let newState = notification.object as? ArcheryState {
                // Update state SwiftUI secara aman di Main Thread
                appModel.arrowState = newState
                
                // Set immersive space ke open jika belum open
                if appModel.immersiveSpaceState != .open {
                    appModel.immersiveSpaceState = .open
                }
            }
        }
    }
}

