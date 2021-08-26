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

setup


