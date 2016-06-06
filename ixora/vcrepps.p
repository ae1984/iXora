/* vcrepps.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Реестр оформленных паспортов сделок за период по всем контрактам по экспорту и/или импорту
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-3-5
 * AUTHOR
        11.11.2002
 * CHANGES
        24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        13.02.2004 nadejda - добавлен параметр вызова vcreppsdat.p - суммы всех доплисты показывать или только изменившиеся
        17.02.2004 tsoy - добавлены поля outcorr и reciver regdate rname  cname  в таблицу t-psa
        06.07.2004 saltanat - добавлена глоб. переменная v-contrtype для вызова процедуры: vcreppsdat.p
        17.01.2005 saltanat - включена передаваемая переменная p-contrvid для проц. vcreppsdat, определяющая нужный вид контракта(активный или закрытый) 
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        02.09.2010 marinav убраны  -H,-S в параметрах конекта
*/


{vc.i}

{global.i}
{comm-txb.i}
{sum2strd.i}

def new shared temp-table t-psa 
  field ps like vcps.ps
  field dntype like vcps.dntype
  field dndate like vcps.dndate
  field psnum as char
  field crc like vcps.ncrc
  field crckod as char
  field sum like vcps.sum
  field sumdelta like vcps.sum
  field sumusd like vcps.sum
  field info as char
  field cifname as char
  field depart as integer
  field rnn as char
  field contrnum as char
  field ctei as char
  field partname as char
  field outcorr as char
  field reciver as char
  field regdate  like vcps.dndate
  field rname    as char
  field cname    as char.



def new shared temp-table t-svodps
  field ei like vccontrs.expimp
  field kolps as integer init 0
  field kolpskzt as integer init 0
  field sumps as deci init 0
  field sumpskzt as deci init 0
  field koldl as integer init 0
  field koldlkzt as integer init 0
  field sumdl as deci init 0
  field sumdlkzt as deci init 0
  index main is primary ei.

def temp-table t-svoddep
  field ei like vccontrs.expimp
  field kolps as integer init 0
  field kolpskzt as integer init 0
  field sumps as deci init 0
  field sumpskzt as deci init 0
  field koldl as integer init 0
  field koldlkzt as integer init 0
  field sumdl as deci init 0
  field sumdlkzt as deci init 0
  index main is primary ei.

def new shared var v-dtb as date.
def new shared var v-dte as date.
def new shared var v-reptype as char init "A".
def new shared var v-dtcurs as date.
def new shared var v-cursusd as deci.
def new shared var v-repvid as char init "A".

def var s-vcourbank as char.
def var v-month as integer.
def var v-god as integer.
def var v-sum as deci.
def var v-numstr as integer.

form 
  skip(1)
  v-dtb label " Начало периода " format "99/99/9999" 
    validate (v-dtb <= g-today, " Дата должна быть не больше текущей!")
  skip
  v-dte label "  Конец периода " format "99/99/9999" 
    validate (v-dtb <= v-dte, " Дата должна быть не больше начальной!")
  skip(1)
  v-dtcurs label  " Дата отчета (дата курсов валют) " format "99/99/9999" skip(1)

  v-reptype label "      E) экспорт     I) импорт     A) все " format "x" 
    validate(index("eEiIaA", v-reptype) > 0, "Неверный тип контракта !") skip(1)
   v-repvid label "      A) открытые    C) закрытые   V) все " format "x" 
    validate(index("aAcCvV", v-repvid) > 0, "Неверный вид контракта !")

  "  " skip (1)
  with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

find last cls no-lock no-error.
v-dtb = cls.whn.
v-dte = cls.whn.
v-dtcurs = g-today.

displ v-dtb v-dte v-dtcurs v-reptype v-repvid with frame f-dt. 

update v-dtb with frame f-dt. 
v-dte = v-dtb.
if v-dte < g-today then do:
  find first cls where cls.whn > v-dte no-lock no-error.
  if avail cls then do:
    v-dtcurs = cls.whn.
    displ v-dtcurs with frame f-dt.
  end.
end.

update v-dte with frame f-dt. 

if v-dte < g-today then do:
  find first cls where cls.whn > v-dte no-lock no-error.
  if avail cls then do:
    v-dtcurs = cls.whn.
    displ v-dtcurs with frame f-dt.
  end.
end.
update v-reptype with frame f-dt.

v-reptype = caps(v-reptype).
displ v-reptype with frame f-dt.

update v-repvid with frame f-dt.

v-repvid = caps(v-repvid).
displ v-repvid with frame f-dt.

message " Формируется отчет...".

s-vcourbank = comm-txb().

/* найти курс USD на отчетную дату */
find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= v-dtcurs no-lock no-error. 
v-cursusd = ncrchis.rate[1].

/* расчеты во временную таблицу */
/* коннект к текущему банку */
find txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
if connected ("txb") then disconnect "txb".
  /*connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). */
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 

run vcreppsdat (s-vcourbank, 0, yes, '1,5', v-repvid).

if connected ("txb") then disconnect "txb".

/* вывод временной таблицы */
def stream vcrpt.
output stream vcrpt to vcps14.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Реестр оформленных паспортов сделок"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>РЕЕСТР ОФОРМЛЕННЫХ ПАСПОРТОВ СДЕЛОК<BR>за период с " + string(v-dtb, "99/99/9999") + 
       " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>N</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Импортер/Экспортер</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>РНН</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Контракт</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>экс/ имп</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Паспорт сделки</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дата паспорта сделки</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма паспорта сделки</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Код вал</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма в USD</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Экспортер/Импортер</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прим</B></FONT></TD>" skip
   "</TR>" skip.

                    
for each t-psa break by t-psa.depart by t-psa.dndate by t-psa.dntype 
      by t-psa.psnum by t-psa.crckod by t-psa.sum by t-psa.ps:
  if first-of(t-psa.depart) then do:
    find ppoint where ppoint.depart = t-psa.depart no-lock no-error.
    put stream vcrpt unformatted
      "<TR><TD colspan=""12""><FONT size=""2""><B>" + ppoint.name + "</B></FONT></TD></TR>" skip.
    v-numstr = 0.
  end.
  v-numstr = v-numstr + 1.

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD align=""left"">" + string(v-numstr) + "</TD>" skip
      "<TD align=""left"">" + t-psa.cifname + "</TD>" skip
      "<TD align=""center"">" + t-psa.rnn + "</TD>" skip
      "<TD align=""left"">" + t-psa.contrnum + "</TD>" skip
      "<TD align=""center"">" + t-psa.ctei + "</TD>" skip
      "<TD align=""left"">" + t-psa.psnum + "</TD>" skip
      "<TD align=""center"">" + string(t-psa.dndate, "99/99/99") + "</TD>" skip
      "<TD align=""right"">" + sum2strd(t-psa.sum, 2) + "</TD>" skip
      "<TD align=""center"">" + t-psa.crckod + "</TD>" skip
      "<TD align=""right"">" + sum2strd(t-psa.sumusd, 2) + "</TD>" skip
      "<TD align=""left"">" + t-psa.partname + "</TD>" skip
      "<TD align=""left"">" + t-psa.info + "</TD>" skip
      "</TR>" skip.

  if last-of(t-psa.depart) then do:
    put stream vcrpt unformatted
      "<TR><TD colspan=""12"">&nbsp;</TD></TR>" skip.
  end.
end.

put stream vcrpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip
   "<TR><TD colspan=""21""><FONT size=""2""><B>ВСЕГО</B></FONT></TD></TR>" skip
   "<TR align=""center"">" skip
     "<TD rowspan=""3""><FONT size=""1""><B>Департамент</B></FONT></TD>" skip   
     "<TD colspan=""10""><FONT size=""1""><B>Эскпорт</B></FONT></TD>" skip
     "<TD colspan=""10""><FONT size=""1""><B>Импорт</B></FONT></TD>" skip
   "</TR>" skip
   "<TR align=""center"">" skip
     "<TD colspan=""4""><FONT size=""1""><B>Паспорта сделок</B></FONT></TD>" skip
     "<TD colspan=""4""><FONT size=""1""><B>Доп. листы</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1""><B>ВСЕГО</B></FONT></TD>" skip
     "<TD colspan=""4""><FONT size=""1""><B>Паспорта сделок</B></FONT></TD>" skip
     "<TD colspan=""4""><FONT size=""1""><B>Доп. листы</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1""><B>ВСЕГО</B></FONT></TD>" skip
   "</TR>" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>Колич.</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма в USD</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Колич.</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма в USD</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Общая сумма в USD</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Колич.</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма в USD</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Колич.</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма в USD</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Общая сумма в USD</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в KZT</B></FONT></TD>" skip
   "</TR>" skip.

for each t-psa break by t-psa.depart by t-psa.ctei by t-psa.dntype by t-psa.crc:
  if first-of(t-psa.depart) then do:
    find ppoint where ppoint.depart = t-psa.depart no-lock no-error.
    put stream vcrpt unformatted
      "<TR><TD><FONT size=""2""><NOBR>" + ppoint.name + "</NOBR></FONT></TD>" skip.
    for each t-svoddep. delete t-svoddep. end.
  end.

  if first-of(t-psa.ctei) then do:
    create t-svoddep.
    t-svoddep.ei = t-psa.ctei.
  end.

  accumulate t-psa.ps (count by t-psa.depart by t-psa.ctei by t-psa.dntype by t-psa.crc).
  accumulate t-psa.sum (total by t-psa.depart by t-psa.ctei by t-psa.dntype by t-psa.crc).

  if last-of(t-psa.crc) then do:
    v-sum = (accum sub-total by t-psa.crc t-psa.sum).
    if t-psa.crc <> 2 then do:
      find last ncrchis where ncrchis.crc = t-psa.crc and ncrchis.rdt <= v-dtcurs no-lock no-error. 
      v-sum = (v-sum * ncrchis.rate[1]) / v-cursusd.
    end.

    find t-svoddep where t-svoddep.ei = t-psa.ctei.
    if t-psa.dntype = "01" then do:
      t-svoddep.kolps = t-svoddep.kolps + (accum sub-count by t-psa.crc t-psa.ps).
      t-svoddep.sumps = t-svoddep.sumps + v-sum.
      if t-psa.crc = 1 then do:
        t-svoddep.kolpskzt = t-svoddep.kolpskzt + (accum sub-count by t-psa.crc t-psa.ps).
        t-svoddep.sumpskzt = t-svoddep.sumpskzt + v-sum.
      end.
    end.
    else do:
      t-svoddep.koldl = t-svoddep.koldl + (accum sub-count by t-psa.crc t-psa.ps).
      t-svoddep.sumdl = t-svoddep.sumdl + v-sum.
      if t-psa.crc = 1 then do:
        t-svoddep.koldlkzt = t-svoddep.koldlkzt + (accum sub-count by t-psa.crc t-psa.ps).
        t-svoddep.sumdlkzt = t-svoddep.sumdlkzt + v-sum.
      end.
    end.
  end.

  if last-of(t-psa.depart) then do:
    if not can-find(t-svoddep where t-svoddep.ei = "e") then
      put stream vcrpt unformatted 
        "<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>" skip.

    for each t-svoddep :
      put stream vcrpt unformatted
        "<TD align=""right""><FONT size=""2""><B>" + sum2strd(decimal(t-svoddep.kolps), 0) + "</B></FONT></TD>" skip
        "<TD align=""right""><FONT size=""2""><B>" + sum2strd(decimal(t-svoddep.kolpskzt), 0) + "</B></FONT></TD>" skip
        "<TD align=""right""><FONT size=""2""><NOBR>" + sum2strd(t-svoddep.sumps, 2) + "</NOBR></FONT></TD>" skip
        "<TD align=""right""><FONT size=""2""><NOBR>" + sum2strd(t-svoddep.sumpskzt, 2) + "</NOBR></FONT></TD>" skip
        "<TD align=""right""><FONT size=""2"">" + sum2strd(decimal(t-svoddep.koldl), 0) + "</NOBR></FONT></TD>" skip
        "<TD align=""right""><FONT size=""2"">" + sum2strd(decimal(t-svoddep.koldlkzt), 0) + "</FONT></TD>" skip
        "<TD align=""right""><FONT size=""2""><NOBR>" + sum2strd(t-svoddep.sumdl, 2) + "</NOBR></FONT></TD>" skip
        "<TD align=""right""><FONT size=""2""><NOBR>" + sum2strd(t-svoddep.sumdlkzt, 2) + "</NOBR></FONT></TD>" skip
        "<TD align=""right""><FONT size=""2""><B><NOBR>" + sum2strd(t-svoddep.sumps + t-svoddep.sumdl, 2) + "</NOBR><B></FONT></TD>" skip
        "<TD align=""right""><FONT size=""2""><B><NOBR>" + sum2strd(t-svoddep.sumpskzt + t-svoddep.sumdlkzt, 2) + "</NOBR><B></FONT></TD>" skip.
    end.
    put stream vcrpt unformatted "</TR>" skip.
  end.
end.

put stream vcrpt unformatted
  "<TR><TD colspan=""21"">&nbsp;</TD></TR>" skip
  "<TR><TD><FONT size=""2""><B><NOBR>ВСЕГО ПО ОФИСУ</NOBR></B></FONT></TD>" skip.

if not can-find(t-svodps where t-svodps.ei = "e") then
  put stream vcrpt unformatted 
    "<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>" skip.

for each t-svodps :
  put stream vcrpt unformatted
    "<TD align=""right""><FONT size=""2""><B>" + sum2strd(decimal(t-svodps.kolps), 0) + "</B></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><B>" + sum2strd(decimal(t-svodps.kolpskzt), 0) + "</B></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><NOBR>" + sum2strd(t-svodps.sumps, 2) + "</NOBR></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><NOBR>" + sum2strd(t-svodps.sumpskzt / v-cursusd, 2) + "</NOBR></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2"">" + sum2strd(decimal(t-svodps.koldl), 0) + "</FONT></TD>" skip
    "<TD align=""right""><FONT size=""2"">" + sum2strd(decimal(t-svodps.koldlkzt), 0) + "</FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><NOBR>" + sum2strd(t-svodps.sumdl, 2) + "</NOBR></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><NOBR>" + sum2strd(t-svodps.sumdlkzt / v-cursusd, 2) + "</NOBR></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><B><NOBR>" + sum2strd(t-svodps.sumps + t-svodps.sumdl, 2) + "</NOBR><B></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><B><NOBR>" + 
        sum2strd((t-svodps.sumpskzt + t-svodps.sumdlkzt) / v-cursusd, 2) + "</NOBR><B></FONT></TD>" skip.
end.

put stream vcrpt unformatted
    "</TR>" skip
  "</TABLE><BR><BR><P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" skip.

find bankl where bankl.bank = s-vcourbank no-lock no-error.
if avail bankl then 
  put stream vcrpt unformatted bankl.name skip.

find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
  put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.

put stream vcrpt unformatted
  "</B></FONT></P>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

hide message no-pause.

unix silent value("cptwin vcps14.htm iexplore").

pause 0.


