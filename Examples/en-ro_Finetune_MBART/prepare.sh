#!/bin/sh
OpenMT=path_to_OpenMT

# basic environment
cd $OpenMT/Envs

git clone https://github.com/moses-smt/mosesdecoder.git
git clone https://github.com/rsennrich/subword-nmt.git

git clone https://github.com/pytorch/fairseq
cd fairseq
pip install --editable ./

pip install jieba

ROOT=$OpenMT/Examples/en-ro_Finetune_MBART

cd $ROOT
# prepare mBART
wget https://dl.fbaipublicfiles.com/fairseq/models/mbart/mbart.cc25.v2.tar.gz
tar -xf mbart.cc25.v2.tar.gz
MBART=$ROOT/mbart.cc25.v2

mkdir $ROOT/processed_data
DATA=$ROOT/processed_data

# prepare data WMT16 en-ro
cd $DATA

wget http://www.statmt.org/europarl/v7/ro-en.tgz
wget http://opus.lingfil.uu.se/download.php?f=SETIMES2/en-ro.txt.zip -O SETIMES2.en-ro.txt.zip

tar -xf ro-en.tgz
unzip SETIMES2.en-ro.txt.zip
cat europarl-v7.ro-en.en SETIMES.en-ro.en > raw.en
cat europarl-v7.ro-en.ro SETIMES.en-ro.ro > raw.ro

wc -l raw.en
wc -l raw.ro

# define scripts
SCRIPTS=/data/home/mc25653/Monolingual-Enhanced-mbart_w2w_limit/scripts/mosesdecoder/scripts
TOKENIZER=${SCRIPTS}/tokenizer/tokenizer.perl
DETOKENIZER=${SCRIPTS}/tokenizer/detokenizer.perl
LC=${SCRIPTS}/tokenizer/lowercase.perl
TRAIN_TC=${SCRIPTS}/recaser/train-truecaser.perl
TC=${SCRIPTS}/recaser/truecase.perl
DETC=${SCRIPTS}/recaser/detruecase.perl
NORM_PUNC=${SCRIPTS}/tokenizer/normalize-punctuation.perl
CLEAN=${SCRIPTS}/training/clean-corpus-n.perl
BPEROOT=$ROOT/Envs/subword-nmt/subword_nmt
MULTI_BLEU=${SCRIPTS}/generic/multi-bleu.perl

# normalize-punctuation
perl ${NORM_PUNC} -l en < raw.en > norm.en
perl ${NORM_PUNC} -l ro < raw.ro > norm.ro

perl ${NORM_PUNC} -l en < raw.en > norm.en
perl ${NORM_PUNC} -l ro < raw.ro > norm.ro

# tokenizer
perl ${TOKENIZER} -l en < norm.en > tok.en
perl ${TOKENIZER} -l ro < norm.ro > tok.ro

# clean
perl ${CLEAN} tok en ro clean 1 80

# detokenizer
perl ${DETOKENIZER} -l en < clean.en > corpus.en
perl ${DETOKENIZER} -l ro < clean.ro > corpus.ro

wc -l corpus.en
wc -l corpus.ro

# split_data
python3 $OpenMT/Scripts/split_data.py en_XX ro_RO corpus.en corpus.ro

# apply sentencepiece sub-word
mkdir $ROOT/spm_data
SPM_DATA=$ROOT/spm_data
SPM=$OpenMT/Scripts/spm.py
MODEL=$MBART/sentence.bpe.model
DATA=$ROOT/processed_data
TRAIN=train
VALID=valid
TEST=test
SRC=en_XX
TGT=ro_RO

python3 ${SPM} ${MODEL} < ${DATA}/${TRAIN}.${SRC} > ${SPM_DATA}/${TRAIN}.spm.${SRC}
python3 ${SPM} ${MODEL} < ${DATA}/${TRAIN}.${TGT} > ${SPM_DATA}/${TRAIN}.spm.${TGT}
python3 ${SPM} ${MODEL} < ${DATA}/${VALID}.${SRC} > ${SPM_DATA}/${VALID}.spm.${SRC}
python3 ${SPM} ${MODEL} < ${DATA}/${VALID}.${TGT} > ${SPM_DATA}/${VALID}.spm.${TGT}
python3 ${SPM} ${MODEL} < ${DATA}/${TEST}.${SRC} > ${SPM_DATA}/${TEST}.spm.${SRC}
python3 ${SPM} ${MODEL} < ${DATA}/${TEST}.${TGT} > ${SPM_DATA}/${TEST}.spm.${TGT}


# fairseq-preprocess
NAME=en-ro
DICT=$MBART/dict.txt
TRAIN=train
VALID=valid
TEST=test
SRC=en_XX
TGT=ro_RO

FAIRSEQ=$OpenMT/Envs/fairseq/fairseq_cli
DEST=$ROOT/$TASK/fairseq_processed

python ${FAIRSEQ}/preprocess.py \
--source-lang ${SRC} \
--target-lang ${TGT} \
--trainpref ${SPM_DATA}/${TRAIN}.spm \
--validpref ${SPM_DATA}/${VALID}.spm \
--testpref ${SPM_DATA}/${TEST}.spm  \
--destdir ${DEST}/${NAME} \
--thresholdtgt 0 \
--thresholdsrc 0 \
--srcdict ${DICT} \
--tgtdict ${DICT} \
--workers 70



