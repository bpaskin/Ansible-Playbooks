This will install or upgrade IBM HTTP Server and the needed Java runtime on a system based on a local repository.  Variables are needed to be passed to the playbook:

```
IHS_DIR: /usr/HTTPServer
versionIHS: 90_9.0.5006.20201109_1605
versionJava: 8_8.0.6020.20201126_0807
```

If Java is not needed, then set `versionJava: null`
