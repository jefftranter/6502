if [ ! -d tmp ]; then
	mkdir tmp
fi

#for i in cbmbasic1 cbmbasic2 kbdbasic osi kb9 applesoft microtan; do
for i in osi; do

echo $i
ca65 -l -D $i msbasic.s -o tmp/$i.o &&
ld65 -vm -m tmp/$i.map -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl
done
bintomon -v -l 0xa000 -r - tmp/osi.bin > tmp/osi.mon
