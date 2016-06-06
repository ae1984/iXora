/* as-es-fl.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var dt1   as date.
def var outf  as char. 
def var str   as char. 
def var strd  as char. 
def var tnpl  as char format "x(30)". 
def var pokch as char. 
def var r as integer init 0. 
def var s as decimal init 0. 
def var ro as integer init 0.  
def var so as decimal init 0. 

def var outfiles  as char init "". 
def var choiceout as logical init false.
def var hostmy   as char format 'x(15)'.
def var dirc     as char format 'x(15)' init "C:/AES".
def var ipaddr   as char format 'x(15)'.

DEFINE STREAM s1.
DEFINE STREAM s2.
OUTPUT STREAM s2 TO commls.txt.

def shared var g-today as date.
dt1 = g-today.
def var crlf as char.
crlf = chr(13) + chr(10).

def var selgrp as integer init 2.

define temp-table tcommpl like commonpl.

update dt1   label 'Дата ' format '99/99/9999' /* skip
       dirc  label 'Копировать в ' format 'x(15)' skip */ with side-label centered frame df.
hide frame df.

/*    input through askhost.
       repeat:
           import hostmy.
       end.
    input close.

    input through value( 'resolveip -s ' + hostmy ). 
       repeat:
           import ipaddr.
       end.
    input close.  */

{stadsel.i}
for each txb where visible and is_branch and city = seltxb no-lock:
     for each commonpl where commonpl.txb = txb.txb and date = dt1 and deluid = ? and commonpl.arp = selarp and 
                             commonpl.grp = selgrp and commonpl.rmzdoc <> ? no-lock:
         create tcommpl.
         buffer-copy commonpl to tcommpl.
     end.
end.

put stream s2 unformatted space(6) "Список файлов для передачи в АстанаЭнергоСервис за " + string(dt1,"99.99.9999") + crlf + crlf
 "  Файл     Наименование услуги             Дата формир.   Кол-во платежей        Сумма " crlf crlf.

FOR EACH tcommpl NO-LOCK use-index gatgt BREAK BY tcommpl.type :

/*    IF FIRST-OF(tcommpl.valid) THEN do:
        find first commonls where commonls.arp = tcommpl.arp use-index arp  no-lock no-error .
        put unformatted space(35) commonls.bn format "x(35)" crlf crlf.
    end.*/

    IF FIRST-OF(tcommpl.type) THEN do:
       OUTPUT STREAM s1 TO commfl.txt.
       r = 0. 
       s = 0.
    end.

        if tcommpl.type > 11 then pokch = trim(string(tcommpl.counter,">>>>>9")) + "|".
                             else pokch = "".

        r = r + 1. s = s + tcommpl.sum.

        str = trim(string(tcommpl.accnt,">>>>>9")) + "|" +
              trim(tcommpl.fio) + "|" + pokch +
              trim(string(tcommpl.sum,">>>>>>>>>>>>>>>9.99")) + "|" +
              trim(tcommpl.adr) + "|" +
              string(year(tcommpl.date),"9999") + string(month(tcommpl.date),"99") + 
              string(day(tcommpl.date),"99") + "|" +
              trim(tcommpl.rnn) + "|" +
              trim(string(tcommpl.dnum,">>>>9")) + "|" +
              trim(string(tcommpl.rko,">>>>>>>9") + "|" +
              "999").

        put stream s1 unformatted  str crlf.
    
    if last-of(tcommpl.type) then do:
            ro = ro + r.
            so = so + s.

           OUTPUT STREAM s1 CLOSE.

           if month(dt1) > 9 then case month(dt1):
                                       when 10 then strd = "A".
                                       when 11 then strd = "B".
                                       when 12 then strd = "C".
                                  end case.
                             else strd = string(month(dt1),"9").

           outf = "TXB"  + trim(tcommpl.service) + "." + string(day(dt1),"99") + strd.
 
           unix silent value('un-dos commfl.txt ' + outf ).

           if tcommpl.type > 11 then unix SILENT value('credbf.pl a ' /* + string(r,">>>>>>9") */ + ' ' + outf).
                                else unix SILENT value('credbf.pl c ' /* + string(r,">>>>>>9") */ + ' ' + outf).

           tnpl = substring(tcommpl.npl,1,30).

           put stream s2 unformatted outf + " ".
           put stream s2 tnpl format "x(30)".
           put stream s2 unformatted  "   "+ string(today,"99.99.9999") + 
                                      "            " + string(r,">>>>>>9") +  
                                      "    " + string(s,">>>>>>>>>9.99") + crlf.

           displ "Формируется файл " + outf format "x(30)".

/*           unix silent value('rcp ' + outf + ' ' + ipaddr + ":" + dirc).*/
           unix SILENT value('rm -f commfl.txt').
           outfiles = outfiles + outf + ";".
    end.
END.

OUTPUT STREAM s2 CLOSE.

str = "txb_" + string(day(dt1),"99") + strd + ".txt".

/*displ "Копируется файл " + str format "x(30)".*/

unix silent value('un-dos commls.txt ' + str ).
/*unix silent value('rcp ' + str + ' ' + ipaddr + ":" + dirc).*/
unix silent value('rm -f commls.txt ').

MESSAGE "Отправить файлы в АстанаЭнергоСервис по e-mail ?" +
        "~nПлатежей: " + trim(string(ro,">>>>9")) + " На общую сумму: " + trim(string(so,">,>>>,>>9.99"))
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
TITLE "Внимание" UPDATE choiceout.

         case choiceout:
            when false then return.
            when true  then /* run mail("erc@aes.asdc.kz,ikoval@elexnet.kz,esmagambetova@elexnet.kz",
                                      "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
                                      "Платежи АстанаЭнергоСервис за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", outfiles + str).                */
                             run mail("municipal" + comm-txb() + "@elexnet.kz",
                                      "TEXAKABANK <apbk@elexnet.kz>",
                                      "Платежи АстанаЭнергоСервис за " + string(day(dt1),'99.') + 
                                      string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2),
                                      "", "1", "", outfiles + str).                

         end.        


unix SILENT value('rm -f TXB* ').
unix silent value('rm -f ' + str).
