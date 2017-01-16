###用于第三方应用加固后对 APK 文件的重签名。

因为应用加固服务的重新签名工具都是 Windows 下的，在 mac OS 下签名好麻烦，所以用这个脚本保存一下签名路径和密码，自动签名和重命名输出。
批量使用的话，可以再套一个脚本循环调用即可。

使用方式：
```shell
sh sign.sh <apk-file> [output-directory]
```

**Update**

签名方式由 ```jarsigner``` 更换为 ```apksigner``` , 可以默认使用 [APK Signature Scheme v2](https://source.android.com/security/apksigning/v2.html) 