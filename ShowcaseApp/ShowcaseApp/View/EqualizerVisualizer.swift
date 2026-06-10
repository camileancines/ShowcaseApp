//
//  EqualizerVisualizer.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import SwiftUI

struct EqualizerVisualizer: UIViewRepresentable {
    var isPlaying: Bool

    func makeUIView(context: Context) -> EqualizerView {
        EqualizerView()
    }

    func updateUIView(_ uiView: EqualizerView, context: Context) {
        isPlaying ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
