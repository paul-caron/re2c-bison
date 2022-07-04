




a.out: parser.cc
	g++ -std=c++17 parser.cc


parser.cc: bparser.tab.c
	/usr/local/Cellar/re2c/3.0/bin/re2c bparser.tab.cc -o parser.cc


bparser.tab.c: bparser.yy
	/usr/local/Cellar/bison/3.8.2/bin/bison bparser.yy


