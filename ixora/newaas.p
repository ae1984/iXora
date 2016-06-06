/* newaas.p
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
 * AUTHOR
        01.12.2004 saltanat
 * CHANGES
        09.08.2005 dpuchkov добавил не попадающие специнструкции
        26.09.2005 dpuchkov переделал вывод в excel
        13.01.2006 dpuchkov добавил удаленные специнструкции в отдельный пункт
        05/01/2009 madiyar - лого тянулось со сберовского сайта, исправил
        11/05/2011 evseev - поставил "'" перед значениями рнн и сумма
        25/05/2011 lyubov - добавлен столбец "Остаток на счете", отображаемый на конечную дату загружаемого периода
        01/06/2011 lyubov - перекомпиляция
        17.06.2011 ruslan - добавил выбор физ и юр лиц, добавил столбцы для удаленных, изменил описание для автоматических вызовов, поставил фильтр на закрытые счета, изменил заголовки отчетов
        21.06.2011 ruslan - изменил выборку из aas, параметр whn на regdt
        24.06.2011 ruslan - добавил основание удаление, которое отображается в ink4.
        05.12.2011 evseev - ТЗ-625. переход на ИИН/БИН
        02.07.2013 yerganat - tz1889, добавление вывода счета ГК, формирования консолидированного отчета
*/

{mainhead.i}
{chbin.i}

def var v-osn as char init 'k2,k-2,к2,К2,предписание,к-2,арест,K-2 предписание,Приост операций за искл бюджет,Полное приостановл. операций,Приост за искл бюджет и пенсион,Приост опер за искл пенсионных'.
def new shared temp-table t-aas
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
    field ost as char format 'x(14)'
    field gl  like aaa.gl.


def new shared var d_date as date.
def new shared var d_date_fin as date.
def new shared var v_type as char init "b".
def new shared var ost as deci init '0'.

def var i_n as integer.
def var v-dep1 as integer.
def var v-path as char no-undo.
v-path = '/data/b'.

d_date = g-today.
d_date_fin = g-today.

  update d_date label "Дата с" with centered side-label.
  update d_date_fin label "по" with centered side-label.
  message "Выберите В для Юр лиц или Р для физ лиц".
  update v_type label "Тип клиента" with centered side-label.


find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.
find comm.txb where comm.txb.consolid and comm.txb.bank = bank.sysc.chval no-lock no-error.

if not comm.txb.is_branch then do:
  {sel-filial.i}
end.
else do:
  v-select = comm.txb.txb + 2.
end.

run sel2 (" Отчеты ", " Текущие специнструкции | Удаленные специнструкции" , output v-dep1).

if  v-dep1 = 1 then do:
  for each comm.txb where comm.txb.consolid and
          (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
     if connected ("txb") then disconnect "txb".
     connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
     run newaas_1.p.
  end.
  if connected ("txb")  then disconnect "txb".
end.


display "Ждите идет формирование отчета..."  with row 12 frame ww centered.
pause 0.




if v-dep1 = 2 then do:
  for each comm.txb where comm.txb.consolid and
          (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
     if connected ("txb") then disconnect "txb".
     connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
     run newaas_2.p.
  end.
  if connected ("txb")  then disconnect "txb".
end.


display "Ждите идет формирование отчета..."  with row 12 frame ww1 centered.
pause 0.




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
 if v-bin then put stream vcrpt unformatted "<TD><FONT size=""2""><B>БИН клиента</B></FONT></TD>" skip.
 else put stream vcrpt unformatted "<TD><FONT size=""2""><B>РНН клиента</B></FONT></TD>" skip.
 put stream vcrpt unformatted "<TD><FONT size=""2""><B>Номер счета</B></FONT></TD>" skip
 "<TD><FONT size=""2""><B>счет ГК</B></FONT></TD>" skip
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

   if v-bin then put stream vcrpt unformatted "<TD><FONT size=""2""> '" + string(t-aas.bin) + "</FONT></TD>"    skip.
   else put stream vcrpt unformatted "<TD><FONT size=""2""> '" + string(t-aas.jss) + "</FONT></TD>"    skip.

   put stream vcrpt unformatted "<TD><FONT size=""2""> '" + t-aas.aaa + "</FONT></TD>"            skip
   "<TD><FONT size=""2"">" + string(t-aas.gl) + "</FONT></TD>"    skip
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


