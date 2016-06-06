/* vcreppsall.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Журнал учета оформленных паспортов сделок
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-3-16
 * AUTHOR
        17.02.2004 tsoy
 * CHANGES
         06.07.2004 saltanat - добавлена глоб. переменная v-contrtype для вызова процедуры: vcreppsdat.p
         04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype 
         17.01.2005 saltanat - включена передаваемая переменная p-contrvid для проц. vcreppsdat, определяющая нужный вид контракта(активный или закрытый) 
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


{vc.i}

{global.i}
{comm-txb.i}
{sum2strd.i}

def new shared temp-table t-psa
  field ps       like vcps.ps
  field dntype   like vcps.dntype
  field dndate   like vcps.dndate
  field psnum    as char
  field crc      like vcps.ncrc
  field crckod   as char
  field sum      like vcps.sum
  field sumdelta like vcps.sum
  field sumusd   like vcps.sum
  field info     as char
  field cifname  as char
  field depart   as integer
  field rnn      as char
  field contrnum as char
  field ctei     as char
  field partname as char
  field outcorr  as char
  field reciver  as char
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
    validate(index("eEiIaA", v-reptype) > 0, "Неверный тип контракта !")
  "  " skip (1)
  with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

v-dtb =  g-today.
v-dte =  g-today.
v-dtcurs = g-today.

displ v-dtb v-dte v-dtcurs v-reptype with frame f-dt. 

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

message " Формируется отчет...".

s-vcourbank = comm-txb().

/* найти курс USD на отчетную дату */
find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= v-dtcurs no-lock no-error. 
v-cursusd = ncrchis.rate[1].

/* расчеты во временную таблицу */
/* коннект к текущему банку */
find txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
if connected ("txb") then disconnect "txb".
connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 

run vcreppsdat (s-vcourbank, 0, yes, '1,5','V').

if connected ("txb") then disconnect "txb".

/* вывод временной таблицы */
def stream vcrpt.
output stream vcrpt to vcpsall.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Журнал учета оформленных паспортов сделок"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Журнал учета оформленных паспортов сделок<BR>за период с " + string(v-dtb, "99/99/9999") + 
       " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD rowspan=""2""><FONT size=""1"" ><B>N</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1"" ><B>Наименование документа</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1"" ><B>Номер и дата</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1"" ><B>Входящие</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1"" ><B>Исходящие</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1"" ><B>Должность, Ф.И.О, подпись лица, получившего документ</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1"" ><B>Ф.И.О оформившего документ</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1"" ><B>Ф.И.О акцептовавшего документ</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1"" ><B>Дата закрытия паспорта сделки</B></FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>Дата поступления</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Корреспондент</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дата Отправки</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Корреспондент</B></FONT></TD>" skip
   "</TR>" skip.

                    
for each t-psa break by t-psa.depart by t-psa.dndate by t-psa.dntype 
      by t-psa.psnum by t-psa.crckod by t-psa.sum by t-psa.ps:
  if first-of(t-psa.depart) then do:
    find ppoint where ppoint.depart = t-psa.depart no-lock no-error.
    put stream vcrpt unformatted
      "<TR><TD colspan=""11""><FONT size=""2""><B>" + ppoint.name + "</B></FONT></TD></TR>" skip.
    v-numstr = 0.
  end.
  v-numstr = v-numstr + 1.

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD align=""left"">" + string(v-numstr) + "</TD>" skip
      "<TD align=""left"">" + t-psa.contrnum + "</TD>" skip
      "<TD align=""center"">" + t-psa.psnum + " " + string(t-psa.regdate, "99/99/99") + "</TD>" skip
      "<TD align=""center"">" + string(t-psa.dndate, "99/99/99") + "</TD>" skip
      "<TD align=""left"">" + t-psa.cifname + "</TD>" skip
      "<TD align=""center"">" + string(t-psa.dndate, "99/99/99") + "</TD>" skip
      "<TD align=""left"">" + t-psa.outcorr + "</TD>" skip
      "<TD align=""left"">" + t-psa.reciver + "</TD>" skip
      "<TD align=""center"">" + t-psa.rname + "</TD>" skip
      "<TD align=""center"">" + t-psa.cname + "</TD>" skip
      "<TD align=""center""></TD>" skip
      "</TR>" skip.

  if last-of(t-psa.depart) then do:
    put stream vcrpt unformatted
      "<TR><TD colspan=""11"">&nbsp;</TD></TR>" skip.
  end.


end.

put stream vcrpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip
    "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" skip.

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

unix silent value("cptwin vcpsall.htm iexplore").

pause 0.


