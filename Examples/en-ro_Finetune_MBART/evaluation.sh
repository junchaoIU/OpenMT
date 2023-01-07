#!/bin/bash
OpenMT=path_to_OpenMT
ROOT=$OpenMT/Examples/en-ro_Finetune_MBART
FAIRSEQ=$OpenMT/Envs//fairseq
CHECK_POINT=$ROOT/checkpoint_en_ro
langs=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN

mkdir $ROOT/eval_result

SRC=en_XX
TGT=ro_RO

DATA=$ROOT/fairseq_processed/en-ro
RESULT=$ROOT/eval_result/en_ro
PYTHONIOENCODING=utf-8 python3 $FAIRSEQ/fairseq_cli/generate.py $DATA \
  --path $CHECK_POINT/checkpoint_best.pt \
  --task translation_from_pretrained_bart \
  --batch-size 32 \
  --gen-subset test \
  -t ${TGT} -s ${SRC} \
  --remove-bpe 'sentencepiece' \
  --langs $langs > ${RESULT}.all

cat ${RESULT}.all | grep -P "^H" |sort -V |cut -f 3- | sed 's/\[ro_RO\]//g' > ${RESULT}.hyp
cat ${RESULT}.all | grep -P "^T" |sort -V |cut -f 2- | sed 's/\[ro_RO\]//g' > ${RESULT}.ref
sacrebleu -tok 'none' -s 'none' ${RESULT}.ref < ${RESULT}.hyp > $RESULT.score

PRERO=$ROOT/ro_postprocess.sh
sh $PRERO ${RESULT}.hyp > ${RESULT}.mbart.tok.hyp
sh $PRERO ${RESULT}.ref > ${RESULT}.mbart.tok.ref
sacrebleu -tok 'none' -s 'none' ${RESULT}.mbart.tok.ref < ${RESULT}.mbart.tok.hyp > $RESULT.mbart.tok.score
