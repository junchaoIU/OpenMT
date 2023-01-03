# Sentence WER

# WER for segment by segment with arguments
# Run this file from CMD/Terminal
# Example Command: python3 compute-wer-sentence.py test_file_name.txt mt_file_name.txt

import sys

import jiwer

transformation = jiwer.Compose([
    jiwer.ToLowerCase(),
    jiwer.RemoveWhiteSpace(replace_by_space=True),
    jiwer.RemoveMultipleSpaces(),
    jiwer.ReduceToListOfListOfWords(word_delimiter=" ")
])

target_test = sys.argv[1]	#  Test file argument
target_pred = sys.argv[2]	#  MTed file argument


# Open the test dataset human translation file
with open(target_test, encoding="utf-8") as test:
    refs = test.readlines()

#print("Reference 1st sentence:", refs[0])

# Open the translation file by the NMT model
with open(target_pred, encoding="utf-8") as pred:
    preds = pred.readlines()

wer_file = "wer-" + target_pred + ".txt"

# Calculate WER for sentence by sentence and save the result to a file
with open(wer_file, "w+", encoding="utf-8") as output:
    for line in zip(refs, preds):
        test = line[0]
        pred = line[1]
        # print(test, pred)

        wer_score = jiwer.wer(test, pred, predstruth_transform=transformation, hypothesis_transform=transformation)  # "standardize" expands abbreviations
        # print(wer_score, "\n")
        output.write(str(wer_score) + "\n")

print("Done! Please check the WER file '" + wer_file + "' in the same folder!")
