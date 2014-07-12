#!/bin/bash

################################################################################
# 
# Lines of text are continuously dumped, but the output changes to
#'book/character_number.txt' at each chapter header, where 'number'
# is incremented each time the charcater is encountered
#
################################################################################

if [ "$1" == "-v" ]
then
    VERBOSE=1
fi

DIR_ASOIAF='Texts/ASOIAF/'

# Short titles
declare -A ABBRV=( [a_game_of_thrones]=AGOT
                   [a_clash_of_kings]=ACOK
                   [a_storm_of_swords]=ASOS
                   [a_feast_for_crows]=AFFC )

# Run on all books
for book in ${DIR_ASOIAF}/*.txt
do
    OUTFILE=/dev/null
    DIR_BOOK=${book%.txt}
    BOOKNAME=${ABBRV[`basename ${DIR_BOOK}`]}
    CHAP_COUNT=0
    declare -A POV_COUNTS

    mkdir -p ${DIR_BOOK}

    echo 'Extracting chapters from' ${BOOKNAME}

    while read line
    do
        # Chapter headers are all-caps and appear by themselves e.g. "ARYA\n"
        pov=$(echo $line | egrep "^[A-Z]{2,}$")

        # New chapter?
        if [ ! -z ${pov} ]
        then
            # Skip front-matter
            if [ ${pov} == 'CONTENT' ]
            then
                OUTFILE=/dev/null
                continue
            fi

            # Nothing after appendix
            if [ ${pov} == 'APPENDIX' ]
            then
                break
            fi

            # Increment book chapter number
            ((CHAP_COUNT++))

            # Increment character chapter number
            if [ ! ${POV_COUNTS[${pov}]} ]
            then
                POV_COUNTS[${pov}]=1
            else
                ((POV_COUNTS[${pov}]++))
            fi

            # Change output destination
            OUTFILE=${DIR_BOOK}/${BOOKNAME}
            OUTFILE+=_$(printf "%02d" ${CHAP_COUNT})_${pov}
            OUTFILE+=_$(printf "%02d" ${POV_COUNTS[${pov}]}).txt

            # Print chapter
            if [ VERBOSE ]
            then
                printf "|-> (%02d) %s\n" ${CHAP_COUNT} $pov
            fi

        else
            # echo $OUTFILE
            echo $line >> ${OUTFILE}
        fi
    done < ${book}
done
