/* r-reestr.p                                                                                   "C:\Documents and Settings\id00005\Desktop\Far.lnk"
 * MODULE
        Реестр принятых, отправленных переводов
 * DESCRIPTION
        Реестр принятых, отправленных переводов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        освное меню Список скриптов, вызывающих этот файл
 * INHERIT

* MENU
        5-8-7
 * AUTHOR
        14.07.05 nataly
 * CHANGES
        28.07.05 nataly разделен отчет для филиалов и ГО
        17/01/06 nataly добавлен раздел Подлежащие выплате
        04/04/06 nataly добавила признак банка-получателя
        30/05/08 marinav - добавление поля РНН
        31/03/11 dmitriy - добавление временных таблиц tt-rtranslat, tt-translat
                         - добавил подключение ко всем филиалам для заполнения ФИО-менеджера
                         - изменил вывод выплаченных и отправленныхплатежей
                         - убрал условие (today - translat.date) <= 45 при заполнении отправленных переводов.
        04/04/2011 madiyar - небольшие исправления
        12/04.2011 marinav - добавила при выплате or (if nmbr.prefix = 'МК16' then  r-translat.rec-code = 'МК00' else true))
        15/03/2012 id00810 - добавила v-bankname для печати
        04/05/2012 evseev - наименование банка из banknameDgv
*/


def stream vcrpt.
output stream vcrpt to rpt.html.
def var v-crc as char.
def var v-sum as char.
def var s-date as date.
def var e-date as date.
def var i as integer init 1.

def new shared temp-table tt-rtranslat
   field number as char
   field date like r-translat.date
   field nomer like r-translat.nomer
   field summa like r-translat.summa
   field crc like r-translat.crc
   field summ-com like r-translat.summ-com
   field rec-fam like r-translat.rec-fam
   field rec-name like r-translat.rec-name
   field rec-otch like r-translat.rec-otch
   field rec-code like r-translat.rec-code
   field jh like r-translat.jh
   field stat like r-translat.stat
   field rec-bank like r-translat.rec-bank
   field who like r-translat.who
   field ofc-name as char
   index idx is primary crc date nomer
   index idx2 ofc-name.

def new shared temp-table tt-translat
   field number as char
   field date like translat.date
   field nomer like translat.nomer
   field summa like translat.summa
   field crc like translat.crc
   field commis like translat.commis
   field rec-fam like translat.rec-fam
   field rec-name like translat.rec-name
   field rec-otch like translat.rec-otch
   field jh like translat.jh
   field stat like translat.stat
   field who like translat.who
   field ofc-name as char
   index idx is primary crc date nomer
   index idx2 ofc-name.

def var v-path     as char no-undo.
def var v-bankname as char no-undo.

    find first bank.cmp no-lock no-error.
    if not avail bank.cmp then do:
        message " Не найдена запись cmp " view-as alert-box error.
    end.
    find first sysc where sysc.sysc = "banknameDgv" no-lock no-error.
    if avail sysc then v-bankname = sysc.chval.

    if  bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
    else v-path = '/data/b'.


{opr-stat.i}

function rec-opr-stat return char (stat as int).
    case stat:
      when 1 then
        return ("Доставлен").
      when 11 then
        return ("Подтвер").
      when 2 then
        return ("Выплачен").
      when 3 then
        return ("Отменен").
      when 4 then
        return ("Возвращен").
    end.
end function.

{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}


 update s-date format "99/99/9999" label "Введите дату С "
        e-date format "99/99/9999" label  "По" with frame www row 1 col 5.
 find nmbr where nmbr.code = 'translat' no-lock no-error.
 find first spr_bank where spr_bank.code = nmbr.prefix no-lock no-error.
  if not avail spr_bank then do:
    message " Не найден банк отправитель перевода в таблице spr_bank!".
    pause 3.
    return.
  end.

if nmbr.prefix <> 'МК00' then
  put stream vcrpt unformatted "<p align=""right""><b> Реестр принятых/отправленных платежей за период   с " string(s-date) " ПО " string(e-date) "<br>"
                               spr_bank.name "</b></p>".
  else   put stream vcrpt unformatted "<p align=""right""><b> Консолидированный реестр принятых/отправленных платежей за период   с " string(s-date) " ПО " string(e-date) "</b></p>".


/*ВЫПЛАЧЕННЫЕ*/


for each r-translat no-lock where ((if nmbr.prefix <> 'МК00' then  r-translat.rec-code = nmbr.prefix else true) or (if nmbr.prefix = 'МК16' then  r-translat.rec-code = 'МК00' else true)) and
    r-translat.date >= s-date and r-translat.date <= e-date  and stat = 2.
    create tt-rtranslat.
    assign
        tt-rtranslat.date = r-translat.date.
        tt-rtranslat.nomer = r-translat.nomer.
        tt-rtranslat.summa =  r-translat.summa.
        tt-rtranslat.crc = r-translat.crc.
        tt-rtranslat.summ-com =  r-translat.summ-com.
        tt-rtranslat.rec-fam =  r-translat.rec-fam.
        tt-rtranslat.rec-name =  r-translat.rec-name.
        tt-rtranslat.rec-otch =  r-translat.rec-otch.
        tt-rtranslat.rec-code = r-translat.rec-code.
        tt-rtranslat.jh =  r-translat.jh.
        tt-rtranslat.stat =  r-translat.stat.
        tt-rtranslat.rec-bank =  r-translat.rec-bank.
        tt-rtranslat.who =  r-translat.who.
        tt-rtranslat.ofc-name =  ofc-name.
end.

/*ОТПРАВЛЕННЫЕ*/
i = 1.
for each translat no-lock where (if nmbr.prefix <> 'МК00' then  translat.nomer begins nmbr.prefix else true) and
    translat.date >= s-date and translat.date <= e-date and translat.stat >= 2  /*and (today - translat.date) <= 45*/.
    create tt-translat.
    assign
        tt-translat.number = string(i).
        tt-translat.date =  translat.date.
        tt-translat.nomer =  translat.nomer.
        tt-translat.summa =  translat.summa.
        tt-translat.crc = translat.crc.
        tt-translat.commis =  translat.commis.
        tt-translat.rec-fam =  translat.rec-fam.
        tt-translat.rec-name =  translat.rec-name.
        tt-translat.rec-otch =  translat.rec-otch.
        tt-translat.jh =  translat.jh.
        tt-translat.stat =  translat.stat.
        tt-translat.who =  translat.who.
        tt-translat.ofc-name =  ofc-name.
end.

for each comm.txb where comm.txb.consolid and comm.txb.logname <> "rkc" no-lock:
    find first tt-rtranslat where tt-rtranslat.ofc-name = '' no-lock no-error.
    find first tt-translat where tt-translat.ofc-name = '' no-lock no-error.
    if (not avail tt-rtranslat) and (not avail tt-translat) then leave.
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run find-ofc.
end.
if connected ("txb") then disconnect "txb".

/*ВЫПЛАЧЕННЫЕ*/

put stream vcrpt unformatted
   "<TABLE width=""75%"" border=""1"" cellspacing=""0"" cellpadding=""10"">" skip
   "<TR align=""center"">" skip
     "<TD width=""40%"" colspan = 9><FONT size=""1""><B> Выплаченные АО " v-bankname " переводы </B></FONT></TD></TR>" skip
     "<TR><TD width=""40%""><FONT size=""1""><B>N </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Дата </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Количество </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>УКН </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Сумма </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Валюта </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Комиссия </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Получатель </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Номер проводки </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Статус </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Банк-получатель </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Ф.И.О. менеджера </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>id менеджера </B></FONT></TD></TR>" skip.


for each tt-rtranslat no-lock break by tt-rtranslat.crc.
    accum tt-rtranslat.summa  (total by tt-rtranslat.crc).
    accum tt-rtranslat.summ-com (total by tt-rtranslat.crc).
    accum tt-rtranslat.summa (count by tt-rtranslat.crc).

    find crc where crc.crc = tt-rtranslat.crc no-lock no-error.
    if avail crc then v-crc = crc.code.
    put stream vcrpt unformatted
       "<TR align=""left"">" skip
         "<TD width=""40%"" ><FONT size=""1"">" string(i)       "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" tt-rtranslat.date "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">      1           </FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" tt-rtranslat.nomer    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" replace(trim(string(tt-rtranslat.summa,">>>>>>>>>>>9.99")),'.',',') "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" v-crc    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" replace(trim(string(tt-rtranslat.summ-com,">>>>>>>>>>>9.99")),'.',',') "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" tt-rtranslat.rec-fam + " " +  tt-rtranslat.rec-name + " "  + tt-rtranslat.rec-otch    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" tt-rtranslat.jh   "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" rec-opr-stat(tt-rtranslat.stat)    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" tt-rtranslat.rec-bank    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" tt-rtranslat.ofc-name    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" tt-rtranslat.who    "</FONT></TD></TR>" skip.
    if last-of(tt-rtranslat.crc) then
        put stream vcrpt unformatted
            "<TR align=""left"">" skip
            "<TD width=""40%"" ><FONT size=""1""><B> ИТОГО " v-crc "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b> " accum  count by tt-rtranslat.crc tt-rtranslat.summa     " </b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b>" accum  total by tt-rtranslat.crc tt-rtranslat.summa   "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b>" accum  total by tt-rtranslat.crc tt-rtranslat.summ-com   "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip.
    i = i + 1.
end.
put stream vcrpt unformatted "</TR> </TABLE>".

put stream vcrpt unformatted "<p></p><br><br><br>".

/*ОТПРАВЛЕННЫЕ*/
i = 1.
put stream vcrpt unformatted
   "<TABLE width=""75%"" border=""1"" cellspacing=""0"" cellpadding=""9"">" skip
   "<TR align=""center"">" skip
     "<TD width=""40%"" colspan = 9><FONT size=""1""><B> Отправленные АО " v-bankname " переводы </B></FONT></TD></TR>" skip
     "<TR><TD width=""40%""><FONT size=""1""><B>N </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Дата </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Количество </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>УКН </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Сумма </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Валюта </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Комиссия </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Отправитель </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Номер проводки </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Статус </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Ф.И.О. менеджера </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>id менеджера </B></FONT></TD></TR>" skip.

for each tt-translat no-lock break by tt-translat.crc.
    accum tt-translat.summa  (total by tt-translat.crc).
    accum tt-translat.commis (total by tt-translat.crc).
    accum tt-translat.summa (count by tt-translat.crc).

    find crc where crc.crc = tt-translat.crc no-lock no-error.
    if avail crc then v-crc = crc.code.
    put stream vcrpt unformatted
        "<TR align=""left"">" skip
        "<TD width=""40%"" ><FONT size=""1"">" string(i)       "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" tt-translat.date "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">      1           </FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" tt-translat.nomer    "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" replace(trim(string(tt-translat.summa,">>>>>>>>>>>9.99")),'.',',') "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" v-crc    "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" replace(trim(string(tt-translat.commis,">>>>>>>>>>>9.99")),'.',',') "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" tt-translat.rec-fam + " " +  tt-translat.rec-name + " "  + tt-translat.rec-otch    "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" tt-translat.jh   "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" opr-stat(tt-translat.stat)  "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" tt-translat.ofc-name  "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" tt-translat.who  "</FONT></TD></TR>" skip.
    if last-of(tt-translat.crc) then
        put stream vcrpt unformatted
            "<TR align=""left"">" skip
            "<TD width=""40%"" ><FONT size=""1""><B> ИТОГО " v-crc "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b> " accum  count by tt-translat.crc tt-translat.summa     " </b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b>" accum  total by tt-translat.crc tt-translat.summa   "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b>" accum  total by tt-translat.crc tt-translat.commis   "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip.
    i = i + 1.
end.
put stream vcrpt unformatted "</TR> </TABLE>".

put stream vcrpt unformatted "<p></p><br><br><br>".


/*ПЕРЕВОДЫ ДЛЯ ВЫПЛАТЫ*/
 i = 1.
put stream vcrpt unformatted
   "<TABLE width=""75%"" border=""1"" cellspacing=""0"" cellpadding=""10"">" skip
   "<TR align=""center"">" skip
     "<TD width=""40%"" colspan = 9><FONT size=""1""><B> Переводы для выплаты  </B></FONT></TD></TR>" skip
     "<TR><TD width=""40%""><FONT size=""1""><B>N </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Дата </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Количество </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>УКН </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Сумма </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Валюта </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Комиссия </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Получатель </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Номер проводки </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Статус </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Банк-получатель</B></FONT></TD></TR>" skip.

for each r-translat no-lock where  (if nmbr.prefix <> 'МК00' then  r-translat.rec-code = nmbr.prefix else true) and
       r-translat.date  <=  e-date /*- 5*/ and r-translat.stat  = 1 break /*by r-translat.stat*/ by r-translat.crc.
    accum r-translat.summa  (total by r-translat.crc).
    accum r-translat.summ-com (total by r-translat.crc).
    accum r-translat.summa (count by r-translat.crc).

    find crc where crc.crc = r-translat.crc no-lock no-error.
    if avail crc then v-crc = crc.code.
    put stream vcrpt unformatted
        "<TR align=""left"">" skip
        "<TD width=""40%"" ><FONT size=""1"">" string(i)       "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" r-translat.date "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">      1           </FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" r-translat.nomer    "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" replace(trim(string(r-translat.summa,">>>>>>>>>>>9.99")),'.',',') "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" v-crc    "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" replace(trim(string(r-translat.summ-com,">>>>>>>>>>>9.99")),'.',',') "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" r-translat.rec-fam + " " +  r-translat.rec-name + " "  + r-translat.rec-otch    "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" r-translat.jh   "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" rec-opr-stat(r-translat.stat) "</FONT></TD>" skip
        "<TD width=""40%"" ><FONT size=""1"">" r-translat.rec-bank    "</FONT></TD></TR>" skip.
    if last-of(r-translat.crc) then
        put stream vcrpt unformatted
            "<TR align=""left"">" skip
            "<TD width=""40%"" ><FONT size=""1""><B> ИТОГО " v-crc "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b> " accum  count by r-translat.crc r-translat.summa     " </b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b>" accum  total by r-translat.crc r-translat.summa   "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b>" accum  total by r-translat.crc r-translat.summ-com   "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip.
    i = i + 1.
end.
put stream vcrpt unformatted "</TR> </TABLE>".

put stream vcrpt unformatted "<p></p><br><br><br>".

/*ПОДЛЕЖАЩИЕ ВОЗВРАТУ*/
i = 1.
put stream vcrpt unformatted
   "<TABLE width=""75%"" border=""1"" cellspacing=""0"" cellpadding=""9"">" skip
   "<TR align=""center"">" skip
     "<TD width=""40%"" colspan = 9><FONT size=""1""><B> Подлежащие возврату в АО " v-bankname " переводы </B></FONT></TD></TR>" skip
     "<TR><TD width=""40%""><FONT size=""1""><B>N </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Дата </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Количество </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>УКН </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Сумма </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Валюта </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Комиссия </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Отправитель </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Номер проводки </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Статус </B></FONT></TD></TR>" skip.

for each translat no-lock where (if nmbr.prefix <> 'МК00' then translat.nomer begins nmbr.prefix else true)
    /*and
    translat.date >= s-date and translat.date <= e-date*/ and (translat.stat = 2 or translat.stat = 3)
    and (today - translat.date) > 45 break /*by translat.stat*/ by translat.crc.
    accum translat.summa  (total by translat.crc).
    accum translat.commis (total by translat.crc).
    accum translat.summa (count by translat.crc).

    find crc where crc.crc = translat.crc no-lock no-error.
    if avail crc then v-crc = crc.code.
    put stream vcrpt unformatted
       "<TR align=""left"">" skip
         "<TD width=""40%"" ><FONT size=""1"">" string(i)       "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" translat.date "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">      1           </FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" translat.nomer    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" replace(trim(string(translat.summa,">>>>>>>>>>>9.99")),'.',',') "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" v-crc    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" replace(trim(string(translat.commis,">>>>>>>>>>>9.99")),'.',',') "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" translat.rec-fam + " " +  translat.rec-name + " "  + translat.rec-otch    "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" translat.jh   "</FONT></TD>" skip
         "<TD width=""40%"" ><FONT size=""1"">" opr-stat(translat.stat)  "</FONT></TD></TR>" skip.
    if last-of(translat.crc) then
        put stream vcrpt unformatted
            "<TR align=""left"">" skip
            "<TD width=""40%"" ><FONT size=""1""><B> ИТОГО " v-crc "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b> " accum  count by translat.crc translat.summa     " </b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b>" accum  total by translat.crc translat.summa   "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""><b>" accum  total by translat.crc translat.commis   "</b></FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip
            "<TD width=""40%"" ><FONT size=""1""> </FONT></TD>" skip.
    i = i + 1.
end.
put stream vcrpt unformatted "</TR> </TABLE>".


{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent value("cptwin rpt.html  excel").
pause 0.

