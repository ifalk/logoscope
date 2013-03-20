LOGO_HOME=/home/falk/Logoscope
PROLEX=${LOGO_HOME}/casen1.0/dela/Prolex-Unitex.dic
LOGO_KNOWN=${LOGO_HOME}/VC/logoscope/logoscope_2/data/known_forms


LOGO_DIR=/home/falk/Logoscope/VC/logoscope/logoscope_2
SCRIPT_DIR=${LOGO_DIR}/bin

merged_known_forms.txt: ${SCRIPT_DIR}/make_exclusion_list.pl ${PROLEX} ${LOGO_KNOWN} multiwords
	perl $< --prolex=${PROLEX} --mwes=multiwords ${LOGO_KNOWN} > $@

WS_DIR=/var/resources/LCC
WS_WORD_FILES=${WS_DIR}/fra_news_2005-2008_10M-words.txt ${WS_DIR}/fra_news_2009_3M-words.txt ${WS_DIR}/fra_news_2010_3M-words.txt 

ws_known_forms.txt: ${SCRIPT_DIR}/make_ws_exclusion_list.pl
	perl $< ${WS_WORD_FILES} > $@
