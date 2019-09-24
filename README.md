# concourse-aliyun-oss-resource [Concourse](https://concourse-ci.org/)

This is aliyun oss resource for [Concourse](https://concourse-ci.org/) to be able to manipulate oss on aliyun from concourse.  
这个resource type用于在concourse上通过ossutil指令行工具操作阿里云oss

参考:  
[developing-a-custom-concourse-resource](https://content.pivotal.io/blog/developing-a-custom-concourse-resource)  
[Tutorials](https://github.com/concourse/concourse/wiki/Tutorials)  
[ali oss cp document](https://help.aliyun.com/document_detail/120057.html)

### build步骤:
需要一个docker注册中心,可以使用docker hub或自己搭建一个ssl安全的docker registry
```shell
docker build -t gugege/concourse-aliyun-oss-resource:0.1 -f Dockerfile .  
docker push gugege/concourse-aliyun-oss-resource:0.1  
fly -t example login --concourse-url $url  
fly -t example set-pipeline --pipeline ali-oss-sample --config alioss-ci.yml  --load-vars-from concourse-credentials.yml
```

### example pipeline
[alioss-ci.yml](https://github.com/gugegev5/concourse-aliyun-oss-resource/blob/master/alioss-ci.yml)

### 功能

#### put
通过cmd/cmds 执行ossutil32 --config-file myconfig $CMD  
cmds,cmd会拼成数组遍历执行  
#### get
需要单独建一个git项目,根目录放一个deploy_hash的文件用来拼接路径:`url_to_download="$prefix_dir/$deploy_hash/"`  
e.g:  
prefix_dir=oss://h5-concourse/h5  
deploy_hash存放的值是test  
执行`ossutil32 --config-file myconfig cp -r oss://h5-concourse/h5/test/ $SRC_DIR"`  
> 其中`SRC_DIR`是concourse的get路径

#### Parameters
```
resource_types:
- name: ali-oss-resource
  type: docker-image
  source:
      repository: gugege/concourse-aliyun-oss-resource
      tag: 0.1

resources:
- name: ali-oss
  type: ali-oss-resource
  source:
    endpoint: ((endpoint))
    accessKeyID: ((accessKeyID))
    accessKeySecret: ((accessKeySecret))
    git_private_key: ((git_private_key))
```
```
  - put: ali-oss
    params:
        cmd: "cp upload_src/testfile1 oss://h5-concourse/h5/test/testfile1 -u"
        cmds:
        - "cp upload_src/testfile2 oss://h5-concourse/h5/test/testfile2 -u"
        - "cp upload_src/testfile3 oss://h5-concourse/h5/test/testfile3 -u"

  - get: ali-oss
    params:
      prefix_dir: oss://h5-concourse/h5
      git_url: git@gitee.com:buybuystore/h5-deploy.git
```

### Tips:
1. 之前的step产生的文件路径:`${task.outputs}/`
> [task-outputs](https://concourse-ci.org/tasks.html#task-outputs)
The directory will be automatically created before the task runs, and the task should ***place any artifacts it wants to export in the directory***.
```
jobs:
- name: test
  public: true
  plan:
  - task: test upload
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: gugege/node_12_4_cnpm_rsync
          tag: '1.0'
      run:
        path: /bin/bash
        args:
        - -exc
        - |
          echo "testfile1" > ./upload_src/testfile1
          echo "testfile2" > ./upload_src/testfile2
          pwd
          ls -alhR .
      outputs:
      - name: upload_src
  - put: ali-oss
    params:
        cmds:
        - "cp -r upload_src/ oss://h5-concourse/h5 -u"
```
2. tag: 1.0 在set-pipeline时会自动解析成tag: 1

### 用shell编写的resources参考list
[concourse-rsync-resource](https://github.com/mrsixw/concourse-rsync-resource)  
[rocketchat-notification-resource](https://github.com/michaellihs/rocketchat-notification-resource/blob/master/out)  
[semver-config-concourse-resource](https://github.com/brightzheng100/semver-config-concourse-resource/blob/master/in)  
[eng-concourse-resource-github-list-repos](https://github.com/coralogix/eng-concourse-resource-github-list-repos/blob/master/src/in)  
[concourse-rubygems-resource](https://github.com/troykinsella/concourse-rubygems-resource/blob/master/assets/out#L60)  
[concourse-docker-compose-resource](https://github.com/troykinsella/concourse-docker-compose-resource)  
