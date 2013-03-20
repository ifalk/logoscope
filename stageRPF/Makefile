### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/03/14 16:16:25 falk Exp $
## Keywords: 
## X-URL: 

LOGO_HOME=/home/falk/Logoscope
LOGO_DIR=/home/falk/Logoscope/VC/logoscope/logoscope_2
SCRIPT_DIR=${LOGO_DIR}/bin
WEBSITES=${LOGO_DIR}/websites

UNITEX_CORPUS_DIR=${LOGO_HOME}/Unitex3.0/French/Corpus/
CORPUS_NAME=$(shell date +"%Y-%m-%d" --date 2013-03-18)

${CORPUS_NAME}.tagged.txt: taggerLogoscope.sh
	rm ${UNITEX_CORPUS_DIR}/* ; \
cat ${LOGO_DIR}/sources_${CORPUS_NAME}/*.txt > ${UNITEX_CORPUS_DIR}/${CORPUS_NAME}.txt ; \
bash taggerLogoscope.sh ${CORPUS_NAME} ; \
mv ${UNITEX_CORPUS_DIR}/${CORPUS_NAME}.Phase9.txt  ${CORPUS_NAME}.tagged.txt

${CORPUS_NAME}.casen.txt ${CORPUS_NAME}.casen.mwes.txt: ${SCRIPT_DIR}/extract_casen.pl ${CORPUS_NAME}.tagged.txt
	perl $< --mwes_out=${CORPUS_NAME}.casen.mwes.txt ${CORPUS_NAME}.tagged.txt > ${CORPUS_NAME}.casen.txt 



### Makefile ends here
