import sys

from tqdm import tqdm, trange
from sklearn.model_selection import train_test_split

dict_path = sys.argv[1]
src_output = sys.argv[2]
tgt_output = sys.argv[3]

src_data = []
tgt_data = []

with open(dict_path, "r",encoding="utf-8") as fp:
    for line in tqdm(fp):
        line_data = line.rstrip().split('\t')
        src_data.append(line_data[1] + '\n')
        tgt_data.append(line_data[2] + '\n')

with open(src_output, "w",encoding="utf-8") as e:
    e.writelines(src_data)

with open(tgt_output, "w",encoding="utf-8") as r:
    r.writelines(tgt_data)