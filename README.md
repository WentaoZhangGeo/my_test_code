my_test_code
============
Using github in Pycharm
-------
1. Set git & github in Pycharm
2. Create a new repository in github website
3. Clone the repository in Pycharm


github常见命令:
========
```bash
# 显示当前的Git配置
git config --list
# 编辑Git配置文件
git config -e [--global]
# 设置提交代码时的用户信息
git config --global user.name "w**"
git config --global user.email "z******.com@gmail.com"


# 下载一个项目和它的整个代码历史
git clone https://github.com/wzhang1994/my_test_code
# 检查是否有变更的文件
cd $Repository_dir$ # 进入仓库的目录
git status
# 更新最新的代码
git pull 

# 新文件提交到缓冲区，但注意并没有提交到远程仓库
git add .
# 备注新文件的信息
git commit -m 
# 提交到远程仓库
git pull

```
