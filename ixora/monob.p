/* monob.p
 * MODULE
        Операционка
 * DESCRIPTION
        Мониторинг оборотов клиентов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9.14.11
 * AUTHOR
        22.11.05 ten
 * CHANGES
        15/03/12 id00810 - добавила v-bankname для печати
*/

{global.i}
{get-dep.i}
{msg-box.i}

def var vdep1 as integer.
def var vdep like ppoint.depart format "999".
def var stime as date.
def var endtime as date.
def var stime1 as date.
def var endtime1 as date.
def var dt as date .
def var quest   as logical format "Да/Нет".
def var quest1 as log format "Да/Нет".
def var ind as int.
def var ind1 as int.
def var v-prc as decim format "99".
def new shared var vpoint like ppoint.point.
def var v-opis as char.
def buffer bjl for   jl.
def var v-sum as dec.
def var v-sum1 as dec.
def var v-obor as dec.
def var v-obor1 as dec.
def var v-doh as dec.
def var v-doh1 as dec.
def var i as int.
def var ii as int.
def var iii as int.
def var www as dec.
def var v-bankname as char no-undo.
def temp-table tempf
    field cif as char
    field name as char
    field code as char
    field whn as date
    field ntar as char
    field saldo_1 as decimal
    field saldo_2 as decimal
    field saldo_3 as decimal
    field prc as decimal
    field obor as decimal
    field ost as decim
    field osts as char
    field osts1 as char
    field prcc as dec
    field ost1 as decimal
    field obor1 as decimal
    field for1 as dec
    field doh as dec
    field doh1 as dec
    field for2 as dec
index dcod is primary prc saldo_3 saldo_1 saldo_2 cif.

def temp-table temp
    field cif like tarifex.cif
index ciif is primary cif.

def temp-table ort
    field for1 as dec
    field for2 as dec
    field cif as char
    field str5 like tarifex.str5
    index ppp is primary cif.

def temp-table tempp
    field doh like jl.cam
    field doh1 like jl.cam
    field cif as char
    field saldo1 as dec
    field saldo2 as dec
    field for1 as dec
    field for2 as dec
    index dop is primary cif.

def new shared frame opt
        vdep      label  "Код структурного подразделения" skip
        v-prc     label  "Процент  оборотов" skip
        stime     label  "Дата начала периода (текущий) " validate (stime <= g-today, " Дата не может быть больше текущей!") skip
        endtime   label  "Дата конца периода (текущий) " validate (endtime <= g-today, " Дата не может быть больше текущей!") skip(1)
        stime1    label  "Дата начала периода (для сравнения)" skip
        endtime1  label  "Дата конца периода  (для сравнения)" skip
        dt        label  "Дата установления льготы не позднее" skip
        with row 8 centered side-labels.

form vdep  help ' F2 - список департаментов'
  validate(can-find (ppoint where ppoint.depart = vdep no-lock),
  ' Ошибочный код департамента - повторите ! ') skip with frame opt.
  vpoint = 1.

update vdep
       v-prc
       stime
       endtime
       stime1
       endtime1
       dt
       with frame opt.

if endtime < stime then do:
    message "Неверно задана дата конца отчета".
    undo,retry.
end.

if endtime1 < stime1 then do:
    message "Неверно задана дата конца отчета".
    undo,retry.
end.


message  "При условии увеличения оборотности" update quest.
     if quest then ind = 1.
              else ind = 2.


message "С разбивкой по тарифным кодам?" update quest1.
     if quest1 then ind1 = 1.
               else ind1 = 2.

hide frame opt.


for each tarifex where tarifex.stat = "r" and tarifex.whn <= dt use-index id-stat  no-lock.
    find first temp where temp.cif = tarifex.cif no-error.
    if not avail temp then do:
       create temp.
              temp.cif = tarifex.cif.
    end.
end.


if ind1 = 2 then do:
for each temp no-lock.
        v-obor = 0.
        v-obor1 = 0.
        v-doh = 0.
        v-doh1 = 0.
        find first cif where cif.cif = temp.cif no-lock no-error.
        if avail cif and caps(cif.type) = "B" and integer(cif.jame) mod 1000 = integer(vdep) then do:
           for each aaa where aaa.cif = cif.cif no-lock.
           if aaa.sta <> "C" and aaa.sta <> "E" then do:
               for each jl where jl.acc = aaa.aaa and
                                 jl.dc = "d" and
                                 jl.jdt >= stime and
                                 jl.jdt <= endtime and
                                 jl.gl = aaa.gl  no-lock.
                      find jh where jh.jh eq jl.jh no-lock no-error.
                        if avail jh and not jh.party matches "*storn*" then do:
                           find last crchis where crchis.crc = jl.crc and
                                                  crchis.regdt <= jl.jdt and
                                                  crchis.tim <> 0  no-lock no-error.
                             if avail crchis then do:
                                v-obor = v-obor + jl.dam * crchis.rate[1].
                                find first bjl where bjl.jh = jh.jh and
                                                     bjl.ln = jl.ln + 1  and
                                                     bjl.jdt = jl.jdt no-lock no-error.
                                if avail bjl then do:
                                     if substring(string(bjl.gl),1,1) = "4" then
                                         v-doh = v-doh + bjl.cam * crchis.rate[1].
                                end.
                             end.
                        end.
               end.
               for each jl where jl.acc = aaa.aaa and
                                 jl.dc = "d" and
                                 jl.jdt >= stime1 and
                                 jl.jdt <= endtime1 and
                                 jl.gl = aaa.gl  no-lock.
                      find jh where jh.jh eq jl.jh no-lock no-error.
                        if avail jh and not jh.party matches "*storn*" then do:
                           find last crchis where crchis.crc = jl.crc and
                                                  crchis.regdt <= jl.jdt and
                                                  crchis.tim <> 0 use-index crcrdt no-lock no-error.
                           if avail crchis then do:
                                v-obor1 = v-obor1 + jl.dam * crchis.rate[1].
                                find first bjl where bjl.jh = jh.jh and
                                                     bjl.ln = jl.ln + 1  and
                                                     bjl.jdt = jl.jdt no-lock no-error.
                                if avail bjl then do:
                                     if substring(string(bjl.gl),1,1) = "4" then
                                         v-doh1 = v-doh1 + bjl.cam * crchis.rate[1].
                                end.
                             end.
                        end.
               end.
               end.
               end.


               find first tarifex where tarifex.cif = temp.cif and tarifex.stat = "r" and tarifex.whn <= dt no-lock no-error.
               if avail tarifex then do:
               find tarif2 where tarif2.str5 = tarifex.str5 no-lock no-error.
/*               if  tarifex.ost <> tarif2.ost then do:*/
               create tempf.
                      tempf.ntar = tarifex.pakalp.
                      tempf.whn = tarifex.whn.
                      tempf.name = cif.prefix + " " + cif.name.
                      tempf.code = tarifex.str5.
                      if (tarifex.whn - cif.regdt) < 31 then
                      tempf.cif = tarifex.cif + " " + string(cif.regdt).
                      else tempf.cif = tarifex.cif.
                      tempf.obor = v-obor. /*saldo1*/
                      tempf.obor1 = v-obor1.  /*saldo2*/
                      tempf.doh = v-doh.
                      tempf.doh1 = v-doh1.
                      if tarifex.ost <> 0 then tempf.ost = tarifex.ost.
                      else tempf.osts = string(tarifex.proc) + "%".
                      if tarif2.ost <> 0 then tempf.ost1 = tarif2.ost.
                      else tempf.osts1 = string(tarif2.proc) + "%".
                   if ind = 2 then do:
                      tempf.saldo_3 = (tempf.obor - tempf.obor1).
                      tempf.prc = round((abs(tempf.saldo_3) / tempf.obor1) * 100, 1).
                   end. else
                   if ind = 1 then do:
                      tempf.saldo_3 = (tempf.obor1 - tempf.obor).
                      tempf.prc = round((abs(tempf.saldo_3) / tempf.obor) * 100, 1).
                   end.
               end.
end.
end.
end.

if ind1 = 1 then do:

for each tarifex where tarifex.stat = "r" and tarifex.whn <= dt use-index id-stat  no-lock.
    find first tarif2 where tarif2.str5 = tarifex.str5 no-lock no-error.
    find first cif where cif.cif = tarifex.cif no-lock no-error.
      if avail cif and caps(cif.type) = "B" and integer(cif.jame) mod 1000 = integer(vdep) then do:

         create tempf.
                tempf.ntar = tarifex.pakalp.
             if tarifex.ost <> 0 then tempf.ost = tarifex.ost.
             else tempf.osts = string(tarifex.proc) + "%".
             if tarif2.ost <> 0 then tempf.ost1 = tarif2.ost.
             else tempf.osts1 = string(tarif2.proc) + "%".
                tempf.whn = tarifex.whn.
                tempf.name = cif.prefix + " " + cif.name.
                tempf.code = tarifex.str5.
               if (tarifex.whn - cif.regdt) < 30 then
                    tempf.cif = cif.cif + " " + string(cif.regdt).
               else tempf.cif = cif.cif.

    for each aaa where aaa.cif = cif.cif no-lock.
        if aaa.sta <> "C" and aaa.sta <> "E" then do:

         for each jl where jl.acc = aaa.aaa and
                           jl.dc = "d" and
                           jl.jdt >= stime and
                           jl.jdt <= endtime and
                           jl.gl = aaa.gl  no-lock.
               find jh where jh.jh eq jl.jh no-lock no-error.
               if avail jh and not jh.party matches "*storn*" then do:
                  find last crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt and crchis.tim <> 0 use-index crcrdt no-lock no-error.
                  if avail crchis then do:

                     tempf.saldo_1 = tempf.saldo_1 + jl.dam  * crchis.rate[1].
                     find first bjl where bjl.jh = jh.jh and
                                          bjl.ln = jl.ln + 1  and
                                          bjl.jdt = jl.jdt no-lock no-error.
                         if avail bjl then do:
                            v-opis = trim(bjl.rem[1]) + trim(bjl.rem[2]) + trim(bjl.rem[3]) + trim(bjl.rem[4]) + trim(bjl.rem[5]).
                            if bjl.gl = tarifex.kont and (tarifex.pakalp matches "*" + v-opis + "*" or v-opis matches "*" + tarifex.pakalp + "*") then do:
                               tempf.obor = tempf.obor + bjl.cam * crchis.rate[1].
                               tempf.for1 = tempf.for1 + bjl.cam * crchis.rate[1].
                            end.
                            if substring(string(bjl.gl),1,1) = "4" then
                               tempf.doh = tempf.doh + bjl.cam * crchis.rate[1].
                         end.
                  end.
               end.
         end.
         for each jl where jl.acc = aaa.aaa and
                           jl.dc = "d"  and
                           jl.jdt >= stime1 and
                           jl.jdt <= endtime1 and
                           jl.gl = aaa.gl no-lock.
               find jh where jh.jh eq jl.jh use-index jh no-lock no-error.
               if avail jh and not jh.party matches "*storn*" then do:
                  find last crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt and crchis.tim <> 0 use-index crcrdt no-lock no-error.
                  if avail crchis then do:

                     tempf.saldo_2 = tempf.saldo_2 + jl.dam  * crchis.rate[1].
                     find first bjl where bjl.jh = jh.jh and
                                          bjl.ln = jl.ln + 1 and
                                          bjl.jdt = jl.jdt no-lock no-error.
                         if avail bjl then do:
                            v-opis = trim(bjl.rem[1]) + trim(bjl.rem[2]) + trim(bjl.rem[3]) + trim(bjl.rem[4]) + trim(bjl.rem[5]).
                            if bjl.gl = tarifex.kont and (tarifex.pakalp matches "*" + v-opis + "*" or v-opis matches "*" + tarifex.pakalp + "*") then do:
                               tempf.obor1 = tempf.obor1 + bjl.cam * crchis.rate[1].
                               tempf.for2 = tempf.for2 + bjl.cam * crchis.rate[1].
                            end.
                            if substring(string(bjl.gl),1,1) = "4" then
                               tempf.doh1 = tempf.doh1 + bjl.cam * crchis.rate[1].

                         end.
                  end.
               end.
        end.
           if ind = 2 then do:
                 tempf.saldo_3 = (tempf.saldo_1 - tempf.saldo_2).
                 tempf.prc = round((abs(tempf.saldo_3) / tempf.saldo_2) * 100, 1).
           end. else
           if ind = 1 then do:
                 tempf.saldo_3 = (tempf.saldo_2 - tempf.saldo_1).      /* Разница между ... */
                 tempf.prc = round((abs(tempf.saldo_3) / tempf.saldo_1) * 100, 1).
           end.
   end.
end.
end.
end.
end.

find first sysc where sysc.sysc = "bankname" no-lock no-error.
if avail sysc then v-bankname = sysc.chval.

output  to txt1.htm.
put unformatted  "<html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"">"   skip
                 "<head><title>""</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"  skip
                 "</head><body>" skip.
put unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr"">" skip
   " АО " v-bankname "  <br>"    skip
   " Мониторинг оборотов клиентов в отчетный период с " stime " по " endtime " и период для сравнения c " stime1 " по " endtime1 " <br>" skip
   " c установлением льготы не позднее " dt " </FONT>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip.


if ind1 = 1 then do:
put unformatted
     "<tr><TD   bgcolor=""#95B2D1"" valign = ""top"">Наиме<br>нование</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">T <br>код</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Обороты по<br>дебету(1-й<br>период) </FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">Доходность<br>" stime "-" endtime "</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Обороты по<br>дебету(2-й<br>период)</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">Доходность<br>" stime1 "-" endtime1 "</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Код<br>тар<br>ифа</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">Наименова<br>ние тарифа</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Стоимость<br>тарифа(льг.)</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">Дата<br>установления</FONT></TD>" skip.
if ind = 1 then do:
put unformatted
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Увеличение<br>процентов</FONT></TD>" skip.
end.
if ind = 2 then do:
put unformatted
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Уменьшение<br>процентов</FONT></TD>" skip.
end.
put unformatted
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Стоимость<br>тарифа</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">Вознаграж<br>дение по <br>кредитам</FONT></TD></tr>" skip.


for each tempf where tempf.prc >= v-prc and
                     tempf.saldo_3 < 0 and
                     tempf.saldo_1 > 0 and
                     tempf.saldo_2 > 0
                     use-index dcod no-lock break /*by tempf.name*/  by substring(tempf.cif,1,6) by tempf.code.

for each lon where lon.cif = substring(tempf.cif,1,6) use-index cif  no-lock.
 if  lon.rdt <= endtime then
    for each lnsci where lnsci.lni = lon.lon and lnsci.idat >= stime and lnsci.idat <= endtime no-lock:
     if  lnsci.flp > 0  then
        tempf.prcc = tempf.prcc + lnsci.paid.
    end.
end.

accumulate tempf.obor (total by tempf.code).
accumulate tempf.obor1 (total  by tempf.code).

if first-of (substring(tempf.cif,1,6)) then do:
v-sum = 0.
v-sum1 = 0.

find first cif where cif.cif = substring(tempf.cif,1,6) no-lock no-error.
/*if  tempf.saldo_1 <> 0 or tempf.saldo_2 <> 0 or tempf.saldo_3 <> 0 then do:*/
put unformatted "<TR><TD>" cif.prefix + " " cif.name  "</TD>" skip
                    "<TD>" tempf.cif "</TD>" skip
                    "<TD>" tempf.saldo_1 "</TD>" skip
                    "<TD>" tempf.doh  "</TD>" skip
                    "<TD>" tempf.saldo_2 "</TD>" skip
                    "<TD>" tempf.doh1 "</TD>" skip
                    "<TD>"  "</TD>" skip
                    "<TD>"  "</TD>" skip
                    "<TD>"  "</TD>" skip
                    "<TD>"  "</TD>" skip
                    "<TD>" tempf.prc "</TD>" skip
                    "<TD>"  "</TD>" skip
                    "<TD>" tempf.prcc "</TD></TR>" skip.

/*end.*/
end.

v-sum = v-sum + tempf.for1.
v-sum1 = v-sum1 + tempf.for2.

find first tarifex where tarifex.str5 = tempf.code no-lock no-error.
put unformatted "<TR><TD>"  "</TD>" skip
                    "<TD>"  "</TD>" skip
                    "<TD>"  "</TD>" skip
                    "<TD>" (accum total by tempf.code tempf.obor) "</TD>" skip
                    "<TD>"  "</TD>" skip
                    "<TD>" (accum total by tempf.code tempf.obor1) "</TD>" skip
                    "<TD>" tempf.code "</TD>" skip
                    "<TD>" tempf.ntar "</TD>" skip.
                 if tempf.ost <> 0 then
put unformatted
                    "<TD>" tempf.ost "</TD>" skip.
                 else
put unformatted
                    "<TD>" tempf.osts "</TD>" skip.
put unformatted
                    "<TD>" tempf.whn "</TD>" skip
                    "<TD>" "</TD>" skip.
                 if tempf.ost1 <> 0 then
put unformatted
                    "<TD>" tempf.ost1 "</TD>" skip.
                 else
put unformatted
                    "<TD>" tempf.osts1 "</TD>" skip.
put unformatted
                    "<TD>" "</TD></TR>" skip.


if last-of (substring(tempf.cif,1,6)) then do:
put unformatted "<tr><td> ИТОГО: </td>" skip
                "<td> </td> <td> </td> "    skip
                "<td>" v-sum "</td>"   skip
                "<td></td>" skip
                "<td>" v-sum1 "</td>"   skip
                "<td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>"    skip.
end.
end.
end.


if ind1 = 2 then do:
put unformatted
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Наименование</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">Tкод</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Обороты по<br>дебету" stime "-" endtime "</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">Доходность<br>(1-й период)</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"" valign = ""top"">Обороты по<br>дебету" stime1 "-" endtime1 "</FONT></TD>" skip
     "<TD   bgcolor=""#95B2D1"">Доходность<br>(2-й период)</FONT></TD>" skip.
if ind = 1 then do:
put unformatted
     "<TD   bgcolor=""#95B2D1"" valign = ""top""><br>Увеличение<br>процентов</FONT></TD>" skip.
end.
if ind = 2 then do:
put unformatted
     "<TD   bgcolor=""#95B2D1"" valign = ""top""><br>Уменьшение<br>процентов</FONT></TD>" skip.
end.
put unformatted
     "<TD   bgcolor=""#95B2D1"">Вознаграж<br>дение по <br>кредитам</FONT></TD></tr>" skip.

for each tempf where tempf.prc >= v-prc and
                     tempf.saldo_3 < 0 and
                     tempf.obor > 0 and
                     tempf.obor1 > 0
                     use-index dcod no-lock break by substring(tempf.cif,1,6).


for each lon where lon.cif = substring(tempf.cif,1,6) use-index cif  no-lock.
 if  lon.rdt <= endtime then
    for each lnsci where lnsci.lni = lon.lon and lnsci.idat >= stime and lnsci.idat <= endtime no-lock:
     if  lnsci.flp > 0  then
        tempf.prcc = tempf.prcc + lnsci.paid.
    end.
end.

if last-of(substring(tempf.cif,1,6)) then do:
   find first cif where cif.cif = substring(tempf.cif,1,6) no-lock no-error.
/*   if (tempf.obor <> 0 or tempf.obor1 <> 0) then do:*/
      put unformatted "<TR><TD>" cif.prefix + " " cif.name "</TD>" skip
                      "<TD>" tempf.cif "</TD>" skip
                      "<TD>" tempf.obor "</TD>" skip
                      "<TD>" tempf.doh "</TD>" skip
                      "<TD>" tempf.obor1 "</TD>" skip
                      "<TD>" tempf.doh1 "</TD>" skip
                      "<TD>" tempf.prc "</TD>" skip
                      "<TD>" tempf.prcc "</TD></TR>" skip.
/*   end.*/
end.

end.
end.

put unformatted "</TABLE>" skip.
unix silent cptwin txt1.htm excel.


