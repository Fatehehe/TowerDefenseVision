//
//  ContentView.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    var body: some View {
        VStack {
            Text("Tower Deffense")
                .font(.title)
            Text(appModel.arrowState.rawValue)
            
        }
        .padding()
        .onAppear {
            Task{
                await openImmersiveSpace(id: appModel.immersiveSpaceID)
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
