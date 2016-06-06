/* vcltrlic-i.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Письма клиенту импорт
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
        12.05.2004 tsoy
 * CHANGES
         17.05.2004 tsoy изменил данные для отчета а также установлена нижняя граница в 20 мрп 
         28.05.2004 tsoy - изменение описания таблицы t-dolgs для совместимости
         06.07.2004 saltanat - добавлена глоб. переменная v-contrtype для вызова процедуры: vcrepdpldat.p
         09.07.2004 tsoy     - исправил опечатку в названии банка
         04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype 
         28.12.2004 tsoy     - изменил текст
    	 03/01/2005 u00121 - Название банка теперь берем из таблицы CMP - п.п. Прагмы 9-1-1-1
         29/12/2005 nataly  - добавила наименование СПФ и ФИО директоров
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{global.i}
{comm-txb.i}
{sum2strd.i}
def stream vcrpt.
output stream vcrpt to vcltrlic.htm.
def new shared var s-vcourbank as char.

def new shared temp-table t-dolgs
  field cif like cif.cif
  field depart as integer
  field cifname as char
  field contract like vccontrs.contract
  field ctdate as date
  field ctnum as char
  field ctei as char
  field ncrc like ncrc.crc
  field sumcon as decimal init 0
  field sumusd as decimal init 0
  field sumdolg as decimal init 0
  field lcnum as char
  field days as integer
  field cifrnn as char
  field cifokpo as char
  index main is primary cifname cif ctdate ctnum contract.

def var v-days as integer.
def var v-title as char.
def var v-cursusd as deci.
def var v-partnername as char.
def var v-mrp as deci.

def var v-psnum as char.
def var v-ncrccod like ncrc.code.
def var v-dep as integer.
def var v-dep2 as char.
def var v-c-dep as integer.


s-vcourbank = comm-txb().

find first txb where bank = s-vcourbank and city = 998 no-lock.
if connected ("alga") then disconnect "alga".
connect value ("-db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld alga "). 
run get-mrp.

v-mrp = deci(return-value).

find first crc where crc.crc = 2 no-lock no-error.
   if avail crc then
      v-mrp = v-mrp / crc.rate[1].

if connected ("alga") then disconnect "alga".


{vcrepdt.i " УВЕДОМЛЕНИЕ ДЛЯ ЛИЦЕНЗИРОВАНИЕ "}


/* расчеты во временную таблицу */
/* коннект к текущему банку */
find txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
if connected ("txb") then disconnect "txb".
connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 

run vcrepdpldat ("i", s-vcourbank, 0, v-dtb, v-dte, v-closed, '1,5').

if connected ("txb") then disconnect "txb".

/* выдача отчета в HTML */
{html-title.i 
 &stream = " stream vcrpt "
 &title = "Для лицензирования"
 &size-add = "x-"
}
{get-dep.i}
v-dep = get-dep(g-ofc, g-today).

for each t-dolgs where t-dolgs.sumusd >= v-mrp * 20
                       and t-dolgs.days >= 180
      break by t-dolgs.depart by t-dolgs.cif by t-dolgs.ctdate 
      by t-dolgs.ctnum by t-dolgs.contract:

/*  find first cif where cif.cif = t-dolgs.cif no-lock no-error.
  if avail cif then do:
      v-c-dep = integer (cif.jame)  / 1000.
      if  v-c-dep <> v-dep then next.
  end.
*/
  if v-dep <> t-dolgs.depart then next.

  find first vcps where vcps.contract = t-dolgs.contract and vcps.dntype = "01" no-lock no-error.
  if avail vcps  then 
      v-psnum = vcps.dnnum. 
  else 
      v-psnum = "&nbsp;".

  find ncrc where ncrc.crc = t-dolgs.ncrc no-lock no-error.
  if avail ncrc then 
        v-ncrccod = ncrc.code. 
  else 
        v-ncrccod = "&nbsp;".
  
find vccontrs where vccontrs.contract = t-dolgs.contract no-lock no-error.
find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
  if avail vcpartners then
    v-partnername = trim(vcpartners.formasob) + ' ' + trim(trim(vcpartners.name)).
  else  v-partnername = ''.


put stream vcrpt unformatted 
   "<BR><BR><BR><BR><BR><BR><BR><BR>" skip
   "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
   "<TR><TD><BR>" skip
     "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
       "<TR valign=""top"">" skip
         "<TD width=""60%"" align=""left""></TD>" skip
         "<TD width=""40%"" align=""center""><FONT size=""3"">"
                  t-dolgs.cifname 
         "</FONT><BR><BR><BR><BR>"
         "</TD>" skip
       "</TR>"
     "</TABLE></TR>" skip.

find first bank.cmp no-lock no-error. /*03/01/2004 u00121*/       

put stream vcrpt unformatted 
  "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""3"" align=""center"" >" skip
    "<TR><TD colspan=""6"">" skip 
    "<P align =""justify""><FONT size=""3"">"       skip
    "<CENTER> Уважаемый клиент "  t-dolgs.cifname   "! </CENTER><BR>" skip 

    "&nbsp;&nbsp;&nbsp;Просим принять к сведению, что по Вашему импортному контракту N " + trim(t-dolgs.ctnum) skip
    " от "  string(t-dolgs.ctdate, "99.99.9999") skip 
    " c "  v-partnername  " (паспорт сделки "  trim(v-psnum)  ")" skip
    " к настоящему времени в банк не представлены таможенные декларации на сумму "  skip
    sum2strd(t-dolgs.sumcon, 2)  " " v-ncrccod skip
    "&nbsp;&nbsp;&nbsp;Если у вас имеются в наличии таможенные декларации, то просим вас в течении 5 дней " skip  
    "предоставить их в Департамент валютного контроля  или в обслуживающий Вас СПФ. <BR> " skip.

    if t-dolgs.sumusd > 10000 then do:
        put stream vcrpt unformatted 
        "&nbsp;&nbsp;&nbsp;Если имеет место непоставка товара, то выше названная сумма, по действующему"     skip
        "законодательству, подлежит лицензированию в Национальном Банке Республики Казахстан.<BR>"               skip
        "&nbsp;&nbsp;&nbsp;Убедительно просим Вас обратиться в Национальный Банк РК за получением лицензии.<BR>" skip.
    
        put stream vcrpt unformatted 
        "&nbsp;&nbsp;&nbsp;За дополнительными разъяснениями по вопросу лицензирования можете обращаться в Департамент Валютного Контроля " CAPS(bank.cmp.name) "  или в обслуживающий Вас СПФ.<BR>" skip.  

    end. else do:
        put stream vcrpt unformatted 
        "&nbsp;&nbsp;&nbsp;Если имеет место непоставка товара, то предоставьте документы, подтверждающие " skip
        "принятие Вами мер по обеспечению получения в полном объеме импортируемого товара, а в случае "     skip
        "невозможности поставки товара, возврата суммы авансового платежа, ранее переведенной инопартнеру" skip
        "по данному контракту.<BR> " skip.  

        put stream vcrpt unformatted 
        "&nbsp;&nbsp;&nbsp;За дополнительными разъяснениями можете обращаться в Департамент Валютного Контроля " CAPS(bank.cmp.name) "  или в обслуживающий Вас СПФ.<BR>" skip.  
    end.


put stream vcrpt unformatted                                       
    "</FONT></P>" skip
    "</TD></TR>" skip 
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip.

/*find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
  put stream vcrpt unformatted
    "<TR><TD colspan=""2"" align=""left""><FONT size=""3"">С уважением, <BR>" entry(2, sysc.chval)  skip
    "<BR>"    "</FONT>" skip
    "<TD colspan=""2""></TD>" skip
    "<TD colspan=""2"" align=""left""><FONT size=""3"">" entry(1, sysc.chval)  skip
    "</TR>" skip.                                       */

  find cif where cif.cif = t-dolgs.cif no-lock no-error.
  v-dep2 = string(int(cif.jame) - 1000) .
  find first codfr where codfr = 'vchead' and codfr.code = v-dep2 no-lock no-error .

  if avail codfr and codfr.name[1] <> "" then   /*if avail sysc then*/
  put stream vcrpt unformatted
    "<TR><TD colspan=""2"" align=""left""><FONT size=""3"">С уважением, <BR>" /*entry(2, sysc.chval)*/ entry(1, trim(codfr.name[1]))  skip
    "<BR>"    "</FONT>" skip
    "<TD colspan=""2""></TD>" skip
    "<TD colspan=""2"" align=""left""><FONT size=""3"">" entry(2, trim(codfr.name[1]))  skip
    "</TR>" skip.


put stream vcrpt unformatted 
  "</TABLE> </TABLE>" skip.

put stream vcrpt unformatted 
    "<P><BR clear=all style=""page-break-before:always""></P>" skip.

end.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcltrlic.htm winword").

pause 0.



