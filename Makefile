### Makefile --- 

## Author: falk@jamballa.loria.fr
## Version: $Id: Makefile,v 0.0 2013/02/09 13:30:06 falk Exp $
## Keywords: 
## X-URL: 

.IGNORE:

LOGO_DIR=/home/falk/Logoscope/SourceSup/logoscope/logoscope_2
SCRIPT_DIR=${LOGO_DIR}/bin
WEBSITES=${LOGO_DIR}/websites
TEXT_DIR=${LOGO_DIR}/sources

TODAY=$(shell date +"%Y-%m-%d")
TODAY_FEEDS=feeds_${TODAY}.pl

get_today_feeds: ${SCRIPT_DIR}/get_links_4_today.pl ${WEBSITES}
	perl $< ${WEBSITES} 

get_today_articles: ${SCRIPT_DIR}/get_articles_4_date.pl ${TODAY_FEEDS}
	perl $< ${TODAY_FEEDS} --source_dir=${TEXT_DIR} > ${TODAY}_articles.log

get_2013-02-09_articles: ${SCRIPT_DIR}/get_articles_4_date.pl feeds_2013-02-09.pl
	perl $< feeds_2013-02-09.pl --source_dir=${TEXT_DIR} > 2013-02-09_articles.log

get_2013-02-12_articles: ${SCRIPT_DIR}/get_articles_4_date.pl feeds_2013-02-12.pl
	perl $< feeds_2013-02-12.pl --source_dir=${TEXT_DIR} > 2013-02-12_articles.log

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

TINY_CC_SOURCES=${LOGO_HOME}/SourceSup/logoscope/logoscope_2/sources

#CORPUS_NAME=${TODAY}
CORPUS_NAME=$(shell date +"%Y-%m-%d" --date 2013-02-26)


TEMP=temp
RES_DIR=${CORPUS_NAME}_tinyCC2_results

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

tinyCC_tokenize:
	perl ${TINY_CC_PL}/tokenize_utf8.pl ${RES_DIR}/${CORPUS_NAME}.sentences ${TEMP}/${CORPUS_NAME}.tok #; \
#perl ${TINY_CC_PL}/tok_multiwords_utf8.pl none ${TEMP}/none.tok

tinyCC_count:
	perl ${TINY_CC_PL}/freqSingle.pl ${TEMP}/${CORPUS_NAME}.tok ${TEMP}/${CORPUS_NAME}.singlewords ;\
perl ${TINY_CC_PL}/freqMulti.pl ${TEMP}/${CORPUS_NAME}.singlewords ${TEMP}/none.tok ${TEMP}/${CORPUS_NAME}.tok ${TEMP}/${CORPUS_NAME}.words

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
	perl ${TINY_CC_PL}/detok_multiwords_utf8.pl ${TEMP}/${CORPUS_NAME}.wordlist_tok ${RES_DIR}/${CORPUS_NAME}.words

###### filter resulting words using exclusion list in ${KNOWN_WORDS}
KNOWN_WORDS=${LOGO_HOME}/SourceSup/logoscope/logoscope_2/data/known_forms

${CORPUS_NAME}_filtered.txt: ${SCRIPT_DIR}/filter.pl ${RES_DIR}/${CORPUS_NAME}.words ${KNOWN_WORDS}
	perl $< --word_list=${RES_DIR}/${CORPUS_NAME}.words --exc_list=${KNOWN_WORDS} > $@

${CORPUS_NAME}_capitalised_filtered.txt: ${SCRIPT_DIR}/filter_capitalised.pl ${CORPUS_NAME}_filtered.txt ${KNOWN_WORDS}
	perl $< --word_list=${CORPUS_NAME}_filtered.txt --exc_list=${KNOWN_WORDS} --words2sentences=${RES_DIR}/${CORPUS_NAME}.inv_w > $@


### Makefile ends here
