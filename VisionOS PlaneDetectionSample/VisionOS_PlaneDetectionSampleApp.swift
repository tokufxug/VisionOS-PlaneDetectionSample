//
//  VisionOS_PlaneDetectionSampleApp.swift
//  VisionOS PlaneDetectionSample
//
//  Created by Sadao Tokuyama on 2/14/24.
//

import SwiftUI

@main
struct VisionOS_PlaneDetectionSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
