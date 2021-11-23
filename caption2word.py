#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Description
caption2word reads one or more caption files and writes out.

Convert caption to word for printing

Synopsis
python caption2word 

Note: The caption comes from Mooc. 

@author: wzhang
Created on Tue Nov 23 11:36:14 2021
"""
def caption2word(file_in, file_out):
    file_data = ''
    with open(file_in, 'r') as f:
        for (num, line) in enumerate(f):
            if line[0:2]!='00' and line!='\n' and line[0:2].isdigit()==False:
                file_data += line[:-2] + ' '
    
    with open(file_out, 'w') as f:
        f.write(file_data)


# file_in='/home/ictja/Downloads/Mooc_Downloader-master/Mooc/大学英语综合课程(一)__大学英语综合课程(一)__国防科技大学/{1}--课程/{1}--Week1UnitOneStartingOut/{1}--Overview/[1.1.1]--overview.srt'
print('Input file name:')
file_in=input()
file_out=file_in[:-3] + 'txt'

caption2word(file_in, file_out)
print('OK!')
