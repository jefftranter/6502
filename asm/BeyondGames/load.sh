#!/bin/sh
#
# Send files to load

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1000" >>ALL.bas
echo "620 DATA 1031" >>ALL.bas
cat E1.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1100" >>ALL.bas
echo "620 DATA 1127" >>ALL.bas
cat E2.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1200" >>ALL.bas
echo "620 DATA 1235" >>ALL.bas
cat E3.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1300" >>ALL.bas
echo "620 DATA 1341" >>ALL.bas
cat E4.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1400" >>ALL.bas
echo "620 DATA 1475" >>ALL.bas
cat E5.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1500" >>ALL.bas
echo "620 DATA 1539" >>ALL.bas
cat E6.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1600" >>ALL.bas
echo "620 DATA 1633" >>ALL.bas
cat E7.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1700" >>ALL.bas
echo "620 DATA 1785" >>ALL.bas
cat E8.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1800" >>ALL.bas
echo "620 DATA 1841" >>ALL.bas
cat E9.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 1900" >>ALL.bas
echo "620 DATA 1963" >>ALL.bas
cat E10.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 2000" >>ALL.bas
echo "620 DATA 2009" >>ALL.bas
cat E11.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas
sleep 20

echo "NEW" >ALL.bas
cat OBJECTCODELOADER.bas >>ALL.bas
echo "600 DATA 2100" >>ALL.bas
echo "620 DATA 2102" >>ALL.bas
cat E12.bas | grep " DATA  " >> ALL.bas
echo "RUN" >>ALL.bas

SEND ALL.bas

# Now do:
#   POKE 11,7 : POKE 12,18
#   X=USR(X)
