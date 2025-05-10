import coremltools as ct

# 从 TensorFlow 的 SavedModel 格式加载模型并进行转换
mlmodel = ct.convert('saved_model_dir', source='tensorflow')

# 保存转换后的 Core ML 模型
mlmodel.save('HandwrittenDigitClassifier.mlmodel')

print("模型已成功转换为 Core ML 格式并保存为 'HandwrittenDigitClassifier.mlmodel'")
