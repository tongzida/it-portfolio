import ssl
ssl._create_default_https_context = ssl._create_unverified_context

import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms
from torch.utils.data import DataLoader
import matplotlib.pyplot as plt

# 定义数据的转换方式：将图像转换为张量，并对图像进行标准化
transform = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.5,), (0.5,))])

# 下载和加载训练集与测试集
train_dataset = datasets.MNIST(root='./data', train=True, transform=transform, download=True)
test_dataset = datasets.MNIST(root='./data', train=False, transform=transform, download=True)

# 将训练集和测试集加载到 DataLoader 中，以批次形式读取
train_loader = DataLoader(dataset=train_dataset, batch_size=64, shuffle=True)
test_loader = DataLoader(dataset=test_dataset, batch_size=64, shuffle=False)

# 定义模型
class MNISTModel(nn.Module):
    def __init__(self):
        super(MNISTModel, self).__init__()
        self.fc1 = nn.Linear(28 * 28, 128)  # 输入层
        self.fc2 = nn.Linear(128, 64)       # 隐藏层
        self.fc3 = nn.Linear(64, 10)        # 输出层
        
    def forward(self, x):
        x = x.view(-1, 28 * 28)  # 将输入的图片展平成一维张量
        x = torch.relu(self.fc1(x))  # 使用 ReLU 激活函数
        x = torch.relu(self.fc2(x))  # 第二层的 ReLU
        x = self.fc3(x)              # 输出层
        return x

# 实例化模型
model = MNISTModel()
criterion = nn.CrossEntropyLoss()  # 使用交叉熵损失函数
optimizer = optim.Adam(model.parameters(), lr=0.001)  # 使用Adam优化器

# 记录每个 Epoch 的损失
losses = []

# 训练模型
epochs = 5  # 训练的轮次
for epoch in range(epochs):
    model.train()  # 设置模型为训练模式
    running_loss = 0.0
    for images, labels in train_loader:
        optimizer.zero_grad()  # 清除之前的梯度
        outputs = model(images)  # 前向传播，计算预测值
        loss = criterion(outputs, labels)  # 计算损失
        loss.backward()  # 反向传播，计算梯度
        optimizer.step()  # 优化器更新权重

        running_loss += loss.item()  # 累积损失值
    
    avg_loss = running_loss / len(train_loader)
    losses.append(avg_loss)  # 保存每个 epoch 的平均损失
    print(f"Epoch [{epoch+1}/{epochs}], Loss: {avg_loss}")

# 评估模型
model.eval()  # 设置模型为评估模式
correct = 0
total = 0

with torch.no_grad():
    for images, labels in test_loader:
        outputs = model(images)
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

accuracy = 100 * correct / total
print(f"Accuracy of the model on the 10000 test images: {accuracy}%")

# 保存模型
torch.save(model.state_dict(), 'mnist_model.pth')
print("模型已保存")

# 保存模型准确率到文件
with open('model_report.txt', 'w') as f:
    f.write(f"Model Accuracy on the test set: {accuracy}%\n")

# 绘制损失曲线
plt.plot(losses)
plt.title('Training Loss Over Epochs')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.grid(True)
plt.savefig('loss_curve.png')  # 保存损失曲线为图像文件
plt.show()

# 加载模型
model = MNISTModel()  # 重新实例化MNISTModel
model.load_state_dict(torch.load('mnist_model.pth'))  # 加载模型权重
model.eval()  # 切换到评估模式
print("模型已加载并切换到评估模式")

# 测试加载的模型
correct = 0
total = 0
with torch.no_grad():
    for images, labels in test_loader:
        outputs = model(images)
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

loaded_model_accuracy = 100 * correct / total
print(f"Accuracy of the loaded model on the 10000 test images: {loaded_model_accuracy}%")
