# Rails 的 Capistrano 部署助手任务

此项目是为了节省使用 Capistrano 部署 Rails 应用的时间。

## 使用方法

配置好 Capistrano 后，复制任务文件到项目中，使用 `cap` 命令来执行。

## 任务介绍

* 创建项目的 *.rbenv-vars* 配置文件:

      cap production rbenv:setup

* 创建项目的 Nginx 配置文件:

      cap production nginx:setup

* 从服务器端备份数据

      cap production backup
