# Corpus BLEU - files must be untokenized/unsubworded
# Run this file from CMD/Terminal
# Example Command: python3 compute-chrf.py test_file_name.txt mt_file_name.txt


import sys
from sacrebleu.metrics import BLEU, CHRF, TER

chrf = CHRF()

target_test = sys.argv[1]  # Test file argument
target_pred = sys.argv[2]  # MTed file argument

# Open the test dataset human translation file and detokenize the references
refs = []

with open(target_test, encoding="utf-8") as test:
    for line in test: 
        line = line.strip()
        refs.append(line)

print("Reference 1st sentence:", refs[0])

refs = [refs]  # Yes, it is a list of list(s) as required by sacreBLEU


# Open the translation file by the NMT model and detokenize the predictions
preds = []

with open(target_pred, encoding="utf-8") as pred:
    for line in pred: 
        line = line.strip()
        preds.append(line)

print("MTed 1st sentence:", preds[0])


# Calculate and print the BLEU score
score = chrf.corpus_score(preds, refs)
signature = chrf.get_signature()

print(str(score) + "\n" + str(signature))
