### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/03/14 16:16:25 falk Exp $
## Keywords: 
## X-URL: 

LOGO_HOME=/home/falk/Logoscope
LOGO_DIR=/home/falk/Logoscope/VC/logoscope/logoscope_2
SCRIPT_DIR=${LOGO_DIR}/bin
DATA_DIR=${LOGO_DIR}/data
WEBSITES=${LOGO_DIR}/websites

UNITEX_CORPUS_DIR=${LOGO_HOME}/Unitex3.0/French/Corpus/
CORPUS_NAME=$(shell date +"%Y-%m-%d" --date 2013-03-20)
#CORPUS_NAME=neo_corpus

${CORPUS_NAME}.tagged.txt: taggerLogoscope.sh ${LOGO_DIR}/sources_${CORPUS_NAME}/*.txt
	rm -r ${UNITEX_CORPUS_DIR}/* ; \
cat ${LOGO_DIR}/sources_${CORPUS_NAME}/*.txt > ${UNITEX_CORPUS_DIR}/${CORPUS_NAME}.txt ; \
bash taggerLogoscope.sh ${CORPUS_NAME} ; \
mv ${UNITEX_CORPUS_DIR}/${CORPUS_NAME}.Phase9.txt  ${CORPUS_NAME}.tagged.txt

${CORPUS_NAME}.casen.txt ${CORPUS_NAME}.casen.mwes.txt: ${SCRIPT_DIR}/extract_casen.pl ${CORPUS_NAME}.tagged.txt
	perl $< --mwes_out=${CORPUS_NAME}.casen.mwes.txt ${CORPUS_NAME}.tagged.txt > ${CORPUS_NAME}.casen.txt 

NEO_CORPUS=corpusNeologismesFinal.xml
neo_corpus_ws.txt neo_corpus_not_ws.txt: ${SCRIPT_DIR}/get_corpus_neo.pl ${DATA_DIR}/ws_known_forms.txt corpusNeologismesFinal.xml
	perl $< --ws=${DATA_DIR}/ws_known_forms.txt ${NEO_CORPUS} > neo_corpus_ws.txt 2>neo_corpus_not_ws.txt

### Makefile ends here
