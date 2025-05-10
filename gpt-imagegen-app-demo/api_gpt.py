# coding: UTF-8

import openai
import os

# 设置 API key
openai.api_key = "sk-dead-token-for-demo-only"
def useChatGpt_manual(messageForGpt):
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=messageForGpt
        )
        message_back = response.choices[0].message['content']
        return message_back
    except Exception as e:
        return f"error: {e}"

if __name__ == '__main__':
    text = '''
        {黄昏的景色在镜后移动着。也就是说,镜面映现的虚像与镜后的实物好像电影里的叠影一样在晃动。
        出场人物和背景没有任何联系。而且人物是一种透明的幻像,景物则是在夜霭中的朦胧暗流,两者消融在一起,描绘出一个超脱人世的象征的世界。
        特别是当山野里的灯火映照在姑娘的脸上时,那种无法形容的美,使岛村的心都几乎为之颤动。}
        '''

    command = "从下面这段文章中提取出一些关键字，并转化成英文，当作用来生成图像的prompt："
    p = command + text

    messageForGpt = [
        {"role": "user", "content": p},
    ]
    print(useChatGpt_manual(messageForGpt))
