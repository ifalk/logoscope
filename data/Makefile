LOGO_HOME=/home/falk/Logoscope
PROLEX=${LOGO_HOME}/casen1.0/dela/Prolex-Unitex.dic
LOGO_KNOWN=${LOGO_HOME}/SourceSup/logoscope/logoscope_2/data/known_forms
MULTIWORDS=


LOGO_DIR=/home/falk/Logoscope/SourceSup/logoscope/logoscope_2
SCRIPT_DIR=${LOGO_DIR}/bin

merged_known_forms.txt: ${SCRIPT_DIR}/make_exclusion_list.pl ${PROLEX} ${LOGO_KNOWN} multiwords
	perl $< --prolex=${PROLEX} --mwes=multiwords ${LOGO_KNOWN} > $@

