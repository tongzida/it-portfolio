import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import requests
from io import BytesIO
from api_gpt import useChatGpt_manual
from api_diffusions import useStableDiffusion  

def generate_image():
    try:
        color = text_color.get("1.0", tk.END).strip()
        animal = animal_var.get()
        place = place_var.get()
        additional_info = text_additional.get("1.0", tk.END).strip()

        input_text = f"好きな色: {color}\n好きな動物: {animal}\n好きな場所: {place}"
        if additional_info:
            input_text += f"\n補充情報: {additional_info}"
        
        print("入力テキスト:", input_text)

        text_c.configure(state="normal")
        text_c.insert(tk.END, input_text + "\n")

        command = "以下の文章からいくつかのキーワードを抽出し、英語に翻訳して、画像生成のプロンプトとして使用してください："
        text_c.insert(tk.END, "GPTを使用中" + "\n")
        print("コマンド:", command)

        prompt_gpt = command + input_text
        messageForGpt = [{"role": "user", "content": prompt_gpt}]
        print("GPTへのメッセージ:", messageForGpt)

        # GPT API を呼び出して応答をチェック
        prompt_diff = useChatGpt_manual(messageForGpt)
        if "error" in prompt_diff:
            raise Exception(prompt_diff)
        print("Diffusionのプロンプト:", prompt_diff)

        text_c.configure(state="normal")
        text_c.insert(tk.END, prompt_diff + "\n")

        text_c.insert(tk.END, "Diffを使用中" + "\n")
        
        # Stable Diffusion API を呼び出して応答をチェック
        img_urls = useStableDiffusion(prompt_diff)
        if not img_urls or len(img_urls) == 0:
            raise Exception("Stable Diffusion API から画像URLを取得できませんでした")
        img_url = img_urls[0]
        print("画像URL:", img_url)

        response = requests.get(img_url)
        if response.status_code != 200:
            raise Exception(f"URLから画像を取得できませんでした: {img_url}")
        
        img = Image.open(BytesIO(response.content))
        img.thumbnail((300, 300))
        tk_img = ImageTk.PhotoImage(img)
        text_c.image_create(tk.END, image=tk_img, padx=10)
        text_c.image.append(tk_img)
        
        text_c.configure(state="disabled")

        # 生成後清空补充信息
        text_additional.delete("1.0", tk.END)
    except Exception as e:
        text_c.configure(state="normal")
        text_c.insert(tk.END, f"エラー: {e}\n")
        text_c.configure(state="disabled")
        print(f"エラー: {e}")

window = tk.Tk()
window.title("インターフェース")

screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()
window.geometry(f"{screen_width}x{screen_height}")

frame_left = ttk.Frame(window)
frame_left.pack(side="left", padx=10, pady=10)

# 好きな色部分
frame_color = ttk.LabelFrame(frame_left, text="好きな色")
frame_color.pack(fill="x", pady=5)
text_color = tk.Text(frame_color, width=90, height=2, wrap="word")
text_color.pack(padx=5, pady=5)

# 好きな動物部分
frame_animal = ttk.LabelFrame(frame_left, text="好きな動物")
frame_animal.pack(fill="x", pady=5)
animal_var = tk.StringVar(value="猫")  # 设置默认值
animals = ["猫", "犬", "鳥", "ウサギ", "イルカ", "カメ", "クマ", "サル"]
for animal in animals:
    rb = ttk.Radiobutton(frame_animal, text=animal, variable=animal_var, value=animal)
    rb.pack(anchor="w", padx=5, pady=2)

# 好きな場所部分
frame_place = ttk.LabelFrame(frame_left, text="好きな場所")
frame_place.pack(fill="x", pady=5)
place_var = tk.StringVar(value="海")  # 设置默认值
places = ["海", "山", "公園", "森"]
for place in places:
    rb = ttk.Radiobutton(frame_place, text=place, variable=place_var, value=place)
    rb.pack(anchor="w", padx=5, pady=2)

# 補充情報部分
frame_additional = ttk.LabelFrame(frame_left, text="補充情報")
frame_additional.pack(fill="x", pady=5)
text_additional = tk.Text(frame_additional, width=90, height=4, wrap="word")
text_additional.pack(padx=5, pady=5)

frame_right = ttk.Frame(window)
frame_right.pack(side="right", padx=10, pady=10)

label_c = ttk.Label(frame_right, text="表示エリア")
label_c.pack()
text_c = tk.Text(frame_right, width=100, height=100, wrap="word", state="disabled")
text_c.pack(pady=10)

text_c.image = []

scrollbar_c = ttk.Scrollbar(frame_right, orient="vertical", command=text_c.yview)
scrollbar_c.pack(side="right", fill="y")
text_c.configure(yscrollcommand=scrollbar_c.set)

button_generate = ttk.Button(window, text="生成開始", command=generate_image)
button_generate.pack(side="bottom", pady=5)

style = ttk.Style()
style.configure("TFrame", background="#ffffff")
style.configure("TButton", background="#666666", foreground="white")

window.mainloop()
