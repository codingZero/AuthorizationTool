# AuthorizationTool
### 对各种获取授权代码进行了封装，直接调用即可，iOS10需要在info.plist中配置获取隐私数据权限声明

#### 以获取相册权限为例
###### iOS10首先在info.plist中配置
![](http://upload-images.jianshu.io/upload_images/1429074-b4381671b27b4840.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###### 获取相册权限的代码如下
![](http://upload-images.jianshu.io/upload_images/1429074-887a62a4801b6a45.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](http://upload-images.jianshu.io/upload_images/1429074-9b756a66a051d0c0.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
>1. 首先获取授权状态，如果为已授权则直接回调block
>2. 如果没有授权则会去请求授权，用户同意授权后回调block
>3. 如果用户之前已经拒绝授权，则会弹框提示让用户开启授权

###### 使用方法
![](http://upload-images.jianshu.io/upload_images/1429074-99e3dd641a381169.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
直接通过类调用即可，在block里面就可以继续其他操作了

### 注意
##### 用户拒绝授权后，提醒用户开启授权的提示信息需要在info.plist中配置，格式如下图所示
![](http://upload-images.jianshu.io/upload_images/1429074-682f1fed58939c7c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
根节点为Authorization，类型为字典，字典里面存放的是获取不同权限对应的不同提示文字，对应关系如下
>* 相册：photo
>* 相机：camera
>* 麦克风：audio
>* 通讯录：contact
>* 日历事件：event
>* 提醒事项：remind
>* common：通用（优先级比上面的低，如果上面的没有配置，就会使用common）
