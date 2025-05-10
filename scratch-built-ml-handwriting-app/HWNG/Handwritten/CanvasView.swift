import UIKit

class CanvasView: UIView {
    // 用于存储所有绘制的线条
    private var lines = [[CGPoint]]()

    // 开始触摸事件，初始化新的线条
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())  // 每次触摸开始时，创建一条新的线条
    }

    // 触摸移动事件，记录新的点并刷新显示
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.append(point)  // 将新点添加到当前线条
        lines.append(lastLine)
        setNeedsDisplay()  // 触发视图重绘
    }

    // 绘制所有线条
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setStrokeColor(UIColor.black.cgColor)  // 设置线条颜色为黑色
        context.setLineWidth(5)  // 设置线条宽度
        context.setLineCap(.round)  // 设置线条末端为圆形

        // 遍历每一条线并绘制
        lines.forEach { line in
            for (i, point) in line.enumerated() {
                if i == 0 {
                    context.move(to: point)  // 移动画笔到线条起点
                } else {
                    context.addLine(to: point)  // 画线到下一个点
                }
            }
        }

        context.strokePath()  // 绘制路径
    }

    // 清空画板
    func clear() {
        lines.removeAll()  // 清空所有线条
        setNeedsDisplay()  // 触发视图重绘
    }

    // 将画板内容转换为 UIImage
    func getImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)  // 创建上下文，使用当前视图大小和设备分辨率
        drawHierarchy(in: bounds, afterScreenUpdates: true)  // 绘制当前视图层级
        let image = UIGraphicsGetImageFromCurrentImageContext()  // 获取图像
        UIGraphicsEndImageContext()  // 结束上下文
        return image
    }
}
