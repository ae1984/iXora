/*newaas2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Новые специнструкции, наложенные сегодня
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
 * BASES
        BANK COMM
 * AUTHOR
        03.06.2011 copyrighter ruslan
 * CHANGES
        03.06.2011 скопировал newaas для пункта 1.3.1.14
        21.06.2011 21.06.2011 ruslan - изменил выборку из aas, параметр whn на regdt
        24.06.2011 ruslan - добавил основание удаление, которое отображается в ink4.
        27.08.2012 evseev - переход на ИИН/БИН
*/

{mainhead.i}
{chbin.i}

def var v-osn as char init 'k2,k-2,к2,К2,предписание,к-2,арест,K-2 предписание,Приост операций за искл бюджет,Полное приостановл. операций,Приост за искл бюджет и пенсион,Приост опер за искл пенсионных'.
def temp-table t-aas
    field cif  like cif.cif
    field name like cif.name
    field aaa  like aaa.aaa
    field tim  like aas.tim
    field jss  like cif.jss
    field bin  like cif.bin
    field prim  as char
    field fnum like aas.fnum
    field whn like aas.whn
    field dt1 as char
    field regdt like aas.regdt
    field prim1 as char
    field whn1 like aas.whn1
    field sum as char format 'x(14)'
    field ost as char format 'x(14)'.

def var d_date as date.
def var d_date_fin as date.
def var v_type as char init "b".
def var i_n as integer.
def var ost as deci init '0'.

def var v-dep1 as integer.
def buffer b-aas_hist for aas_hist.

  d_date = g-today.
  d_date_fin = g-today.

  update d_date label "Дата с" with centered side-label.
  update d_date_fin label "по" with centered side-label.
  message "Выберите В для Юр лиц или Р для физ лиц".
  update v_type label "Тип клиента" with centered side-label.





  run sel2 (" Отчеты ", " Текущие специнструкции | Удаленные специнструкции" , output v-dep1).
  if  v-dep1 = 1 then do:


display "Ждите идет формирование отчета..."  with row 12 frame ww centered.
pause 0.

for each aas where aas.regdt >= d_date and aas.regdt <= d_date_fin and aas.ln <> 7777777 and aas.sta = 0 and (aas.who <> "bankadm" or aas.who <> "superman") /*and lookup(aas.payee,v-osn) > 0*/ no-lock:
find aaa where aaa.aaa = aas.aaa /*and aaa.sta <> "c"*/ no-lock no-error.
if not avail aaa then next.
find cif where cif.cif = aaa.cif and cif.type = v_type no-lock no-error.
if avail cif then do: ost = 0.
find last histrxbal where histrxbal.acc = aaa.aaa and histrxbal.dt le d_date_fin and histrxbal.subled = 'cif' and histrxbal.level = 1 no-lock no-error.
if avail histrxbal then do:
find last crchis where crchis.crc = histrxbal.crc and crchis.whn le histrxbal.dt no-lock no-error.
if avail crchis then do:
     ost = (histrxbal.cam - histrxbal.dam) * crchis.rate[1].
end.
end.

     create t-aas.
     assign
     t-aas.cif =  cif.cif
     t-aas.name = cif.name
     t-aas.aaa  = aaa.aaa
     t-aas.jss  = cif.jss
     t-aas.bin  = cif.bin
     t-aas.prim  = aas.payee
     t-aas.dt1 = string(aas.docdat)
     t-aas.regdt = aas.regdt
     t-aas.ost = "'" + string (ost).

     if aas.fnum <> "" then
        t-aas.fnum = aas.fnum.
     else
        t-aas.fnum = aas.docnum.

     if lookup(string(aas.sta),"4,5,6,8,9,15") <> 0 then
        t-aas.sum = "'" + aas.docprim.
     else
        t-aas.sum = "'" + string (aas.chkamt).

     t-aas.whn = aas.whn.
end.
end.
end.


if v-dep1 = 2 then do:

display "Ждите идет формирование отчета..."  with row 12 frame ww1 centered.
pause 0.

     for each aas_hist where aas_hist.regdt >= d_date and aas_hist.regdt <= d_date_fin and aas_hist.ln <> 7777777 and (aas_hist.chgoper = 'A') and aas_hist.sta = 0 and (aas_hist.who <> "bankadm" or aas_hist.who <> "superman") no-lock:

         find last b-aas_hist where b-aas_hist.aaa = aas_hist.aaa and b-aas_hist.ln = aas_hist.ln and (b-aas_hist.chgoper = 'D' or b-aas_hist.chgoper = 'O' or b-aas_hist.chgoper = 'X') no-lock no-error.
         if avail b-aas_hist then do:

             find aaa where aaa.aaa = b-aas_hist.aaa /*and aaa.sta <> "c"*/ no-lock no-error.
             if not avail aaa then next.
             find cif where cif.cif = aaa.cif and cif.type = v_type no-lock no-error.
             if avail cif then do: ost = 0.
                find last histrxbal where histrxbal.acc = aaa.aaa and histrxbal.dt le d_date_fin and histrxbal.subled = 'cif' and histrxbal.level = 1 no-lock no-error.
                if avail histrxbal then do:
                    find last crchis where crchis.crc = histrxbal.crc and crchis.whn le histrxbal.dt no-lock no-error.
                    if avail crchis then do:
                        ost = (histrxbal.cam - histrxbal.dam) * crchis.rate[1].
                    end.
                end.

                create t-aas.
                assign
                t-aas.cif   = cif.cif /*cif клиента*/
                t-aas.name  = cif.name /*наименование клиента*/
                t-aas.aaa   = aaa.aaa /*счет клиента*/
                t-aas.jss   = cif.jss /*рнн клиента*/
                t-aas.bin   = cif.bin
                t-aas.prim  = b-aas_hist.payee /*вид ограничения*/
                t-aas.dt1   = string(b-aas_hist.docdat) /*дата ограничения*/
                t-aas.regdt = b-aas_hist.regdt /**/
                t-aas.whn1  = b-aas_hist.whn
                t-aas.ost = "'" + string (ost).

                if b-aas_hist.fnum <> "" then
                    t-aas.fnum = b-aas_hist.fnum.
                else
                    t-aas.fnum = b-aas_hist.docnum.

                if lookup(string(b-aas_hist.sta),"4,5,6,8,9,15") <> 0 then
                   t-aas.sum = "'" + b-aas_hist.docprim.
                else
                   t-aas.sum = "'" + string (b-aas_hist.chkamt).
                t-aas.whn = b-aas_hist.whn.

                if b-aas_hist.who = "bankadm" or b-aas_hist.who = "superman" then do:
                     if b-aas_hist.docprim1 <> '' then t-aas.prim1 = b-aas_hist.docprim1.
                     else do:
                        find prev b-aas_hist where b-aas_hist.aaa = aas_hist.aaa and b-aas_hist.ln = aas_hist.ln no-lock no-error.
                            if avail b-aas_hist then do:
                                if b-aas_hist.chgoper = 'A' then t-aas.prim1 = "Введено". else
                                if b-aas_hist.chgoper = 'E' then t-aas.prim1 = "Изменено  ". else
                                if b-aas_hist.chgoper = 'D' then t-aas.prim1 = "Удалено   ". else
                                if b-aas_hist.chgoper = 'P' then t-aas.prim1 = "Опл полн  ". else
                                if b-aas_hist.chgoper = 'L' then t-aas.prim1 = "Опл част  ". else
                                if b-aas_hist.chgoper = 'T' then t-aas.prim1 = "Приост-но ". else
                                if b-aas_hist.chgoper = 'O' then t-aas.prim1 = "Отозвано  ". else
                                if b-aas_hist.chgoper = 'X' then t-aas.prim1 = "Отк Акцепт". else
                                if b-aas_hist.chgoper = 'Q' then t-aas.prim1 = "Действует ".
                            end.
                     end.
                     /*else t-aas.prim1 = "Отзыв по электронному каналу связи".*/
                end.
                else
                    t-aas.prim1 = b-aas_hist.docprim1.
             end.
         end.
     end.
end.



/* вывод отчета в HTML */

def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i
 &stream   = " stream vcrpt "
 &title    = "Cпецинструкции"
 &size-add = "xx-"
}

if v-dep1 = 1 then do:
    put stream vcrpt unformatted
          "<P align = ""left""><img src=""top_logo_bw.gif""></P>"
          "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans""><B>Текущие спец.инструкции за период c " d_date " по " d_date_fin " </B></FONT></P>" skip.
end.
else do:
        put stream vcrpt unformatted
          "<P align = ""left""><img src=""top_logo_bw.gif""></P>"
          "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans""><B>Удаленные спец.инструкции за период c " d_date " по " d_date_fin " </B></FONT></P>" skip.
end.
put stream vcrpt unformatted
"<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" bordercolor=#d8e4f8>" skip.
put stream vcrpt unformatted
"<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip

 "<TD><FONT size=""2""><B>Nпп</B></FONT></TD>" skip

 "<TD><FONT size=""2""><B>CIF-код</B></FONT></TD>" skip
 "<TD><FONT size=""2""><B>Наименование клиента</B></FONT></TD>" skip.
if v-bin then put stream vcrpt unformatted "<TD><FONT size=""2""><B>ИИН/БИН клиента</B></FONT></TD>" skip.
else put stream vcrpt unformatted "<TD><FONT size=""2""><B>РНН клиента</B></FONT></TD>" skip.
put stream vcrpt unformatted "<TD><FONT size=""2""><B>Номер счета</B></FONT></TD>" skip
 "<TD><FONT size=""2""><B>Дата регистрации</B></FONT></TD>" skip
 "<TD><FONT size=""2""><B>Вид ограничения</B></FONT></TD>" skip
 "<TD><FONT size=""2""><B>Номер ограничения</B></FONT></TD>" skip
 "<TD><FONT size=""2""><B>Дата огр-я</B></FONT></TD>" skip
 "<TD><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
 "<TD><FONT size=""2""><B>Остаток на счете</B></FONT></TD>" skip.
if v-dep1 = 2 then do:
    put stream vcrpt unformatted
     "<TD><FONT size=""2""><B>Причина удаления</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата удаления</B></FONT></TD>" skip.
end.
put stream vcrpt unformatted
"</TR>" skip.

i_n = 1.
for each t-aas break by t-aas.cif by t-aas.tim.

put stream vcrpt unformatted
"<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8>"   skip
   "<TD><FONT size=""2"">" + string(i_n) + "</FONT></TD>"       skip
   "<TD><FONT size=""2"">" + t-aas.cif + "</FONT></TD>"         skip
   "<TD><FONT size=""2"">&nbsp;" + t-aas.name + "</FONT></TD>"  skip.
if v-bin then put stream vcrpt unformatted   "<TD><FONT size=""2""> '" + string(t-aas.bin) + "</FONT></TD>"    skip.
else put stream vcrpt unformatted   "<TD><FONT size=""2""> '" + string(t-aas.jss) + "</FONT></TD>"    skip.

put stream vcrpt unformatted   "<TD><FONT size=""2""> '" + t-aas.aaa + "</FONT></TD>"            skip
   "<TD><FONT size=""2"">" + string(t-aas.regdt) + "</FONT></TD>" skip
   "<TD><FONT size=""2"">" + t-aas.prim + "</FONT></TD>"           skip
   "<TD><FONT size=""2""> '" + string(t-aas.fnum) + "</FONT></TD>" skip.



if string(t-aas.dt1) = ? then
   put stream vcrpt unformatted
   "<TD><FONT size=""2"">" + string(" ") + "</FONT></TD>"    skip.
else
   put stream vcrpt unformatted
   "<TD><FONT size=""2"">" + string(t-aas.dt1) + "</FONT></TD>"    skip.
   put stream vcrpt unformatted
   "<TD><FONT size=""2"">" + string(t-aas.sum) + "</FONT></TD>"    skip.
put stream vcrpt unformatted
   "<TD><FONT size=""2"">" + string(t-aas.ost) + "</FONT></TD>"    skip.

if v-dep1 = 2 then do:
    put stream vcrpt unformatted
     "<TD><FONT size=""2"">" + t-aas.prim1 + "</FONT></TD>"           skip
     "<TD><FONT size=""2"">" + string(t-aas.whn1) + "</FONT></TD>" skip.
end.
put stream vcrpt unformatted
"</TR>" skip.
   i_n = i_n + 1.
end.

put stream vcrpt unformatted
"</TABLE>" skip.

put stream vcrpt unformatted
      "<P align = ""left"">" string(g-today,"99/99/9999") "</P>".

{html-end.i "stream vcrpt" }

output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcreestr.htm excel.

hide all.