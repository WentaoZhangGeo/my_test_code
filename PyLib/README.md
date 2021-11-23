# Readme

## 本文件目录

**0PyBasic.ipynb**
Python & Jupyter 常用的规则、函数库和快捷键

**1Py_vs_Mat.ipynb**
Matlab & Python 对求解大型稀疏矩阵不同方法的对比

**2PythonPlot.md**
Python 绘图的常见命令

## python 小数点精度问题

计算机中通常是以二进制保存的浮点数，并不完全精确。其中python是以双精度(64)位来保存浮点数，后面多余的位会被截掉，当保存1.1时，在电脑上实际保存的二进制的1.1，不是精确的0.1。例如：

```python
print(1.1+2.2)
3.3000000000000003
1.1+1.1+1.1==3.3
False
```

可以使用 [decimal](https://docs.python.org/zh-cn/3/library/decimal.html) 模块进行修改，支持十进制浮点运算以提供完全精确的计算，满足高精度要求。简单例子：

```python
from decimal import Decimal
a = Decimal('1.1')
b = Decimal('2.2')
a+b
Decimal('3.3')
```





