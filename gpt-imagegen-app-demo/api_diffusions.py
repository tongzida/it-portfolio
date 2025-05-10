
import replicate
import os
from io import BytesIO
import requests


#https://replicate.com/blog/run-stable-diffusion-with-an-api

os.environ["REPLICATE_API_TOKEN"] = "sk-dead-token-for-demo-only"



def useStableDiffusion(_prompt):

    # print("------------stable diffusion Demo started---------------")
    # print("please wait~")
    
    #model = replicate.models.get("stability-ai/stable-diffusion")
    output_url = replicate.run(
        "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
        input={"prompt": _prompt}
    )
    return(output_url)


if __name__ == '__main__':

    prompt = "sunset scenery, mirror, reflection, illusion, transparent figure, hazy landscape, symbolism, lights, girl's face, indescribable beauty."

    print(useStableDiffusion(prompt))