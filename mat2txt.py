import scipy.io as scio
import numpy as np
import time
from datetime import date




def mat2txt(path):
    data = scio.loadmat(path)
    x = data['P7_15_bt']

    return x


data = mat2txt('/home/wentao/Downloads/P7_15_bt.mat')
x = time.localtime(data[1, 0])
print(x)
y = time.strftime('%Y-%m-%d %H:%M:%S %Z', time.localtime(time.time()))
print(y)
print(time.localtime(time.time()))
i = 0
# m=len(data)

fw = open('/home/wentao/Downloads/P7_15_bt.txt', 'w')  # 将要输出保存的文件地址
for Date in data[:, 0]:
    y = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(Date))
    i = +1
    fw.write(y + ' ')
    fw.write(str(Date))
    fw.write("\n")  # 换行
fw.close()

print(time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(731878)))
# 1970-03-27 07:17:42
print(date.toordinal(date(1970,3,27)))


# for line in open("/home/wentao/Downloads/P7_15_bt.txt"):  # 读取的文件
#
#     # line.rstrip("\n")为去除行尾换行符
#     fw.write("\n")  # 换行






