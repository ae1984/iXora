/* kztcout.p
 * MODULE
     Коммунальные платежи
 * DESCRIPTION
     Подготовка и отправка файла платежей Казахтелеком в формате DBF
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.1.2
 * AUTHOR
        01/01/02 pragma
 * CHANGES
     20.09.2002 kanat - добавил формирование файлов в формате DBF
     13.07.2003 kanat - добавил при отправке платежей в файле поиск только по счету - извещению
     17.09.2003 sasco - поменял наименование файла DBF на TXddmmyy.DBF
     31.10.2003 kanat - формирование файла берется из справочника
     16.01.2004 nadejda - отправитель письма по эл.почте изменен на общий адрес abpk@elexnet.kz
     10.01.2004 kanat - поставил фильтр на отсутствие лицевых счетов абонентов при отпрапвке файлов в Алматытелеком
     01.09.2005 kanat - добавил формирование файлов для филиала в г. Астана
     16.11.2005 suchkov - поменял казахтелекомовский email
     11/04/2006 u00568 Evgeniy - открыли Атырау
     03/05/2006 u00568 Evgeniy - открыли Уральск
     11.09.2006 dpuchkov разделил отправку платежей по файлам (биллинг/обычные).
     02.10.2006 u00124 исправил грамматическую ошибку. 
*/

{get-dep.i}
{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var dat1 as date initial today.
def var dat2 as date initial today.
def var dat as date.
def var files as char initial "".
def var ftxt as char initial "".
def var subj as char.
def var selgrp  as integer init 3.
def var selarp  as char.
def var str as char.
def var count_rec as integer init 0.
def var sum_final as decimal init 0.
def var sum_send as decimal init 0.
def var choiceout as logical init false.
def var choiceout1 as logical init false.
def var outtxt as char.
def var s_ack as char.
def var s_izv as char.

def var crlf as char.
crlf = chr(13) + chr(10).

def var v-bank-id as char.
def var v-email-name as char.

update dat1 label "Начальная дата" dat2 label "Конечная дата".
DEFINE STREAM s1.
DEFINE STREAM s2.
def var out as char.
dat = dat1.

/*if seltxb = 0 then selgrp = 3.*/

if seltxb = 1 then
   selgrp = 10.


find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
           commonls.visible = yes no-lock no-error.

selarp = commonls.arp.

display trim(OS-GETENV("DBDIR")) label "OS directory: ".

do while dat <= dat2 with frame f1 no-box no-labels:

/*
out = "Tx" + string(dat, "999999" ) + "." + "dbf".
*/

if seltxb = 0 then
out = "TX" + string(day(dat), "99") + string(month(dat), "99") + substr(string(year(dat), "9999"), 3) + "." + "dbf".

if seltxb = 1 then
out = "frombank.dbf".

if seltxb = 2 then
  out = "frombank.dbf".

if seltxb = 3 then
  out = "frombank.dbf".



 outtxt = "Tx" + string(dat, "99.99.99" ).
 substr(outtxt, 5, 1) = "".

 OUTPUT STREAM s1 TO value(out).
 OUTPUT STREAM s2 TO value(outtxt).

 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and
                         commonpl.deluid = ? and
                         commonpl.arp = selarp and
                         commonpl.grp = selgrp no-lock:


/* Уже есть в биллинге */
if commonpl.billing <> "1" then do:

        count_rec = 0.

    PUT STREAM s2 "14" + string(get-dep(uid, dat),"99") format "9999" " "
        commonpl.counter format "999999" " "
        commonpl.fioadr format "x(15)" " "
        commonpl.sum format ">>>>>>>>9.99" " "
        left-trim(string(commonpl.dnum,">>>>>>9")) format "x(5)"  " "
        commonpl.date
        chr(13) format "9"
        skip.


        find first kaztelsp where kaztelsp.statenmb = commonpl.fioadr and kaztelsp.accnt = commonp.accnt no-lock no-error.
        if avail kaztelsp then do:
        s_izv = trim(kaztelsp.statenmb).
        s_ack = string(kaztelsp.accnt).
        end.
        else do:
        if commonpl.accnt <> 0 then do:
        s_izv = commonpl.fioadr.
        s_ack = string(commonpl.accnt).
        end.
        else do:
        message "Отсутствует счет извещения абонента" view-as alert-box title "Внимание".
        return.
        end.
        end.


        if seltxb = 0 then
           v-bank-id = "0007".

        if seltxb = 1 then
           v-bank-id = "0098".

        if seltxb = 2 then
           v-bank-id = "2222".

        if seltxb = 3 then
           v-bank-id = "3333".


        str = v-bank-id + "|" +
              trim(string(commonpl.rko)) + "|" +
              s_izv + "|" +
              s_ack + "|" +
              string(day(commonpl.date),"99") + "." +
              string(month(commonpl.date),"99") + "." +
              string(year(commonpl.date)) + " " +
              string(commonpl.cretime,"HH:MM:SS") + "|" +
              trim(string(commonpl.dnum)) + "|" +
              trim(string(commonpl.sum)).



        count_rec = count_rec + 1.
        put stream s1 unformatted str crlf.
        sum_final = sum_final + commonpl.sum.
end.
 END.

 OUTPUT STREAM s1 CLOSE.
 OUTPUT STREAM s2 CLOSE.

           unix SILENT value('kztdbf.pl 1 ' /* + string(count_rec,">>>>>>9") */ + ' ' + out).

 if sum_final > 0 then do:
     files = files + ";" + out.
     ftxt = ftxt + ";" + outtxt.
     display
     "Сформирован файл "
     out format "x(9)"
     " на сумму "
     sum_final.
   end.

 dat = dat + 1.
 sum_send = sum_send + sum_final.
 sum_final = 0.
end.

substr(files,1,1) = "".


if seltxb = 0 then do:
if files = "" then subj = "С " + string(dat1,"99.99.99") + " по " + string(dat2,"99.99.99") + " платежей не было.".
else subj = "Платежи АлматыТелеком с " + string(dat1,"99.99.99") + " по " + string(dat2,"99.99.99").
end.

if seltxb = 1 then do:
subj = "frombank".
end.


   if seltxb = 0 then
      v-email-name = "municipal" + comm-txb() + "@elexnet.kz,oud@almatytelecom.kz".

   if seltxb = 1 then
      v-email-name = "municipal" + comm-txb() + "@elexnet.kz,bank@at.kz".

   if seltxb = 2 then
      v-email-name = "municipal" + comm-txb() + "@elexnet.kz,ruslan@elexnet.kz".

   if seltxb = 3 then
      v-email-name = "municipal" + comm-txb() + "@elexnet.kz,mvishenin@elexnet.kz".




MESSAGE "Отправить платежи АлматыТелеком по e-mail на общую сумму"
    sum_send " тенге ?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи Казахтелеком" UPDATE choiceout1.

        case choiceout1:
        when true then do:
          run mail(v-email-name, "TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files).
          run mail("dpuchkov@elexnet.kz","TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
        end.
        when false then
         return.
         end.


unix SILENT value('rm -f ' + out).
unix SILENT value('rm -f Tx*').






sum_send = 0.
sum_final = 0.
count_rec = 0.
files = "".

dat = dat1.

do while dat <= dat2 with frame f2 no-box no-labels:


if seltxb = 0 then
out = "ONLINE_TX" + string(day(dat), "99") + string(month(dat), "99") + substr(string(year(dat), "9999"), 3) + "." + "dbf".

if seltxb = 1 then
out = "frombank.dbf".

if seltxb = 2 then
  out = "frombank.dbf".

if seltxb = 3 then
  out = "frombank.dbf".



 outtxt = "Tx" + string(dat, "99.99.99" ).
 substr(outtxt, 5, 1) = "".

 OUTPUT STREAM s1 TO value(out).
 OUTPUT STREAM s2 TO value(outtxt).

 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and
                         commonpl.deluid = ? and
                         commonpl.arp = selarp and
                         commonpl.grp = selgrp no-lock:


/* Уже есть в биллинге */
if commonpl.billing = "1" then do:

        count_rec = 0.

    PUT STREAM s2 "14" + string(get-dep(uid, dat),"99") format "9999" " "
        commonpl.counter format "999999" " "
        commonpl.fioadr format "x(15)" " "
        commonpl.sum format ">>>>>>>>9.99" " "
        left-trim(string(commonpl.dnum,">>>>>>9")) format "x(5)"  " "
        commonpl.date
        chr(13) format "9"
        skip.


        find first kaztelsp where kaztelsp.statenmb = commonpl.fioadr and kaztelsp.accnt = commonp.accnt no-lock no-error.
        if avail kaztelsp then do:
        s_izv = trim(kaztelsp.statenmb).
        s_ack = string(kaztelsp.accnt).
        end.
        else do:
        if commonpl.accnt <> 0 then do:
        s_izv = commonpl.fioadr.
        s_ack = string(commonpl.accnt).
        end.
        else do:
        message "Отсутствует счет извещения абонента" view-as alert-box title "Внимание".
        return.
        end.
        end.

        if seltxb = 0 then v-bank-id = "0007".
        if seltxb = 1 then v-bank-id = "0098".
        if seltxb = 2 then v-bank-id = "2222".
        if seltxb = 3 then v-bank-id = "3333".

        str = v-bank-id + "|" +
              trim(string(commonpl.rko)) + "|" +
              s_izv + "|" +
              s_ack + "|" +
              string(day(commonpl.date),"99") + "." +
              string(month(commonpl.date),"99") + "." +
              string(year(commonpl.date)) + " " +
              string(commonpl.cretime,"HH:MM:SS") + "|" +
              trim(string(commonpl.dnum)) + "|" +
              trim(string(commonpl.sum)).



        count_rec = count_rec + 1.
        put stream s1 unformatted str crlf.
        sum_final = sum_final + commonpl.sum.
end.
 END.

 OUTPUT STREAM s1 CLOSE.
 OUTPUT STREAM s2 CLOSE.

           unix SILENT value('kztdbf.pl 1 ' /* + string(count_rec,">>>>>>9") */ + ' ' + out).

 if sum_final > 0 then do:
     files = files + ";" + out.
     ftxt = ftxt + ";" + outtxt.
     display
     "Сформирован файл "
     out format "x(9)"
     " на сумму "
     sum_final.
   end.

 dat = dat + 1.
 sum_send = sum_send + sum_final.
 sum_final = 0.
end.

substr(files,1,1) = "".


if seltxb = 0 then do:
if files = "" then subj = "С " + string(dat1,"99.99.99") + " по " + string(dat2,"99.99.99") + " биллинг платежей не было.".
else subj = "Биллинг платежи АлматыТелеком с " + string(dat1,"99.99.99") + " по " + string(dat2,"99.99.99").
end.

if seltxb = 1 then do:
subj = "frombank".
end.


   if seltxb = 0 then
      v-email-name = "oud@almatytelecom.kz".

   if seltxb = 1 then
      v-email-name = "municipal" + comm-txb() + "@elexnet.kz,bank@at.kz".

   if seltxb = 2 then
      v-email-name = "municipal" + comm-txb() + "@elexnet.kz,ruslan@elexnet.kz".

   if seltxb = 3 then
      v-email-name = "municipal" + comm-txb() + "@elexnet.kz,mvishenin@elexnet.kz".




MESSAGE "Отправить Биллинг платежи АлматыТелеком по e-mail на общую сумму"
    sum_send " тенге ?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи Казахтелеком" UPDATE choiceout1.

        case choiceout1:
        when true then
        do:
          run mail(v-email-name, "TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
          run mail("dpuchkov@elexnet.kz","TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
        end.
        when false then
         return.
         end.


unix SILENT value('rm -f ' + out).
unix SILENT value('rm -f Tx*').


