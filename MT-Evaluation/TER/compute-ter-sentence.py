# BLEU for segment by segment with arguments
# Run this file from CMD/Terminal
# Example Command: python3 compute-bleu-sentence.py test_file_name.txt mt_file_name.txt

import sys
from sacrebleu.metrics import BLEU, CHRF, TER

ter = TER()
target_test = sys.argv[1]  # Test file argument
target_pred = sys.argv[2]  # MTed file argument

# Open the test dataset human translation file and detokenize the references
refs = []

with open(target_test, encoding="utf-8") as test:
    for line in test:
        line = line.strip()
        refs.append(line)

print("Reference 1st sentence:", refs[0])

# Open the translation file by the NMT model and detokenize the predictions
preds = []

with open(target_pred, encoding="utf-8") as pred:
    for line in pred:
        line = line.strip()
        preds.append(line)

# Calculate BLEU for sentence by sentence and save the result to a file
with open("ter-" + target_pred + ".txt", "w+", encoding="utf-8") as output:
    for line in zip(refs,preds):
        test = line[0]
        pred = line[1]
        print(test + "\n" + pred)
        score = ter.sentence_score(pred, [test])
        signature = ter.get_signature()
        print(score)
        print(signature, "\n")
        output.write(str(score) + "\n" + str(signature) + "\n" + line[0] + "\n" + line[1] + "\n\n")
