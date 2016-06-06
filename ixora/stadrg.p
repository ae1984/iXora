/* stadrg.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Сводный реестр по станции диагностики
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-10-7-3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        17/04/2002 sasco  - детализация количества по суммам по типам платежей
        19/08/2004 sasco  - детализация по КБК (для таможни ARP 000076261)
	03/01/2005 u00121 - Название банка теперь берем из таблицы CMP - п.п. Прагмы 9-1-1-1
	05/08/2005 kanat  - заменил условие по АРП счетам на условие по type в таблице commonls
	14/03/2006 u00600 - заменила дату на период 
*/

{comm-txb.i}
def var seltxb as int no-undo.
seltxb = comm-cod().

def var dt1 as date no-undo.
def var dt2 as date no-undo.  /*14.03.2006 u00600*/
def var out as char no-undo. 
def shared var g-today as date.
dt1 = g-today.
dt2 = g-today.   /*14.03.2006 u00600*/
def var crlf as char no-undo.
crlf = chr(13) + chr(10).

def input parameter selgrp   as integer.
def input parameter alldoc   as logical.
def temp-table tcommpl like commonpl
               field typesel like commonpl.type. /* для сортировок внутри типов, например для таможни по КБК */

def temp-table tamt  
         field tcol as integer
         field tamt as decimal.

/*update dt1 format '99/99/9999' label "Дата " with centered frame df.*/
/*14.03.2006 u00600*/
form 
  dt1  format "99/99/9999" label " Начальная дата периода " 
    help " Введите дату начала периода!"
    validate (dt1 <= g-today, " Дата не может быть больше " + string (g-today)) skip 

  dt2  format "99/99/9999" label " Конечная дата периода  " 
    help " Введите дату конца периода"
    validate (dt2 <= g-today, " Дата не может быть больше " + string (g-today)) skip

with overlay width 78 centered row 6 side-label title " Дата "  frame df.
update dt1 dt2 with frame df.

if alldoc then do:
     for each commonpl where (date >= dt1 and date <= dt2) no-lock:
       if txb = seltxb and deluid = ? and commonpl.grp = selgrp then do: 
         create tcommpl.
         buffer-copy commonpl to tcommpl.
         tcommpl.typesel = commonpl.type.
       end.
     end.
end.
else do:
{stadsel.i}
     for each commonpl where  (date >= dt1 and date <= dt2) no-lock:
       if txb = seltxb and deluid = ? and commonpl.arp = selarp and commonpl.grp = selgrp then do:
         create tcommpl.
         buffer-copy commonpl to tcommpl.
         tcommpl.typesel = commonpl.type.
       end.
     end.
end.

/* sasco для таможенных платежей */
for each tcommpl where tcommpl.arp = '000076261':
    tcommpl.typesel = tcommpl.kb.
end.

output to commpl1.txt.

FOR EACH tcommpl NO-LOCK use-index gatgt BREAK BY tcommpl.arp BY tcommpl.typesel BY tcommpl.date BY tcommpl.sum :

accumulate tcommpl.sum
    (sub-count by tcommpl.typesel).
    
accumulate tcommpl.sum
    (sub-total by tcommpl.typesel).

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

    IF FIRST-OF(tcommpl.typesel) THEN do:
	find first bank.cmp no-lock no-error. /*03/01/2004 u00121*/       
        /* sasco */
        for each tamt: delete tamt. end.

          put unformatted  bank.cmp.name  crlf 
                           "                Р Е Е С Т Р  Платежей за период с " string (dt1,"99.99.9999") "г.  по " string (dt2,"99.99.9999") "г.  ". 

        find first commonls where commonls.txb = seltxb and commonls.grp = tcommpl.grp and 
                                  commonls.type = tcommpl.type no-lock no-error.

        put unformatted 
                    trim(commonls.bn) 
                    "  БИК:" commonls.bikbn format "999999999" 
                    "  ИИК:" commonls.iik   format "999999999"  crlf
                    space(10) 
                    (commonls.npl + if tcommpl.kb <> 0 then ", КБК " + string (tcommpl.kb) else " ") format "x(65)"      crlf  crlf .

        put unformatted
        fill("-", 110) format "x(110)"  crlf
        "| N квит.|           ФИО            |    РНН     |  Дата    |         Вид                  |   Сумма    |"  crlf
        "|        |       плательщика        |плательщика | платежа  |       платежа                |  платежа   |"  crlf
 
        fill("-", 110) format "x(110)"  crlf.

    end.

        find tamt where tamt.tamt = tcommpl.sum no-error.
        if not avail tamt then do:
            create tamt.
            tamt.tamt = tcommpl.sum.
            tamt.tcol = 0.
        end.
        tamt.tcol = tamt.tcol + 1.

        put unformatted "|"
        tcommpl.dnum format ">>>>>>>9" "|" 
        tcommpl.fioadr  format "x(26)" "|" 
        tcommpl.rnn  format "x(12)" "|" 
        tcommpl.date format "99.99.9999" "|" 
        tcommpl.npl  format "x(30)" "|" 
        tcommpl.sum  format ">>>>>>>>9.99" "|" crlf.
    
    if last-of(tcommpl.typesel) then do:
        put unformatted 
            Fill("-", 110) format "x(110)" crlf 
            "Итого платежей получателя: "
            (accum sub-count by tcommpl.typesel tcommpl.sum) format ">>>>>>>>>9"  crlf
            "на сумму всего:" (accum sub-total by tcommpl.typesel tcommpl.sum) format ">>>>>>>>>>>>9.99"
            " в т.ч. пеня:  0.00"  crlf crlf.

        put unformatted
            "Детали: (количество  x  сумма)" crlf.

        for each tamt by tamt.tamt:
            put unformatted fill (" ", 9) format "x(9)" tamt.tcol " x " tamt.tamt crlf.
        end.

        put unformatted
            crlf
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
                            
END.

if alldoc then 
   put unformatted
    fill("=", 110) format "x(110)" crlf  crlf 
    "Всего:"  crlf
            "платежей :" (accum count tcommpl.sum) format ">>>>>>>>>>>>>>9"  crlf
            "на сумму :" (accum total tcommpl.sum) format ">>>>>>>>>>>>9.99"  crlf
            " в т.ч. пеня:  0.00"  crlf.

output close.

run menu-prt("commpl1.txt").

/*output through value("ftp -nc  192.168.1.132") no-echo.
put unformatted
"user tbank Paskuda1975" skip
"put" skip
"tn" out skip
"out/tn" out skip.
output close.*/
/*a1975" skip
"put" skip
"tn" out skip
"out/tn" out skip.
output close.*/
