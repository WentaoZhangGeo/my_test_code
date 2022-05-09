#!python
# import numpy as np

import pandas as pd
import csv
# s = pd.Series([1, 3, 5, np.nan, 6, 8])
tb = pd.read_html('https://www.boc.cn/sourcedb/whpj/')
df = tb[1]

EUR=df[6:7]