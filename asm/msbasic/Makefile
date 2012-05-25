default: msbasic

msbasic:
	mkdir msbasic ; cd msbasic ; unzip ../msbasic.zip ; patch -p1 <../REPLICA1-PATCHES-FOR-OSI.patch ; ./make.sh

clean:
	$(RM) -rf msbasic

distclean: clean
