//
//  TutorialView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import SwiftUI

struct TutorialView: View {
    @Environment(AppModel.self) var appModel
    @State private var currentStep = 0
    let totalSteps = 3
    
    var body: some View {
        VStack {
            Text("Cara Bermain")
                .font(.largeTitle)
                .bold()
                .padding(.top, 30)
            
            // Slider Tutorial
            TabView(selection: $currentStep) {
                TutorialSlide(icon: "hand.raised.fill", title: "1. Siapkan Senjata", description: "Kepalkan kedua tanganmu untuk memunculkan busur dan panah.")
                    .tag(0)
                
                TutorialSlide(icon: "arrow.left.and.right", title: "2. Tarik Panah", description: "Dekatkan tangan kanan ke kiri, lalu tarik ke belakang seperti memanah sungguhan.")
                    .tag(1)
                
                TutorialSlide(icon: "target", title: "3. Tembak!", description: "Buka jari tangan kananmu untuk melepaskan panah ke arah monster.")
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 300)
            
            // Navigasi Bawah
            HStack {
                if currentStep < totalSteps - 1 {
                    Button("Next") {
                        withAnimation { currentStep += 1 }
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button(action: {
                        appModel.currentGameState = .playing
                    }) {
                        Text("Paham, Mari Mulai!")
                            .bold()
                            .padding(.horizontal, 30)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding(.bottom, 40)
        }
        .frame(width: 600, height: 500)
    }
}

struct TutorialSlide: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.title)
                .bold()
            
            Text(description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
