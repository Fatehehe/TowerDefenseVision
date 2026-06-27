//
//  TutorialView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import SwiftUI

struct TutorialView: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.dismissWindow) var dismissWindow
    
    @State private var currentStep = 0
    let totalSteps = 4
    
    var body: some View {
        VStack {
            Text("Cara Bermain")
                .font(.largeTitle)
                .bold()
                .padding(.top, 30)
            
            TabView(selection: $currentStep) {
                TutorialSlide(icon: "hand.raised.fill", title: "1. Siapkan Senjata", description: "renggangkan jari di tangan kiri kamu untuk memunculkan panah.")
                    .tag(0)
                
                TutorialSlide(icon: "arrow.left.and.right", title: "2. Siapkan Busur", description: "lakukan thumbs up untuk memunculkan busur.")
                    .tag(1)
                
                TutorialSlide(icon: "target", title: "3. Tarik Panah", description: "Dekatkan busur ke panah, kemudian tarik tangan kanan kamu.")
                    .tag(2)
                TutorialSlide(icon: "target", title: "4. Tembak!", description: "Buka semua jari tangan kanan kamu untuk melepas busur!.")
                    .tag(3)
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
                                    appModel.playGame()
                                    // 🎯 2. Tutup window utama!
                                    dismissWindow(id: "MainWindow")
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
