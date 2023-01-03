# Sentence METEOR

# METEOR mainly works on sentence evaluation rather than corpus evaluation
# Run this file from CMD/Terminal
# Example Command: python3 compute-meteor-sentence.py test_file_name.txt mt_file_name.txt

import sys
from nltk.translate import meteor
from nltk import word_tokenize

# import nltk
# nltk.download('punkt')

target_test = sys.argv[1]	#  Test file argument
target_pred = sys.argv[2]	#  MTed file argument


# Open the test dataset human translation file
with open(target_test, encoding="utf-8") as test:
    refs = test.readlines()

#print("Reference 1st sentence:", refs[0])

# Open the translation file by the NMT model
with open(target_pred, encoding="utf-8") as pred:
    preds = pred.readlines()

meteor_file = "meteor-" + target_pred + ".txt"

# Calculate METEOR for each sentence and save the result to a file
with open(meteor_file, "w+", encoding="utf-8") as output:
    for line in zip(refs, preds):
        test = line[0]
        pred = line[1]
        #print(test, pred)

        score = round(meteor([word_tokenize(test)],word_tokenize(pred)), 4) # list of references
        #print(meteor, "\n")
        output.write(str(score) + "\n")

print("Done! Please check the METEOR file '" + meteor_file + "' in the same folder!")
