### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/03/12 08:24:02 falk Exp $
## Keywords: 
## X-URL: 

LOGO_DIR=/home/falk/Logoscope/VC/logoscope/logoscope_2
SCRIPT_DIR=${LOGO_DIR}/bin

#CORPUS_NAME=${TODAY}
CORPUS_NAME=$(shell date +"%Y-%m-%d" --date 2013-03-09)

quest_${CORPUS_NAME}_lc.xml: ${SCRIPT_DIR}/make_moodle_quest.pl ../${CORPUS_NAME}_all_capitalised_filtered.txt
	perl $< --db_name=logodb --db_user=logo --db_pw=scope --unknown_type=lc ${LOGO_DIR}/${CORPUS_NAME}_all_capitalised_filtered.txt > $@





### Makefile ends here
