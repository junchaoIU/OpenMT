#!/usr/bin/python
# -*- coding: UTF-8 -*-
import json
import sys
import random

import chardet
from tqdm import tqdm

## AA_lang need 大写，如：EN
SCR_lang = sys.argv[1]
TGT_lang = sys.argv[2]
dic_path = sys.argv[3]
input_file = sys.argv[4]
output_file = sys.argv[5]

with open(dic_path, encoding="utf-8") as user_file:
    file_contents = user_file.read()
langs_dic = json.loads(file_contents)

keys = langs_dic.keys()

with open(input_file, encoding="utf-8") as in_file:
    input_content = in_file.readlines()

with open(output_file, "w", encoding="utf-8") as out_file:

    for x in tqdm(input_content):
        x = x.split()
        length = len(x)
        # percent = 0.9
        # index = random.sample(range(0, len(x)-1), int(percent*len(x)))
        # print(x)

        for i in range(length):
            if str(SCR_lang) + "__" + str(x[i]) in keys:
                tar_words = langs_dic[str(SCR_lang) + "__" + str(x[i])]
                tar_list = []
                for word in tar_words:
                    if TGT_lang in word:
                        tar_list.append(word)
                x[i] = tar_list[random.randint(0, len(tar_list)-1)][4:]

            elif str(x[i]).casefold() != str(x[i]) and str(SCR_lang) + "__" + str(x[i]).casefold() in keys:
                tar_words = langs_dic[str(SCR_lang) + "__" + str(x[i]).casefold()]
                tar_list = []
                for word in tar_words:
                    if TGT_lang in word:
                        tar_list.append(word)
                x[i] = tar_list[random.randint(0, len(tar_list) - 1)][4:].capitalize()

            else:
                # VVO
                pass


        out_file.writelines(' '.join(x) + '\n')