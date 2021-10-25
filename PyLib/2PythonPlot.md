这里提供Python常见的绘图命令及简单例子

# 常用的库
```python
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import rcParams						# 用于自定义matplotlib的默认参数
```

```python
# 自定义matplotlib的默认参数
rcParams['pcolor.shading']='auto'
rcParams["image.cmap"] = 'Spectral_r'

params={'font.family':'serif', 
        'font.serif':'Arial', # 'Times New Roman', 'Arial'
        'font.style':'normal', # ‘normal’, ‘italic’ or ‘oblique’.
        'font.weight':'normal', #or ‘normal’ 'bold'
        'font.size':16,#or large,small 'medium'
        }
rcParams.update(params)
# rcParams["mathtext.default"]  


# 函数: 控制次级图像坐标轴线段的粗细
def font_tick_params(ax):                     # ax = fig.add_subplot(1, 4, 1)
#     ax.tick_params(axis='y', labelsize=14)
    ax.tick_params(direction='in',length=6,labelsize=16)
    LW=2
    ax.spines['bottom'].set_linewidth(LW) ###设置底部坐标轴的粗细
    ax.spines['left'].set_linewidth(LW) ####设置左边坐标轴的粗细
    ax.spines['right'].set_linewidth(LW) ###设置右边坐标轴的粗细
    ax.spines['top'].set_linewidth(LW) ####设置上部坐标轴的粗细


# 函数: 控制字体的格式
def font():
    font={
#         'family':'Times New Roman', 		# 'Times New Roman', 'Arial'
#         'style':'normal',								# ‘normal’, ‘italic’ or ‘oblique’.
#         'weight':'normal',						#or ‘normal’ 'bold'
#         'color':'black',
        'size':16
         }
    return font

# 使用def font()函数控制字体的格式
def fig_pcolor(X, Y, Z,label):
    plt.figure()
    plt.pcolormesh(X, Y, Z,)      # X, Y, Z为二维数组，二维伪彩图。
    plt.gca().invert_yaxis()         # y轴颠倒，例如绘制随深度变化的曲线
    plt.colorbar().set_label(label, fontdict=font())                            # 色标标签
    plt.xlabel('Distance ($%s$)' %length_unit, fontdict=font())       # x轴标签
    plt.ylabel('Depth ($%s$)' %length_unit, fontdict=font())           # y轴标签
    plt.grid(True, linestyle='dotted', linewidth=0.5)    # 绘制网格
# fig_pcolor(MX, MY, MI,'Type of rocks')

def subfig_pcolor(X, Y, Z, ax, Title, Label):
    subfig = ax.pcolormesh(X, Y, Z)         
    ax.set_title(Title, fontdict=font())        # 标题
#     ax.set_xlabel('Distance ($%s$)' %length_unit, fontdict=font())
#     ax.set_ylabel('Depth ($%s$)' %length_unit, fontdict=font())
    ax.grid(True, linestyle='dotted', linewidth=0.5)
    ax.invert_yaxis()　　　　    # y轴颠倒
    font_tick_params(ax)             # font_tick_params函数, 控制次级图像坐标轴线段的粗细
    Cbar = plt.colorbar(subfig)
    Cbar.set_label(Label, fontdict=font())  # ,fontweight='bold'    # colorbar标签, font()控制字体

```  
