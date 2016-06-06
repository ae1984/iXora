/* ensrg.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Реестр платежей Астана Энерго Сбыт
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
        19/03/2005 kanat
 * CHANGES
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var dt1 as date.
def var out as char. 
def shared var g-today as date.
dt1 = g-today.
def var crlf as char.
crlf = /*chr(13) + */ chr(10).

def input parameter selgrp   as integer.
def input parameter alldoc   as logical.

define temp-table tcommpl like commonpl.

update dt1 format '99/99/9999' label "Дата " with centered frame df.

if alldoc then do:
     for each commonpl where txb = seltxb and date = dt1 and deluid = ? and commonpl.grp = selgrp no-lock:
         create tcommpl.
         buffer-copy commonpl to tcommpl.
     end.
end.
else do:
{stadsel.i}
     for each commonpl where txb = seltxb and date = dt1 and deluid = ? and commonpl.arp = selarp and 
                             commonpl.grp = selgrp no-lock:
         create tcommpl.
         buffer-copy commonpl to tcommpl.
     end.
end.


output to commpl1.txt.

FOR EACH tcommpl NO-LOCK use-index gatgt BREAK BY tcommpl.arp by tcommpl.valid BY tcommpl.type :

accumulate tcommpl.sum
    (sub-count by tcommpl.type).
    
accumulate tcommpl.sum
    (sub-total by tcommpl.type).

accumulate tcommpl.sum
    (sub-count by tcommpl.arp).
        
accumulate tcommpl.sum
    (sub-total by tcommpl.arp).

accumulate tcommpl.sum
    (count).
        
accumulate tcommpl.sum
    (total).
            
/*    IF FIRST-OF(tcommpl.arp) THEN do:
        find first commonls where commonls.arp = tcommpl.arp use-index arp  no-lock no-error .
        put unformatted space(35) commonls.bn format "x(35)"  crlf  crlf.
    end.*/

    IF FIRST-OF(tcommpl.type) THEN do:
	  find first bank.cmp no-lock no-error. /*03/01/2004 u00121*/
          put unformatted  bank.cmp.name /*03/01/2004 u00121*/  crlf 
                           "                Р Е Е С Т Р  Платежей за " dt1 format "99.99.9999" " г.  ". 

        find first commonls where commonls.txb = seltxb and commonls.arp = tcommpl.arp no-lock no-error.

        put unformatted 
                    trim(commonls.bn) 
                    "  БИК:" commonls.bikbn format "999999999" 
                    "  ИИК:" commonls.iik   format "999999999"  crlf.

        if tcommpl.type < 11 then put unformatted "Счет-извещение, ".
                             else put unformatted "Абонентская книжка, ".

               
        put unformatted commonls.npl format "x(65)" crlf .

        put unformatted
        fill("-", 149) format "x(149)"  crlf
        "|  Счет  | N квит.|  Дата    |             ФИО              |                     Адрес                        |      Назначение       |   Сумма    |"  crlf
        "|        |        | платежа  |         плательщика          |                   плательщика                    |        платежа        |  платежа   |"  crlf
 
        fill("-", 149) format "x(149)"  crlf.

    end.

        if tcommpl.valid then put unformatted "|"  tcommpl.accnt format ">>>>>>>9".
                         else put unformatted "|*" tcommpl.accnt format ">>>>>>9".

        put unformatted "|"
        tcommpl.dnum format ">>>>>>>9" "|" 
        tcommpl.date format "99.99.9999" "|" 
        tcommpl.fio  format "x(30)" "|" 
        tcommpl.adr  format "x(50)" "|" 
        tcommpl.npl  format "x(23)" "|" 
        tcommpl.sum  format ">>>>>>>>9.99" "|" crlf.
    
    if last-of(tcommpl.type) then do:
        put unformatted 
            Fill("-", 149) format "x(149)" crlf 
            "Итого платежей получателя: "
            (accum sub-count by tcommpl.type tcommpl.sum) format ">>>>>>>>>9"  crlf
            "на сумму всего:" (accum sub-total by tcommpl.type tcommpl.sum) format ">>>>>>>>>>>>9.99" crlf
            Fill("- ", 75) format "x(149)" crlf 
            crlf  crlf .
    end.

    if last-of(tcommpl.arp) then do:
        put unformatted
            fill("=", 149) format "x(149)"  crlf
            "Итого по " commonls.bn  crlf 
            "платежей :" (accum sub-count by tcommpl.arp tcommpl.sum) format ">>>>>>>>>>>>>>9"  crlf
            "на сумму :" (accum sub-total by tcommpl.arp tcommpl.sum) format ">>>>>>>>>>>>9.99"
            crlf  crlf  crlf .
    end.
                            
END.

/*
if alldoc then 
   put unformatted
    fill("=", 149) format "x(149)" crlf  crlf 
    "Всего:"  crlf
            "платежей :" (accum count tcommpl.sum) format ">>>>>>>>>>>>>>9"  crlf
            "на сумму :" (accum total tcommpl.sum) format ">>>>>>>>>>>>9.99"  crlf.
*/
output close.

run menu-prt("commpl1.txt").

out = "sd" + string(day(dt1),'99') + string(month(dt1),'99') + substring(string(year(dt1),'9999'),3,2) + ".txt".
unix SILENT value('cat commpl1.txt | koi2win  > ' + out).

/*if selarp = '010904501' and not alldoc then do:
         MESSAGE "Отправить реестр в ТОО 'ЛАТОН' ? Файл: " + out 
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE " Станция диагностики " UPDATE choiceout as logical.

         case choiceout:
            when false then return.
            when true  then run mail("laton@kaznet.kz,gulnur@elexnet.kz,litosh@elexnet.kz,
                                      alex@netbank.kz,koval@elexnet.kz",
                                      "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
                                      "Реестр пл. ТОО Латон за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).
         end.        
end.*/

/*output through value("ftp -nc  192.168.1.132") no-echo.
put unformatted
"user tbank Paskuda1975" skip
"put" skip
"tn" out skip
"out/tn" out skip.
output close.*/
