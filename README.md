# Requirements

IOS 8 or later , XCode 7 or later

# Installation

pod 'WTNetworking'

# WTNetworking
架构图
![WTNetworking.jpg](http://upload-images.jianshu.io/upload_images/901318-ae4c504e623f1230.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
# 主要类
# WTRequest
1. 网络请求基类，上层request需要继承这个类
2. 请求前会判断是否使用缓存，如果使用缓存，直接返回缓存数据，同事发送网络请求，请求回来后，跟新缓存数据
3. 包含cancel接口，可以cancel请求。

# WTCache
1. 数据库缓存
2. 内存缓存

# WTSessionManager
1. 封装AFNetworking接口
