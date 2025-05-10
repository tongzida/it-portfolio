import Cocoa

class CanvasView: NSView {

    private var lines: [[NSPoint]] = [] // 记录所有的绘制轨迹

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // 设置背景颜色为深灰色
        NSColor.darkGray.setFill()
        dirtyRect.fill()

        // 设置绘制线条的颜色和属性
        NSColor.white.setStroke() // 设置绘制线条为白色，和背景形成对比
        let path = NSBezierPath()
        path.lineWidth = 5.0
        path.lineCapStyle = .round

        // 绘制线条
        for line in lines {
            guard let firstPoint = line.first else { continue }
            path.move(to: firstPoint)
            for point in line.dropFirst() {
                path.line(to: point)
            }
        }
        path.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        // 开始新的一条线
        lines.append([event.locationInWindow])
    }

    override func mouseDragged(with event: NSEvent) {
        // 更新当前正在绘制的线
        guard var lastLine = lines.popLast() else { return }
        lastLine.append(event.locationInWindow)
        lines.append(lastLine)
        setNeedsDisplay(bounds)
    }

    // 清空所有绘制的线条
    func clear() {
        lines.removeAll()
        setNeedsDisplay(bounds)
    }

    // 获取画布上的图像
    func getImage() -> NSImage? {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
}
