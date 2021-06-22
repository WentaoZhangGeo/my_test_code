# 下载 Anaconda
建议 Python 用户使用 Anaconda 而非系统自带的 Python。

进入 Anaconda 官方下载页面，会看到类似下图的下载页面。根据自己的系统选择对应的安装包。

# 安装 Anaconda
bash Anaconda3-2020.11-Linux-x86_64.sh

# 常用命令:
桌面图形用户界面<br>
anaconda-navigator

安装完成后，对所有工具包进行升级，以避免可能的错误。打开你终端，在命令行中输入：<br>
conda upgrade --all

更新 conda 和 Anaconda:<br>
conda update conda
conda update anaconda

添加 conda 的第三方软件包源 conda-forge:<br>
conda config --add channels conda-forge

创建虚拟环境:<br>
conda create --name $环境名字$

激活名为 $环境名字$ 的虚拟环境<br>
conda activate $环境名字$

取消激活当前虚拟环境:<br>
conda deactivate

注意:<br>
安装 Anaconda 后，打开终端默认会激活 base 环境，取消此默认设置:<br>
conda config --set auto_activate_base False

取消后，可以临时激活 base 环境:<br>
conda activate base

重新激活此默认设置:<br>
conda config --set auto_activate_base True

搜索模块:<br>
conda search numpy

安装模块:<br>
conda install numpy

更新模块:<br>
conda update numpy

使用 pip 安装模块:<br>
pip install numpy

显示所有的环境：<br>
conda env list

当分享代码的时候，同时也需要将运行环境分享给大家，执行如下命令可以将当前环境下的 package 信息存入名为 environment 的 YAML 文件中。<br>
conda env export > environment.yaml

同样，当执行他人的代码时，也需要配置相应的环境。这时你可以用对方分享的 YAML 文件来创建一摸一样的运行环境。 <br>
conda env create -f environment.yaml
