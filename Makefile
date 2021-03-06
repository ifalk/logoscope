### Makefile --- 

## Author: falk@jamballa.loria.fr
## Version: $Id: Makefile,v 0.0 2013/02/09 13:30:06 falk Exp $
## Keywords: 
## X-URL: 
TEXT_DIR=${LOGO_DIR}/sources

.IGNORE:

LOGO_DIR=/home/falk/Logoscope/VC/logoscope/logoscope_2
SCRIPT_DIR=${LOGO_DIR}/bin
WEBSITES=${LOGO_DIR}/websites

TODAY=$(shell date +"%Y-%m-%d")
TODAY_FEEDS=feeds_${TODAY}.pl
TEXT_DIR=${LOGO_DIR}/sources_${TODAY}

get_today_feeds: ${SCRIPT_DIR}/get_links_4_today.pl ${WEBSITES}
	perl $< ${WEBSITES} 

get_today_articles: ${SCRIPT_DIR}/get_articles_4_date.pl ${TODAY_FEEDS}
	perl $< ${TODAY_FEEDS} --source_dir=${TEXT_DIR} > ${TODAY}_articles.log

get_2013-03-09_articles: ${SCRIPT_DIR}/get_articles_4_date.pl feeds_2013-03-09.pl
	perl $< feeds_2013-03-09.pl --source_dir=${LOGO_DIR}/sources_$(shell date +"%Y-%m-%d" --date 2013-03-09) > 2013-03-09_articles.log

get_2013-03-18_articles: ${SCRIPT_DIR}/get_articles_4_date.pl feeds_2013-03-18.pl
	perl $< feeds_2013-03-18.pl --source_dir=${LOGO_DIR}/sources_$(shell date +"%Y-%m-%d" --date 2013-03-18) > 2013-03-18_articles.log

NEO_CORPUS=${LOGO_DIR}/stageRPF/corpusNeologismesFinal.xml
neo_corpus_sources: ${SCRIPT_DIR}/make_neo_corpus_sources.pl ${NEO_CORPUS}
	perl $< --source_dir=${LOGO_DIR}/sources_neo_corpus ${NEO_CORPUS} > neo_corpus_articles.log

#### prepare with tinyCC 
#### 1) split into sentences
#### 2) number sentences
#### 3) tokenise
#### 4) read known MWEs        ## not yet needed
#### 5) Index
############### the following are not yet needed
#### 6) compute neighbour co-occurences
#### 7) compute sentence co-occurences
#### 8) collect and sort pairwise frequencies
#### 9) add frequencies
#### 10) compute significancies
#### 11) de-tokenise word list 
##############
#### output should be a collection of words, with pointers to sentences 
#### and source documents (so the context is conserved)
####

LOGO_HOME=/home/falk/Logoscope

TINY_CC_HOME=${LOGO_HOME}/LCC/tinyCC2.1.1
TINY_CC_BIN=${TINY_CC_HOME}/bin
TINY_CC_PL=${TINY_CC_HOME}/perl
TINY_CC_ABBREV=${TINY_CC_HOME}/bin/abbrev

# CORPUS_NAME=${TODAY}
CORPUS_NAME=$(shell date +"%Y-%m-%d" --date 2013-03-20)
# CORPUS_NAME=neo_corpus
TINY_CC_SOURCES=${LOGO_HOME}/VC/logoscope/logoscope_2/sources_${CORPUS_NAME}

TEMP=temp
RES_DIR=${CORPUS_NAME}_tinyCC2_results

#### shell vars for tinyCC scripts

# input text is in format (latin|utf8)
export TEXTFORM=utf8
# locales for latin__must__ be installed on your system!
# See `localedef --list-archive` for a list of installed locales
# Edit /etc/locale.gen and sudo locale-gen to enable specific locales
# locale to be used for processing ISO 8859 text
export LTYPE=fr_FR@euro
# name of this locale as understood by `recode`
export LNAME=latin1
# locale to be used for processing UTF-8 text
export UTYPE=fr_FR.utf8

# Memory max usage in MB (approximate)
export MAXMEM=600
# min frequency for scoocs
export SMINFREQ=2
# min sig for scooc
export SMINSIG=6.63
# min freq for nbcooc
export NMINFREQ=2
# min sig for NBcooc
export NMINSIG=3.84
# number of digits after .
export DIGITS=2

RECODE_CMD=`which recode`

#### data dir
DATA_DIR=${LOGO_HOME}/VC/logoscope/logoscope_2/data

.PHONY: process_with_tinyCC tinyCC_collect_convert tinyCC_number_sentences tinyCC_tokenize tinyCC_count tinyCC_index tinyCC_neighbour_cooc tinyCC_sentence_cooc tinyCC_detok merge_known_forms filtered capitalised_filtered known_capitalised_filtered all_capitalised_filtered keep_capitalised_filtered process_with_casen

process_with_tinyCC: tinyCC_collect_convert tinyCC_number_sentences tinyCC_tokenize tinyCC_count tinyCC_index tinyCC_neighbour_cooc tinyCC_sentence_cooc tinyCC_detok
	$(MAKE) $^

tinyCC_collect_convert:
	mkdir $(TEMP) ; \
rm $(TEMP)/* ; \
mkdir ${RES_DIR} ; \
java -jar ${TINY_CC_BIN}/text2satz.jar -d ${CORPUS_NAME} -a ${TINY_CC_ABBREV} -e -p ${TEMP}/ ${TINY_CC_SOURCES} ; \
${RECODE_CMD} -f utf8..${LNAME} ${TEMP}/${CORPUS_NAME}.s ; \
mv ${TEMP}/sentsrc.txt ${RES_DIR}/${CORPUS_NAME}.inv_so ; \
mv ${TEMP}/sources.txt ${RES_DIR}/${CORPUS_NAME}.sources

tinyCC_number_sentences:
	perl ${TINY_CC_PL}/numberIt.pl ${TEMP}/${CORPUS_NAME}.s > ${RES_DIR}/${CORPUS_NAME}.sentences

KNOWN_MWES=${LOGO_HOME}/VC/logoscope/logoscope_2/data/multiwords
tinyCC_tokenize:
	perl ${TINY_CC_PL}/tokenize_utf8.pl ${RES_DIR}/${CORPUS_NAME}.sentences ${TEMP}/${CORPUS_NAME}.tok ; \
perl ${TINY_CC_PL}/tok_multiwords_utf8.pl ${KNOWN_MWES} ${TEMP}/multiwords.tok

tinyCC_count:
	perl ${TINY_CC_PL}/freqSingle.pl ${TEMP}/${CORPUS_NAME}.tok ${TEMP}/${CORPUS_NAME}.singlewords ;\
perl ${TINY_CC_PL}/freqMulti.pl ${TEMP}/${CORPUS_NAME}.singlewords ${TEMP}/multiwords.tok ${TEMP}/${CORPUS_NAME}.tok ${TEMP}/${CORPUS_NAME}.words

tinyCC_index:
	perl ${TINY_CC_PL}/index_wl_utf8.pl ${TEMP}/${CORPUS_NAME}.words ${TEMP}/${CORPUS_NAME}.tok ${TEMP}/${CORPUS_NAME} ;\
cp ${TEMP}/${CORPUS_NAME}.index ${RES_DIR}/${CORPUS_NAME}.inv_w

tinyCC_neighbour_cooc:
	perl ${TINY_CC_PL}/nbcooc.pl ${TEMP}/${CORPUS_NAME}.wordlist_tok ${TEMP}/${CORPUS_NAME}.index ${MAXMEM} ${NMINFREQ} ${NMINSIG} ${DIGITS} ${RES_DIR}/${CORPUS_NAME}.co_n

tinyCC_sentence_cooc:
	perl ${TINY_CC_PL}/sfreq.pl ${TEMP}/${CORPUS_NAME}.wordlist_tok ${TEMP}/${CORPUS_NAME}.index ${MAXMEM} ${SMINFREQ} ${TEMP}/${CORPUS_NAME} ;\
${TINY_CC_BIN}/sort64 --buffer-size=${MAXMEM}M -T . -k1n -k2n ${TEMP}/${CORPUS_NAME}.sfreqtemp -o ${TEMP}/${CORPUS_NAME}.sfreqtempsort ;\
perl ${TINY_CC_PL}/add3col_sym.pl ${TEMP}/${CORPUS_NAME}.sfreqtempsort ${SMINFREQ} ${TEMP}/${CORPUS_NAME}.sfreq ;\
perl ${TINY_CC_PL}/ssig.pl ${TEMP}/${CORPUS_NAME}.wordlist_tok ${TEMP}/${CORPUS_NAME}.index ${TEMP}/${CORPUS_NAME}.sfreq ${SMINSIG} ${DIGITS} ${RES_DIR}/${CORPUS_NAME}.co_s

tinyCC_detok: 
	perl ${SCRIPT_DIR}/detok_multiwords_utf8.pl ${TEMP}/${CORPUS_NAME}.wordlist_tok ${RES_DIR}/${CORPUS_NAME}.words

#### 

process_with_casen: ${LOGO_DIR}/stageRPF/${CORPUS_NAME}.casen.txt
	cd ${LOGO_DIR}/stageRPF; \
$(MAKE) ${CORPUS_NAME}.casen.txt

#### merge known words from various sources into one list

MWES=${DATA_DIR}/multiwords
PROLEX=${LOGO_HOME}/casen1.0/dela/Prolex-Unitex.dic
CASEN=${LOGO_DIR}/stageRPF/${CORPUS_NAME}.casen.txt
WS=${LOGO_DIR}/data/ws_known_forms.txt
LOGO_KNOWN=${DATA_DIR}/known_forms

merge_known_forms: merged_known_forms.txt ${CORPUS_NAME}_merged_known_forms_casen.txt merged_known_forms_ws.txt ${CORPUS_NAME}_merged_known_forms_ws_casen.txt
	$(MAKE) $^


# Number of words in Prolex: 118006
# Number of Prolex words in logo known words list: 20194
# Number of words in merged exclusion list: 549600
merged_known_forms.txt: ${SCRIPT_DIR}/make_exclusion_list.pl ${PROLEX} ${LOGO_KNOWN} ${MWES}
	perl $< --prolex=${PROLEX} --mwes=${MWES} ${LOGO_KNOWN} > $@

# Number of words in merged exclusion list: 550865
${CORPUS_NAME}_merged_known_forms_casen.txt: ${SCRIPT_DIR}/make_exclusion_list.pl ${PROLEX} ${LOGO_KNOWN} ${MWES} ${CASEN}
	perl $< --prolex=${PROLEX} --mwes=${MWES} ${CASEN} ${LOGO_KNOWN} > $@

# Number of words in merged exclusion list: 2333312
merged_known_forms_ws.txt: ${SCRIPT_DIR}/make_exclusion_list.pl ${PROLEX} ${LOGO_KNOWN} ${MWES}
	perl $< --prolex=${PROLEX} --mwes=${MWES} ${WS} ${LOGO_KNOWN} > $@

# Number of words in merged exclusion list: 2333425
${CORPUS_NAME}_merged_known_forms_ws_casen.txt: ${SCRIPT_DIR}/make_exclusion_list.pl ${PROLEX} ${LOGO_KNOWN} ${MWES} ${CASEN}
	perl $< --prolex=${PROLEX} --mwes=${MWES} ${WS} ${LOGO_KNOWN} ${CASEN} > $@



###### filter resulting words using exclusion list in ${KNOWN_WORDS}


KNOWN_WORDS=merged_known_forms.txt

KNOWN_WORDS_CASEN=${CORPUS_NAME}_merged_known_forms_casen.txt

KNOWN_WORDS_WS=merged_known_forms_ws.txt

KNOWN_WORDS_CASEN_WS=${CORPUS_NAME}_merged_known_forms_ws_casen.txt

filtered: ${CORPUS_NAME}_filtered.txt ${CORPUS_NAME}_filtered_casen.txt ${CORPUS_NAME}_filtered_ws.txt ${CORPUS_NAME}_filtered_casen_ws.txt
	$(MAKE) $^

${CORPUS_NAME}_filtered.txt: ${SCRIPT_DIR}/filter.pl ${RES_DIR}/${CORPUS_NAME}.words ${KNOWN_WORDS}
	perl $< --word_list=${RES_DIR}/${CORPUS_NAME}.words --exc_list=${KNOWN_WORDS} > $@

${CORPUS_NAME}_filtered_casen.txt: ${SCRIPT_DIR}/filter.pl ${RES_DIR}/${CORPUS_NAME}.words ${KNOWN_WORDS_CASEN}
	perl $< --word_list=${RES_DIR}/${CORPUS_NAME}.words --exc_list=${KNOWN_WORDS_CASEN} > $@

${CORPUS_NAME}_filtered_ws.txt: ${SCRIPT_DIR}/filter.pl ${RES_DIR}/${CORPUS_NAME}.words ${KNOWN_WORDS_WS}
	perl $< --word_list=${RES_DIR}/${CORPUS_NAME}.words --exc_list=${KNOWN_WORDS_WS} > $@

${CORPUS_NAME}_filtered_casen_ws.txt: ${SCRIPT_DIR}/filter.pl ${RES_DIR}/${CORPUS_NAME}.words ${KNOWN_WORDS_CASEN_WS}
	perl $< --word_list=${RES_DIR}/${CORPUS_NAME}.words --exc_list=${KNOWN_WORDS_CASEN_WS} > $@

#### filter capitalised unknown words as follows: remove word if in
#### most cases it is the first in the sentence and the downcase
#### version is known.

capitalised_filtered: ${CORPUS_NAME}_capitalised_filtered.txt ${CORPUS_NAME}_capitalised_filtered_casen.txt ${CORPUS_NAME}_capitalised_filtered_ws.txt ${CORPUS_NAME}_capitalised_filtered_casen_ws.txt
	$(MAKE) $^


${CORPUS_NAME}_capitalised_filtered.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered.txt ${KNOWN_WORDS}
	perl $< --word_list=${CORPUS_NAME}_filtered.txt --exc_list=${KNOWN_WORDS} --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_capitalised_filtered_casen.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_casen.txt ${KNOWN_WORDS_CASEN}
	perl $< --word_list=${CORPUS_NAME}_filtered_casen.txt --exc_list=${KNOWN_WORDS_CASEN} --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_capitalised_filtered_ws.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_ws.txt ${KNOWN_WORDS_WS}
	perl $< --word_list=${CORPUS_NAME}_filtered_ws.txt --exc_list=${KNOWN_WORDS_WS} --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_capitalised_filtered_casen_ws.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_casen_ws.txt ${KNOWN_WORDS_CASEN_WS}
	perl $< --word_list=${CORPUS_NAME}_filtered_casen_ws.txt --exc_list=${KNOWN_WORDS_CASEN_WS} --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@


#### filter capitalised unknown words as follows: 
#### remove if downcase version is known

known_capitalised_filtered: ${CORPUS_NAME}_known_capitalised_filtered.txt ${CORPUS_NAME}_known_capitalised_filtered_casen.txt  ${CORPUS_NAME}_known_capitalised_filtered_ws.txt ${CORPUS_NAME}_known_capitalised_filtered_casen_ws.txt
	$(MAKE) $^

${CORPUS_NAME}_known_capitalised_filtered.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered.txt ${KNOWN_WORDS}
	perl $< --word_list=${CORPUS_NAME}_filtered.txt --exc_list=${KNOWN_WORDS} --discard --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_known_capitalised_filtered_casen.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_casen.txt ${KNOWN_WORDS_CASEN}
	perl $< --word_list=${CORPUS_NAME}_filtered_casen.txt --exc_list=${KNOWN_WORDS_CASEN} --discard --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_known_capitalised_filtered_ws.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_ws.txt ${KNOWN_WORDS_WS}
	perl $< --word_list=${CORPUS_NAME}_filtered_ws.txt --exc_list=${KNOWN_WORDS_WS} --discard --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_known_capitalised_filtered_casen_ws.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_casen_ws.txt ${KNOWN_WORDS_CASEN_WS}
	perl $< --word_list=${CORPUS_NAME}_filtered_casen_ws.txt --exc_list=${KNOWN_WORDS_CASEN_WS} --discard --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

#### remove all capitalised words

all_capitalised_filtered: ${CORPUS_NAME}_all_capitalised_filtered.txt ${CORPUS_NAME}_all_capitalised_filtered_casen.txt ${CORPUS_NAME}_all_capitalised_filtered_ws.txt ${CORPUS_NAME}_all_capitalised_filtered_casen_ws.txt
	$(MAKE) $^

${CORPUS_NAME}_all_capitalised_filtered.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered.txt ${KNOWN_WORDS}
	perl $< --word_list=${CORPUS_NAME}_filtered.txt --exc_list=${KNOWN_WORDS} --discard --discard --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_all_capitalised_filtered_casen.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_casen.txt ${KNOWN_WORDS_CASEN}
	perl $< --word_list=${CORPUS_NAME}_filtered_casen.txt --exc_list=${KNOWN_WORDS_CASEN} --discard --discard --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_all_capitalised_filtered_ws.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_ws.txt ${KNOWN_WORDS_WS}
	perl $< --word_list=${CORPUS_NAME}_filtered_ws.txt --exc_list=${KNOWN_WORDS_WS} --discard --discard --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

${CORPUS_NAME}_all_capitalised_filtered_casen_ws.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered_casen_ws.txt ${KNOWN_WORDS_CASEN_WS}
	perl $< --word_list=${CORPUS_NAME}_filtered_casen_ws.txt --exc_list=${KNOWN_WORDS_CASEN_WS} --discard --discard --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@

#### keep only capitalised words where the downcase version is not known

keep_capitalised_filtered: ${CORPUS_NAME}_keep_capitalised_filtered.txt ${CORPUS_NAME}_keep_capitalised_filtered_casen.txt ${CORPUS_NAME}_keep_capitalised_filtered_ws.txt ${CORPUS_NAME}_keep_capitalised_filtered_casen_ws.txt
	$(MAKE) $^

${CORPUS_NAME}_keep_capitalised_filtered.txt: ${SCRIPT_DIR}/filter_keep_capitalised.pl ${CORPUS_NAME}_filtered.txt ${KNOWN_WORDS}
	perl $< --word_list=${CORPUS_NAME}_filtered.txt --exc_list=${KNOWN_WORDS} > $@

${CORPUS_NAME}_keep_capitalised_filtered_casen.txt: ${SCRIPT_DIR}/filter_keep_capitalised.pl ${CORPUS_NAME}_filtered_casen.txt ${KNOWN_WORDS_CASEN}
	perl $< --word_list=${CORPUS_NAME}_filtered_casen.txt --exc_list=${KNOWN_WORDS_CASEN} > $@

${CORPUS_NAME}_keep_capitalised_filtered_ws.txt: ${SCRIPT_DIR}/filter_keep_capitalised.pl ${CORPUS_NAME}_filtered_ws.txt ${KNOWN_WORDS_WS}
	perl $< --word_list=${CORPUS_NAME}_filtered_ws.txt --exc_list=${KNOWN_WORDS_WS} > $@

${CORPUS_NAME}_keep_capitalised_filtered_casen_ws.txt: ${SCRIPT_DIR}/filter_keep_capitalised.pl ${CORPUS_NAME}_filtered_casen_ws.txt ${KNOWN_WORDS_CASEN_WS}
	perl $< --word_list=${CORPUS_NAME}_filtered_casen_ws.txt --exc_list=${KNOWN_WORDS_CASEN_WS} > $@

#### load database

logo_db: ${SCRIPT_DIR}/load_db.pl
	perl $< --db_user=logo --db_pw=scope --db_dir=${RES_DIR} --basename=${CORPUS_NAME}

load_db_new_words: ${SCRIPT_DIR}/load_db_unknown_words.pl
	perl $< --db_name=logodb --db_user=logo --db_pw=scope --file=${CORPUS_NAME}_capitalised_filtered.txt


### Makefile ends here

