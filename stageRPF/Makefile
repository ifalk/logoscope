### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/03/14 16:16:25 falk Exp $
## Keywords: 
## X-URL: 

LOGO_HOME=/home/falk/Logoscope
LOGO_DIR=/home/falk/Logoscope/VC/logoscope/logoscope_2
SCRIPT_DIR=${LOGO_DIR}/bin
WEBSITES=${LOGO_DIR}/websites
TEXT_DIR=${LOGO_DIR}/sources

UNITEX_CORPUS_DIR=${LOGO_HOME}/Unitex3.0/French/Corpus/
CORPUS_NAME=$(shell date +"%Y-%m-%d" --date 2013-03-09)

${CORPUS_NAME}.tagged.txt: taggerLogoscope.sh
	rm ${UNITEX_CORPUS_DIR}/* ; \
cat ${LOGO_DIR}/sources/*.txt > ${UNITEX_CORPUS_DIR}/${CORPUS_NAME}.txt ; \
bash taggerLogoscope.sh ${CORPUS_NAME} ; \
mv ${UNITEX_CORPUS_DIR}/${CORPUS_NAME}.Phase9.txt  ${CORPUS_NAME}.tagged.txt





### Makefile ends here
