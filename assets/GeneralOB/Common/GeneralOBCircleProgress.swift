//
//  GeneralOBCircleProgress.swift
//  OOG141
//
//  Created by chai chai on 2026/7/20.
//
import UIKit
import Components
import SnapKit

class GeneralOBCircleProgress: UIView {
    
    // MARK: - 属性配置
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer() // 新增渐变图层
    
    // 定时器用于追踪动画实时进度
    private var displayLink: CADisplayLink?
    
    /// 核心：进度改变的回调闭包 (返回值范围 0.0 ~ 1.0)
    var progressChanged: ((CGFloat) -> Void)?
    
    /// 渐变颜色数组（支持传入多种颜色）
    var gradientColors: [UIColor] = [.systemBlue, .systemTeal] {
        didSet {
            gradientLayer.colors = gradientColors.map { $0.cgColor }
        }
    }
    
    /// 渐变起点 (默认左上角 0, 0)
    var gradientStartPoint: CGPoint = CGPoint(x: 0.5, y: 0) {
        didSet { gradientLayer.startPoint = gradientStartPoint }
    }
    
    /// 渐变终点 (默认右下角 1, 1)
    var gradientEndPoint: CGPoint = CGPoint(x: 0.5, y: 1) {
        didSet { gradientLayer.endPoint = gradientEndPoint }
    }
    
    /// 进度条背景轨道颜色
    var trackColor: UIColor = .systemGray5 {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    /// 线条宽度
    var lineWidth: CGFloat = 10 {
        didSet {
            progressLayer.lineWidth = lineWidth
            trackLayer.lineWidth = lineWidth
            updatePath()
        }
    }
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackLayer.frame = bounds
        gradientLayer.frame = bounds
        progressLayer.frame = bounds
        updatePath()
    }
    
    private func setupLayers() {
        // 1. 设置背景轨道
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // 2. 配置进度遮罩 Layer (注意：strokeColor 设置为不透明颜色即可，实际显示颜色由 gradientLayer 决定)
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        
        // 3. 配置渐变 Layer，并将 progressLayer 设为其遮罩
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = gradientStartPoint
        gradientLayer.endPoint = gradientEndPoint
        gradientLayer.mask = progressLayer // 核心：Mask 机制
        
        layer.addSublayer(gradientLayer)
    }
    
    private func updatePath() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: startAngle,
                                        endAngle: endAngle,
                                        clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    // MARK: - 核心方法：设置进度（带回调追踪）
    func setProgress(_ value: CGFloat, animated: Bool, duration: CFTimeInterval = 1.0) {
        let clampedValue = max(0, min(1, value))
        
        // 清理之前的定时器
        invalidateDisplayLink()
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            animation.fromValue = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
            animation.toValue = clampedValue
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            progressLayer.strokeEnd = clampedValue
            progressLayer.add(animation, forKey: "progressAnim")
            
            // 启动定时器，监听 presentationLayer 的实时变化
            startDisplayLink()
        } else {
            progressLayer.removeAnimation(forKey: "progressAnim")
            progressLayer.strokeEnd = clampedValue
            progressChanged?(clampedValue)
        }
    }
    
    // MARK: - CADisplayLink 实时监听机制
    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(animationTick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func animationTick() {
        if let presentationLayer = progressLayer.presentation() {
            let currentProgress = presentationLayer.strokeEnd
            progressChanged?(currentProgress)
            
            if abs(currentProgress - progressLayer.strokeEnd) < 0.001 {
                progressChanged?(progressLayer.strokeEnd)
                invalidateDisplayLink()
            }
        }
    }
    
    deinit {
        invalidateDisplayLink()
    }
}
