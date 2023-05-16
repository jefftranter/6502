/*
 *  A65 - an assembler for the MOS Technology 6502 microprocessor
 *
 *  Most source files intended for the MOS Technology 6502 assembler
 *  will assemble correctly under A65.
 *
 *  A65 is a public domain work. It is derived from the "as6502"
 *  cross-assembler written by J. H. Van Ornum and J. Swank.
 *
 *  To compile A65 under Borland/Turbo-C 2.x, 3.x, 5.5.x :
 *
 *    tcc a65.c
 *
 */

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "ctype.h"

char	*pvers  = "1.24";			/* program version */
char	*pdate  = "2023-05-16"; 		/* program date */
char	*ptitle = "A65 65C02 Assembler";	/* program name */

#define SFIELD	23	/* source line offset in print line buffer */
#define STABSZ	32767	/* default symbol table size */
#define SBOLSZ	16	/* maximum symbol size */
#define MAXIF	8	/* maximum IFE/IFN nesting */

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

/* globals */

FILE	*iptr;			/* source input file */
FILE	*lptr;			/* listing output file */
FILE	*optr;			/* hex object output file */
FILE	*bptr;			/* binary output file */
FILE    *sptr;			/* storage when reading .lib file */
int	errcnt;			/* error counter */
int	eflag;			/* errors flag */
int	warncnt;		/* warning counter */
int	gflag;			/* generate flag */
char	hex[5];			/* hexadecimal character buffer	*/
int	lablptr;		/* label pointer into symbol table */
int	lflag;			/* listing flag */
unsigned loccnt;		/* location counter */
int	nflag;			/* normal/split address mode */
int	mflag;			/* generate MOS Technology object format */
int	nxt_free;		/* next free location in symtab */
int	objcnt;			/* object byte counter */
int	oflag;			/* object output flag */
int	opflg;			/* operation code flags */
int	opval;			/* operation code value */
int	pass;			/* pass counter */
char	prlnbuf[LINESIZE+1];	/* print line buffer */
int	rflag;			/* reformat listing flag */
int	sflag;			/* symbol table output flag */
unsigned slnum;			/* source line number counter */
unsigned char	*symtab;		/* symbol table */
				/* struct sym_tab */
				/* 	char	size; */
				/*	char	chars[size]; */
				/*	char	flag; */
				/*	int	value; */
				/*	int	line defined */
				/*	char	# references */
				/*	int	line referenced	*/
int	size;			/* symbol table size */
char	symbol[SBOLSZ+1];	/* temporary symbol storage */
int	udtype;			/* undefined symbol type */
int	undef;			/* undefined symbol in expression flg */
int	value;			/* operand field value */
char	zpref;			/* zero page reference flag */
int	pagect;			/* count of pages */
int	paglin;			/* lines printed on current page */
int	pagesize;		/* maximum lines per page */
int	linesize;		/* maximum characters per line */
int	titlesize;		/* title string size */
char	titlbuf[LINESIZE+1];	/* buffer for title from .page */
int	badflag;
int	act;
char	**avt;
char	objrec[60];		/* buffer for object record */
int	objptr;			/* pointer to object record */
unsigned objloc;		/* object file location counter */
int	objbytes;		/* count of bytes in current record */
int	reccnt;			/* count of records in file */
int	cksum;			/* record check sum accumulator */
int	cflag;			/* console flag */
int	endflag;		/* end assembly flag */
int	bflag;			/* binary output flag */
int	cbflag;			/* codebase flag */
unsigned cbase;			/* codebase for binary file */
int	locflag;		/* location change flag */
unsigned lastloc;		/* last location change */
int	qflag;			/* quiet flag */
int	lstflag;		/* list file flag */
int	cmos;			/* cmos flag */
int	flevel;			/* false conditional */
int	tlevel;			/* nesting level */
int	iflvl[MAXIF+1];		/* nesting stack */
int	islflg;			/* is location flag */
char	fname[LINESIZE+1];	/* file name */
char    lname[LINESIZE+1];	/* lib name */
int goloc;			/* go location for MOS, OSI emitted output */
int curObLoc;
int lastOSI;			/* last address emitted for OSI 65V */

/*********************************************************************/

/* operation code flags */

#define IMM1	0x1000		/* opval + 0x00	2 byte */
#define IMM2	0x0800		/* opval + 0x08	2 byte */
#define ABS	0x0400		/* opval + 0x0C	3 byte */
#define ZER	0x0200		/* opval + 0x04	2 byte */
#define INDX	0x0100		/* opval + 0x00	2 byte */
#define ABSY2	0x0080		/* opval + 0x1C	3 byte */
#define INDY	0x0040		/* opval + 0x10	2 byte */
#define ZERX	0x0020		/* opval + 0x14	2 byte */
#define ABSX	0x0010		/* opval + 0x1C	3 byte */
#define ABSY	0x0008		/* opval + 0x18	3 byte */
#define ACC	0x0004		/* opval + 0x08	1 byte */
#define IND	0x0002		/* opval + 0x2C	3 byte */
#define ZERY	0x0001		/* opval + 0x14	2 byte */

/* opcode classes */

#define PSEUDO	0x6000
#define CLASS1	0x2000
#define CLASS2	0x4000
#define CLASS3	ABS
#define CLASS4	ABS|IND
#define CLASS5	ABS|ZER
#define CLASS6	ABS|ZER|INDX|INDY|ZERX|ABSX|ABSY
#define CLASS7	ABS|ZER|ZERX
#define CLASS8	ABS|ZER|ZERX|ABSX
#define CLASS9	ABS|ZER|ZERX|ABSX|ACC
#define CLASS10	ABS|ZER|ZERY
#define CLASS11	IMM1|ABS|ZER
#define CLASS12	IMM1|ABS|ZER|ABSX|ZERX
#define CLASS13	IMM1|ABS|ZER|ABSY2|ZERY
#define CLASS14	IMM2|ABS|ZER|IND|INDX|INDY|ZERX|ABSX|ABSY
#define CLASS15	IMM2|ABS|ZER|ZERX|ABSX


#define A	0x20)+('A'&0x1f))
#define B	0x20)+('B'&0x1f))
#define C	0x20)+('C'&0x1f))
#define D	0x20)+('D'&0x1f))
#define E	0x20)+('E'&0x1f))
#define F	0x20)+('F'&0x1f))
#define G	0x20)+('G'&0x1f))
#define H	0x20)+('H'&0x1f))
#define I	0x20)+('I'&0x1f))
#define J	0x20)+('J'&0x1f))
#define K	0x20)+('K'&0x1f))
#define L	0x20)+('L'&0x1f))
#define M	0x20)+('M'&0x1f))
#define N	0x20)+('N'&0x1f))
#define O	0x20)+('O'&0x1f))
#define P	0x20)+('P'&0x1f))
#define Q	0x20)+('Q'&0x1f))
#define R	0x20)+('R'&0x1f))
#define S	0x20)+('S'&0x1f))
#define T	0x20)+('T'&0x1f))
#define U	0x20)+('U'&0x1f))
#define V	0x20)+('V'&0x1f))
#define W	0x20)+('W'&0x1f))
#define X	0x20)+('X'&0x1f))
#define Y	0x20)+('Y'&0x1f))
#define Z	0x20)+('Z'&0x1f))

#define OPSIZE	127

/* nmemonic operation code table
   entries consists of 3 fields - opcode name (hashed to a 16-bit
   value and sorted NUMERICALLY), opcode class, opcode value. */

int	optab[]	=					/* '.' = 31
							   '*' = 30
							   '=' = 29 */
{
	((0*0x20)+(29)),PSEUDO,1,			/* = */
	((((0*0x20)+(30))*0x20)+(29)),PSEUDO,3,		/* *= */
	((((((0*A*D*C,CLASS14,0x61,			/* ADC */
	((((((0*A*N*D,CLASS14,0x21,			/* AND */
	((((((0*A*S*L,CLASS9,0x02,			/* ASL */
	((((((0*B*C*C,CLASS2,0x90,			/* BCC */
	((((((0*B*C*S,CLASS2,0xb0,			/* BCS */
	((((((0*B*E*Q,CLASS2,0xf0,			/* BEQ */
	((((((0*B*I*T,CLASS15,0x20,			/* BIT */
	((((((0*B*M*I,CLASS2,0x30,			/* BMI */
	((((((0*B*N*E,CLASS2,0xd0,			/* BNE */
	((((((0*B*P*L,CLASS2,0x10,			/* BPL */
	((((((0*B*R*A,CLASS2,0x80,			/* BRA */
	((((((0*B*R*K,CLASS1,0x00,			/* BRK */ //should be class 2
	((((((0*B*V*C,CLASS2,0x50,			/* BVC */
	((((((0*B*V*S,CLASS2,0x70,			/* BVS */
	((((((0*C*L*C,CLASS1,0x18,			/* CLC */
	((((((0*C*L*D,CLASS1,0xd8,			/* CLD */
	((((((0*C*L*I,CLASS1,0x58,			/* CLI */
	((((((0*C*L*V,CLASS1,0xb8,			/* CLV */
	((((((0*C*M*P,CLASS14,0xc1,			/* CMP */
	((((((0*C*P*X,CLASS11,0xe0,			/* CPX */
	((((((0*C*P*Y,CLASS11,0xc0,			/* CPY */
	((((((0*D*E*A,CLASS1,0x3a,			/* DEA */
	((((((0*D*E*C,CLASS9,0xc2,			/* DEC */
	((((((0*D*E*X,CLASS1,0xca,			/* DEX */
	((((((0*D*E*Y,CLASS1,0x88,			/* DEY */
	((((((0*E*O*R,CLASS14,0x41,			/* EOR */
	((((((0*I*N*A,CLASS1,0x1a,			/* INA */
	((((((0*I*N*C,CLASS9,0xe2,			/* INC */
	((((((0*I*N*X,CLASS1,0xe8,			/* INX */
	((((((0*I*N*Y,CLASS1,0xc8,			/* INY */
	((((((0*J*M*P,CLASS4,0x40,			/* JMP */
	((((((0*J*S*R,CLASS3,0x14,			/* JSR */
	((((((0*L*D*A,CLASS14,0xa1,			/* LDA */
	((((((0*L*D*X,CLASS13,0xa2,			/* LDX */
	((((((0*L*D*Y,CLASS12,0xa0,			/* LDY */
	((((((0*L*S*R,CLASS9,0x42,			/* LSR */
	((((((0*N*O*P,CLASS1,0xea,			/* NOP */
	((((((0*O*R*A,CLASS14,0x01,			/* ORA */
	((((((0*P*H*A,CLASS1,0x48,			/* PHA */
	((((((0*P*H*P,CLASS1,0x08,			/* PHP */
	((((((0*P*H*X,CLASS1,0xda,			/* PHX */
	((((((0*P*H*Y,CLASS1,0x5a,			/* PHY */
	((((((0*P*L*A,CLASS1,0x68,			/* PLA */
	((((((0*P*L*P,CLASS1,0x28,			/* PLP */
	((((((0*P*L*X,CLASS1,0xfa,			/* PLX */
	((((((0*P*L*Y,CLASS1,0x7a,			/* PLY */
	((((((0*R*O*L,CLASS9,0x22,			/* ROL */
	((((((0*R*O*R,CLASS9,0x62,			/* ROR */
	((((((0*R*T*I,CLASS1,0x40,			/* RTI */
	((((((0*R*T*S,CLASS1,0x60,			/* RTS */
	((((((0*S*B*C,CLASS14,0xe1,			/* SBC */
	((((((0*S*E*C,CLASS1,0x38,			/* SEC */
	((((((0*S*E*D,CLASS1,0xf8,			/* SED */
	((((((0*S*E*I,CLASS1,0x78,			/* SEI */
	((((((0*S*T*A,CLASS6,0x81,			/* STA */
	((((((0*S*T*X,CLASS10,0x82,			/* STX */
	((((((0*S*T*Y,CLASS7,0x80,			/* STY */
	((((((0*S*T*Z,CLASS8,0x60,			/* STZ */
	((((((0*T*A*X,CLASS1,0xaa,			/* TAX */
	((((((0*T*A*Y,CLASS1,0xa8,			/* TAY */
	((((((0*T*R*B,CLASS5,0x10,			/* TRB */
	((((((0*T*S*B,CLASS5,0x00,			/* TSB */
	((((((0*T*S*X,CLASS1,0xba,			/* TSX */
	((((((0*T*X*A,CLASS1,0x8a,			/* TXA */
	((((((0*T*X*S,CLASS1,0x9a,			/* TXS */
	((((((0*T*Y*A,CLASS1,0x98,			/* TYA */
	((((((0*0x20)+(31))*B*Y^((0*T,PSEUDO,0,		/* .BYT */
	((((((0*0x20)+(31))*D*W^((0*O,PSEUDO,13,	/* .DWO yes this hash is < the next one*/
	((((((0*0x20)+(31))*D*B^((0*Y,PSEUDO,6,		/* .DBY */
	((((((0*0x20)+(31))*E*N^((0*D,PSEUDO,4,		/* .END */
	((((((0*0x20)+(31))*E*X^((0*E,PSEUDO,11,	/* .EXE */
	((((((0*0x20)+(31))*F*I^((0*L,PSEUDO,15,	/* .FIL */
	((((((0*0x20)+(31))*I*F^((0*E,PSEUDO,9,		/* .IFE */
	((((((0*0x20)+(31))*I*F^((0*N,PSEUDO,10,	/* .IFN */
	((((((0*0x20)+(31))*L*I^((0*B,PSEUDO,14,	/* .LIB */
	((((((0*0x20)+(31))*O*P^((0*T,PSEUDO,5,		/* .OPT */
	((((((0*0x20)+(31))*O*R^((0*G,PSEUDO,12,	/* .ORG */
	((((((0*0x20)+(31))*P*A^((0*G,PSEUDO,7,		/* .PAG */
	((((((0*0x20)+(31))*S*K^((0*I,PSEUDO,8,		/* .SKI */
	((((((0*0x20)+(31))*W*O^((0*R,PSEUDO,2,		/* .WOR */
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0,
	0x7fff,0,0
};

int	step[] =
{
	3*((OPSIZE+1)/2),
	3*((((OPSIZE+1)/2)+1)/2),
	3*((((((OPSIZE+1)/2)+1)/2)+1)/2),
	3*((((((((OPSIZE+1)/2)+1)/2)+1)/2)+1)/2),
	3*((((((((((OPSIZE+1)/2)+1)/2)+1)/2)+1)/2)+1)/2),
	3*(2),
	3*(1),
	0
};

/*********************************************************************/

/* display help */

void help(void)
{
	fprintf(stdout, "use:  A65 [options] files[.asm]\n\n");
	fprintf(stdout, "-B   output binary file\n");
	fprintf(stdout, "-X   output listing to console\n");
	fprintf(stdout, "-L   output listing to file\n");
	fprintf(stdout, "-H   output INTEL hex object file\n");
	fprintf(stdout, "-M   output MOS Technology hex object file\n");
	fprintf(stdout, "-A   output OSI 65A serial monitor object file\n");
	fprintf(stdout, "-O   output OSI 65V monitor lod object file\n");
	fprintf(stdout, "-Gx  specify execute address in hex for MOS/65V/65A\n");
	fprintf(stdout, "-Pn  page length (0 = no paging)\n");
	fprintf(stdout, "-Q   quiet (suppress warnings)\n");
	fprintf(stdout, "-R   reformat listing\n");
	fprintf(stdout, "-S   include symbol table in listing\n");
	fprintf(stdout, "-Tn  symbol table size\n");
	fprintf(stdout, "-Wn  page width\n");
	fprintf(stdout, "-C   enable 65C02 instructions\n");
}

/*********************************************************************/

/* parse the command args and save data */

void getargs(int argc, char *argv[])
{
	int	i;
	char 	c;
	int	sz;
	while (--argc > 0 && (*++argv)[0] == '-') {
		for (i = 1; (c = (*argv)[i]) != '\0'; i++) {
			switch (toupper(c)) {
			case 'B':		/* binary output flag */
				bflag = 1;
				break;
			case 'X':		/* console output */
				cflag = lflag = lstflag = 1;
				pagesize = 0;
				break;
			case 'L':		/* enable listing flag */
				lflag = lstflag = 1;
				break;
			case 'O':		/* OSI 65V object format */
				oflag = 1;
				mflag = 2;
				break;
			case 'A':		/* OSI 65A object format */
				oflag = 1;
				mflag = 3;
				break;
			case 'M':		/* MOS Tech. object format */
				mflag = 1;
			case 'H':		/* object output flag */
				oflag = 1;
				break;
			case 'R':		/* reformat listing flag */
				rflag = 1;
				break;
			case 'S':		/* list symbol table flag */
				sflag = 1;
				break;
			case 'G':		/* specified 'Go' location in hex */
				{
					char *pEnd = NULL;
					if ((*argv)[++i] == '\0') {
						++argv;
						argc--;
						goloc = strtol(*argv, &pEnd, 16 );
						} else goloc = strtol(&(*argv)[i], &pEnd, 16);
						if (pEnd)
							i = (pEnd - &(*argv)[i]) +1;
				}
				break;	
			case 'T':           	/* input symbol table size */
				{
				if ((*argv)[++i] == '\0') {
					++argv;
					argc--;
					sz = atoi(*argv);
					} else sz = atoi(&(*argv)[i]);
				if (sz>=1000) size=sz;
				else {
				     fprintf(stdout,
				     "Invalid symbol table size (min 1000)\n");
				     badflag++; }
				goto outofloop;
				}
			case 'P':		/* input lines per page */
				{
				if ((*argv)[++i] == '\0') {
					++argv;
					argc--;
					sz = atoi(*argv);
					} else sz = atoi(&(*argv)[i]);
				if (sz>=10 || sz == 0 ) pagesize=sz;
				else {
				     fprintf(stdout,
				     "Invalid pagesize (min 10)\n");
				     badflag++; }
				goto outofloop;
				}
			case 'Q':		/* quiet */
				qflag = 1;
				break;
			case 'W':		/* input characters per line */
				{
				if ((*argv)[++i] == '\0') {
					++argv;
					argc--;
					sz = atoi(*argv);
				} else sz = atoi(&(*argv)[i]);
				if (sz >= 40 && sz < LINESIZE+1) linesize=sz;
				else {
				     fprintf(stdout,
				     "Invalid linesize (min 40, max %d)\n",LINESIZE);
				     badflag++; }
				goto outofloop;
				}
			case 'C':		/* 65C02 instructions */
				cmos = 1;
				break;
			default:
			help();
			badflag++;
			} /* end switch */
		} /* end for  */
		outofloop: ;
	}
	act=argc; /* return values to main */
	avt=argv;
}

/*********************************************************************/

/* open files */

void initialize(int ac, char *av[], int argc)
{
	char	name[80];
	char	*cp;
	sptr    = NULL;
	strcpy(fname, *av);
	cp = strchr(fname, '.');
	if (cp == 0) strcat(fname, ".asm");
	if ((iptr = fopen(fname, "r")) == NULL) {
		fprintf(stdout, "Open error for file '%s'\n", fname);
		exit(1);
	}

	if ((pass == LAST_PASS) && ac == argc) {
		if (lstflag) {
			if (cflag) lptr = stdout;
			else {
				strcpy(name, *av);
				cp = strchr(name, '.');
				if (cp) *cp = '\0';
				strcat(name, ".lst");
				if ((lptr = fopen(name, "w")) == NULL) {
				fprintf(stdout, "Create error for list file %s\n", name);
				exit(1);
				}
			}
		}

		if (oflag) {
			strcpy(name, *av);
			cp = strchr(name, '.');
			if (cp) *cp = '\0';
			if (mflag == 3)
				strcat(name, ".65a");
			else if (mflag == 2)
				strcat(name, ".lod");
			else if (mflag == 1)
				strcat(name, ".chk");
			else
				strcat(name, ".hex");
			if ((optr = fopen(name, "wb")) == NULL) {
			fprintf(stdout, "Create error for object file %s\n", name);
			exit(1);
			}
		}

		if (bflag) {
			strcpy(name, *av);
			cp = strchr(name, '.');
			if (cp) *cp = '\0';
			strcat(name, ".bin");
			if ((bptr = fopen(name, "wb")) == NULL) {
			fprintf(stdout, "Create error for binary file %s\n", name);
			exit(1);
			}
		}
	}
}

/*********************************************************************/

/* clear the print buffer */

void clrlin(void)
{
	int i;
	for (i = 0; i < LINESIZE; i++)
		prlnbuf[i] = ' ';
}

/*********************************************************************/

/* reads and formats an input line */

int	field[] =
{
	SFIELD,
	SFIELD + 8,
	SFIELD + 16,
	SFIELD + 24,
	SFIELD + 32,
	SFIELD + 40
};

int readline(void)
{
	int	i;		/* pointer into prlnbuf */
	int	j;		/* pointer to current field start */
	int	ch;		/* current character */
	int	cmnt;		/* comment line flag */
	int	spcnt;		/* consecutive space counter */
	int	string;		/* ASCII string flag */
	unsigned temp1;		/* temp used for line number conversion */

	temp1 = ++slnum;
	clrlin();			/* clear line buffer */
	i = 4;				/* line# offset */
	while (temp1 != 0) {		/* put source line number into prlnbuf */
		prlnbuf[i--] = temp1 % 10 + '0';
		temp1 /= 10;
	}
	i = SFIELD;
	cmnt = spcnt = string = 0;
	j = 1;
	while ((ch = getc(iptr)) != '\n') { /* while not EOL */
		if (ch == '\r')		/* ignore CR */
			continue;

		prlnbuf[i++] = ch;	/* place char */

		if (i >= LINESIZE)	/* truncate long line */
			--i;

		if ((ch == ' ') && (string == 0) && rflag) {
			if (spcnt != 0)
				--i;
			else if (cmnt == 0) {
				++spcnt;
				if (i < field[j])
					i = field[j];
				if (++j > 3) {
					spcnt = 0;
					++cmnt;
				}
			}
		}
		else if (ch == '\t') {	/* perform tab */
			prlnbuf[i - 1] = ' ';
			spcnt = 0;
			if ((cmnt == 0) && rflag) {
				if (i < field[j])
					i = field[j];
				if (++j > 3)
					++cmnt;
			}
			else
				i = ((i - SFIELD-1 + 8) & 0x78) + SFIELD;
		}
		else if ((ch == ';') && (string == 0) && rflag) {
			if (i == SFIELD + 1)
				++cmnt;
			else {
				if (i < field[3] && cmnt == 0) {
					prlnbuf[i-1] = ' ';
					i = field[3];
					prlnbuf[i++] = ';';
					spcnt = 0;
					++cmnt;
				}
			}
		}
		else if (ch == EOF || ch == CPMEOF) /* end of file */
		{
			if (sptr)
			{
				iptr = sptr;
				sptr = NULL;
			}
			else
				return(-1);
		}
		else {
			if ((ch == '\'') && (cmnt == 0) && rflag)
				string = 1;
			spcnt = 0;
		}
	}
	prlnbuf[i] = 0;
	return(0);
}

/*********************************************************************/

/* convert number supplied as argument to hexadecimal
   in hex[digit] (lsd) through hex[1] (msd) */

void hexcon(int digit, int num)
{
	for (; digit > 0; digit--) {
		hex[digit] = (num & 0x0f) + '0';
		if (hex[digit] > '9')
			hex[digit] += 'A' -'9' - 1;
		num >>= 4;
	}
}

/*********************************************************************/

/* put one object byte in hex */

void putobj(unsigned val)
{
	hexcon(2,val);
	objrec[objptr++] = hex[1];
	objrec[objptr++] = hex[2];
	cksum += (val & 0xff);
	objbytes++;
}

/*********************************************************************/

/* print the current object record if any */

void prtobj(void)
{
	int	i;

	if (objbytes == 0) return;
	cksum += objbytes;
	hexcon(2,objbytes);
	objrec[objptr] = '\0';

	if (mflag == 0) {	 /* intel */
		fprintf(optr,":%c%c",hex[1],hex[2]); /* number data bytes */
		for (i = 0; i <= 3; ++i) fputc(objrec[i],optr);
		fprintf(optr,"00%s",objrec+4);
		hexcon(2,0-cksum);
		fprintf(optr,"%c%c\r\n",hex[1],hex[2]);
	}
	else if (mflag == 1){  /* MOS */
		fprintf(optr,";%c%c",hex[1],hex[2]); /* number data bytes */
		fprintf(optr,"%s",objrec);
		hexcon(4,cksum);
		fprintf(optr,"%c%c%c%c\r\n",hex[1],hex[2],hex[3],hex[4]);
	}
	else if (mflag == 3) { /*OSI 65A */
		if (lastOSI < 0 || lastOSI != curObLoc)
		{
			if (lastOSI < 0)
				fputc( 'L', optr);
			else if (lastOSI > 0)
				fprintf(optr,"R\rL L LLL");
			for (i = 0; i <= 3; ++i) fputc(objrec[i],optr);
			lastOSI = curObLoc;
		}
		for (i=4; i < objptr; i++) {
			fputc(objrec[i],optr);
			if ((i & 1) != 0) {
			//	fputc( 0x20, optr);
				lastOSI++;
			}
			
		}

	}
	else
	{
		if (lastOSI < 0 || lastOSI != curObLoc)
		{
			fputc( '.', optr);
			for (i = 0; i <= 3; ++i) fputc(objrec[i],optr);
			fputc( '/', optr);
			lastOSI = curObLoc;
		}
		for (i=4; i < objptr; i++) {
			fputc(objrec[i],optr);
			if ((i & 1) != 0) {
				fputc( 0x0D, optr);
				lastOSI++;
			}
			
		}


	}
	reccnt++;
}

/*********************************************************************/

/* start an object record (end previous) */

void startobj(void)
{
	prtobj();	/* print the current record if any */
	hexcon(4,objloc);
	curObLoc = objloc;
	objbytes=0;
	for (objptr=0; objptr<4; objptr++)
		objrec[objptr] = hex[objptr+1];
	cksum = (objloc>>8) + (objloc & 0xff);
	if (mflag == 0) objcnt = 16;
	else objcnt = 24;
}

/*********************************************************************/

/* finish object file */

void finobj(void)
{
	unsigned i, j;

	prtobj();
	if (mflag == 0)		/* INTEL */
		fprintf(optr,":00000001FF");
	else if (mflag == 1) {	 /* MOS */
		hexcon(4,reccnt);
		fprintf(optr,";00");
		for (j=1; j<3; j++)
			for (i=1; i<5; i++) fputc(hex[i],optr);
		if (goloc >= 0)
		{
			fprintf(optr,"\r\n$%04X",goloc);
			return;  //no EOL
		}
	}
	else if (mflag == 2) /* OSI65V */
	{
		if (goloc >= 0)
		{
			fprintf(optr,".%04XG",goloc);
			return;	 //no EOL
		}
	}
	else if (mflag == 3) /* OSI 65A */
	{
		if (goloc >= 0)
		{	//multiple L to delay and resync port after R[eset]
			fprintf(optr,"R\rL L LL012900000004FD%02X%02XRGGGG",((goloc >> 8) & 0xFF), (goloc & 0xFF));
		}
		else
			fprintf(optr,"R\r");
		return; //no more output


	}
	fprintf(optr,"\r\n");
}

/*********************************************************************/

/* closes the source, object and stdout files */

void wrapup(void)
{
	fclose(iptr); /* close source file */

	if (pass == DONE) {
		if ((lstflag != 0) && (lptr != 0) && (cflag == 0)) {
			fclose(lptr);
		}

		if ((oflag != 0) && (optr != 0)) {
			finobj();
			fclose(optr);
		}

		if ((bflag != 0) && (bptr != 0)) {
			fclose(bptr);
		}
	}
	return;
}

/*********************************************************************/

/* prints the symbol page heading */

void prsymhead(void)
{
	if (pagesize == 0) return;
	pagect++ ;
	fprintf(lptr, "\f\nPage %-5d  %s\n",pagect,titlbuf);
	fprintf(lptr, "\nSymbol            Value Line  References\n\n");
	paglin = 0;
}

/*********************************************************************/

/* prints the contents of prlnbuf */

void prsyline(void)
{
	if (paglin >= pagesize) prsymhead();
	prlnbuf[linesize] = '\0';
	fprintf(lptr, "%s\n", prlnbuf);
	paglin++ ;
	clrlin();
}

/*********************************************************************/

/* prints the page heading */

void printhead(void)
{
	if (pagesize == 0) return;
	pagect++ ;
	fprintf(lptr, "\f\nPage %-5d  %s\n",pagect,titlbuf);
	fprintf(lptr, "\nLine#  Loc   Code      Line\n\n");
	paglin = 0;
}

/*********************************************************************/

/* prints the contents of prlnbuf */

void println(void)
{
	char	c;

	if (lflag != 0 && lptr != 0 ) {
		if (paglin >= pagesize) printhead();
		c = prlnbuf[linesize];
		prlnbuf[linesize] = '\0';
		fprintf(lptr, "%s\n", prlnbuf);
		prlnbuf[linesize] = c;
		paglin++ ;
	}
}

/*********************************************************************/

/* error printing routine */

void msg(char *s1, char *s2)
{
	println();
	if (lflag != 0 && lptr != 0 ) {
		if (paglin >= pagesize) printhead();
		fprintf(lptr, "*%s* %s\n", s1, s2);
		paglin++ ;
	}
	fprintf(stdout, "%s\n", prlnbuf);
	fprintf(stdout, "*%s* %s\n", s1, s2);
}

void error(char *stptr)
{
	errcnt++;
	msg("Error", stptr);
}

void warn(char *stptr)
{
	warncnt++;
	if (qflag == 0)	msg("Warning", stptr);
}

/*********************************************************************/

/* common messages */

void badopcode(void)
{ error("Invalid operation code"); }

void badadmode(void)
{ error("Invalid addressing mode"); }

void divzero(void)
{ error("Divide by zero"); }

void badoperand(void)
{ error("Invalid operand field"); }

void undefsym(void)
{ error("Undefined symbol in operand field"); }

void fullsymtbl(void)
{ error("Symbol table full"); }

void nesterr(void)
{ error("Nesting error"); }

/*********************************************************************/

/* load 16 bit value in printable form into prlnbuf */

void loadlc(int val, int f)
{
	int	i;

	i = 7 + 6*f; /* start pos */
	hexcon(4, val);
	prlnbuf[i++] = hex[1];
	prlnbuf[i++] = hex[2];
	prlnbuf[i++] = hex[3];
	prlnbuf[i] = hex[4];
}

/*********************************************************************/

/* collects a symbol from prlnbuf into symbol[], leaves prlnbuf pointer
   at first invalid symbol character, returns 0 if no symbol collected */

int colsym(int *ip)
{
	int	valid;
	int	i;
	char	ch;

	valid = 1;
	i = 0;
	while (valid == 1) {
		ch = prlnbuf[*ip];
		ch = toupper(ch);
		if (ch == '_' && i != 0);
		else if (ch >= 'a' && ch <= 'z');
		else if (ch >= 'A' && ch <= 'Z');
		else if (ch >= '0' && ch <= '9' && i != 0);
		else if (ch == ':' && (*ip)++ < 0x21) continue;
		else valid = 0;
		if (valid == 1) {
			if (i < SBOLSZ)
				symbol[++i] = ch;
			(*ip)++;
		}
	}
	if (i == 1) {
		switch (symbol[1]) {
		case 'A': case 'a':
		case 'S': case 's':
		case 'P': case 'p':
		case 'X': case 'x':
		case 'Y': case 'y':
			error("Symbol is reserved (A,X,Y,S,P)");
			i = 0;
		}
	}
	symbol[0] = i;
	return(i);
}

/*********************************************************************/

/* open up a space in the symbol table. the space will be at (ptr)
   and will be len characters long. return -1 if no room. */

int openspc(int ptr, int len)
{
	int	ptr2, ptr3;
	if (nxt_free + len > size) return -1;
	if (ptr != nxt_free) {
		ptr2 = nxt_free -1;
		ptr3 = ptr2 + len;
		while (ptr2 >= ptr) symtab[ptr3--] = symtab[ptr2--];
	}
	nxt_free += len;
	if (lablptr >= ptr) lablptr += len;
	return 0;
}

/*********************************************************************/

/* install symbol into symtab */

int stinstal(int ptr)
{
	int	ptr2, i;

	if (openspc(ptr,symbol[0]+7) == -1) {
		fullsymtbl();	/* print error msg and ...  */
		pass = DONE;	/* cause termination of assembly */
		return -1;
	}
	ptr2 = ptr;
	for (i=0; i< symbol[0]+1; i++)
		symtab[ptr2++] = symbol[i];
	symtab[ptr2++] = udtype;
	symtab[ptr2+4] = 0;
	return(ptr);
}

/*********************************************************************/

/* symbol table lookup, if found, return pointer to symbol else,
   install symbol as undefined, and return pointer */

int stlook(void)
{
	int ptr, ln, eq;
	ptr = 0;
	while (ptr < nxt_free) {
		ln = symbol[0]; if (symtab[ptr] < ln) ln = symtab[ptr];
		if ((eq = strncmp((const char *)&symtab[ptr+1], &symbol[1], ln)) == 0 &&
		symtab[ptr] == symbol[0]) return ptr;
		if (eq > 0) return(stinstal(ptr));
		ptr = ptr+6+ symtab[ptr];
		ptr = ptr +1 + 2*(symtab[ptr] & 0xff);
	}
return (stinstal(ptr));
}

/*********************************************************************/

/* add a reference line to the symbol pointed to by ip. */

void addref(int ip)
{
	int	rct, ptr;

	rct = ptr =ip + symtab[ip] + 6;
	if ((symtab[rct] & 0xff) == 255) {	/* limit to 255 lines */
		return;				/* not an error */
	}
	ptr += (symtab[rct] & 0xff) * 2 +1;
	if (openspc(ptr,2) == -1) {
		fullsymtbl();
		return;
	}
	symtab[ptr] = slnum & 0xff;
	symtab[ptr+1] = (slnum >> 8) & 0xff;
	symtab[rct]++;
}

/*********************************************************************/

/* operation code table lookup if found, return pointer to symbol,
   else return -1 */

int oplook(int *ip)
{
register char	ch;
register int	i;
register int	j;
	 int	k;
	 int	temp[3];
	 int	flag;

	i = j = flag = 0;
	temp[0] = temp[1] = 0;
	while((ch = prlnbuf[*ip])!= ' ' && ch!= 0 && ch!= '\t' && ch!= ';') {
		if (flag == 0) {
			if (ch >= 'A' && ch <= 'Z')
				ch &= 0x1f;
			else if (ch >= 'a' && ch <= 'z')
				ch &= 0x1f;
			else if (ch == '.')
				ch = 31;
			else if (ch == '*')
				ch = 30;
			else if (ch == '=')
				ch = 29;
			else return(-1);
			temp[j] = (temp[j] * 0x20) + (ch & 0xff);
			if (ch == 29)
				break;
			/* ++(*ip); */
			if (++i >= 3) {
				i = 0; ++j;
			}
			if ((j > 0) && (i >= 1)) flag = 1;
		}
		++(*ip);
	}
	if ((j = temp[0]^temp[1]) == 0)
		return(-2);
	k = 0;
	i = step[k] - 3;
	do {
		if (j == optab[i]) {
			opflg = optab[++i];
			opval = optab[++i];
			return(i);
		}
		else if (j < optab[i])
			i -= step[++k];
		else i += step[++k];
	} while (step[k] != 0);
	return(-1);
}

/*********************************************************************/

/* assign <value> to label pointed to by lablptr, checking for
   valid definition, etc. */

int labldef(
    int lval,
    int isloc  /* true if label is a location */
)
{
	int	i;

	if (lablptr != -1) {
		lablptr += symtab[lablptr] + 1;
		if (pass == FIRST_PASS) {
			if (symtab[lablptr] == UNDEF) {
				symtab[lablptr + 1] = lval & 0xff;
				i = symtab[lablptr + 2] = (lval >> 8) & 0xff;
				if (i == 0)
					symtab[lablptr] = DEFZRO;
				else	symtab[lablptr] = DEFABS;
			}
			else if (symtab[lablptr] == UNDEFAB) {
				symtab[lablptr] = DEFABS;
				symtab[lablptr + 1] = lval & 0xff;
				symtab[lablptr + 2] = (lval >> 8) & 0xff;
			}
			else {
				symtab[lablptr] = MDEF;
				symtab[lablptr + 1] = 0;
				symtab[lablptr + 2] = 0;
				error("Label multiply defined");
				return(-1);
			}
		symtab[lablptr+3] = slnum & 0xff;
		symtab[lablptr+4] = (slnum >> 8) & 0xff;
		}
		else {
			i = (symtab[lablptr + 2] << 8) +
				(symtab[lablptr+1] & 0xff);
			i &= 0xffff;
			if (i != lval && pass == LAST_PASS) {
				if (isloc) {
					loadlc(loccnt, 0);
					error("Sync error");
					return(-1);
				}
				else {
					loadlc(loccnt, 0);
					warn("Value changed");
					symtab[lablptr + 1] = lval & 0xff;
					symtab[lablptr + 2] = (lval >> 8) & 0xff;
				}
			}
		}
	}
	return(0);
}

/*********************************************************************/

/* determine the value of the symbol, given pointer to first
   character of symbol in symtab */

int symval(int *ip)
{
	int	ptr;
	int	svalue;

	svalue = 0;
	colsym(ip);
	if ((ptr = stlook()) == -1)
		undef = 1;		/* no room error */
	else if (symtab[ptr + symtab[ptr] + 1] == UNDEF)
		undef = 1;
	else if (symtab[ptr + symtab[ptr] + 1] == UNDEFAB)
		undef = 1;
	else svalue = ((symtab[ptr + symtab[ptr] + 3] << 8) +
		(symtab[ptr + symtab[ptr] + 2] & 0xff)) & 0xffff;
	if (symtab[ptr + symtab[ptr] + 1] == DEFABS)
		zpref = 1;
	if (undef != 0)
		zpref = 1;

	/* add a reference entry to symbol table on first pass only,
	   except for branch instructions (CLASS2) which do not come
	   through here on the first pass */
	if (sflag) {
		if (ptr >= 0 && pass == FIRST_PASS) addref(ptr);
		if (ptr >= 0 && opflg == CLASS2) addref(ptr); /* branch addresses */
	}
	return(svalue);
}

/*********************************************************************/

/* collect number operand */

int colnum(int *ip)
{
	int	mul = 0;
	int	nval;
	char	ch;

	nval = 0;
	if ((ch = prlnbuf[*ip]) == '$')
		mul = 16;
	else if (ch >= '0' && ch <= '9') {
		mul = 10;
		nval = ch - '0';
	}
	else if (ch == '@')
		mul = 8;
	else if (ch == '%')
		mul = 2;
	while ((ch = prlnbuf[++(*ip)] - '0') >= 0) {
		if (ch > 9) {
			ch -= ('A' - '9' - 1);
			if (ch > 15)
				ch -= ('a' - 'A');
			if (ch > 15)
				break;
			if (ch < 10)
				break;
		}
		if (ch >= mul)
			break;
		nval = (nval * mul) + ch;
	}
	return(nval);
}

/*********************************************************************/

/* evaluate expression */

int evaluate(int *ip)
{
	int	tvalue;
	int	invalid;
	int	parflg, value2 = 0;
	char	ch;
	char	op;
	char	op2;

	islflg = 0;

	op = '+';
	parflg = zpref = undef = value = invalid = 0;

/* hcj: zpref should reflect the value of the expression, not the value of
   the intermediate symbols */

	while ((ch = prlnbuf[*ip]) != ' ' && ch != ')' && ch != ',' && ch != ';') {
		tvalue = 0;
		if (ch == '$' || ch == '@' || ch == '%')
			tvalue = colnum(ip);
		else if (ch >= '0' && ch <= '9')
			tvalue = colnum(ip);
		else if (ch >= 'a' && ch <= 'z')
			tvalue = symval(ip);
		else if (ch >= 'A' && ch <= 'Z')
			tvalue = symval(ip);
		else if (ch == '_')
			tvalue = symval(ip);
		else if (ch == '*') {
			tvalue = loccnt;
			++(*ip);
			++islflg;
		}
		else if (ch == '\'') {
			++(*ip);
			tvalue = prlnbuf[*ip] & 0xff;
			++(*ip);
			if (prlnbuf[*ip] == '\'') ++(*ip);
		}
		else if (ch == '[') {
			if (parflg == 1) {
				error("Too many [ in expression");
				invalid++;
			}
			else {
				value2 = value;
				op2 = op;
				value = tvalue = 0;
				op = '+';
				parflg = 1;
			}
			goto next;
		}
		else if (ch == ']') {
			if (parflg == 0) {
				error("Missing [ in expression");
				invalid++;
			}
			else {
				parflg = 0;
				tvalue = value;
				value = value2;
				op = op2;
			}
			++(*ip);
		}
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmaybe-uninitialized"
		switch(op) {
#pragma GCC diagnostic pop
		case '+':
			value += tvalue;
			break;
		case '-':
			value -= tvalue;
			break;
		case '/':
			if (tvalue == 0) {
				divzero();
				value = 0; break;
			}
			value = (unsigned) value/tvalue;
			break;
		case '*':
			value *= tvalue;
			break;
		case '%':
			if (tvalue == 0) {
				divzero();
				value = 0; break;
			}
			value = (unsigned) value%tvalue;
			break;
		case '^':
			value ^= tvalue;
			break;
		case '~':
			value = ~tvalue;
			break;
		case '&':
			value &= tvalue;
			break;
		case '|':
			value |= tvalue;
			break;
		case '>':
			tvalue >>= 8;		/* fall through to '<' */
		case '<':
			if (value != 0) {
				error("High/low byte operator misplaced");
			}
			value = tvalue & 0xff;
			zpref = 0;
			break;

		case '!':			/* Force absolute addressing */
			value = tvalue;
                        zpref = 0;
                        opflg &= (ABS|ABSX|ABSY|ABSY2|IND|IMM1|IMM2);
			break;
		default:
			invalid++;
		}
		if ((op=prlnbuf[*ip]) == ' '
				|| op == ')'
				|| op == ','
				|| op == ';')
			break;
		else if (op != ']')
next:			++(*ip);
	}
	if (parflg == 1) {
		error("Missing ] in expression");
		return(1);
	}
	if (value < 0 || value >= 256) {
		zpref = 1;
	}
	if (undef != 0) {
		if (pass != FIRST_PASS) {
			loadlc(loccnt, 0);
			undefsym();
			invalid++;
		}
		value = 0;
	}
	else if (invalid != 0)
	{
		badoperand();
	}
	else { /* This is the only way out that may not signal error */
		if (value < 0 || value >= 256)
			zpref = 1;
		else
			zpref = 0;
	}
	return(invalid);
}

/*********************************************************************/

/* load value in hex into prlnbuf[contents[i]] and output
   hex characters to obuf if LAST_PASS & oflag == 1 */

void loadv(
    int val,
    int f,		/* contents field subscript */
    int outflg		/* flag to output object bytes */
)
{
	long	pos;

	hexcon(2, val);
	prlnbuf[13 + 3*f] = hex[1];
	prlnbuf[14 + 3*f] = hex[2];
	if ((pass == LAST_PASS) && (outflg != 0)) {
		if (oflag != 0) {
			if (objcnt == 0) startobj();
			putobj(val);
			objcnt--;
			objloc++;
		}
		if (bflag != 0)
		{
			if (cbflag == 0)
			{ /* cbase not yet set */
				cbase = lastloc;
				/* fprintf(stdout,"\nCBASE:%x\n",cbase); */
				cbflag++;
			}
			if ((locflag) && (cbflag))
			{ /* location changed */
				if (lastloc < cbase)
				{
					error("Invalid binary reposition");
				}
				else
				{
					pos = lastloc-cbase;
					/* fprintf(stdout,"\nLOC:%x CBASE:%x POS:%x\n",lastloc,cbase,pos); */
					fseek(bptr,(pos),SEEK_SET);
				}
				locflag = 0;
			}
			fputc(val,bptr);	/* output byte */
		}
	}
}

/*********************************************************************/

/* machine operations processor - 1 byte, no operand field */

void class1(void)
{
	switch (opval) {
	case 0x1a:  /* INA */
	case 0x3a:  /* DEA */
	case 0x5a:  /* PHY */
	case 0x7a:  /* PLY */
	case 0xda:  /* PHX */
	case 0xfa:  /* PLX */
		if (cmos == 0) badopcode();
	}
	if (pass == LAST_PASS) {
		loadlc(loccnt, 0);
		loadv(opval, 0, 1);
		println();
	}
	loccnt++;
}

/*********************************************************************/

/* machine operations processor - 2 byte, relative addressing */

void class2(int *ip)
{
	if (opval == 0x80 && cmos == 0) badopcode();  /* BRA */
	if (pass == LAST_PASS) {
		loadlc(loccnt, 0);
		loadv(opval, 0, 1);
		while (prlnbuf[++(*ip)] == ' ');
		if (evaluate(ip) != 0) {
			loccnt += 2;
			return;
		}
		loccnt += 2;
		value -= loccnt;
		loadv(value, 1, 1);
		if (value >= -128 && value < 128)
			println();
		else
			error("Invalid branch address");
	}
	else loccnt += 2;
}

/*********************************************************************/

/* machine operations processor - various addressing modes */

void class3(int *ip)
{
	char	ch;
	int	code = 0;
	int	flag =0;
	int	i = 0;
	int	ztmask = 0;

	while ((ch = prlnbuf[++(*ip)]) == ' ');
	switch(ch) {
	case 0:
	case ';':
		if (opval == 0x02 || opval == 0x22 || opval == 0x42 || opval == 0x62) {
			flag = ACC;	 /* Assume ACC for LRS, ASL, ROL, ROR w/ no arg */
			break;
		}
		error("Operand field missing");
		return;
	case 'A':
	case 'a':
		if ((ch = prlnbuf[*ip + 1]) == ' ' || ch == ';' || ch == 0) {
			flag = ACC;
			break;
		}
	default:
		switch(ch = prlnbuf[*ip]) {
		case '#':
			flag = IMM1|IMM2;
			++(*ip);
			break;
		case '(':
			flag = IND|INDX|INDY;
			++(*ip);
			break;
		default:
			flag = ABS|ZER|ZERX|ABSX|ABSY|ABSY2|ZERY;
		}
		if ((flag & (INDX|INDY|ZER|ZERX|ZERY) & opflg) != 0)
			udtype = UNDEFAB;
		if (evaluate(ip) != 0)
			return;
		if (zpref != 0) {
			flag &= (ABS|ABSX|ABSY|ABSY2|IND|IMM1|IMM2);
			ztmask = 0;
		}
		else ztmask = ZER|ZERX|ZERY;
		code = 0;
		i = 0;
		while (( ch = prlnbuf[(*ip)++]) != ' ' && ch != ';' && ch != 0 && i++ < 4) {
			code *= 8;
			switch(toupper(ch)) {
			case ')':		/* ) = 4 */
				++code;
			case ',':		/* , = 3 */
				++code;
			case 'X':		/* X = 2 */
				++code;
			case 'Y':		/* Y = 1 */
				++code;
				break;
			default:
				flag = 0;
			}
		}
		switch(code) {
		case 0:		/* no termination characters */
			flag &= (ABS|ZER|IMM1|IMM2);
			break;
		case 4:		/* termination = ) */
			if (opval != 0x40 && ((flag & IND) == IND)) {
				if (zpref == 1) flag=0 ; /* fail it */
				else {	  /* (zp)Mode */
				flag = ZER;
				opval += 13;
				}
				break;
			}
			flag &= IND;
			break;
		case 25:	/* termination = ,Y */
			flag &= (ABSY|ABSY2|ZERY);
			break;
		case 26:	/* termination = ,X */
			flag &= (ABSX|ZERX);
			break;
		case 212:	/* termination = ,X) */
			if (opval == 0x40 && zpref == 1) {  /* JMP (abs,X) */
				if (cmos == 0) goto badmode;
				flag &= IND;
				opval = 0x50;
				break;
			}
			flag &= INDX;
			break;
		case 281:	/* termination = ),Y */
			flag &= INDY;
			break;
		default:
			flag = 0;
		}
	}
	if ((opflg &= flag) == 0) {
		loadlc(loccnt, 0);
		goto badmode;
	}
	if ((opflg & ztmask) != 0)
		opflg &= ztmask;
	switch(opflg) {
	case ACC:		/* single byte - class 3 */
		if (opval == 0xc2 || opval == 0xe2) {  /* DEC A  INC A */
			opval ^= 0xf0;
			if (cmos == 0) goto badmode;
		}
		if (pass == LAST_PASS) {
			loadlc(loccnt, 0);
			loadv(opval + 8, 0, 1);
			println();
		}
		loccnt++;
		return;
	case ZERX:	/* double byte - class 3 */
		if (cmos == 0) {
			if (opval == 0x20) goto badmode;  /* BIT zp,X */
			if (opval == 0x60) goto badopc;   /* STZ zp,X */
		}
	case ZERY:
		opval += 4;
	case INDY:
		opval += 8;
	case IMM2:
		if (opval == 0x20) {  /* BIT # */
			if (cmos == 0) goto badmode;
			opval = 0x81;
		}
		opval += 4;
	case ZER:
		if (cmos == 0) {
			switch(opval) {
			case 0x00:  /* TSB */
			case 0x10:  /* TRB */
			case 0x60:  /* STZ */
				goto badopc;
			case 0x0e:  /* ORA */
			case 0x2e:  /* AND */
			case 0x4e:  /* EOR */
			case 0x6e:  /* ADC */
			case 0x8e:  /* STA */
			case 0xae:  /* LDA */
			case 0xce:  /* CMP */
			case 0xee:  /* SBC */
				goto badmode;
			}
		}
		opval += 4;
	case INDX: case IMM1:
		if (pass == LAST_PASS) {
			loadlc(loccnt, 0);
			loadv(opval, 0, 1);
			loadv(value, 1, 1);
			println();
		}
		loccnt += 2;
		return;
	case IND:		/* triple byte - class 3 */
		opval += 16;
	case ABSX:
		if (opflg == ABSX)
                	if (opval == 0x60) {  /* STZ abs,X */
                		if (cmos == 0) goto badopc;
                		opval = 0x82;
                	}
                if (opval == 0x20) {  /* BIT abs,X */
                	if (cmos == 0) goto badmode;
		}
	case ABSY2:
		opval += 4;
	case ABSY:
		opval += 12;
	case ABS:
		if (opflg == ABS) {
			switch(opval) {
			case 0x60:  /* STZ abs */
				opval=0x90;
			case 0x00:  /* TSB abs */
			case 0x10:  /* TRB abs */
				if (cmos == 0) goto badopc;
			}
		}
		if (pass == LAST_PASS) {
			opval += 12;
			loadlc(loccnt, 0);
			loadv(opval, 0, 1);
			loadv(value, 1, 1);
			loadv(value >> 8, 2, 1);
			println();
		}
		loccnt += 3;
		return;
	default: {
badmode:		badadmode();
			return;
badopc:			badopcode();
			return;
		}
	}
}

/*********************************************************************/

/* location counter has changed */

void newlc(unsigned val)
{
	if (val == loccnt) return;
	if (pass == LAST_PASS) {
		if (oflag != 0) { /* start new record */
			objloc = val;
			startobj();
		}
	}
	loccnt = lastloc = val;
	locflag++;
}

/*********************************************************************/

/* pseudo operations processor */

void pseudo(int *ip)
{
	int	count;
	int	i,j;
	int	tvalue;
	int	quote;
	int	ch;

	switch(opval) {
	case 0:					/* .BYTE pseudo */
		labldef(loccnt, 1);
		loadlc(loccnt, 0);
		count = quote = 0;
		while (prlnbuf[++(*ip)] == ' ');
		do {
			while ((ch = prlnbuf[(*ip)]) == ' ') ++(*ip);
			if (ch == ';' || ch == 0) {
				badoperand();
				return;
			}
			if (ch == '\'') {
				++quote;
				while (quote != 0) {
					tvalue = prlnbuf[++(*ip)];
					if (tvalue == 0) {
						error("Unterminated ASCII string");
						return;
					}
					if (tvalue == '\'') {
						if ((tvalue = prlnbuf[++(*ip)]) != '\'') {
							quote = 0;
							--(*ip);
							goto done1;
						}
					}
					loccnt++;
					if (pass == LAST_PASS) {
						loadv(tvalue, count, 1);
						if (++count >= 3) {
							println();
							for (i = 0; i < SFIELD; i++)
								prlnbuf[i] = ' ';
							prlnbuf[i] = 0;
							loadlc(loccnt, 0);
							count = 0;
						}
					}
					done1:;
				}
				++(*ip);
			}
			else if (ch == '\"') {
				++quote;
				while (quote != 0) {
					tvalue = prlnbuf[++(*ip)];
					if (tvalue == 0) {
						error("Unterminated ASCII string");
						return;
					}
					if (tvalue == '\"') {
						if ((tvalue = prlnbuf[++(*ip)]) != '\"') {
							quote = 0;
							--(*ip);
							goto done1q;
						}
					}
					loccnt++;
					if (pass == LAST_PASS) {
						loadv(tvalue, count, 1);
						if (++count >= 3) {
							println();
							for (i = 0; i < SFIELD; i++)
								prlnbuf[i] = ' ';
							prlnbuf[i] = 0;
							loadlc(loccnt, 0);
							count = 0;
						}
					}
					done1q:;
				}
				++(*ip);
			}

			else {
				if (evaluate(ip) != 0) {
					loccnt++;
					return;
				}
				loccnt++;
				if (value > 0xff) {
					error("Operand field size error");
					return;
				}
				else if (pass == LAST_PASS) {
					loadv(value, count, 1);
					if (++count >= 3) {
						println();
						for (i = 0; i < SFIELD; i++)
							prlnbuf[i] = ' ';
						prlnbuf[i] = 0;
						count = 0;
						loadlc(loccnt, 0);
					}
				}
			}
		} while ((ch = prlnbuf[(*ip)++]) == ',');
		if (ch != ' ' && ch != ';' && ch != 0) {
			badoperand();
			return;
		}
		if ((pass == LAST_PASS) && (count != 0))
			println();
		return;
	case 1:					/* = pseudo*/
		while (prlnbuf[++(*ip)] == ' ');
		if (evaluate(ip) != 0)
			return;
		labldef(value, islflg);
		if (pass == LAST_PASS) {
			loadlc(value, 0);
			println();
		}
		return;
	case 13:				/* .DWORD pseudo */
	case 2:					/* .WORD pseudo */
		labldef(loccnt, 1);
		loadlc(loccnt, 0);
		while (prlnbuf[++(*ip)] == ' ');
		do {
			while ((ch = prlnbuf[(*ip)]) == ' ') ++(*ip);
			if (ch == ';' || ch == 0) {
				badoperand();
				return;
			}
			if (evaluate(ip) != 0) {
				loccnt += 2;
				if (opval == 13)
					loccnt += 2;
				return;
			}
			loccnt += 2;
			if (opval == 13)
				loccnt += 2;
			if (pass == LAST_PASS) {
				loadv(value, 0, 1);
				loadv(value>>8, 1, 1);
				if (opval == 13)
				{
					loadv(value>>16, 2, 1);
					loadv(value>>24, 3, 1);
				}
				println();
				for (i = 0; i < SFIELD; i++)
					prlnbuf[i] = ' ';
				prlnbuf[i] = 0;
				loadlc(loccnt, 0);

			}
		} while (prlnbuf[(*ip)++] == ',');
		return;
	case 12:				/* .ORG */
		while (prlnbuf[++(*ip)] == ' ');
                if (evaluate(ip) != 0)
                	return;
                if (undef != 0) {
                	undefsym();
                	return;
                }
                tvalue = value;
		newlc(value);
		labldef(tvalue, 0);
		if (pass == LAST_PASS) {
			loadlc(tvalue, 0);
			println();
		}
		return;
	case 3:					/* *= pseudo */
		while (prlnbuf[++(*ip)] == ' ');
		if (prlnbuf[*ip] == '*') {
			if (evaluate(ip) != 0)
				return;
			if (undef != 0) {
				undefsym();
				return;
			}
			tvalue = loccnt;
		}
		else {
			if (evaluate(ip) != 0)
				return;
			if (undef != 0) {
				undefsym();
				return;
			}
			tvalue = value;
		}
		newlc(value);
		labldef(tvalue, 0);
		if (pass == LAST_PASS) {
			loadlc(tvalue, 0);
			println();
		}
		return;
	case 4:					/* .END pseudo */
		if (sptr)
		{
			//if in .lib file, return to main
			iptr = sptr;
			sptr = NULL;
			return;
		}
		labldef(loccnt, 1);
		loadlc(loccnt, 0);

		if (pass == LAST_PASS) println();
		endflag = 1;
		return;
	case 5:					/* .OPT pseudo */
		while (prlnbuf[++(*ip)] == ' ');
		do {
			i = 0; j = 1;
			while ((ch = prlnbuf[*ip]) != ' ' && ch != ',' && ch != ';' && ch != '\0') {
				if (i < 3) { /* hash string */
					j = j * (toupper(ch) & 0x1f);
					++i;
				}
				++(*ip);
			}
			switch (j) {
			case 0x1ea:	/* GEN */
				gflag = 1;
				break;
			case 0x249:	/* CMO */
				cmos = 1;
				break;
			case 0x276:	/* NOC */
				cmos = 0;
				break;
			case 0x41a:	/* NOE */
				eflag = 0;
				break;
		 	case 0x5be:	/* NOG */
				gflag = 0;
				break;
		 	case 0x654:	/* ERR */
				eflag = 1;
				break;
		 	case 0x804:	/* LIS */
				lflag = lstflag = 1;
				break;
		 	case 0x9d8:	/* NOL */
				lflag = 0;
				break;
		 	case 0xf96:	/* NOS */
				sflag = 0;
				break;
		 	case 0x181f:	/* SYM */
				sflag = 1;
				break;
			default:
				error("Invalid option");
				return ;
			}
		} while (prlnbuf[(*ip)++] == ',');
		return;
	case 6:					/* .DBYTE pseudo */
		labldef(loccnt, 1);
		loadlc(loccnt, 0);
		while (prlnbuf[++(*ip)] == ' ');
		do {
			while ((ch = prlnbuf[(*ip)]) == ' ') ++(*ip);
			if (ch == ';' || ch == 0) {
				badoperand();
				return;
			}
			if (evaluate(ip) != 0) {
				loccnt += 2;
				return;
			}
			loccnt += 2;
			if (pass == LAST_PASS) {
				loadv(value>>8, 0, 1);
				loadv(value, 1, 1);
				println();
				for (i = 0; i < SFIELD; i++)
					prlnbuf[i] = ' ';
				prlnbuf[i] = 0;
				loadlc(loccnt, 0);
			}
		} while (prlnbuf[(*ip)++] == ',');
		return;
	case 7:					/* .PAGE pseudo */
		if (pagesize == 0) return;
		while (prlnbuf[++(*ip)] == ' ');
		if (prlnbuf[(*ip)] == '\'') {
			i = quote = 0;
			++quote;
			while (quote != 0) {
				tvalue = prlnbuf[++(*ip)];
				if (tvalue == 0) {
					error("Unterminated ASCII string");
					return;
				}
				if (tvalue == '\'') {
					if ((tvalue = prlnbuf[++(*ip)]) != '\'') {
						/* quote = 0; */
						--(*ip);
						goto done2;
					}
				}
				if (i < titlesize) {
					titlbuf[i++] = tvalue;
				}
			}
			done2:;
			titlbuf[i]='\0';
		}
		if ((lflag != 0) && (pass == LAST_PASS)) printhead();
		return;
	case 8:					/* .SKIP pseudo */
	/* unimplemented directives which are non-fatal */
		if (pass == LAST_PASS) {
			warn("Not implemented");
		}
		return;
	case 9:					/* .IFE pseudo */
		while (prlnbuf[++(*ip)] == ' ');
		if (evaluate(ip) != 0)
			return;
		while (prlnbuf[++(*ip)] == ' ');
		if (prlnbuf[*ip] != '<') {
			badoperand();
			return;
		}
		if (tlevel < MAXIF) {
			iflvl[++tlevel] = flevel;
			if (value != 0) ++flevel;
		} else nesterr();
		if (pass == LAST_PASS) {
			loadlc(value, 0);
			println();
		}
		return;
	case 10:				/* .IFN pseudo */
		while (prlnbuf[++(*ip)] == ' ');
		if (evaluate(ip) != 0)
			return;
		while (prlnbuf[++(*ip)] == ' ');
		if (prlnbuf[*ip] != '<') {
			badoperand();
			return;
		}
		if (tlevel < MAXIF) {
			iflvl[++tlevel] = flevel;
			if (value == 0) ++flevel;
		} else nesterr();
		if (pass == LAST_PASS) {
			loadlc(value, 0);
			println();
		}
		return;
	 case 11:               /* .EXE pseudo */
		while (prlnbuf[++(*ip)] == ' ');
		goloc = loccnt;
		if (evaluate(ip) != 0) //allow stand-alone opt or expression
			return;
		loadlc(loccnt, 0);

		goloc = value;
		labldef(value, islflg);
		if (pass == LAST_PASS) {
			loadlc(value, 0);
			println();
		}
		return;
	case 14:               /* .LIB pseudo -insert lib file into current stream*/

	case 15:               /* .FIL pseudo -linked source file, end current source*/
		{
			char *p;
			if (opval == 14 && sptr)
			{
				/* .lib can not contain a .lib, but may contain .fil */
				fprintf(stdout, "Nested .LIB error for file '%s'\n", lname);
				exit(1);
				
			}
			if (!sptr)
			{
				sptr = iptr;
				iptr = NULL;
			}
			if (iptr)
				fclose(iptr);


			p = &lname[0];
			while (prlnbuf[++(*ip)] == ' ');
			if (prlnbuf[(*ip)] == '"') ++(*ip);


			if (prlnbuf[*ip])
			{
				while ((ch = prlnbuf[(*ip)]) && ch != '"')
				{	*p++ = ch;
					++(*ip);
				}
				*p++ = 0;

				if ((iptr = fopen(lname, "r")) == NULL)
				{
					fprintf(stdout, "Open error for file '%s'\n", lname);
					exit(1);
				}
				else
				{
					fprintf(stdout, "Reading file '%s'\n", lname);
				}
			}
			else
			{
			}
		}
		return;
	}
}

/*********************************************************************/

/* init variables */

void initvar(void)
{
	loccnt = lastloc = objloc = 0;	/* location counter */
	slnum = 0;			/* line number */
	errcnt = warncnt = 0;		/* error/warning count */
	reccnt = cksum = 0;		/* hex file variables */
	cbflag = locflag = 0;		/* codebase/location flags */
	flevel = tlevel = iflvl[0] = 0;	/* conditional assembly */
}

/*********************************************************************/

/* symbol table print */

void stprnt(void)
{
	int	i;		/* print line position */
	int	ptr;		/* symbol table position */
	int	j;		/* integer conversion variable */
	int	k;		/* printf buffer pointer */
	int	refct;		/* counter for references */
	char	buf[6];
	paglin = pagesize;
	ptr = 0;
	clrlin();
	while (ptr < nxt_free)
		{
		for (i=0; i < symtab[ptr]; i++) prlnbuf[i] = symtab[ptr+i+1];

		ptr += i+2; i=18;         /* symbol value */
		j = symtab[ptr++] & 0xff;
		j += (symtab[ptr++] << 8);
		hexcon(4,j);
		for (k=1; k<5; k++) prlnbuf[i++] = hex[k];
		j = symtab[ptr++] & 0xff;
		j += (symtab[ptr++] << 8);
		sprintf(buf,"%d",j);

		k=0;i=24;		/* line number */
		while (buf[k] != '\0') prlnbuf[i++] = buf[k++];

		k=0;i=30;		/* count of references    */
		refct = symtab[ptr++] & 0xff;
		sprintf(buf,"(%d)",refct);

		while (buf[k] != '\0') prlnbuf[i++] = buf[k++];
		i++;			/* and all the references   */
		while (refct > 0)
			{
			j = symtab[ptr++] & 0xff;
			j += (symtab[ptr++] << 8);
			sprintf(buf,"%d",j);
			k=0;
			while (buf[k] != '\0') prlnbuf[i++] = buf[k++];
			i++;
			refct--;
			if ( i > linesize-5 && refct > 0) {
				prlnbuf[i] = '\0';
				prsyline(); i=30+4; }
			}
		prlnbuf[i] = '\0';
		prsyline();
		}
}

/*********************************************************************/

/* translate source line to machine language */

void assemble(void)
{
	int	flg;
	int	i;	/* prlnbuf pointer */
	int	tmp;

	if (prlnbuf[SFIELD] == '>') {
		if (tlevel)
			flevel = iflvl[tlevel--];
		else nesterr();
		if (pass == LAST_PASS)
			println();
		return;
	}

	if (flevel) {
		i=SFIELD;
		while (prlnbuf[i] == ' ') i++;
		if ((flg = oplook(&i)) < 0)
			return;
		if ((opflg == PSEUDO) && ((opval == 9) || (opval == 10))) {
			pseudo(&i);
		}
		return;
	}

	if ((prlnbuf[SFIELD] == ';') || (prlnbuf[SFIELD] == 0)) {
		if (pass == LAST_PASS)
			println();
		return;
	}

	lablptr = -1;
	i = SFIELD;
	udtype = UNDEF;
	if (colsym(&i) != 0 && (lablptr = stlook()) == -1)
		return;

	while (prlnbuf[i] == ' ') i++;	/* find first non-space */

	/* scan for '* =' */
	if ((prlnbuf[i] == '*') && (prlnbuf[i+1] != '=')) {
		tmp = i;
		i++;
		while (prlnbuf[i] == ' ') i++;
		if (prlnbuf[i] == '=') {
			opflg = PSEUDO; opval = 3;
			goto assemble1;
		}
		else	i = tmp;	/* restore position */
	}

	if ((flg = oplook(&i)) < 0) {	/* collect operation code */
		labldef(loccnt, 1);
		if (flg == -1)
			badopcode();
		if ((flg == -2) && (pass == LAST_PASS)) {
			if (lablptr != -1)
				loadlc(loccnt, 0);
			println();
		}
		return;
	}

assemble1:

	if (opflg == PSEUDO)
		pseudo(&i);
	else if (labldef(loccnt, 1) == -1)
		return;
	else {
		if (opflg == CLASS1)
			class1();
		else if (opflg == CLASS2)
			class2(&i);
		else class3(&i);
	}
}

/*********************************************************************/

/* main */

int main(int argc, char *argv[])
{
	int	i, j;
	int	ac;
	char	**av;

	size = STABSZ;
	pagesize = PAGESIZE;
	linesize = LINESIZE;
	goloc = -1;
	lastOSI = -1;
	curObLoc = -1;

	fprintf(stdout, "\n%s %s  %s\n\n",ptitle,pvers,pdate);
	getargs(argc, argv);	/* parse the command line arguments */
	if (badflag > 0) exit(1);
	if (act == 0) {
		help();		/* if no arg show help */
		exit(1);
	}
	symtab = malloc(size);
	if (symtab == 0) {
		fprintf(stdout,"Symbol table allocation failed - specify smaller size\n");
		exit(2);  }
	memset(symtab, 0, size);
	pagect = 0;
	paglin = pagesize;

	titlesize = linesize-(5+5+2);  /* allow for page number field */
	for (i=0; i<titlesize; i++) titlbuf[i] = ' ';
	titlbuf[titlesize] = '\0';

	for (i=0; (unsigned) i<strlen(ptitle); i++) titlbuf[i] = ptitle[i];
	j = i + 1;
	for (i=0; (unsigned) i<strlen(pvers); i++) titlbuf[i+j] = pvers[i];
/*	j = i + j + 2;
	for (i=0; (unsigned) i<strlen(pdate); i++) titlbuf[i+j] = pdate[i];
*/
	titlbuf[i+j] = '\0';

	ac = act;
	av = avt;
	pass = FIRST_PASS;
	initvar();
	gflag = eflag = 1;
	while (pass != DONE) {
		initialize(ac, av, act);
		fprintf(stdout,"Pass %d %s\n",pass+1,fname);
		endflag = 0;
		if(pass == LAST_PASS && ac == act)
			initvar();
		/* lower level routines can terminate assembly by setting
		   pass = DONE  ('symbol table full' does this) */
		while (readline() != -1 && pass != DONE && endflag == 0)
			assemble(); /* rest of assembler executes from here */
		if (errcnt != 0) {
			pass = DONE;
		}
		switch (pass) {
		case FIRST_PASS:
			--ac;
			++av;
			if (ac == 0){
				pass = LAST_PASS;
				/* if (lflag == 0)
					lflag++; */
				ac = act;
				av = avt;
			}
			break;
		case LAST_PASS:
			--ac;
			++av;
			if (ac == 0) {
				pass = DONE;
				if ((sflag != 0) && (lstflag != 0)) {
					if ((paglin < pagesize) || (pagesize == 0))
						fprintf(lptr, "\n");
					stprnt();
				}
			}
		}
	}

	if (tlevel)
		nesterr();

	if (lptr != 0) {
		fprintf(lptr,"\nErrors   = %d\n", errcnt);
		if (qflag == 0) fprintf(lptr,"Warnings = %d\n", warncnt);
	}
	if (cflag == 0) {
		fprintf(stdout,"\nErrors   = %d\n", errcnt);
		if (qflag == 0) fprintf(stdout,"Warnings = %d\n", warncnt);
	}
	wrapup();
	free(symtab);
	fclose(stdout);
	return(0);
}

/*********************************************************************/

/* Details of hex object files

(all data is in ASCII encoded hexadecimal)

INTEL
-----
 Data record : :nnaaaattdddd...xx[cr]
 Last record : :00ssssttxx[cr]

 Where:
	:	= Start of record (ASCII 3A)
	nn	= Number of data bytes in the record (max = 16 bytes).
	aaaa	= address of first data byte in the record.
	tt	= record type: 00 for data, 01 for ending record.
	dd	= 1 data byte.
	xx	= checksum byte which when added the sum of all the
		  previous bytes in this record gives zero (mod 256).
	ssss	= optional start address; also signifies end-of-file.
	[cr]	= ASCII end-of-line sequence (CR,LF).


MOS Technology
--------------
 Data record : ;nnaaaadddd...xxxx[cr]
 Last record : ;00ccccxxxx[cr]
 Start execution: $aaaa

 Where:
	;	= Start of record (ASCII 3B)
	nn	= Number of data bytes in the record (max = 24 bytes).
	aaaa	= address of first data byte in the record.
	dd	= 1 data byte.
	xxxx	= checksum that is the twos compliment sum of all
		  data bytes, the count byte and the address bytes.
	cccc	= count of records in the file (not including the
		  last record).
	[cr]	= ASCII end-of-line sequence (CR,LF).

     $aaaa  = specifiy execution address

OSI 65V lod format
------------------
Specify Address Mode '.aaaa' followed by 4 hex digit address
Specify Data Mode '/dd<CR>' where dd is 2 hex data plus <CR> to advance to next position
Specify Start of Execution '.aaaaG' where a is 4 digit hex address
  example  .L0222/A9<cr>20<cr>60.0222G

OSI 65A format
-------------------
65A monitor commands
 R - reset
 L - load mode followed by <2 Byte Address in hex><data as hex>, R to exit
 P - print mode followed by <2 Byte Address in hex> dump data at address, Any key to exit
 G - go with $012D=K, $012A=X, $0129=Y, $012B=A, addr=($012F lo,$012E hi)
     via RTI Note that unlike RTS, RTI does NOT add one to the destination before placing
     it in the Program Counter (PC)
 0-9,A-F hex digit

 Lxxxx
 00 11 22 33 44 55 66 77
 88 99 AA BB CC DD EE FF
 R
 L0120


*/
