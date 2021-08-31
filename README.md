# Girnel

Eric O Meehan
2021-08-30

A journel for git repositories.

# Introduction

Girnel is a light weight, searchable journal for git repositories that allows
developers to track their research and decision making process alongside the 
changes in code.

Create a .girnel file in the root of your project repository, then use the girnel.sh 
script to add entries, read, and query the girnel.  New entries are given a 
human-readable header and appended to the .girnel file.  Girnel will use this header
to create sqlite database that can be queried by author, date, time, branch, and commit.  


# Installation

Simply copy the girnel.sh file into your git repository and begin using girnel!
If you would like to create a more perminent installation, clone this repository
into a safe location (such as /usr/local/src), make the script executable:

```
chmod a+x /usr/local/src/girnel/girnel.sh
```
and create a symbolic link using the full path of each file:
```
ln -s /usr/local/src/girnel/girnel.sh /usr/local/bin/grnl
```
This method of installation will both allow you to use the grnl command globally
and easily pull updates to the source code.

# Usage

grnl <mode> 'input'
    modes:
            -r      read (uses less to read .girnel)
            -w      write (opens vim to compose an entry)
            -q      query (opens a sqlite database)
    input:
            -w and -q accept a quoted argument to be used
            as the girnel entry or sqlite query respectively
