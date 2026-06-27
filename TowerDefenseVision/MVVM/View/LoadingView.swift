//
//  LoadingView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 25/06/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 30) {
            ProgressView()
                .controlSize(.extraLarge)
            
            Text("Tunggu dulu yaw...")
                .font(.title2)
                .bold()
                .foregroundColor(.secondary)
        }
        .padding(50)
        .frame(width: 400, height: 300)
    }
}
