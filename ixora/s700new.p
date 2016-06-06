/* s700new.p
 * MODULE
        Расчет отчета 700H в banks
 * DESCRIPTION
        Расчет отчета 700H в banks
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
        03/11/03 nataly trxbal.sub = 'lon' валюта берется не по lon.crc,  trxbal.crc
        05/12/03 nataly добавлена обработка ценных бумаг SCU
        28.06.06 u00121 по всем счетам GL, не имеющим sub теперь ведется поиск остатков не по glbal, а по glday
        11.07.07 u00119 добавила вывод ошибок в файл errs
        16/08/06 nataly перевела отчет на histrxbal.
        26/10/2011 madiyar - по ценным бумагам (scu) поправил определение резидентства и сектора экономики
*/


{global.i}
{push.i }

def new shared var v-frm 	as char.
def new shared var s-referid 	like sthead.referid.
def new shared var v-gldate 	as date.
def new shared var v-dt 	like sthead.rptto.

def var v-bilext as char 	no-undo.
def var v-err 	 as log 	no-undo.
def var v-str 	 as char 	no-undo.

def var v-name 	 as char init "Приложение к форме ежедневного баланса банков второго уровня (700Н)" no-undo.
def var v-gltot  as char 	no-undo.
def var i 	 as int 	no-undo.
def var v-gl 	 like gl.gl 	no-undo.
def var v-hs 	 as char 	no-undo.
def var v-cgr 	 as char 	no-undo.
def var v-r 	 as char 	no-undo.
def var v-code 	 as char 	no-undo.
def var v-geoi 	 as int 	no-undo.
def var v-cgri 	 as int 	no-undo.
def var v-bal 	 like glbal.bal no-undo.
def var v-bank 	 as char 	no-undo.
def var v-mfo 	 as char 	no-undo.
def var v-day 	 as char 	no-undo.
def var v-mon 	 as char	no-undo.
def var v-god 	 as char 	no-undo.
def var j 	 as integer 	no-undo.
def var sum1 	 as decimal 	no-undo.
def var sum2 	 as decimal 	no-undo.



def stream errs.
def stream st-err.


def stream rpt1.
output stream rpt1 to 'rpt11.img'.

def new shared temp-table wt no-undo
    field code as char
    field amt as dec decimals 10 format ">>>,>>>,>>>,>>9.99-"
    index wt-idx1 is unique primary code.

def temp-table wgl no-undo
    field gl like gl.gl
    field subled like gl.subled
    field type like gl.type
    index wgl-idx1 is unique primary gl
    index wgl-idx2 subled.

find last sysc where sysc.sysc eq "GLDATE" no-lock .   /* закрытый день */
if avail sysc then v-gldate = sysc.daval.
v-err = no.

output stream errs to errs.img.
output stream st-err to rpt.err.

/* определение счета главной книги */
function fgl return int (input v-gl as int, input v-lev as int).
    def var v-glout as int no-undo.
    v-glout = 0.
    find gl where gl.gl eq v-gl no-lock no-error.
    if available gl then do :
       find trxlevgl where trxlevgl.gl eq v-gl
                       and trxlevgl.lev eq v-lev
                       and trxlevgl.sub eq gl.subled no-lock no-error.
       if available trxlevgl then v-glout = trxlevgl.glr.
    end.
    return v-glout.
end function.

find last sysc where sysc.sysc eq "gltot" no-lock no-error.
if available sysc then v-gltot = sysc.chval.
else v-gltot = "199995,299990,399995,499995,599995".

do i = 1 to 2 :
   v-gl = integer(entry(i,v-gltot)).
   run cwgl(v-gl). /* определяются все неитоговые счета из 199995 и 299995 */
end.

v-frm = '7pn'.

for each trxbal /*where subled = 'fun'*/  no-lock :        /* для каждого счета GL, по кот.были обороты */

 /*   if trxbal.dam eq trxbal.cam then next.*/  /* обороты не равны, есть остаток */
            /*!!!*/
    if trxbal.sub eq "ARP" then do:         /* разбор по типам счетов */

        find last arp where arp.arp eq trxbal.acc no-lock no-error.
        if not avail arp then do: put stream errs skip 'Не найден arp для trxbal  ' trxbal.acc trxbal.sub trxbal.lev. next. end.
        find last crchs where crchs.crc eq arp.crc no-lock no-error.
        if crchs.hs eq "L" then v-hs = "1".
           else if crchs.hs eq "H" then v-hs = "2".
                else if crchs.hs eq "S" then v-hs = "3".
        find last cif where cif.cif eq arp.cif no-lock no-error.
        if available cif then do:
           v-geoi = integer(cif.geo).
           find last sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' no-lock no-error.
           if avail sub-cod then v-cgr = sub-cod.ccode.
        end.
        else do :
           v-geoi = integer(arp.geo).
           find last sub-cod where sub-cod.sub = 'arp' and sub-cod.acc = arp.arp and sub-cod.d-cod = 'secek' no-lock no-error.
           if avail sub-cod then v-cgr = sub-cod.ccode.
        end.
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        {700.i &gl=arp.gl}
    end.

    if trxbal.sub eq "AST" then do:              /* основные средства */
        find last ast where ast.ast eq trxbal.acc no-lock no-error.
        if not avail ast then do: put stream errs skip 'Не найден ast для trxbal  ' trxbal.acc trxbal.sub trxbal.lev. next. end.
        v-gl = fgl(ast.gl,trxbal.lev).
        find last wgl where wgl.gl eq v-gl no-lock no-error.
        if available wgl then do :
           v-code = string(truncate(v-gl / 100, 0)) + "141".
           if v-code eq ? then
              put stream st-err unformatted
              v-r eq ? " " v-cgr eq ? " " v-hs eq ? skip
              trxbal.sub " " trxbal.acc " "
              string(v-geoi) " " string(v-cgri) skip.

           find last wt where wt.code eq v-code no-error.
           if not available wt then do:
              create wt.
              wt.code = v-code.
           end.
           v-bal = trxbal.pcam - trxbal.pdam.
           if wgl.type eq "A" or wgl.type eq "E" then
              v-bal = - v-bal.
           find last crchis where crchis.crc eq trxbal.crc and crchis.rdt lt g-today no-lock no-error.
           wt.amt = wt.amt + v-bal * crchis.rate[1] / crchis.rate[9].
        end.
    end.
    if trxbal.sub eq "CIF" then do:                /* клиентские счета */

       find last aaa where aaa.aaa eq trxbal.acc no-lock no-error.
        if not avail aaa then do: put stream errs skip 'Не найден aaa для trxbal  ' trxbal.acc trxbal.sub trxbal.lev. next. end.
       find last cif where cif.cif eq aaa.cif no-lock no-error.
        if not avail cif then do: put stream errs 'Не найден код CIF для счета  ' aaa.aaa. next. end.
       find last crchs where crchs.crc eq aaa.crc no-lock no-error.
       if crchs.hs eq "L" then v-hs = "1".
          else if crchs.hs eq "H" then v-hs = "2".
               else if crchs.hs eq "S" then v-hs = "3".
       if substring(string(integer(cif.geo),"999"),3,1) eq "1" then v-r = "1".
          else v-r = "2".
       find last sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' no-lock no-error.
       if avail sub-cod then v-cgr = sub-cod.ccode.

       {700.i &gl=aaa.gl}

       if string(aaa.gl) begins '2206' and v-r = "2" and v-cgr = "6" then  put stream rpt1 skip aaa.aaa aaa.gl aaa.cif v-hs v-cgr v-bal * crchis.rate[1] / crchis.rate[9] format 'zzz,zzz,zzz,zz9.99'.
    end.

    if trxbal.sub eq "DFB" then do:              /* коррсчета */

       find last dfb where dfb.dfb eq trxbal.acc no-lock no-error.
        if not avail dfb then do: put stream errs skip 'Не найден lon для trxbal  ' trxbal.acc trxbal.sub trxbal.lev. next. end.
       find last bankl where bankl.bank eq dfb.bank no-lock no-error.
       if available bankl then v-geoi = bankl.stn.
          else do:
            put stream st-err trxbal.sub " " trxbal.acc " not found bank for " dfb.bank skip "Summa " string(trxbal.dam - trxbal.cam,">>>,>>>,>>>,>>>,>>9.99-") " Crc " trxbal.crc skip.
          end.
       find last crchs where crchs.crc eq dfb.crc no-lock no-error.
       if crchs.hs eq "L" then v-hs = "1".
          else if crchs.hs eq "H" then v-hs = "2".
               else if crchs.hs eq "S" then v-hs = "3".
       if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
          else v-r = "2".

       if dfb.gl ge 105100 and dfb.gl lt 105200 then v-cgr = '3'.
          else v-cgr = '4'.

       {700.i &gl=dfb.gl}
    end.

    if trxbal.sub eq "FUN" then do:      /* межбанковские депозиты и кредиты */

       find last fun where fun.fun eq trxbal.acc no-lock no-error.
        if not avail fun then do: put stream errs 'Не найден fun для trxbal  ' trxbal.acc trxbal.sub trxbal.lev. next. end.
       find last bankl where bankl.bank eq fun.bank no-lock no-error.
       if available bankl then v-geoi = bankl.stn.
          else do:
            put stream st-err trxbal.sub " " trxbal.acc " not found bank for " fun.bank skip "Summa " string(trxbal.dam - trxbal.cam,">>>,>>>,>>>,>>>,>>9.99-") " Crc " trxbal.crc skip.
          end.
       find last crchs where crchs.crc eq fun.crc no-lock no-error.
       if crchs.hs eq "L" then v-hs = "1".
          else if crchs.hs eq "H" then v-hs = "2".
               else if crchs.hs eq "S" then v-hs = "3".
       if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
          else v-r = "2".

   	find last sub-cod where sub-cod.sub = 'fun' and sub-cod.acc = fun.fun and sub-cod.d-cod = 'secek' no-lock no-error.
        if avail sub-cod then v-cgr = sub-cod.ccode.
         else  v-cgr = '4'.

       {700.i &gl=fun.gl}
    end.

    if trxbal.sub eq "SCU" then do:      /* Ценные бумаги */

       find last scu where scu.scu eq trxbal.acc no-lock no-error.
        if not avail scu then do: put stream errs 'Не найден scu для trxbal  ' trxbal.acc trxbal.sub trxbal.lev. next. end.
       /*
       find last bankl where bankl.bank eq scu.bank no-lock no-error.
       if available bankl then v-geoi = bankl.stn.
          else do:
            put stream st-err trxbal.sub " " trxbal.acc " not found bank for " scu.bank skip "Summa " string(trxbal.dam - trxbal.cam,">>>,>>>,>>>,>>>,>>9.99-") " Crc " trxbal.crc skip.
          end.
       */
       v-geoi = integer(scu.geo) no-error.
       if error-status:error then v-geoi = 21.

       find last crchs where crchs.crc eq scu.crc no-lock no-error.
       if crchs.hs eq "L" then v-hs = "1".
          else if crchs.hs eq "H" then v-hs = "2".
               else if crchs.hs eq "S" then v-hs = "3".
       if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
          else v-r = "2".

   	/*
    find last sub-cod where sub-cod.sub = 'scu' and sub-cod.acc = scu.scu and sub-cod.d-cod = 'secek' no-lock no-error.
        if avail sub-cod then v-cgr = sub-cod.ccode.
         else  v-cgr = '4'.
    */
    v-cgr = scu.type. /* сектор экономики */

       {700.i &gl=scu.gl}
    end.

    if trxbal.sub eq "LON" then do:                  /* ссудные счета */

       find last lon where lon.lon eq trxbal.acc no-lock no-error.
        if not avail lon then do: put stream errs 'Не найден lon для trxbal  ' trxbal.acc trxbal.sub trxbal.lev. next. end.
       find last cif where cif.cif eq lon.cif no-lock no-error.
        if not avail cif then do: put stream errs 'Не найден код CIF для счета lon  ' lon.lon. next. end.
       /*03/11/03 nataly*/
       find last crchs where crchs.crc eq /*lon.crc*/ trxbal.crc no-lock no-error.
       if crchs.hs eq "L" then v-hs = "1".
          else if crchs.hs eq "H" then v-hs = "2".
               else if crchs.hs eq "S" then v-hs = "3".
       if substring(string(integer(cif.geo),"999"),3,1) eq "1" then v-r = "1".
          else v-r = "2".
       find last sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' no-lock no-error.
       if avail sub-cod then v-cgr = sub-cod.ccode.

       {700.i &gl=lon.gl}
    end.
end.
output close.

for each wgl where wgl.subled eq "" no-lock:                          /* по всем счетам GL, не имеющим sub */
	for each crchs no-lock. /*u00121 28.06.06 переделал поиск с glbal`a на glday */
		find last glday where glday.gl = wgl.gl and glday.crc = crchs.crc no-lock no-error.
		if avail glday and glday.dam <> glday.cam then
		do:
                	if crchs.hs eq "L" then v-hs = "1".
                   	else
                   		if crchs.hs eq "H" then v-hs = "2".
                        	else if crchs.hs eq "S" then v-hs = "3".

                	if v-hs = "1" then v-r = "1".
                   	else v-r = "2".

           		if glday.gl lt 105000 then v-cgr = "3".
              		else
              			if string(glday.gl) begins "2551" then v-cgr = "4".
              			else v-cgr = "6".
           		v-code = string(truncate(glday.gl / 100, 0)) + v-r + v-cgr + v-hs.
           		find last wt where wt.code eq v-code no-error.
           		if not available wt then
           		do:
              			create wt.
              				wt.code = v-code.
           		end.
           		v-bal = glday.cam - glday.dam.

           		if wgl.type eq "A" or gl.type eq "E" then
              			v-bal = - v-bal.
           		find last crchis where crchis.crc eq glday.crc and crchis.rdt lt g-today no-lock no-error.
           		wt.amt = wt.amt + v-bal * crchis.rate[1] / crchis.rate[9].
		end.
	end.
end.

output to rpt.img.
for each wt :
    displ wt.
end.
output close.

for each wgl no-lock :
    displ stream st-err wgl .
end.
output stream st-err close.

output  stream rpt1 close.


output stream errs close .

/*генерация нового referid, создание нового sthead*/
run sref-new.
if s-referid = 0 then return.

find first cmp no-lock no-error.
if avail cmp then v-bank = cmp.name.

/*мфо банка*/
find sysc where sysc.sysc = 'CLECOD' no-lock no-error.
if avail sysc then v-mfo = sysc.chval.

find sthead where sthead.referid = s-referid no-lock no-error.
if not avail sthead then return.
if day(sthead.rptto) < 10 then   v-day  = "0" + string(day(sthead.rptto)) + "." . else  string(day(sthead.rptto)) + "." .
if month(sthead.rptto) < 10 then v-mon  = "0" + string(month(sthead.rptto)) + "." .  else  string(month(sthead.rptto)) + "." .
 v-god  = string(year(sthead.rptto)) + "." .

     do j = 1 to 8.
                create stdata.
                stdata.referid  = s-referid.
                stdata.x1 = string(j,"9999999").
                if j = 1  then stdata.fun = v-bank.
                else if (j = 2 or j = 3)  then stdata.fun = "".
                else if j = 4 then stdata.fun = v-name.
                else if j = 5 then stdata.fun = "за " + string(sthead.rptto) + " (в тыс.тенге)".
                else if (j = 6 or j = 7)  then stdata.fun = "".
                else if (j = 8)  then stdata.fun = "((" + v-mfo + " "  +  string(g-today) + " PRIL " .
     end.
     j = 9.
     for each wt no-lock.
                create stdata.
                stdata.referid  = s-referid.
                stdata.x1 = string(j,"9999999").
                  if wt.code  begins '1'  then do:
                    stdata.fun = wt.code + ";" + string(round(wt.amt / 1000,0)) +  ";0," + string(round(wt.amt / 1000,0)) .
                    sum1 = sum1 + round(decimal(wt.amt) / 1000,0) .
                  end.
                  else do:
                     stdata.fun = wt.code +  ";0;" + string(round(wt.amt / 1000,0)) + "," + string(round(wt.amt / 1000,0)) .
                   sum2 = sum2 + round(decimal(wt.amt) / 1000,0) .
                  end.
                j = j + 1.
     end.
                create stdata.
                stdata.referid  = s-referid.
                stdata.x1 = string(j,"9999999").
                stdata.fun =  "0;" +  string(round(sum1 / 1000,0)) +  ";" + string(round(sum2 / 1000,0)) + "," + string(round((sum1 + sum2) / 1000,0)) + "))" .

vres = yes.  /* успешное формирование файла */

Procedure cwgl. /* определяются неитоговые счета, входящие в 199995 и 299995 */
	def input parameter v-gl like gl.gl.
	def var v-ok as log no-undo.
	def buffer b for gl.
	v-ok = no.
	for each b where b.totgl eq v-gl no-lock :
		v-ok = yes.
		run cwgl(b.gl).
	end.
	if not v-ok then
	do:
		find last b where b.gl eq v-gl no-lock no-error.
		if available b then do:
		    create wgl.                /* формируется рабочая таблица */
		    assign
			    wgl.gl = b.gl                     /* счет GL */
			    wgl.subled = b.subled             /* тип субсчета */
			    wgl.type = b.type.                 /* тип счета A, L */
		end.
	end.
	return.
end procedure.


