#!/bin/bash

dname=$1_snt
fname=$1.txt
spath=~/Logoscope/Unitex3.0/French/App/
cpath=~/Logoscope/Unitex3.0/French/Corpus/



echo "creating directory $dname"
mkdir ~/Logoscope/Unitex3.0/French/Corpus/$dname
cd ~/Logoscope/Unitex3.0/App/

echo "Preprocessing the text"

echo "Normalizing text.."
./Normalize "$cpath$1.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt"
./Grf2Fst2 "/home/falk/Logoscope/Unitex3.0/French/Graphs/Preprocessing/Sentence/Sentence.grf" -y "--alphabet=/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
./Flatten "/home/falk/Logoscope/Unitex3.0/French/Graphs/Preprocessing/Sentence/Sentence.fst2" --rtn -d5 

echo "Processing sentences..."
./Fst2Txt "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Preprocessing/Sentence/Sentence.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -M 
./Grf2Fst2 "/home/falk/Logoscope/Unitex3.0/French/Graphs/Preprocessing/Replace/Replace.grf" -y "--alphabet=/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
./Fst2Txt "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Preprocessing/Replace/Replace.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -R
 
echo "tokenizing the text..."
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 

echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"

echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
echo "Preprocessing done..."



echo "Applying transducers..."
echo "Phase 1"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/toolChercheSigleAvecPoints.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$dname/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase1.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase1.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d1=$1.Phase1_snt
mkdir $cpath/$d1
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase1.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase1.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 1 done..." 

echo "Phase 2"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase1.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/toolSupprimePointDansSigle.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -R --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d1/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase2.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase2.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d2=$1.Phase2_snt
mkdir $cpath/$d2
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase2.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase2.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 2 done..." 


echo "phase 3"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase2.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/tagMotInconnu.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d2/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase3.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase3.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d3=$1.Phase3_snt
mkdir $cpath/$d3
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase3.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase3.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 3 done..." 

echo "phase 4"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase3.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/tagMedia.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d3/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase4.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase4.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d4=$1.Phase4_snt
mkdir $cpath/$d4
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase4.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase4.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 4 done..." 

echo "phase 5"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase4.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/tagDynaste.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d4/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase5.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase5.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d5=$1.Phase5_snt
mkdir $cpath/$d5
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase5.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase5.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 5 done..."

echo "phase 6"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase5.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/tagNomPropre.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d5/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase6.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase6.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d6=$1.Phase6_snt
mkdir $cpath/$d6
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase6.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase6.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 6 done..."

echo "phase 7"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase6.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/tagTopo.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d6/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase7.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase7.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d7=$1.Phase7_snt
mkdir $cpath/$d7
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase7.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase7.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 7 done..."

echo "phase 8"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase7.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/tagSigle.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d7/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase8.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase8.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d8=$1.Phase8_snt
mkdir $cpath/$d8
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase8.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase8.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 8 done..."

echo "phase 9"
./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase8.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/tagNomSeul.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d8/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase9.txt" 
./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase9.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
d9=$1.Phase9_snt
mkdir $cpath/$d9
./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase9.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
echo "applying dictionnaries..."
./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase9.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
echo "sorting sorting dictionaries files..."
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
echo "Phase 9 done..."

# echo "phase 10"
# ./Locate "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase9.snt" "/home/falk/Logoscope/Unitex3.0/French/Graphs/Logoscope/tagAutre.fst2" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" -L -M --all -b -Y 
# ./Concord "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d9/concord.ind" "-m/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase10.txt" 
# ./Normalize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase10.txt" "-r/home/falk/Logoscope/Unitex3.0/French/Norm.txt" 
# d10=$1.Phase10_snt
# mkdir $cpath/$d10
# ./Tokenize "/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase10.txt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" 
# echo "applying dictionnaries..."
# ./Dico "-t/home/falk/Logoscope/Unitex3.0/French/Corpus/$1.Phase10.snt" "-a/home/falk/Logoscope/Unitex3.0/French/Alphabet.txt" "/home/falk/Logoscope/Unitex3.0/French/Dela/dicoCasEN.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Unitex.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/DicoNombreCasEN.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/dela-fr-public.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Dnum-ch.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/ajouts80jours.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/profession.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Papes.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/NPr+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-c.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_cat.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/tagger_data_morph.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-Toponymes.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/RomNum.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/CR.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Suffixes+.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Elements.fst2" "/home/falk/Logoscope/Unitex3.0/French/Dela/Prolex-PaysCapitales.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/prenom-s.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/motsGramf-.bin" "/home/falk/Logoscope/Unitex3.0/French/Dela/Extrait-DelquefM2.bin"
# echo "sorting sorting dictionaries files..."
# ./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d10/dlf" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d10/dlf.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
# ./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d10/dlc" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d10/dlc.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
# ./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d10/err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d10/err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt" 
# ./SortTxt "/home/falk/Logoscope/Unitex3.0/French/Corpus/$d10/tags_err" "-l/home/falk/Logoscope/Unitex3.0/French/Corpus/$d10/tags_err.n" "-o/home/falk/Logoscope/Unitex3.0/French/Alphabet_sort.txt"  
# echo "Phase 10 done..."



exit

