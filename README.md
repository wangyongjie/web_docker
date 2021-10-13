> 需求完成后，前端开发人员如何部署到测试环境呢？
## 一、需求分析
我司的前端项目的部署原本是生成静态文件由运维传到cdn上的，为了提高效率，也避免编译文件纳入代码库，就由前端开发人员自己部署。因此，我分析需求并整理如下：
1. 可以部署多个vue项目
2. 便于部署到多个平台，不依赖于环境
3. 更新项目时，用户是无感知的

## 二、确定方案
决定采用docker部署，不依赖node，npm等环境

## 三、使用步骤

![1.gif](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5be03eae86b94cd7bda2020d5d73961d~tplv-k3u1fbpfcp-watermark.image?)

### 1. 创建deploy目录并拉取web_docker代码

![配.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3fd36ef0bc3a410c9f695c0779e8b7b3~tplv-k3u1fbpfcp-watermark.image?)

> 项目要放在/deploy目录下，如果想放到其他目录，则需要改动相关配置文件。

### 2. 执行init.sh 脚本

![2.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/066e9d58732446afbd42fa8b5b7af4a5~tplv-k3u1fbpfcp-watermark.image?)

该init.sh脚本的作用：
1. 下载所有配置好的项目
2. 自动帮所有项目安装依赖并生成编译文件
3. 根据docker-compose.yml启动nginx容器

**init.sh文件** 
```
#!/bin/bash

# $1 :: project
# $2 :: branch

sh ./update.sh $1 $2
docker-compose -f docker-compose.yml up -d
```
> Tips: 可传入两个参数，分别是project和branch，branch默认为master分支，用于指定安装某个项目，比如 
> sh init.sh vue-admin-template master

**update.sh文件** 
```
#!/bin/bash

project="all"
branch="master"

if [ "$1" != '' ]; then
    project=$1
fi
if [ "$2" != '' ]; then
    branch=$2
fi

if [ "$project" == 'vue-admin-template' ] || [ "$project" == 'all' ]; then
    echo '-------start update vue-admin-template-------'
    cd ../
    if [ ! -d './vue-admin-template' ]; then
        git clone -b $branch https://github.com/PanJiaChen/vue-admin-template.git
    fi
    cp web_docker/build/docker-build.sh vue-admin-template/docker-build.sh
    cp web_docker/build/build.sh vue-admin-template/build.sh
    cd vue-admin-template
    sh ./docker-build.sh
    echo '-------end update vue-admin-template-------'
fi
```

> 这里是下载vue-admin-template项目，那么docker-build.sh 和 build.sh是用来做什么呢？其实这两个文件是用来安装项目依赖并生成编译文件。

**docker-build.sh文件** 
```
#!/bin/bash
echo '---start build---'
docker run --rm -v $(pwd):/work node:14.2.0-slim bash -c "cd /work && sh build.sh"
echo '---end build---'
```
这里会使用docker run命令来启动一个临时容器，使用node:14.2.0-slim镜像，会把项目的文件映射到容器的/work目录，然后在容器内执行sh build.sh

> 这也是docker的强大之处，容器内已经有node环境和npm环境，在容器内可以安装项目依赖和生成编译文件，也就不依赖于宿主机去安装node环境。那么build.sh脚本做了什么呢？

**build.sh文件** 
```
#!/bin/bash

npm install -P && npm run build:prod
if [ -d './dist_docker' ]; then
    mv ./dist_docker ./dist_docker_copy
fi
mv ./dist ./dist_docker
if [ -d './dist_docker_copy' ]; then
    rm -rf ./dist_docker_copy
fi
```

这里是安装项目依赖并生成编译文件，一般vue项目的编译文件是默认放到dist目录下的，为了在项目编译过程中不影响用户的使用，所以额外使用dist_docker文件夹。用户看到的页面是dist_docker里的静态文件。

> 编译需要耗费较长时间，而更改文件夹名称耗时非常短，通过dist和dist_docker文件夹的来回切换来保证项目更新时，用户是无感知的。

**docker-compose.yml文件** 
```
version: "3"
services:
  nginx:
    image: nginx
    build: ./nginx
    container_name: nginx_docker
    volumes:
      - /deploy:/deploy
      - /deploy/web_docker/nginx/conf.d:/etc/nginx/conf.d
    restart: always
  #   ports:
  #     - "80:80"
  # web:
  #   image: web
  #   build: ./web
  #   container_name: web_server_docker
  #   restart: always
  #   volumes:
  #     - /deploy/web_docker/web/node_server:/node_server
  #   ports:
  #     - "20000:20000"
```

根据docker-compose.yml来启动nginx容器，/deploy/web_docker/nginx/conf.d会映射到容器的/etc/nginx/conf.d。那么都有哪些nginx配置呢？

> Tips: 可以看出，这里还有一个web容器被注释掉，因为不一定会被使用，所以注释了，是用来自动更新项目的。如果你希望你push代码到代码仓库后，可以自动更新测试环境或正式环境的项目。那么就可以启动该容器，同时代码仓库中配置web钩子，具体实现细节，可以看该web容器的相关配置，这里就不赘述了。

**vue-admin-template.conf文件** 
```
server{
    listen 20001;
    server_name vue-admin-template;
    root /deploy/vue-admin-template/dist_docker/;
    gzip on;
    gzip_static on;
    gzip_disable "msie6";
    gzip_min_length 10240;
    gzip_buffers 4 16k;
    gzip_comp_level 3;
    gzip_types text/plain application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/peg image/gif image/png;
    gzip_vary off;

    location ~ .*\.(gif|jpg|jpeg|png|css|js|ico|eot|otf|fon|font|ttf|ttc|woff|woff2)(.*) {
        add_header Cache-Control "public, max-age=2592000";
    }

    location ~* .*\.(?!gif|jpg|jpeg|png|css|js|ico|eot|otf|fon|font|ttf|ttc|woff|woff2$){
        add_header Cache-Control 'no-cache, must-revalidate, proxy-revalidate, max-age=0';
    }

    location / {
        try_files $uri $uri/ /index.html;
        error_page 404 /index.html;
    }
}
```
这里定义了vue-admin-template项目在nginx容器的端口为20001，nginx配置了gzip，缓存头等内容。

**domain.conf文件**
```
server {
    listen  80;
    server_name domain.com;
    access_log  /var/log/nginx/domain.com.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP        $remote_addr;
        proxy_set_header X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://172.24.0.2:20001/;
    }
}
```
这里是用来做nginx转发使用的，如果宿主机没有安装nginx监听到80端口，那么可以在docker-compose.yml文件内把80端口映射出来，容器内做nginx转发。

### 3. 查询docker容器启动情况

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e27d490997b41ac92a7378c7ca4a1ff~tplv-k3u1fbpfcp-watermark.image?)

可以看出，nginx_docker容器正常启动，容器id为 eb70ff5855e8。如果容器启动失败，那么在STATUS那栏，会不断尝试重启，这时候我们可以通过docker logs eb70ff5855e8 来查看容器启动日志，找到启动失败原因并解决。

### 4. 查询分配给docker容器的ip
因为docker-compose.yml文件中并没有配置port端口，所以容器的端口和宿主机的端口并没有映射。我们知道，vue-admin-template在容器内的监听端口是20001，假如宿主机的ip是 192.168.x.x, 我们是无法访问 http://192.168.x.x:20001 的，浏览器会报无法访问此网站。这时，我们可通过docker inspect eb70ff5855e8 去查看容器相关内容

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e639c07e694444908a8cece39dd75990~tplv-k3u1fbpfcp-watermark.image?)

可以看到，分配给容器eb70ff5855e8的ip是172.24.0.2，那么我们尝试在宿主机内访问 http://172.24.0.2:20001

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2ecbd0ae524442f7ac348c28c0b0c062~tplv-k3u1fbpfcp-watermark.image?)

可以看出，访问成功，那么浏览器如何访问该项目呢，我们默认宿主机是有安装nginx的，这时就需要在宿主机的nginx配置转发。如果宿主机没有安装nginx且没有监听80端口，我们可以放开80端口映射，在容器内配置转发。


![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9c348ef96d334c9fb6262182f8f1195e~tplv-k3u1fbpfcp-watermark.image?)

### 5. 宿主机的nginx配置转发
增加domain.conf文件，内容如下：
```
server {
    listen  80;
    server_name domain.com;
    access_log  /var/log/nginx/domain.com.log;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP        $remote_addr;
        proxy_set_header X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://172.24.0.2:20001/;
    }
}
```
然后reload宿主机的nginx

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9352f7bc1924457d8c778fc7875a6051~tplv-k3u1fbpfcp-watermark.image?)

### 6. 配置host，domain.com指向宿主机ip，浏览器访问 http://domain.com

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1b998416593b4c73acb17aca8ef5beeb~tplv-k3u1fbpfcp-watermark.image?)

完美。

## 四、FAQ

#### 问题：如果想添加新项目，该如何做？
1. 更新update.sh，添加新项目的git仓库地址。
2. 新增nginx/conf.d 目录下的配置，给该项目添加配置。
3. 宿主机nginx增加配置处理转发。
4. 执行sh init.sh 新项目

#### 问题：项目代码有更新，该如何做？
进入到该项目的目录下，执行 sh docker-build.sh

#### 问题：项目监听端口有变化，该如何做？
1. 修改nginx/conf.d 目录下的配置
2. 进入nginx容器内reload，或者重启nginx容器。

## 五、总结
该docker部署方案也应用到我司的项目中，后续会不断完善，更多代码细节请查看
[web_docker](https://github.com/wangyongjie/web_docker)。 如果觉得对你有帮助，不要吝啬点个赞哈。如果有更好的优化建议，欢迎在评论区讨论，也欢迎大家fork该项目并提交pull request。