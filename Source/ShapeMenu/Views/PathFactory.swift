//
//  PathFactory.swift
//  FolioReaderKit
//
//  Created by Santiago Carmona on 5/11/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

struct PathFactory {
    let viewBounds: CGRect
    
    func createPath(for type: ShapeViewModel.ShapeType) -> UIBezierPath {
        switch type {
        case .circle:
            return circlePath()
        case .rectangle:
            return rectanglePath()
        case .triangle:
            return trianglePath()
        case .arrow:
            return arrowPath()
        }
    }
    
    private func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: viewBounds)
    }
    
    private func rectanglePath() -> UIBezierPath {
        return UIBezierPath(rect: viewBounds)
    }
    
    private func trianglePath() -> UIBezierPath {
        let rect = viewBounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width / 2.0, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.width,y: rect.height))
        path.addLine(to: CGPoint(x: rect.origin.x,y: rect.height))
        path.close()
        
        return path
    }
    
    private func arrowPath() -> UIBezierPath {
        let start = CGPoint(x: viewBounds.origin.x, y: viewBounds.height / 2)
        let end = CGPoint(x: viewBounds.width, y: viewBounds.height / 2)
        let tailWidth: CGFloat = 10
        let headWidth: CGFloat = 25
        let headLength: CGFloat = 40
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength
        
        let points: [CGPoint] = [
            .init(x: 0, y: tailWidth / 2),
            .init(x: tailLength, y: tailWidth / 2),
            .init(x: tailLength, y: headWidth / 2),
            .init(x: length, y: 0),
            .init(x: tailLength, y: -headWidth / 2),
            .init(x: tailLength, y: -tailWidth / 2),
            .init(x: 0, y: -tailWidth / 2)
        ]
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
        
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()
        
        return UIBezierPath(cgPath: path)
    }
}
