/* stadrk.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Сводный реестр по станции диагностики в разрезе СПФ и с отправкой по организациям
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
        03.08.2004 kanat - поменял адресацию для КГП ЦИС.
        06.08.2004 kanat - поменял адресацию для КГП ЦИС на другой.
        13/08/2004 kanat - еще раз поменял адрес КГП ЦИС на другой :)
	03/01/2005 u00121 - Название банка теперь берем из таблицы CMP - п.п. Прагмы 9-1-1-1
	28/03/2005 kanat - добавил НПО Промышленная безопасность в рассылку
*/



{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var dt1 as date.
def var out as char. 
def shared var g-today as date.
dt1 = g-today.
def var crlf as char.
crlf = chr(13) + chr(10).
def var choiceout as logical init false.

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

/*
MESSAGE "Сформировать реестр по всем СПФ ?"
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE " Реестр " UPDATE choicerko.

         case choicerko:
            when false then do: 
                               {selrko.i} 
                               for each tcommpl where tcommpl.rko <> selrko:
                                    delete tcommpl.
                               end.
                            end.
         end.
*/

output to commpl1.txt.

FOR EACH tcommpl NO-LOCK use-index gatgt BREAK BY tcommpl.rko by tcommpl.arp BY tcommpl.type :

accumulate tcommpl.sum
    (sub-count by tcommpl.rko).
        
accumulate tcommpl.sum
    (sub-total by tcommpl.rko).

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
            
            
    IF FIRST-OF(tcommpl.rko) THEN do:
        find first ppoint where ppoint.depart = tcommpl.rko no-lock no-error .
        put unformatted "(" ppoint.depart ")" CAPS(ppoint.name) format "x(30)"  crlf  crlf.
    end.

/*    IF FIRST-OF(tcommpl.arp) THEN do:
        find first commonls where commonls.arp = tcommpl.arp use-index arp  no-lock no-error .
        put unformatted space(35) commonls.bn format "x(35)"  crlf  crlf.
    end.*/

    IF FIRST-OF(tcommpl.type) THEN do:
	find first bank.cmp no-lock no-error. /*03/01/2004 u00121*/       
          put unformatted  bank.cmp.name  crlf 
                           "                Р Е Е С Т Р  Платежей за " dt1 format "99.99.9999" " г.  ". 

        find first commonls where commonls.txb = seltxb and commonls.arp = tcommpl.arp and commonls.type = tcommpl.type no-lock no-error.

        put unformatted 
                    trim(commonls.bn) 
                    "  БИК:" commonls.bikbn format "999999999" 
                    "  ИИК:" commonls.iik   format "999999999"  crlf
                    space(10) commonls.npl format "x(65)"      crlf  crlf .

        put unformatted
        fill("-", 110) format "x(110)"  crlf
        "| N квит.|           ФИО            |    РНН     |  Дата    |         Вид          |Лицевой|   Сумма    |Пеня| "  crlf
        "|        |       плательщика        |плательщика | платежа  |       платежа        | счет  |  платежа   |    | "  crlf
 
        fill("-", 110) format "x(110)"  crlf.

    end.

        put unformatted "|"
        tcommpl.dnum format ">>>>>>>9" "|" 
        tcommpl.fioadr format "x(26)" "|" 
        tcommpl.rnn  format "x(12)" "|" 
        tcommpl.date format "99.99.9999" "|" 
        tcommpl.npl  format "x(22)" "|" 
        " "  format "x(7)" "|" 
        tcommpl.sum  format ">>>>>>>>9.99" "|" 
        0  format "9.99" "|"          crlf.

   

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
                            
END.

if alldoc then 
   put unformatted
    fill("=", 110) format "x(110)" crlf  crlf 
    "Всего по реестру :"  crlf
            "платежей :" (accum count tcommpl.sum) format ">>>>>>>>>>>>>>9"  crlf
            "на сумму :" (accum total tcommpl.sum) format ">>>>>>>>>>>>9.99"  crlf
            " в т.ч. пеня:  0.00"  crlf.

output close.

run menu-prt("commpl1.txt").

out = "sd" + string(day(dt1),'99') + string(month(dt1),'99') + substring(string(year(dt1),'9999'),3,2) + ".txt".
unix SILENT value('cat commpl1.txt | koi2win  > ' + out).


if selarp = '010904501' and not alldoc then do:
         MESSAGE "Отправить реестр в ТОО 'ЛАТОН' ? Файл: " + out 
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE " Станция диагностики " UPDATE choiceout.

         case choiceout:
            when false then return.
            when true  then run mail("laton@kaznet.kz,municipalTXB00@elexnet.kz",
                                      "TEXAKABANK <abpk@elexnet.kz>",
                                      "Реестр пл. ТОО Латон за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).
         end.        
end.

if selarp = '010904103' and not alldoc then do:
         MESSAGE "Отправить реестр в КГП ЦИС г.Алматы ? Файл: " + out 
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE " Станция диагностики " UPDATE choiceout.

         case choiceout:
            when false then return.
            when true  then run mail("irevenku@cisalmaty.kz,municipalTXB00@elexnet.kz",
                                      "TEXAKABANK <abpk@elexnet.kz>",
                                      "Реестр пл. КГП ЦИС г.Алматы за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).
         end.        
end.

if selarp = '010904213' and not alldoc then do:
         MESSAGE "Отправить реестр в Авто Холдинг Комапаниясы? Файл: " + out 
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE " Станция диагностики " UPDATE choiceout.

         case choiceout:
            when false then return.
            when true  then run mail("kamkorauto@nursat.kz,municipalTXB00@elexnet.kz",
                                      "TEXAKABANK <abpk@elexnet.kz>",
                                      "Реестр пл. ТОО Авто-Холдинг Компаниясы г.Алматы за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).
         end.        
end.

if selarp = '010904705' and not alldoc then do:
         MESSAGE "Отправить реестр в ТОО Дана? Файл: " + out 
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE " Станция диагностики " UPDATE choiceout.

         case choiceout:
            when false then return.
            when true  then run mail("Lucky_Jana@mail.ru,municipalTXB00@elexnet.kz",
                                      "TEXAKABANK <abpk@elexnet.kz>",
                                      "Реестр пл. ТОО Дана в г. Алматы за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).
         end.        
end.




if selarp = '000076575' and not alldoc then do:
         MESSAGE "Отправить реестр в ТОО ФОТО-СИСТЕМ ? Файл: " + out 
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE " Станция диагностики " UPDATE choiceout.

         case choiceout:
            when false then return.
            when true  then run mail("Foto-System@asia-soft.com,municipalTXB00@elexnet.kz",
                                      "TEXAKABANK <abpk@elexnet.kz>",
                                      "Реестр пл. ТОО ФОТО-СИСТЕМ за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).
         end.        
end.



if selarp = '010904747' and not alldoc then do:
         MESSAGE "Отправить реестр в ТОО НПО Промышленная безопасность ? Файл: " + out 
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE " Станция диагностики " UPDATE choiceout.

         case choiceout:
            when false then return.
            when true  then run mail("buh.npo@mail.ru,municipalTXB00@elexnet.kz",
                                      "TEXAKABANK <abpk@elexnet.kz>",
                                      "Реестр пл. ТОО НПО Промышленная безопасность за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", out).
         end.        
end.


/*output through value("ftp -nc  192.168.1.132") no-echo.
put unformatted
"user tbank Paskuda1975" skip
"put" skip
"tn" out skip
"out/tn" out skip.
output close.*/


