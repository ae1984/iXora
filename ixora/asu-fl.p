/* lnanlz.p
 * MODULE
        
 * DESCRIPTION
        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        
 * CHANGES
        16.01.2004 nadejda - отправитель письма по эл.почте изменен на общий адрес abpk@elexnet.kz
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var dt1   as date.
def var outf  as char. 
def var str   as char. 
def var tnpl  as char format "x(60)". 
def var pokch as char. 
def var r as integer init 0. 
def var s as decimal init 0. 
def var ro as integer init 0.  
def var so as decimal init 0. 
def var clecod as char.
def shared var g-today as date.
def var selgrp as integer init 7.

def var outfl as char.
def var outfiles  as char init "". 
def var choiceout as logical init false.
def var crlf as char.
define temp-table tcommpl like commonpl.

DEFINE STREAM s1.
DEFINE STREAM s2.
OUTPUT STREAM s2 TO commls.txt.
                                    
dt1 = g-today.
crlf = chr(13) + chr(10).
find sysc where sysc.sysc = "CLECOD" no-lock no-error.
     clecod = trim(sysc.chval).

update dt1 label 'Дата ' format '99/99/9999' with side-label centered frame df.
hide frame df.


for each commonpl where txb = seltxb and date = dt1 and deluid = ? and commonpl.grp = selgrp no-lock:
    create tcommpl.
    buffer-copy commonpl to tcommpl.
end.

outfl = "".

put stream s2 unformatted space(6) "Список файлов для передачи в Астана Су Арнасы за " + string(dt1,"99.99.9999") + crlf + crlf.

FOR EACH tcommpl NO-LOCK use-index gatgt BREAK BY tcommpl.valid:


    IF FIRST-OF(tcommpl.valid) THEN do:
       OUTPUT STREAM s1 TO commfl.txt.
       r = 0. 
       s = 0.
    end.

        if tcommpl.type > 11 then pokch = trim(string(tcommpl.counter,">>>>>9")) + "|".
                             else pokch = "".

        r = r + 1. s = s + tcommpl.sum.

        str = trim(string(tcommpl.accnt,"99999999")) + "|" +            /* ls */
              trim(tcommpl.fio) + "|" +                  /* fio */
              trim(entry(1,tcommpl.adr,"|")) + "|" +   /* street */
              trim(entry(2,tcommpl.adr, "|"))  + "|" + /* house */
              trim(entry(3, tcommpl.adr, "|")) + "|" +    /* flat */
              trim(string(tcommpl.sum,">>>>>>>>>>>>>>9.99")) + "|" +    /* summa */
              string(year(tcommpl.date),"9999") + string(month(tcommpl.date),"99") +
                              string(day(tcommpl.date),"99") + "|" +    /* date */
              clecod.                                                   /* MFO */
                     
        put stream s1 unformatted  str crlf.
    
    if last-of(tcommpl.valid) then do:
            ro = ro + r.
            so = so + s.

           OUTPUT STREAM s1 CLOSE.

           outf = clecod + string(day(dt1),"99") + string(month(dt1),"99").
 
           UNIX SILENT value('un-dos commfl.txt ' + outf ).
           UNIX SILENT value('asudbf.pl ' + outf). 

           tnpl = substring(tcommpl.npl,1,60).

           if tcommpl.valid then put stream s2 unformatted "- Платежи с корректными лицевыми счетами -" + crlf.
                            else put stream s2 unformatted "- Платежи с не найденными в базе лицевыми счетами -" + crlf.
           put stream s2 unformatted "Файл: " + outf + if tcommpl.valid then ".dbf" else "n.dbf".
           put stream s2 unformatted crlf + "Услуги: ".
           put stream s2 tnpl format "x(60)".
           put stream s2 unformatted crlf + "Дата формирования файла: " + string(today,"99.99.9999") + crlf +
                                     "Количество документов: " + trim(string(r)) +  crlf +
                                     "На сумму: " + trim(string(s,">>>>>>>>>9.99")) + crlf + crlf + crlf.

           displ "Формируется файл " + outf format "x(30)".

           /* unix SILENT value('rm -f commfl.txt'). */
           outfiles = outfiles + ";" + outf + if tcommpl.valid then ".dbf" else "n.dbf".
           outfl = outfl + " " + outf + if tcommpl.valid then ".dbf" else "n.dbf".

           if tcommpl.valid then unix silent value('mv txb.dbf ' + outf + '.dbf' ).
                            else unix silent value('mv txb.dbf ' + outf + 'n.dbf' ).
    end.
END.

OUTPUT STREAM s2 CLOSE.

str = clecod + string(day(dt1),"99") + string(month(dt1),"99") + ".txt".
outfiles = outfiles + ";" + str.

outfl = outfl + " " + str.


unix silent value('un-dos commls.txt ' + str ).
unix silent value('rm -f commls.txt '). 
unix silent value('rm -f commfl.txt ').
unix silent value('rm -f ' + clecod + string(day(dt1),"99") + string(month(dt1),"99")).

MESSAGE "Отправить файлы в Астана Су Арнасы по e-mail ?" +
        "~nПлатежей: " + trim(string(ro,">>>>9")) + " На общую сумму: " + trim(string(so,">,>>>,>>9.99"))
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
TITLE "Внимание" UPDATE choiceout.

if choiceout then do:
 run mail("municipal" + comm-txb() + "@elexnet.kz",
          "TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
          "ASTANA SU PAYMENTS (" + string(day(dt1),'99.') + 
          string(month(dt1),'99.') + substring(string(year(dt1),'9999'),3,2) + ")",
          "", "1", "", outfiles).

 str = "txb" + string(day(dt1),'99') + string(month(dt1),'99') + string(year(dt1),'9999').

 /* подготовка файла с архивом для отправки в Астана Су */
 unix silent value ("rm -f " + str + ".zip").
 unix silent value ("zip " + str + " " + outfl).

 /* отправка файла */
 run mail("export@mail.texakabank.kz",
          "TEXAKABANK <abpk@elexnet.kz>",
          "encrypt for astanasu",
          "", "1", "", str + ".zip").
end.
else return.

unix SILENT value('rm -f ' + clecod + '*' ).
unix silent value('rm -f ' + str). 
unix silent value('rm -f ' + str + '.zip').
