#!/bin/bash
# Script for checking where disk space is being used the most on a filesystem.
echo "Which directory do you need to check? (Use / for root directory)"
read FS
echo "How many results would you like to display? (20 is usually enough)"
read NUMRESULTS
time {
resize;\
clear;\
echo -e "\nLargest Files and Directories:\n==============================\n";\
echo -e "Report Generated: $(date)\n";\
df -h $FS; \
echo -e "\nLargest Directories:\n====================\n"; \
du -x $FS 2>/dev/null | sort -rnk1 | head -n $NUMRESULTS | awk '{printf "%d MB %s\n", $1/1024,$2}';\
echo -e "\nLargest Files:\n==============\n";\
find $FS -mount -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n $NUMRESULTS;\
echo -e "\nReport Finished: $(date)\n"
}
