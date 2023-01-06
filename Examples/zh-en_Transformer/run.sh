#!/bin/sh
ROOT=D:\gitHome\OpenMT

# basic environment
cd $ROOT/Envs

git clone https://github.com/moses-smt/mosesdecoder.git
git clone https://github.com/rsennrich/subword-nmt.git

git clone https://github.com/pytorch/fairseq
cd fairseq
pip install --editable ./

pip install jieba

mkdir $ROOT/zh-en_Transformer

# src and tgt
src=zh_CN
tgt=en_XX

# path variable
SCRIPTS=$ROOT/Envs/mosesdecoder/scripts
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

# prepare data
mkdir $ROOT/zh-en_Transformer/data
data_dir=$ROOT/zh-en_Transformer/data

cd data_dir
wget https://data.statmt.org/news-commentary/v15/training/news-commentary-v15.en-zh.tsv.gz
gunzip news-commentary-v15.en-zh.tsv.gz

python $ROOT/zh-en_Transformer/cut_data.py ${data_dir}/news-commentary-v15.en-zh.tsv ${data_dir}/

# normalize-punctuation
perl ${NORM_PUNC} -l en < ${data_dir}/raw.en > ${data_dir}/norm.en
perl ${NORM_PUNC} -l zh < ${data_dir}/raw.zh > ${data_dir}/norm.zh

# Chinese seg
python -m jieba -d " " ${data_dir}/norm.zh > ${data_dir}/norm.seg.zh

# tokenizer
${TOKENIZER} -l en < ${data_dir}/norm.en > ${data_dir}/norm.tok.en
${TOKENIZER} -l zh < ${data_dir}/norm.seg.zh > ${data_dir}/norm.seg.tok.zh

# truecase
${TRAIN_TC} --model ${model_dir}/truecase-model.en --corpus ${data_dir}/norm.tok.en
${TC} --model ${model_dir}/truecase-model.en < ${data_dir}/norm.tok.en > ${data_dir}/norm.tok.true.en

# bpe
python ${BPEROOT}/learn_joint_bpe_and_vocab.py --input ${data_dir}/norm.tok.true.en  -s 32000 -o ${model_dir}/bpecode.en --write-vocabulary ${model_dir}/voc.en
python ${BPEROOT}/apply_bpe.py -c ${model_dir}/bpecode.en --vocabulary ${model_dir}/voc.en < ${data_dir}/norm.tok.true.en > ${data_dir}/norm.tok.true.bpe.en

python ${BPEROOT}/learn_joint_bpe_and_vocab.py --input ${data_dir}/norm.seg.tok.zh  -s 32000 -o ${model_dir}/bpecode.zh --write-vocabulary ${model_dir}/voc.zh
python ${BPEROOT}/apply_bpe.py -c ${model_dir}/bpecode.zh --vocabulary ${model_dir}/voc.zh < ${data_dir}/norm.seg.tok.zh > ${data_dir}/norm.seg.tok.bpe.zh

# clean
mv ${data_dir}/norm.seg.tok.bpe.zh ${data_dir}/toclean.zh
mv ${data_dir}/norm.tok.true.bpe.en ${data_dir}/toclean.en
${CLEAN} ${data_dir}/toclean zh en ${data_dir}/clean 1 256

# data split
python3 Scripts/split_data.py zh_CN en_XX clean.zh.zh clean.zh.en

# fairseq-preprocess
fairseq-preprocess --source-lang ${src} --target-lang ${tgt} \
    --trainpref ${data_dir}/train --validpref ${data_dir}/valid --testpref ${data_dir}/test \
    --destdir ${data_dir}/data-bin

# train
CUDA_VISIBLE_DEVICES=0,1,2,3 nohup fairseq-train ${data_dir}/data-bin --arch transformer \
	--source-lang ${src} --target-lang ${tgt}  \
    --optimizer adam  --lr 0.001 --adam-betas '(0.9, 0.98)' \
    --lr-scheduler inverse_sqrt --max-tokens 4096  --dropout 0.3 \
    --criterion label_smoothed_cross_entropy  --label-smoothing 0.1 \
    --max-update 200000  --warmup-updates 4000 --warmup-init-lr '1e-07' \
    --keep-last-epochs 10 --num-workers 8 \
	--save-dir ${model_dir}/checkpoints &

# eval
fairseq-generate ${data_dir}/data-bin \
    --path ${model_dir}/checkpoints/checkpoint_best.pt \
    --batch-size 128 --beam 8 > ${data_dir}/result/bestbeam8.txt

grep ^H ${data_dir}/result/bestbeam8.txt | cut -f3- > ${data_dir}/result/hyp.tok.true.bpe.en
grep ^T ${data_dir}/result/bestbeam8.txt | cut -f2- > ${data_dir}/result/ref.tok.true.bpe.en

sed -r 's/(@@ )| (@@ ?$)//g' < ${data_dir}/result/hyp.tok.true.bpe.en  > ${data_dir}/result/hyp.tok.true.en
sed -r 's/(@@ )| (@@ ?$)//g' < ${data_dir}/result/ref.tok.true.bpe.en  > ${data_dir}/result/ref.tok.true.en

${DETC} < ${data_dir}/result/hyp.tok.true.en > ${data_dir}/result/hyp.tok.en
${DETC} < ${data_dir}/result/ref.tok.true.en > ${data_dir}/result/ref.tok.en

${MULTI_BLEU} -lc ${data_dir}/result/ref.tok.en < ${data_dir}/result/hyp.tok.en