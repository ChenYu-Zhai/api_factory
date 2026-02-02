企业级 AI 动画师工作台实施策略书 v2.0 (Updated)
1. 产品定义与核心架构（升级版）

产品定位：面向专业 AI 动画师的非线性资产生产工作台。核心价值在于解决“美学”与“一致性”难以兼得的痛点。

核心逻辑："Hybrid Model Pipeline" (混合模型流水线) —— 结合 Midjourney 的审美与 Nano/SD 的控制力，通过 Flutter 客户端进行串联。

技术架构关键点：

UI层：纯展示与指令发送，零阻塞。

Service层：全异步 Isolate 线程池，负责繁重的 Base64 转码与 API 轮询。

数据层：基于“血缘关系 (Lineage)”的文件版本树。

2. 模块化实施方案（重点修改模块）
模块 B：本地资产与数据管理 (DAM System)

新增了对混合模型“加工流”的记录支持。

数据模型更新 (Dart Model)：

code
Dart
download
content_copy
expand_less
class AssetNode {
  String id;
  String filePath;
  String type;        // 'image_base', 'image_refined', 'video'
  String? parentId;   // 指向上一张图（如 MJ 原图）
  
  // [新增] 记录加工流水线，用于回溯和二次编辑
  Map<String, dynamic> pipelineInfo; 
  // 示例: { 
  //   "base_model": "midjourney-v6", 
  //   "refiner_model": "nanobanana-pro", 
  //   "operation": "face_swap_consistency" 
  // }
  
  bool isFavorite;
}
模块 C：API 中转与异步调度系统 (重构)

为了实现“后台修图、前台继续操作”，引入全局任务队列。

架构设计：

UI 交互：用户点击“精修”，UI 立即在界面上生成一个**“占位卡片 (Placeholder Card)”**，显示“处理中...”，用户可立即离开当前页面（例如切换到剧本工作台）。

TaskQueueService (单例)：

接收任务 -> 写入内存队列。

Isolate 运算：使用 Flutter compute() 函数在独立线程处理图片（读取 5MB 图片 -> 压缩 -> 转 Base64），严禁在主线程做 IO 操作。

API 轮询：后台静默轮询 API 状态。

状态通知：任务完成后，通过 Riverpod/Bloc 发送全局广播，更新“占位卡片”为真实图片，并弹出无打扰 Toast 提示。

3. 核心工作流具体实现步骤 (Core Workflow - Revised)

这一部分变动最大，插入了**“精修”**环节。

Step 1: 剧本解析 & 预设 (Script Parsing)

保持不变：LLM 解析文本为 JSON 分镜列表。

新增：解析时自动提取“角色标签”，预判哪些镜头需要高一致性处理。

Step 2: 角色设定 (Character Asset)

产出：生成标准三视图。

关键动作：将角色图上传至 API（或转 Base64），获取并缓存其 Embeddings 或 FaceID，作为后续所有步骤的**“核心参照物 (Master Reference)”**。

Step 3: 首帧底图生成 (Aesthetics Generation)

工具：Midjourney / Flux.1 (取其构图、光影、艺术感)。

操作：批量生成 4 张底图。

痛点：此时角色脸部可能不准，细节不可控。

用户行为：用户挑选一张构图最完美的图，点击**“魔棒 (Refine)”** 按钮。

Step 3.5 (新增): 混合模型精修 (Hybrid Refinement)

目标：将 Step 2 的“角色脸”完美融合进 Step 3 的“底图”。

后台流程 (异步)：

锁定底图：取 Step 3 选中的 MJ 图片。

锁定角色：取 Step 2 的 Master Reference。

API 路由：调用支持一致性的模型接口 (如 NanoBananaPro 或 SDXL + IP-Adapter)。

操作类型：

Type A (换脸/FaceID)：仅替换面部特征，保留 MJ 的光影。

Type B (重绘/Inpainting)：用户在 Flutter 画板涂抹头部，API 进行局部重绘。

产出：生成 v1_refined.png，作为该镜头最终确认的 "Master Start Frame"。

Step 4: 尾帧与视频生成 (Animation)

输入源变更：

首帧：必须使用 Step 3.5 产出的 Refined Frame (确保视频里的主角是对的)。

尾帧：基于 Refined Frame 进行编辑 (Inpainting/Outpainting)。

视频生成：调用 I2V 模型 (Kling/Runway)，输入首尾帧生成视频。

4. 风险控制与应对 (Updated)
风险点	场景描述	技术应对策略
内存溢出 (OOM)	列表里图片太多，且 Base64 转换频繁	1. 虚拟列表：只渲染屏幕内的图片。<br>2. 及时释放：Base64 字符串用完即焚 (置空)，不要常驻内存。<br>3. 缩略图机制：列表仅加载 20KB 的缩略图，详情才加载原图。
任务丢失	用户点了修图，然后把软件关了	持久化队列：将 TaskQueue 写入本地 SQLite/JSON。下次启动软件时，检查是否有 pending 任务，如有则自动恢复轮询或标记失败。
风格割裂	MJ 的底图和 Nano 的修补图画风不统一	参数调优：在 API 请求中引入 denoising_strength (重绘幅度) 参数调节。Flutter 端提供滑杆，允许用户微调“保留原图多少细节”。
5. 研发阶段规划 (Roadmap - Adjusted)

由于增加了复杂的混合模型流程，研发顺序建议调整：

阶段一：骨架与基础生图 (Start)

搭建 Flutter 框架，实现文件管理。

跑通最简单的 T2I (Flux/MJ) 流程。

阶段二：异步任务引擎 (Engine) —— 提权

优先开发 BackgroundTaskManager。这是支持“后台修图”的地基。

解决 Isolate 通信和本地队列持久化问题。

阶段三：混合模型流水线 (Refinement)

开发 Canvas 涂抹功能。

对接“换脸/一致性”API。

实现 Step 3 -> Step 3.5 的 UI 交互 (右键菜单/魔棒)。

阶段四：视频生成 (Video)

最后再接入视频 API，因为视频是基于完美图片生成的。
