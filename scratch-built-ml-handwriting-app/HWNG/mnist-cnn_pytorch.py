import tensorflow as tf
from tensorflow.keras import layers, models
import numpy as np
import os
import coremltools as ct  # 导入 Core ML 工具

# 确认文件路径
path = "/Users/hanyuwang/Desktop/手写数字识别/mnist.npz"
if os.path.exists(path):
    print("路径正确，文件存在")
else:
    print("路径错误，文件不存在")

# 手动加载 mnist 数据
with np.load(path) as data:
    train_images = data['x_train']
    train_labels = data['y_train']
    test_images = data['x_test']
    test_labels = data['y_test']

# 将图像调整为 CNN 可接受的输入格式（28x28x1），并归一化到 [0, 1] 范围
train_images = train_images.reshape((train_images.shape[0], 28, 28, 1)).astype('float32') / 255.0
test_images = test_images.reshape((test_images.shape[0], 28, 28, 1)).astype('float32') / 255.0

# 构建 CNN 模型
model = models.Sequential()

# 第一个卷积层 + 池化层
model.add(layers.Conv2D(32, (3, 3), activation='relu', input_shape=(28, 28, 1)))
model.add(layers.MaxPooling2D((2, 2)))

# 第二个卷积层 + 池化层
model.add(layers.Conv2D(64, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))

# 第三个卷积层
model.add(layers.Conv2D(64, (3, 3), activation='relu'))

# 展平层，将多维输出展平为一维
model.add(layers.Flatten())

# 全连接层
model.add(layers.Dense(128, activation='relu'))

# 输出层，10 个类别，对应手写数字 0-9
model.add(layers.Dense(10, activation='softmax'))

# 编译模型，使用 Adam 优化器和交叉熵损失函数
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# 训练模型，使用训练集进行训练
model.fit(train_images, train_labels, epochs=5, batch_size=64, validation_split=0.1)

# 在测试集上评估模型的性能
test_loss, test_acc = model.evaluate(test_images, test_labels)
print("测试集准确率:", test_acc)

# 创建一个包装函数来执行模型推理并生成 concrete function
@tf.function(input_signature=[tf.TensorSpec([None, 28, 28, 1], tf.float32)])
def serving_fn(input_tensor):
    return model(input_tensor)

# 使用 tf.saved_model.save() 并传递 signatures 保存模型为 TensorFlow SavedModel 格式
tf.saved_model.save(model, 'saved_model_dir', signatures={'serving_default': serving_fn.get_concrete_function()})

print("模型已成功保存为 SavedModel 格式")

# 将模型转换为 Core ML 格式，指定输入为图像类型
mlmodel = ct.convert('saved_model_dir', 
                     source='tensorflow', 
                     inputs=[ct.ImageType(shape=(1, 28, 28, 1), scale=1/255.0, 
                                          color_layout=ct.colorlayout.GRAYSCALE)])

# 保存转换后的 Core ML 模型
mlmodel.save("mnist_model.mlpackage")

print("模型已成功转换为 Core ML 格式，并保存为 mnist_model.mlpackage")
