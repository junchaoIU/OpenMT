#!/usr/bin/python
# -*- coding: UTF-8 -*-
import json
import sys
import random

from tqdm import tqdm

# input file should have been tokenized
input_file = sys.argv[1]
output_file = sys.argv[2]
# 1:del 2:rerange 3:both
mode = sys.argv[3]

def del_x(x):
    percent = 0.1
    indexs = random.sample(range(0, len(x) - 1), int(percent * len(x) + 1))
    counter = 0
    print(x)
    for index in indexs:
        index = index - counter
        x.pop(index)
        counter += 1
    return x

def rerange_x(x):
    new_x = []
    for i in range(1, len(x) - 1, 3):
        item = x[i:i + 3]
        random.shuffle(item)
        new_x.append(item)

    last_x = []
    for y in new_x:
        last_x += y
    x = [x[0]] + last_x + [x[len(x) - 1]]
    return x

with open(input_file, encoding="utf-8") as in_file:
    input_content = in_file.readlines()

    with open(output_file, "w", encoding="utf-8") as out_file:

        for x in tqdm(input_content):
            x = x.split()
            length = len(x)
            if mode == 1:
                x = del_x(x)
            elif mode == 2:
                x = rerange_x(x)
            elif mode == 3:
                x = del_x(x)
                x = rerange_x(x)

            out_file.writelines(' '.join(x) + '\n')