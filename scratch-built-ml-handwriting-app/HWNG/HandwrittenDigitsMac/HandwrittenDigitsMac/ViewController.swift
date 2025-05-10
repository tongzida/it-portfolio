import Cocoa
import CoreML
import Vision

class ViewController: NSViewController {

    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var resultLabel: NSTextField!
    
    var model: VNCoreMLModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Core MLモデルの読み込み
        loadModel()
    }

    // Core MLモデルの読み込み
    func loadModel() {
        do {
            let mlModel = try mnist_model(configuration: MLModelConfiguration())
            model = try VNCoreMLModel(for: mlModel.model)
            resultLabel.stringValue = "Model loaded successfully"
            print("Model loaded successfully: \(mlModel)")
        } catch {
            resultLabel.stringValue = "Failed to load Core ML model: \(error.localizedDescription)"
            print("Model load error: \(error.localizedDescription)")
            // エラー情報の詳細をキャッチ
            if let nsError = error as NSError? {
                print("Error details: \(nsError.localizedDescription)")
                print("Error domain: \(nsError.domain)")
                print("Error code: \(nsError.code)")
            }
        }
    }

    // 認識ボタンのアクション
    @IBAction func recognizeDigit(_ sender: Any) {
        guard let image = canvasView.getImage() else {
            resultLabel.stringValue = "Unable to get image"
            print("Unable to get image")
            return
        }
        // 取得した画像を28x28のグレースケール画像に変換
        guard let resizedImage = resizeImage(image: image, targetSize: NSSize(width: 28, height: 28)) else {
            resultLabel.stringValue = "Image preprocessing failed"
            print("Image preprocessing failed")
            return
        }
        recognizeDigit(from: resizedImage)
    }

    // 画板のクリアボタンのアクション
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.clear()
        resultLabel.stringValue = "Canvas cleared"
    }
    
    // Core MLを使用して手書き数字を認識
    func recognizeDigit(from image: NSImage) {
        guard let ciImage = CIImage(data: image.tiffRepresentation!) else {
            resultLabel.stringValue = "Unable to create CIImage"
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            if let error = error {
                // エラー情報をコンソールに表示
                print("Recognition request error: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("Error details: \(nsError.localizedDescription)")
                    print("Error domain: \(nsError.domain)")
                    print("Error code: \(nsError.code)")
                    if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                        print("Underlying error: \(underlyingError.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    self?.resultLabel.stringValue = "Recognition error: \(error.localizedDescription)"
                }
                return
            }

            // リクエストの結果を表示
            if let results = request.results {
                print("Request results: \(results)")
            } else {
                print("No request results")
            }

            // リクエスト結果を処理し、多次元配列の最大値インデックスを取得して認識結果とする
            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let featureValue = results.first?.featureValue.multiArrayValue else {
                DispatchQueue.main.async {
                    self?.resultLabel.stringValue = "Unable to get recognition result"
                    print("Unable to get recognition result")
                }
                return
            }

            // 多次元配列の最大値インデックス（予測された数字）を取得
            let pointer = UnsafeMutablePointer<Double>(OpaquePointer(featureValue.dataPointer))
            let buffer = UnsafeBufferPointer(start: pointer, count: featureValue.count)
            if let maxIndex = buffer.enumerated().max(by: { $0.element < $1.element })?.offset {
                DispatchQueue.main.async {
                    // 認識結果をresultLabelに表示
                    self?.resultLabel.stringValue = "Recognition result: \(maxIndex)"
                    print("Recognition result: \(maxIndex)")
                }
            } else {
                DispatchQueue.main.async {
                    self?.resultLabel.stringValue = "Unable to get recognition result"
                    print("Unable to get recognition result")
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            resultLabel.stringValue = "Failed to execute recognition request: \(error.localizedDescription)"
            print("Failed to execute recognition request: \(error.localizedDescription)")
        }
    }

    // 画像の前処理関数：画像を28x28のグレースケール画像に変換
    func resizeImage(image: NSImage, targetSize: NSSize) -> NSImage? {
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: targetSize),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()

        // グレースケール画像に変換
        let grayscaleImage = NSImage(size: targetSize)
        grayscaleImage.lockFocus()
        let context = NSGraphicsContext.current!.cgContext
        context.setFillColor(NSColor.white.cgColor)
        context.fill(NSRect(origin: .zero, size: targetSize))

        guard let newImageCG = newImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Failed to get CGImage")
            return nil
        }

        context.draw(newImageCG, in: NSRect(origin: .zero, size: targetSize))
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo: CGBitmapInfo = .byteOrderDefault
        guard let contextGrayscale = CGContext(data: nil, width: Int(targetSize.width), height: Int(targetSize.height),
                                               bitsPerComponent: 8, bytesPerRow: Int(targetSize.width),
                                               space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            print("Failed to create grayscale context")
            return nil
        }
        contextGrayscale.draw(newImageCG, in: NSRect(origin: .zero, size: targetSize))
        
        guard let grayImageRef = contextGrayscale.makeImage() else {
            print("Failed to create grayscale image")
            return nil
        }
        let grayImage = NSImage(cgImage: grayImageRef, size: targetSize)
        
        grayscaleImage.unlockFocus()

        // 新しいビットマップを作成して標準化処理 (Core MLモデルが0-1の範囲を必要とする場合を想定)
        let bitmapRep = NSBitmapImageRep(cgImage: grayImageRef)
        bitmapRep.size = targetSize

        // ピクセル値が0-1の範囲に収まるようにする
        let data = bitmapRep.representation(using: .png, properties: [:])
        let finalImage = data.flatMap { NSImage(data: $0) }

        print("Resized Image Size: \(grayImage.size)")
        return finalImage
    }
}
