#!/bin/bash

################################################################################
# 
# Lines of text are continuously dumped, but the output changes to
#'book/character_number.txt' at each chapter header, where 'number'
# is incremented each time the character is encountered
#
################################################################################

if [ "$1" == "-v" ]
then
    VERBOSE=1
fi

DIR_ASOIAF=Texts/ASOIAF/
DIR_TEXTS=${DIR_ASOIAF}/RAW/

# Short titles
declare -A ABBRV=( [a_game_of_thrones]=AGOT
                   [a_clash_of_kings]=ACOK
                   [a_storm_of_swords]=ASOS
                   [a_feast_for_crows]=AFFC )

in_book=0

# Run on all books
for book in ${DIR_TEXTS}/*.txt
do
    OUTFILE=/dev/null
    BOOKNAME=`basename ${book%.txt}`
    SHORTNAME=${ABBRV[${BOOKNAME}]}
    CHAP_COUNT=0
    declare -A POV_COUNTS

    mkdir -p ${DIR_ASOIAF}/${BOOKNAME}

    echo 'Extracting chapters from' ${BOOKNAME}

    while read line
    do
        # Chapter headers are all-caps and appear by themselves e.g. "ARYA\n"
        pov=$(echo $line | egrep "^([A-Z][ ]?){2,}+$")
        pov=${pov// /_}

        # Content line or chapter header?
        if [ -z ${pov} ]
        then
            echo $line >> ${OUTFILE}
        else
            # Have we reached the beginning?
            if [ ${in_book} -eq 0 ] && [ ${pov} == 'PROLOGUE' ]
            then
                in_book=1
            fi

            # Are we in the content?
            if [ ${in_book} -ne 0 ]
            then
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
                OUTFILE=${DIR_ASOIAF}/${BOOKNAME}/${SHORTNAME}
                OUTFILE+=_$(printf "%02d" ${CHAP_COUNT})_${pov}
                OUTFILE+=_$(printf "%02d" ${POV_COUNTS[${pov}]}).txt

                # Print chapter
                if [ ${VERBOSE} ]
                then
                    printf "|-> (%02d) %s\n" ${CHAP_COUNT} $pov
                fi
            fi
        fi
    done < ${book}
done
