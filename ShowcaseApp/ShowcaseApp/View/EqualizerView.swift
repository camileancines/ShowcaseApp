//
//  EqualizerView.swift
//  ShowcaseApp
//
//  Created by Camile Alves Ancines on 10/06/26.
//

import UIKit

final class EqualizerView: UIView {
    
    private let replicator = CAReplicatorLayer()
    private let bar = CALayer()
    private let barCount = 5
    private let barWidth: CGFloat = 6
    private let barSpacing: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        bar.backgroundColor = UIColor.systemBlue.cgColor
        bar.cornerRadius = barWidth / 2
        bar.anchorPoint = CGPoint(x: 0.5, y: 1.0)   // âncora na base: cresce pra cima
        
        replicator.addSublayer(bar)
        replicator.instanceCount = barCount
        replicator.instanceTransform = CATransform3DMakeTranslation(barWidth + barSpacing, 0, 0)
        replicator.instanceDelay = 0.15            // defasagem entre clones -> onda
        layer.addSublayer(replicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        replicator.frame = bounds
        let totalWidth = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * barSpacing
        let startX = (bounds.width - totalWidth) / 2
        bar.bounds = CGRect(x: 0, y: 0, width: barWidth, height: bounds.height)
        bar.position = CGPoint(x: startX + barWidth / 2, y: bounds.height)
    }
    
    func startAnimating() {
        let anim = CABasicAnimation(keyPath: "transform.scale.y")
        anim.fromValue = 0.15
        anim.toValue = 1.0
        anim.duration = 0.5
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        bar.add(anim, forKey: "equalizer")
    }
    
    func stopAnimating() {
        bar.removeAnimation(forKey: "equalizer")
    }
}
