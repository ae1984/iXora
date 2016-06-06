     /*** KOVAL Расчет суммы пени после 1 июля ***/
     def var deadline as date init 07/01/02.
     def var delta as integer.
     def var newfine as decimal init 0.00.
     /*** KOVAL Расчет суммы пени после 1 июля ***/

define input parameter rid as char.

/*def var rid as char init '0x00a536f80x00a53dda'.*/
def var dsum as decimal.

&scoped-define ttns comm.tns.tns
&scoped-define trnn comm.tns.rnn format "999999999999"
&scoped-define tFIO comm.tns.fio format "x(50)"
&scoped-define tAdr comm.tns.adr format "x(50)"
&scoped-define tdovnum  comm.tns.dovnum
&scoped-define tdovdate if comm.tns.dovdate = ? then '        ' else string(comm.tns.dovdate,'99.99.99')
&scoped-define tdovadr   comm.tns.dovadr format "x(60)"
&scoped-define tModel    comm.tns.model format "x(50)" 
&scoped-define tNumber   comm.tns.Number format "x(9)"
&scoped-define tYear     comm.tns.Year format "x(13)"
&scoped-define tEdizm    comm.tns.Edizm format "x(6)"
&scoped-define tEngine   string(comm.tns.Engine,'>>>>>>9.9')
&scoped-define tBdate    comm.tns.bDate format '99.99.9999'
&scoped-define tEdate    comm.tns.eDate format '99.99.9999'
/*
&scoped-define tV if comm.tns.Edizm = 'куб' then string(tns.Engine,'>>>>>>9.9') else '         ' 
&scoped-define tC if comm.tns.Edizm = 'тон' then string(tns.Engine,'>>>>>>9.9') else '         ' 
&scoped-define tQ if comm.tns.Edizm = 'мес' then string(tns.Engine,'>>>>>>9  ') else '         ' 
&scoped-define tP if comm.tns.Edizm = 'квт' then string(tns.Engine,'>>>>>>9.9') else '         ' 
*/
&scoped-define tpspser  comm.tns.pspser
&scoped-define tpspnum  comm.tns.pspnum
&scoped-define tpspdate if comm.tns.pspdate = ? then '        ' else string(comm.tns.pspdate,'99.99.99')
&scoped-define trec     comm.tns.nkname
&scoped-define td comm.tax.date format '99.99.99' 
&scoped-define tn comm.tax.dnum format '>>>>>9' '  '
&scoped-define tsum chr(27) 'x1' chr(27) 'E' dsum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define tfine if delta > 0 then " в т.ч. пеня " + string(newfine,">,>>>,>>9.99") else ""

def var mark as int.
def var crlf as char.
crlf = chr(10).

def buffer btax for tax.
def var i as int.

def var doctns as int init 0.
def var docrid as rowid.


output to taxprtns.txt.
put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.

do while rid <> "":

find comm.tax where rowid(comm.tax) = to-rowid(substring(rid,1,10)) no-lock no-error.

find first btax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and comm.tax.uid = btax.uid and
           comm.tax.created = btax.created and comm.tax.dnum = btax.dnum no-lock no-error.
find first comm.tax where rowid(btax) = rowid(comm.tax) no-lock no-error.

if comm.tax.tns <> 0 then do:
   doctns = comm.tax.tns.
   docrid = rowid (comm.tax).
end.
else do i = 2 to 5:
   find next comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and comm.tax.uid = btax.uid and
                            comm.tax.created = btax.created and comm.tax.dnum = btax.dnum no-lock no-error.
   if avail comm.tax then
   if comm.tax.tns <> 0 then do:
      doctns = comm.tax.tns.
      docrid = rowid (comm.tax).
   end.
end.
if not avail comm.tax then find first comm.tax where rowid(btax) = rowid(comm.tax) no-lock no-error.

rid = substring(rid, 11).

/* sasco - убрал пеню, так как она считается при приеме платежа */
/*
delta = comm.tax.date - deadline + 1.
if delta > 0 then do:
		newfine = (comm.tax.sum * 0.08 * 1.5 * delta) / 365.
		dsum = comm.tax.sum + newfine.
	end.
	else  dsum = comm.tax.sum.
*/

delta = 0.
dsum = tax.sum.

find first comm.tns where comm.tns.tns = /* comm.tax.tns */ doctns USE-INDEX tns no-lock no-error.

if not avail comm.tns then do:
                         MESSAGE "Справка " comm.tax.tns " не найдена."
                         VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                         TITLE "Не найдена справка".
                         return.
                      end.
 put unformatted "                             Справка N " {&ttns} crlf crlf.
 put unformatted "  Дана: " {&tfio} crlf. 
 put unformatted "        ------------------------------------------------------------------------" crlf.
 put unformatted "  РНН:  " {&trnn} crlf.
 put unformatted "        ------------------------------------------------------------------------" crlf.
 put unformatted "  Адрес владельца: "  {&tadr} crlf.
 put unformatted "                   -------------------------------------------------------------" crlf.
 put unformatted "  Адрес владельца по доверенности N " {&tdovnum} " от " {&tdovdate} crlf crlf .
 put unformatted "  "{&tdovadr} crlf.
 put unformatted "  ------------------------------------------------------------------------------" crlf.
 put unformatted "  Марка а/м: " {&tModel} crlf.
 put unformatted "             -------------------------------------------------------------------" crlf.
 put unformatted "  Гос. номер: " {&tNumber} " Год выпуска: " {&tYear} crlf crlf.
 put unformatted "  Технич.характеристика: " {&tEngine} ", " {&tEdizm} crlf crlf.
/*
 put unformatted "  Объем двигателя: " {&tv} " Грузоподъмность: " {&tc} crlf crlf.
 put unformatted "  Посадочных мест: " {&tQ} " Мощность двиг. (л.с.): " {&tp} crlf crlf.
*/
 put unformatted "  Летательные аппараты: " crlf crlf.
 put unformatted "  ------------------------------------------------------------------------------" crlf.
 put unformatted "  СРТС : серии " {&tpspser} " N " {&tpspnum} " от " {&tpspdate} crlf crlf.
 put unformatted "  Владелец автотранспорта за 2002 год оплатил(а) налог на транспортное средство." crlf crlf.
/* put unformatted "  Владелец автотранспорта за период c " {&tBdate} " по " {&tEdate} " оплатил(а) " crlf.*/
 put unformatted "  Сумма: " {&tsum} " Дата уплаты: " {&td} " Квитанция N: " {&tn} crlf.
 put unformatted " " {&tfine} crlf crlf.
 put unformatted "  Получатель: " {&trec} crlf. 
 put unformatted "              ------------------------------------------------------------------" crlf crlf crlf crlf.
 put unformatted "  Представитель НК:" crlf.
 put unformatted rid crlf crlf crlf.
end.

put unformatted chr(27) chr(64).
output close.

unix silent un-dos taxprtns.txt taxprtns.dos.
unix silent dos-un taxprtns.dos taxprtns.txt.

unix silent prit taxprtns.txt.

/*
run menu-prt ("taxprtns.txt").
*/
