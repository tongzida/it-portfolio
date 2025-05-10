
import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    var canvasView: CanvasView!
    var model: VNCoreMLModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化画板
        canvasView = CanvasView(frame: self.view.frame)
        self.view.addSubview(canvasView)

        // 加载 Core ML 模型
        loadModel()
    }

    // 加载 Core ML 模型
    func loadModel() {
        do {
            let mlModel = try mnist_model(configuration: MLModelConfiguration())
            model = try VNCoreMLModel(for: mlModel.model)
        } catch {
            fatalError("无法加载 Core ML 模型: \(error)")
        }
    }

    // 识别手写数字的按钮动作
    @IBAction func recognizeDigit(_ sender: UIButton) {
        // 实现识别逻辑
        guard let image = canvasView.getImage() else {
            print("无法获取图像")
            return
        }
        recognizeDigit(from: image)
    }
    
    // 清空画板的按钮动作
    @IBAction func clearCanvas(_ sender: UIButton) {
        canvasView.clear()
    }

    // 使用 Core ML 进行手写数字识别
    func recognizeDigit(from image: UIImage) {
        // 确保将 UIImage 转换为正确的 CIImage
        guard let ciImage = CIImage(image: image) else {
            fatalError("无法创建 CIImage")
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                fatalError("无法获得识别结果")
            }

            DispatchQueue.main.async {
                // 确保 self 被使用，避免警告
                guard let self = self else { return }
                // 显示识别结果
                self.displayResult(result: topResult.identifier)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }

    // 显示识别结果
    func displayResult(result: String) {
        print("识别结果：\(result)")
    }
}
