#!/bin/bash

# Simple script to delete bloatware from /system (not recommended to
# do in an actual running Android system)
# @author: JohnDaH4x0r <terencedoesmc12@gmail.com>

# Data & variables
PROG="$(basename "$0")"
CWD="$(pwd)"
LOGFILE="${CWD}/${PROG}-$$.log"
read -e -p "Database file: " DBFILE
read -e -p "Path to /system/: " SYSTEM

# Check variables
if [ ! -f "$DBFILE" ]; then
    echo "${PROG}: File not found! - ${DBFILE}" >&2
    exit 1
elif [ ! -r "$DBFILE" ]; then
    echo "${PROG}: File unreadable! - ${DBFILE}" >&2
    exit 1
elif [ ! -d "$SYSTEM" ]; then
    echo "${PROG}: Directory not found! - ${SYSTEM}" >&2
    exit 1
else
    echo "${PROG}: No problems found..."
fi

DB="$(grep -ve "#" < "${DBFILE}" | tr "\n" " ")"
touch "$LOGFILE"
cd "${SYSTEM}"
for ENTRY in $DB; do
    APK="$(echo "$ENTRY" | cut -d ";" -f 1)"
    LIBS="$(echo "$ENTRY" | cut -d ";" -f 2)"
    EXT="${APK##*.}"
    GENERIC="${APK%.*}"

    
    if [ "$APK" = "%dummy%" ]; then
        echo "Extension check: OVERRIDDEN" | tee -a "$LOGFILE"
        true
    elif [ "$EXT" != "apk" ]; then
        echo "Entry/File not an APK file!" | tee -a "$LOGFILE" >&2
        echo
        continue
    fi

    # Delete APK
    if [ -f "app/${APK}" ]; then 
        APK="app/${APK}"
        echo "Removing APK file: $APK" | tee -a "$LOGFILE"
        rm -f "$APK"
    elif [ -f "priv-app/${APK}" ]; then
        APK="priv-app/${APK}"
        echo "Removing APK file: $APK" | tee -a "$LOGFILE"
        rm -f "$APK"
    elif [ "${APK}" = "%dummy%" ]; then
        echo "APK removal: OVERRIDEN" | tee -a "$LOGFILE"
        true
    else
        echo "Cannot find APK file: ${APK}" | tee -a "$LOGFILE" >&2
    fi

    # Delete ODEX
    ODEX="${GENERIC}.odex"

    if [ -f "app/${ODEX}" ]; then 
        ODEX="app/${ODEX}"
        echo "Removing ODEX file: $ODEX" | tee -a "$LOGFILE"
        rm -f "$ODEX"
    elif [ -f "priv-app/${ODEX}" ]; then
        ODEX="priv-app/${ODEX}"
        echo "Removing ODEX file: $ODEX" | tee -a "$LOGFILE"
        rm -f "$ODEX"
    elif [ "${APK}" = "%dummy%" ]; then
        echo "ODEX removal: OVERRIDDEN" | tee -a "$LOGFILE"
        true
    else
        echo "Cannot find ODEX file: ${ODEX}" | tee -a "$LOGFILE">&2
    fi

    # Delete libraries
    if [ "$LIBS" = "%dummy%" ]; then 
        echo "Library removal: OVERRIDDEN" | tee -a "$LOGFILE"
        echo | tee -a "$LOGFILE"
        continue
    fi

    IFSB="$IFS"
    IFS="&"
    for LIB in $LIBS; do
        LIB_RP="lib/${LIB}"
        if [ ! -f "$LIB_RP" ]; then
            echo "Cannot find library: $LIB" | tee -a "$LOGFILE" >&2
            continue
        fi

        echo "Deleting library: $LIB" | tee -a "$LOGFILE"
        rm -f "$LIB_RP"
    done
    IFS="$IFSB"
    echo | tee -a "$LOGFILE"
done
cd "$CWD"



