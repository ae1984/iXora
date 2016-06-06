/* agaz-reg.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Сводный реестр по станции диагностики в разрезе РКО и с отправкой по организациям
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
        16.01.2004 nadejda - отправитель письма по эл.почте изменен на общий адрес abpk@elexnet.kz
        03/01/2005 u00121 Название банка теперь берем из таблицы CMP - п.п. Прагмы 9-1-1-1
        11/04/2006 u00568 Evgeniy - открыли Атырау
*/


{comm-txb.i}
def var seltxb as integer.
seltxb = comm-cod().

def var dt1 as date.
def var out as char.
def shared var g-today as date.
dt1 = g-today.
def var crlf as char.
crlf = chr(13) + chr(10).
def var choiceout as logical init false.

def var selgrp as integer init 8.

find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
           commonls.visible = yes no-lock no-error.

define temp-table tcommpl like commonpl.

update dt1 format '99/99/9999' label "Дата " with centered frame df.

/*if alldoc then do:*/
for each txb where visible and city = seltxb no-lock:
     for each commonpl where txb = txb.txb and date = dt1 and deluid = ? and commonpl.grp = selgrp no-lock:
         create tcommpl.
         buffer-copy commonpl to tcommpl.
     end.
end.
/*end.*/

output to commpl1.txt.

FOR EACH tcommpl NO-LOCK use-index gatgt BREAK BY tcommpl.rko BY tcommpl.type by tcommpl.service  :

accumulate tcommpl.sum (sub-count sub-total by tcommpl.rko).
        
/*accumulate tcommpl.sum (sub-total by tcommpl.rko).*/

accumulate tcommpl.sum (sub-count sub-total by tcommpl.type).
    
/*accumulate tcommpl.sum (sub-total by tcommpl.type).*/

accumulate tcommpl.sum (sub-count sub-total by tcommpl.service).
        
/*accumulate tcommpl.sum (sub-total by tcommpl.arp).*/

accumulate tcommpl.sum (count total).
        
/*accumulate tcommpl.sum (total).*/
            
/*
    IF FIRST-OF(tcommpl.rko) THEN do:
        find first ppoint where ppoint.depart = tcommpl.rko no-lock no-error .
        put unformatted "(" ppoint.depart ")" CAPS(ppoint.name) format "x(30)"  crlf  crlf.
    end.

    IF FIRST-OF(tcommpl.arp) THEN do:
        find first commonls where commonls.arp = tcommpl.arp use-index arp  no-lock no-error .
        put unformatted space(35) commonls.bn format "x(35)"  crlf  crlf.
    end.*/

    IF FIRST-OF(tcommpl.type) THEN do:
          find first bank.cmp no-lock no-error. /*03/01/2004 u00121*/
          put unformatted  bank.cmp.name /*03/01/2004 u00121*/ crlf
                           "        Р Е Е С Т Р  Платежей за " dt1 format "99.99.9999" " г.  ".

        find first commonls where commonls.txb = seltxb and commonls.arp = tcommpl.arp and
                                  commonls.type = tcommpl.type no-lock no-error.

        put unformatted
                    trim(commonls.bn)
                    "  БИК:" commonls.bikbn format "999999999"
                    "  ИИК:" commonls.iik   format "999999999"  crlf
                    space(1) commonls.npl format "x(65)"      crlf  crlf .

        put unformatted
        fill("-", 110) format "x(110)"  crlf
        "|  Лиц.счет  |      ГРУ/КСК      |            Адрес             |           Ф.И.О            |       Сумма   |"  crlf
        fill("-", 110) format "x(110)"  crlf.

    end.

        put unformatted "| "
        tcommpl.accnt   format ">>>>>>>>>9" " |"
        tcommpl.service format "x(19)" "|"
        tcommpl.adr     format "x(30)" "|"
        tcommpl.fio     format "x(28)" "|"
        tcommpl.sum     format ">>>,>>>,>>9.99" " |" crlf.
/*
    if last-of(tcommpl.type) then do:
        put unformatted
            Fill("-", 110) format "x(110)" crlf
            "Итого платежей получателя: "
            (accum sub-count by tcommpl.type tcommpl.sum) format ">>>>>>>>>9"  crlf
            "на сумму всего:" (accum sub-total by tcommpl.type tcommpl.sum) format ">>>>>>>>>>>>9.99"
            " в т.ч. пеня:  0.00"  crlf
            Fill("- ", 55) format "x(110)" crlf
            crlf  crlf .
    end.

    if last-of(tcommpl.arp) then do:
        put unformatted
            fill("=", 110) format "x(110)"  crlf
            "Итого по " commonls.bn  crlf
            "платежей :" (accum sub-count by tcommpl.arp tcommpl.sum) format ">>>>>>>>>>>>>>9"  crlf
            "на сумму :" (accum sub-total by tcommpl.arp tcommpl.sum) format ">>>>>>>>>>>>9.99"
            " в т.ч. пеня:  0.00"
            crlf  crlf  crlf .
    end.
 
    if last-of(tcommpl.rko) then do:
        find first ppoint where ppoint.depart = tcommpl.rko no-lock no-error .
        put unformatted
            Fill("-", 110) format "x(110)" crlf
            "Итого платежей по: " CAPS(ppoint.name)
            (accum sub-count by tcommpl.rko tcommpl.sum) format ">>>>>>>>>9"  crlf
            "на сумму всего:" (accum sub-total by tcommpl.rko tcommpl.sum) format ">>>>>>>>>>>>9.99"
            " в т.ч. пеня:  0.00"  crlf
            Fill("- ", 55) format "x(110)" crlf
            crlf  crlf .
    end.
*/
END.

/*if alldoc then */
   put unformatted
    fill("=", 110) format "x(110)" crlf  crlf
    "Всего по реестру :"  crlf
            "платежей :" (accum count tcommpl.sum) format ">>>>>>>>>>>>>>9"  crlf
            "на сумму :" (accum total tcommpl.sum) format ">>>>>>>>>>>>9.99"  crlf.

output close.

run menu-prt("commpl1.txt").

out = "sd" + string(day(dt1),'99') + string(month(dt1),'99') + substring(string(year(dt1),'9999'),3,2) + ".txt".
unix SILENT value('cat commpl1.txt | koi2win  > ' + out).

 MESSAGE "Отправить реестр в " + trim(commonls.bn) + " ? Файл: " + out
 VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
 TITLE "Внимание" UPDATE choiceout.

         case choiceout:
            when false then return.
            when true  then /*
            run mail("atg-akmola@kaznet.kz,esmagambetova@elexnet.kz,ikoval@elexnet.kz",
                                      "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
                                      "Реестр пл. " + trim(commonls.bn) + " за " + string(day(dt1),'99.') +
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out). */
               if seltxb = 1 then
                             run mail("municipal" + comm-txb() + "@elexnet.kz,atg-akmola@kaznet.kz",
                                      "TEXAKABANK <abpk@elexnet.kz>",
                                      "Реестр пл. " + trim(commonls.bn) + " за " + string(day(dt1),'99.') +
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).
               else
                 if seltxb = 3 then
                             run mail("municipal" + comm-txb() + "@elexnet.kz,mvishenin@elexnet.kz",
                                      "TEXAKABANK <abpk@elexnet.kz>",
                                      "Реестр пл. " + trim(commonls.bn) + " за " + string(day(dt1),'99.') +
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).


         end.
