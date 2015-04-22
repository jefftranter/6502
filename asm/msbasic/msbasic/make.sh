if [ ! -d tmp ]; then
	mkdir tmp
fi

#for i in cbmbasic1 cbmbasic2 kbdbasic osi kb9 applesoft microtan; do
for i in osi; do

echo $i
ca65 -l msbasic.lst -D $i msbasic.s -o tmp/$i.o &&
ld65 -vm -m tmp/$i.map -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl
done

# For ROM
#bintomon -v -l 0xa000 -r 0xbd0d tmp/osi.bin > tmp/osi.mon
# For RAM
bintomon -v -l 0x6000 -r 0x7d0d tmp/osi.bin > tmp/osi.mon
