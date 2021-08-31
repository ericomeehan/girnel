#!/bin/bash
#
# ========
# GIRNEL
# ========
#
# Eric O Meehan
# 2021-08-26
#
# A simple, searchable journal for git repositories.
#

help()
{
    echo "usage:"
    echo "      grnl <mode> 'input'"
    echo "      modes:"
    echo "          -r      read (uses less to read .girnel)"
    echo "          -w      write (opens vim to compose an entry)"
    echo "          -q      query (opens a sqlite database)"
    echo "      input:"
    echo "          -w and -q accept a quoted argument to be used"
    echo "          as the girnel entry or sqlite query respectively"
}

declare -A PROJECT
GIRNEL=""

git_check()
{
    if [[ $(git status 2> /dev/null) == "" ]]
    then
        echo "girnel requires a git repository"
        exit 1
    fi
}

girnel_check()
{
    if [[ $(ls $GIRNEL 2> /dev/null) == "" ]]
    then
        echo ".girnel missing from project root"
        exit 1
    fi
}

setup()
{
    git_check
    PROJECT=(
        ['author']="$(git config user.name)"
        ['date']="$(date +%F)"
        ['time']="$(date +%H:%M:%S)"
        ['repository']="$(git rev-parse --show-toplevel)"
        ['branch']="$(git status | grep branch | cut -d ' ' -f3)"
        ['commit']="$(git rev-parse --short HEAD)"
    )
    GIRNEL="${PROJECT['repository']}/.girnel"
    girnel_check
}

# Compose an Entry

compose()
{
    touch /tmp/girnel.txt
    vim /tmp/girnel.txt
    ENTRY="$(cat /tmp/girnel.txt)"
    if [[ $ENTRY == "" ]]
    then
        echo "No body written, canceling entry."
        exit 0
    fi
}


write()
{
    ENTRY="$(cat /tmp/girnel)"
    rm /tmp/girnel
    echo "========" >> $GIRNEL
    echo "Author: ${PROJECT['author']}" >> $GIRNEL
    echo "Date: ${PROJECT['date']}" >> $GIRNEL
    echo "Time: ${PROJECT['time']}" >> $GIRNEL
    echo "Branch: ${PROJECT['branch']}" >> $GIRNEL
    echo "Commit: ${PROJECT['commit']}" >> $GIRNEL
    echo "" >> $GIRNEL
    echo "$ENTRY" >> $GIRNEL
    echo "" >> $GIRNEL
    echo "" >> $GIRNEL
}

# Query Previous Entries

DB_SCHEMA="CREATE TABLE entries (
        entry_id INTEGER PRIMARY KEY NOT NULL,
        author TEXT,
        date TEXT,
        time TEXT,
        branch TEXT,
        hash TEXT,
        message TEXT NOT NULL
    );"

insert()
{
    sqlite /tmp/girnel.db "
        INSERT INTO entries (
            author, date, time, branch, hash, mesage
        ) VALUES (
            \"${ENTRY['author']}\",
            \"${ENTRY['date']}\",
            \"${ENTRY['time']}\",
            \"${ENTRY['branch']}\",
            \"${ENTRY['commit']}\",
            \"${ENTRY['message']}\"
        );"
}

create_db()
{
    touch /tmp/girnel.db
    sqlite /tmp/girnel.db "$DB_SCHEMA"

    while IFS='' read -r line || [ -n "${line}" ]
    do
        if [[ $line =~ "========" ]]
        then
            if [[ ${ENTRY['message']} != "" ]]
            then
                insert
            fi
        elif [[ $line =~ "Author:" ]]
        then
            ENTRY['author']=$(echo "$line" | cut -d ' ' -f2-)
        elif [[ $line =~ "Date:" ]]
        then
            ENTRY['date']=$(echo "$line" | cut -d ' ' -f2-)
        elif [[ $line =~ "Time:" ]]
        then
            ENTRY['time']=$(echo "$line" | cut -d ' ' -f2-)
        elif [[ $line =~ "Branch:" ]]

        then
            ENTRY['branch']=$(echo "$line" | cut -d ' ' -f2-)
        elif [[ $line =~ "Commit:" ]]
        then
            ENTRY['commit']=$(echo "$line" | cut -d ' ' -f2-)
        elif [[ $line != "" ]]
        then
            if [[ ${ENTRY['message']} == "" ]]
            then
                ENTRY['message']="$line"
            else
                ENTRY['message']="${ENTRY['message']}\n$line"
            fi
        fi
    done < $GIRNEL
    insert
}

query()
{
    create_db
    if [[ $# -ge 1 ]]
    then
        sqlite3 /tmp/girnel.db "$1"
    else
        sqlite3 /tmp/girnel.db
    fi
    if [[ $(ls /tmp/girnel.db 2> /dev/null) != "" ]]
    then
        rm /tmp/girnel.db
    fi
}

main()
{
    declare -A OPTIONS=(
        ['-r']=false
        ['-w']=false
        ['-q']=false
    )

    if [[ $# -eq 0 ]]
    then
        compose
        write
    else
        if [[ "$1" != "-r" && "$1" != "-w" && "$1" != "-q" ]]
        then
            help
        else
            OPTIONS["$1"]=true
        fi
    fi

    if [[ ${OPTIONS['-r']} == "true" ]]
    then
        less $GIRNEL
    elif [[ ${OPTIONS['-w']} == "true" ]]
    then
        if [[ $# -gt 1 ]]
        then
            echo "$2" > /tmp/girnel
            write
        else
            compose
            write
        fi
    elif [[ ${OPTIONS['-q']} == "true" ]]
    then
        if [[ $# -gt 1 ]]
        then
            query "$2"
        else
            query
        fi
    fi
}

main
