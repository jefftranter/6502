
#define SFIELD	23	/* source line offset in print line buffer */
#define STABSZ	35000	/* default symbol table size */
#define SBOLSZ	16	/* maximum symbol size */

/* symbol flags */

#define DEFZRO	2	/* defined - page zero address	*/
#define MDEF	3	/* multiply defined		*/
#define UNDEF	1	/* undefined - may be zero page */
#define DEFABS	4	/* defined - two byte address	*/
#define UNDEFAB	5	/* undefined - two byte address */
#define PAGESIZE 60	/* number of lines on a page    */
#define LINESIZE 132	/* number of characters on a line */
#define TITLESIZE 80	/* maximum characters in title  */

/* pass flags */

#define FIRST_PASS	0
#define LAST_PASS	1
#define DONE		2

#define CPMEOF EOF

void getargs(int argc, char *argv[]);
void pseudo(int *ip);
void class1();
void class2(int *ip);
void class3(int *ip);
void help();
void initvar();
void initialize(int ac, char *av[], int argc);
int readline();
void assemble();
void stprnt();
void wrapup();
void clrlin();
void finobj();
void wrapup();
void loadv(int val, int f, int outflg);
void prsyline();
void prsymhead();
void hexcon(int digit, int num);
void println();
int colsym(int *ip);
int stinstal(int ptr);
int stlook();
int oplook(int *ip);
int labldef(int lval);
void error(char *stptr);
void loadlc(int val, int f);
void printhead();
int openspc(int ptr,int len);
void startobj();
void putobj(unsigned val);
void prtobj();
int evaluate(int *ip);
void newlc(unsigned val);
int colnum(int *ip);
int addref(int ip);
