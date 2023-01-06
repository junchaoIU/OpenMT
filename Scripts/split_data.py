import sys

from tqdm import tqdm, trange
from sklearn.model_selection import train_test_split

SCR_lang = sys.argv[1]
TGT_lang = sys.argv[2]
SCR_file = sys.argv[3]
TGT_file = sys.argv[4]

src_data = []
tgt_data = []

with open(SCR_file, encoding="utf-8") as fp:
    src_data=fp.readlines()

with open(TGT_file, encoding="utf-8") as fp:
    tgt_data=fp.readlines()

# en_data = en_data[:500000]
# ro_data = ro_data[:500000]

total_test = 4000
en_train, en_subtotal, ro_train, ro_subtotal = train_test_split(
        src_data, tgt_data, test_size=total_test, random_state=42)

en_test, en_val, ro_test, ro_val = train_test_split(
        en_subtotal, ro_subtotal, test_size=0.5, random_state=42)

file_mapping = {
    'train.'+SCR_lang: en_train,
    'train.'+TGT_lang: ro_train,
    'valid.'+SCR_lang: en_val,
    'valid.'+TGT_lang: ro_val,
    'test.'+SCR_lang: en_test,
    'test.'+TGT_lang: ro_test,

}
for k, v in file_mapping.items():
    with open(f'{k}', 'w', encoding="utf-8") as fp:
        fp.writelines(v)

