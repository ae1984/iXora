/* ballst.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/


{global.i}
def shared var aaa like aaa.aaa.
def shared frame aaacif.
def shared var l as char form "x(12)" extent 8.
def shared var a like aaa.cbal extent 6.
def var fdt as date.
def var tdt as date.
def var bal like aat.bal.
def var vcnt as int.

form "    ACCT-#:" aaa.aaa crc.code to 74
     "     CIF-#:" cif.cif " - " cif.sname
     "     TAX-ID:" to 60 cif.pss format "  XXX-XXX-XXX" skip
     "   ADDRESS:" cif.addr[1] l[1] to 60 a[1] skip
     "           " cif.addr[2] l[2] to 60 a[2] skip
     "           " cif.addr[3] l[3] to 60 a[3] skip
     "     TEL-#:" cif.tel     l[4] to 60 a[4] skip
     l[7] aaa.rate             l[5] to 60 a[5] skip
     with frame aaacif row 1 centered no-label overlay title
     " A C C O U N T    Q U E R Y    W I T H    R U N N I N G    B A L A N C E "
     .
fdt = g-today. tdt = g-today.
{mesg.i 0853} update fdt.
{mesg.i 0854} update tdt.

status default
"ABOVE LISTS ACTIVITY BETWEEN " + string(fdt) + " - " + string(tdt) + " ... ".

find aaa where aaa.aaa = aaa no-lock.
find last aab where aab.aaa = aaa and aab.fdt < fdt no-lock no-error.
if available aab then bal = aab.bal.
if aaa.regdt = g-today then bal = 0.

display "[ START-BAL]" @ l[5] bal @ a[5] with frame aaacif.

{itemlisy.i
&var = "def var dr as dec form ""zz,zzz,zz9.99-"".
	def var cr as dec form ""zz,zzz,zz9.99-"".
	def var des as char form ""x(14)""."
&where = "aat.aaa = aaa.aaa and aat.regdt >= fdt and aat.regdt <= tdt and
	  aat.sta <> ""RJ"" and aat.amt <> 0"
&file = "aat"
&frame = "row 10 scroll 1 9 down overlay centered no-label title
""    TRX-# REG-DATE DESCRIPTION            DEBIT-      "" +
""  CREDIT-        BALANCE- """
&predisp = "dr = 0. cr = 0.
	    find aax where aax.lgr = aaa.lgr and aax.ln = aat.aax no-lock.
	    if aax.drcr = -1 then cr = aat.amt.
			     else dr = aat.amt.
	    if aat.aax = 21 or aat.aax = 71 then des = aat.rem.
					    else des = aax.des.
	    bal = bal + (aat.amt * aax.drcr * -1)."
&flddisp = "aat.aat aat.regdt des dr cr bal"
&form = "aat.aat aat.regdt des dr cr bal"
&chkey = "aat"
&index = "regdt"
&chtype = "integer"
&funadd = "if frame-value = """" then do:
	     {mesg.i 9205}.
	     pause 2.
	     next.
	   end."
}

status default.
