# my_test_code
Using github in Pycharm
-------
1. Set git & github in Pycharm
2. Create a new repository in github website
3. Clone the repository in Pycharm

## ubuntu下配置git
1. 安装git
`sudo apt install git`
2. 配置git
 * 本地计算机配置用户名和邮箱
```bash
# 显示当前的Git配置
git config --list
# 编辑Git配置文件 (nano打开文件)
git config -e --global
# 设置提交代码时的用户信息
git config --global user.name "w**"
git config --global user.email "z******.com@gmail.com"
# 查看配置
git config --list
```
 * 配置SSH秘钥
```bash
ssh-keygen -t rsa -C "zhangwentaoucas@gmail.com"
# 提示的地方直接按Enter

# 查看生成秘钥
cat ~/.ssh/id_rsa.pub
# 或者
gedit ~/.ssh/id_rsa.pub
```
**配置SSH**
- 登录github官网，网址：https://github.com/
- 右上角 登陆后点击settings->SSH and GPS keys->New SSH key
- 将id_rsa.pub文件中的内容全部复制到key中，输入title，点击Add SSH key 即可。

- 最后检查下本地是否与github连接成功 `ssh -T git@github.com` 选择yes即可
- SSH用法 `git clone git@github.com:wzhang1994/Log.git`
-  或者 `git clone https://github.com/wzhang1994/Log`

**配置个人访问令牌**
- 登录github官网，网址：https://github.com/
- 右上角 登陆后点击settings->Developer settings(最后一行)->Personal access tokens, 根据需要选择和填写，密码只显示一次，请保存好
- 避免同一个仓库每次提交代码都要输入token，把token直接添加远程仓库链接中
```bash
git remote set-url origin https://<your_token>@github.com/<USERNAME>/<REPO>
```
<your_token>：换成你自己得到的token

<USERNAME>：是你自己github的用户名

<REPO>：是你的仓库名称
- 

**注意**: 从 2021 年 8 月 13 日起，GitHub 在对 Git 操作进行身份验证时不再接受帐户密码。您需要添加PAT（个人访问令牌），您可以按照以下方法在您的系统上添加 PAT。


## github常见命令:

```bash

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
git push

```
