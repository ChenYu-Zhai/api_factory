Gemini 图片创作接口使用指南 (v1.1 更新版)
1. 核心差异说明
● 返回格式: 接口不返回图片 URL，而是直接返回 Base64 编码的图片数据。
● 数据位置: 数据包裹在 Markdown 图片语法中：![image](data:image/jpeg;base64,...)。
● 客户端处理: 调用方必须从 content 字段中提取 Base64 字符串，解码并保存为图片文件。
2. 接口信息 & 请求 (保持不变)
● 接口地址: https://yunwu.ai/v1/chat/completions
● Header: Authorization: Bearer <YOUR_KEY>, Content-Type: application/json
3. 实际响应结构 (Response)
根据您提供的实际数据，响应如下：
{
  "id": "chatcmpl-20260128230620820804445tzXsxNPL",
  "model": "gemini-3-pro-image-preview",
  "object": "chat.completion",
  "created": 1769612804,
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "![image](data:image/jpeg;base64,/9j/4AAQSkZ...[省略大量Base64字符]...//Z)"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 263,
    "completion_tokens": 1393,
    "total_tokens": 1656
  }
}
4. Python 调用与图片保存示例 (重要)
由于返回的是 Base64 数据，我们需要使用正则表达式提取数据并解码保存。
import os
import re
import base64
from openai import OpenAI

# 1. 配置客户端
client = OpenAI(
    base_url="https://yunwu.ai/v1",
    api_key="YOUR_API_KEY"
)

# 2. 发送请求
try:
    print("正在请求生成图片...")
    response = client.chat.completions.create(
        model="gemini-3-pro-image-preview",  # 或 gemini-2.0-flash-exp-image-generation
        messages=[
            {
                "role": "user", 
                "content": "画一只在月球上喝咖啡的宇航员猫，写实风格"
            }
        ]
    )

    # 3. 获取返回内容
    content = response.choices[0].message.content
    print("请求成功，正在解析图片数据...")

    # 4. 提取 Base64 字符串 (使用正则匹配 Markdown 图片格式)
    # 匹配格式: ![image](data:image/jpeg;base64,......)
    image_pattern = r"!\[.*?\]\(data:image\/\w+;base64,(.*?)\)"
    match = re.search(image_pattern, content)

    if match:
        base64_data = match.group(1)
        
        # 5. 解码并保存为文件
        file_name = "gemini_generated_image.jpg"
        with open(file_name, "wb") as f:
            f.write(base64.b64decode(base64_data))
        
        print(f"图片已成功保存为: {os.path.abspath(file_name)}")
    else:
        print("未在返回内容中找到图片数据。原始内容:", content)

except Exception as e:
    print(f"发生错误: {e}")
5. 常见问题排查
● Response body 很大:
  ○ 因为包含了完整的 Base64 图片流，响应体可能会非常大（几 MB）。请确保您的 HTTP 客户端设置了足够的超时时间（Timeout）。
● JSON 解析失败:
  ○ 某些轻量级 JSON 解析器在处理超长字符串时可能会报错，请使用标准的 JSON 库。
● 图片格式:
  ○ 虽然示例中是 image/jpeg，但建议通过正则动态解析 image/png 或 image/webp 等可能的格式，或者根据文件头判断。
● 模型名称:
  ○ 示例中使用了 gemini-3-pro-image-preview，请根据平台实际支持的模型列表选择正确的 ID。
这份文档基于您提供的 OpenAPI Specification 编写，旨在帮助开发者快速接入 Midjourney 绘画 API。
该 API 采用异步任务模式：先提交绘画任务获取任务 ID，再通过任务 ID 查询生成进度和结果。

Midjourney API 使用指南
1. 基础信息
● API Base URL: https://yunwu.ai
● 鉴权方式: Bearer Token
● Content-Type: application/json
所有请求头 (Header) 需包含：
Authorization: Bearer {{YOUR_API_KEY}}
Content-Type: application/json

2. 核心流程
● 调用 [提交 Imagine 任务] 接口，获取 result (任务ID)。
● 使用任务ID 轮询 [查询任务状态] 接口，直到 status 变为 SUCCESS 或 progress 为 100%。
● 从查询结果中获取 imageUrl。

3. 接口详情
3.1 提交 Imagine 任务
提交提示词进行绘画（支持文生图、图生图）。
● 接口地址: /mj/submit/imagine
● 请求方式: POST
请求参数 (Body)
参数名	类型	必填	说明
prompt	string	是	绘画提示词（例如：Cat 或 A cyberpunk city --v 6.1）。
botType	string	是	机器人类型。<br>枚举值：MID_JOURNEY (默认 MJ 模型), NIJI_JOURNEY (二次元 Niji 模型)。
base64Array	array	否	垫图列表。包含图片 Base64 字符串的数组，用于图生图。
notifyHook	string	否	回调地址。任务完成或状态变更时，服务端会 POST 该地址。为空则使用全局配置。
state	string	否	自定义透传参数，查询任务时会原样返回，用于业务关联。
请求示例
{
    "botType": "MID_JOURNEY",
    "prompt": "A cute cat playing piano, cinematic lighting --ar 16:9",
    "base64Array": [],
    "notifyHook": "https://your-domain.com/callback",
    "state": "user_123_request"
}
响应示例
{
    "code": 1,
    "description": "Submit success",
    "result": "1730621718151844",  // 核心字段：任务ID，用于后续查询
    "properties": {
        "discordChannelId": "1300842676874379336",
        "discordInstanceId": "1572398367386955776"
    }
}

3.2 查询任务状态
根据任务 ID 获取绘画进度、图片链接及操作按钮（U/V 变换）。
● 接口地址: /mj/task/{id}/fetch
● 请求方式: GET
● 路径参数: 将 {id} 替换为提交接口返回的 result 值。
响应参数 (核心字段)
字段名	类型	说明
id	string	任务 ID。
status	string	任务状态。SUCCESS (成功), IN_PROGRESS (进行中), FAILURE (失败)。
progress	string	进度百分比，例如 100%。
imageUrl	string	生成的图片 URL（仅成功后有值）。
failReason	string	失败原因（如有）。
buttons	array	后续操作按钮列表（U1-U4, V1-V4 等），用于放大或变体操作。
响应示例 (成功状态)
{
    "id": "1730621826053455",
    "action": "IMAGINE",
    "prompt": "pig --v 6.1",
    "status": "SUCCESS",
    "progress": "100%",
    "imageUrl": "https://cdnmjp.oneabc.org/attachments/.../pig.png",
    "failReason": "",
    "buttons": [
        {
            "customId": "MJ::JOB::upsample::1::3785da...",
            "label": "U1",
            "type": 2
        },
        {
            "customId": "MJ::JOB::variation::1::3785da...",
            "label": "V1",
            "type": 2
        }
    ],
    "properties": {
        "finalPrompt": "pig --v 6.1"
    }
}

4. Python 调用示例 (完整流程)
以下代码演示了从提交任务到轮询获取结果的完整过程。
import time
import requests

# 配置信息
API_BASE_URL = "https://yunwu.ai"
API_KEY = "YOUR_API_KEY_HERE"  # 替换为你的 API Key

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

def submit_imagine(prompt):
    """提交绘画任务"""
    url = f"{API_BASE_URL}/mj/submit/imagine"
    payload = {
        "botType": "MID_JOURNEY",
        "prompt": prompt
    }
    
    try:
        resp = requests.post(url, headers=headers, json=payload)
        resp_json = resp.json()
        if resp_json.get("code") == 1:
            task_id = resp_json.get("result")
            print(f"[提交成功] 任务ID: {task_id}")
            return task_id
        else:
            print(f"[提交失败] {resp.text}")
            return None
    except Exception as e:
        print(f"[请求异常] {e}")
        return None

def fetch_task_result(task_id):
    """轮询查询任务结果"""
    url = f"{API_BASE_URL}/mj/task/{task_id}/fetch"
    
    while True:
        try:
            resp = requests.get(url, headers=headers)
            data = resp.json()
            
            status = data.get("status")
            progress = data.get("progress")
            
            print(f"[查询中] 状态: {status}, 进度: {progress}")
            
            if status == "SUCCESS":
                print(f"\n[绘画完成] 图片地址: {data.get('imageUrl')}")
                # print(f"后续操作按钮: {data.get('buttons')}")
                return data
            elif status == "FAILURE":
                print(f"\n[任务失败] 原因: {data.get('failReason')}")
                return None
            
            # 未完成则等待后重试
            time.sleep(3)
            
        except Exception as e:
            print(f"[查询异常] {e}")
            break

if __name__ == "__main__":
    # 1. 提交任务
    prompt_text = "A futuristic city floating in the sky, cyberpunk style --ar 16:9"
    task_id = submit_imagine(prompt_text)
    
    # 2. 如果提交成功，开始轮询
    if task_id:
        fetch_task_result(task_id)
5. 注意事项
● 轮询频率: 建议轮询间隔不要过短（建议 3-5 秒一次），以免触发速率限制。推荐使用 notifyHook 进行回调处理。
● 垫图 (Image Prompt): 如果需要使用参考图，请将图片转为 Base64 字符串放入 base64Array 数组中。
● Bot 类型:
  ○ MID_JOURNEY: 通用风格，适合写实、艺术等。
  ○ NIJI_JOURNEY: 动漫风格模型。
● 图片链接有效期: 返回的 CDN 链接可能存在有效期，建议业务端在获取到图片 URL 后及时转存。
这份指南基于您提供的 OpenAPI Specification 编写，旨在帮助开发者快速接入 Veo 视频生成 API。
该 API 采用异步任务模式：
● 调用 [创建视频] 接口提交任务，获取 id。
● 使用 id 轮询 [查询任务] 接口，直到生成完成并获取 video_url。

Veo 视频生成 API 使用指南
1. 基础信息
● API Base URL: https://yunwu.ai
● 鉴权方式: Bearer Token
● Content-Type: application/json
在所有 HTTP 请求头中需包含：
Authorization: Bearer {{YOUR_API_KEY}}
Content-Type: application/json

2. 核心流程
2.1 创建视频任务 (Create Video)
支持文生视频、图生视频（首尾帧控制）及视频元素编辑。
● 接口地址: /v1/video/create
● 请求方式: POST
请求参数 (Body)
参数名	类型	必填	说明
model	string	是	模型 ID（详见下方模型与图片规则表）。
prompt	string	是	视频内容的提示词。
images	array	否	图片 URL 列表。根据选择的 model 不同，图片的数量和用途不同。
aspect_ratio	string	是	视频比例。仅 veo3 系列支持。可选值："16:9" 或 "9:16"。
enhance_prompt	boolean	是	是否开启提示词增强。建议 true（将中文自动转为模型更好的英文 Prompt）。
enable_upsample	string	是	是否开启超分（提升分辨率）。建议开启。
🛠 模型与图片规则表 (Model & Images)
模型 ID (model)	图片数量限制	图片用途说明
veo2-fast-frames	最多 2 张	第1张为首帧，第2张为尾帧。
veo3-pro-frames	最多 1 张	仅支持首帧参考。
veo2-fast-components	最多 3 张	图片作为视频中的元素/物体。
veo3-fast-frames	(同类推)	首尾帧生成。
其他 (如 veo3, veo2)	0 张	纯文本生成视频。
请求示例
{
    "model": "veo3-fast-frames",
    "prompt": "一只牛飞上天了，背景是蓝天白云",
    "images": [
        "https://filesystem.site/cdn/start_frame.png",
        "https://filesystem.site/cdn/end_frame.png"
    ],
    "enhance_prompt": true,
    "enable_upsample": "true",
    "aspect_ratio": "16:9"
}
响应示例
{
    "id": "veo3-fast-frames:1762010543-twr7BEQ5wO",
    "status": "pending",
    "status_update_time": 1762010543957
}
注意：请保存返回的 id 用于后续查询。

2.2 查询任务结果 (Query Task)
根据任务 ID 查询生成状态和下载链接。
● 接口地址: /v1/video/query
● 请求方式: GET
请求参数 (Query)
参数名	类型	必填	说明
id	string	是	创建任务时返回的 id。
响应参数
字段名	类型	说明
id	string	任务 ID。
status	string	任务状态。pending (排队/处理中), success (成功), failed (失败)。
video_url	string	最终视频下载链接 (仅当 status 为 success 时有值)。
enhanced_prompt	string	经过 AI 润色后的实际执行提示词。
响应示例 (成功)

{
    "id": "veo3-fast-frames:1762010543-twr7BEQ5wO",
    "status": "success",
    "video_url": "https://filesystem.site/generated/video_result.mp4",
    "enhanced_prompt": "A surreal and whimsical digital painting of a cow...",
    "status_update_time": 1750323167003
}

3. Python 调用示例
以下代码演示了完整的“提交任务 -> 轮询等待 -> 获取视频”流程。

import time
import requests

# 配置
API_BASE_URL = "https://yunwu.ai"
API_KEY = "YOUR_API_KEY"  # 替换您的 API Key

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

def create_video_task():
    """提交生成视频任务"""
    url = f"{API_BASE_URL}/v1/video/create"
    
    # 示例：使用首尾帧生成视频
    payload = {
        "model": "veo3-fast-frames",
        "prompt": "Cinematic shot, rapid motion, from day to night timelapse",
        "images": [
            "https://filesystem.site/cdn/demo_start.png", # 首帧 URL
            # "https://filesystem.site/cdn/demo_end.png"    # 尾帧 URL (可选)
        ],
        "enhance_prompt": True,
        "enable_upsample": "true",
        "aspect_ratio": "16:9"
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        data = response.json()
        task_id = data.get("id")
        print(f"[任务提交成功] ID: {task_id}")
        return task_id
    except Exception as e:
        print(f"[提交失败] {e}")
        return None

def wait_for_result(task_id):
    """轮询查询结果"""
    url = f"{API_BASE_URL}/v1/video/query"
    params = {"id": task_id}
    
    start_time = time.time()
    timeout = 600  # 设置超时时间 (秒)
    
    while True:
        if time.time() - start_time > timeout:
            print("[超时] 任务生成时间过长")
            break
            
        try:
            response = requests.get(url, headers=headers, params=params)
            if response.status_code == 200:
                data = response.json()
                status = data.get("status")
                
                if status == "success":
                    video_url = data.get("video_url")
                    print(f"\n[生成完成] 视频地址: {video_url}")
                    print(f"[优化后提示词]: {data.get('enhanced_prompt')[:100]}...")
                    return video_url
                elif status == "failed":
                    print("\n[生成失败] 请检查参数或重试")
                    return None
                else:
                    print(f"\r[处理中] 状态: {status}...", end="")
            
            time.sleep(5) # 每5秒查询一次
            
        except Exception as e:
            print(f"\n[查询出错] {e}")
            break

if __name__ == "__main__":
    # 1. 创建任务
    tid = create_video_task()
    
    # 2. 如果创建成功，开始轮询
    if tid:
        wait_for_result(tid)
4. 注意事项
● 图片链接: images 数组中的 URL 必须是公网可访问的直链（如 CDN 链接）。
● 宽高比限制: 参数 aspect_ratio 目前仅在使用 veo3 系列模型时生效，且只支持 "16:9" 或 "9:16"。
● 模型选择:
  ○ 想要速度快：选 veo2-fast 或 veo3-fast。
  ○ 想要质量高：选 veo3-pro。
  ○ 需要控制画面连贯性：选 ...-frames 结尾的模型并传入首/尾帧图片。