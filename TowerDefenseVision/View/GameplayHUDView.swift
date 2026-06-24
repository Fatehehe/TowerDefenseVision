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
        VStack(spacing: 15) {
            Text("Status Panah")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Ambil data langsung dari ECS yang sudah kamu buat sebelumnya
            Text("\(appModel.arrowState.rawValue)")
                .font(.largeTitle)
                .bold()
                .textCase(.uppercase)
        }
        .padding(30)
        // Mengecilkan ukuran window saat masuk ke mode bermain
        .frame(width: 300, height: 200)
    }
}
