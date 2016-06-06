/* swmt-cre1.p                                                                                              ,
 * MODULE
        Название Программного Модуля
 * DESCRIPTION

 * RUN

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        22.06.2004 dpuchkov
 * CHANGES
        08.07.04 dpuchkov - добавил банк получ в заголовок свифта
        15.09.04 dpuchkov - добавил shared переменную
        04.11.04 dpuchkov - добавил поле 57 в 103 
        04.07.05 dpuchkov - убрал 21 58 33b из 103 
	13.06.06 u00121   - убрал параметр -p
        24.08.2011 id00004 изменил e-mail с @elexnet.kz на @metrocombank.kz
*/


{lgps.i new}
{comm-txb.i}
def var destination as char format "x(12)".  
def input parameter s-remtrz like remtrz.remtrz.
def input parameter g-today as date.
def input parameter what as char.              
def input parameter swmt as char format "x(3)".
def input parameter s-sqn as cha.
def input parameter scod as char.

def var date1 as char format "x(20)".
def var date2 as char format "x(8)".
def var pay1 as char format "x(20)".
def var tmptype as char format "x(1)".
def var tmpfld  as char format "x(2)".
def var tmpcont as char format "x(35)".
def var tmpdesc as char format "x(35)".
def var tmpwrit as char format "x(35)".
def var tmpsent as char format "x(20)".
def var tmpemail as char format "x(20)".
def var tmpcreate as char format "x(20)".
def var tmpfile   as char format "x(20)".
def var bpref   as char format "x(5)" init "+++ :".
def var tpref   as char format "x(40)" init "                                        ".
def var ii as integer.
def var srmz as char format "x(10)".
def var ourcode as integer.
def var logic as logical init false.
def shared var v-destnumber as char.
def shared var v-dest202 as char.
define shared temp-table tmpswbody like swbody.
def var l_71block as logical init false.
/* Определяем где запускам печать 
ourcode=comm-cod().
&scoped-define bnkf if ourcode<>0 then 'txb.' else '' 
if ourcode<>0 then  */

find remtrz where remtrz.remtrz = s-remtrz no-lock.
find first cmp.
find crc where crc.crc = remtrz.tcrc no-lock.

date1 = string(day(g-today), "99")  + "/" + string(month(g-today), "99"  )  + "/" + substr(string(year(g-today)), 3, 2).

if what <> "send" then do:
 output to rpt.txt.
 put unformatted "Валютный перевод (Swift), " + string(today,"99.99.9999") + " " + string(time,"HH:MM:SS") 
 " " comm-txb() skip(1).

 find first ofc where ofc.ofc = userid('bank') no-lock no-error.
 if not avail ofc then do:
   run tb( 'Ошибка', '', 'Отсутствует офицер ' + userid( 'bank' ) + '!', '' ).
   return.
 end.
end.
else output to value(s-remtrz).


put unformatted "=====customer transfer ================ FM" + swmt + " ==============================" skip.

/* Готовим DESTINATION */ 


if swmt = "202" then do:
find first tmpswbody no-lock where tmpswbody.rmz = s-remtrz and tmpswbody.swfield='DS' no-error.
if avail tmpswbody then destination=caps(trim(tmpswbody.content[1])).
                else do:
                     message "Платеж еще не отправлен! (пустое поле Destination)". pause. leave.
                end.
end.
else
do:
find first swbody no-lock where swbody.rmz = s-remtrz and swbody.swfield='DS' no-error.
if avail swbody then destination = caps(trim(v-destnumber)) /* caps(trim(swbody.content[1]))*/ .
                else do:
                     message "Платеж еще не отправлен! (пустое поле Destination)". pause. leave.
                end.
end.



find sysc where sysc.sysc = "swicod" no-lock. /* Возьмем наш свифт-код */

/* HEADER SEND */
if what = "send" then do:
if swmt = "103" then do:
        put unformatted
        "+++ DESTINATION  " v-destnumber format "x(12)" "DATE SENT " at 41 date1 skip
        "+++ SENDER       ".

                 put caps(trim(sysc.chval)) format "x(12)".
                 put "TIME SENT " at 41.
                 put string(time,"HH:MM:SS") skip.
end.  else
do:
        put unformatted
        "+++ DESTINATION  " destination format "x(12)" "DATE SENT " at 41 date1 skip 
        "+++ SENDER       ".

                 put caps(trim(sysc.chval)) format "x(12)".
                 put "TIME SENT " at 41.
                 put string(time,"HH:MM:SS") skip.
end.

        put unformatted 
        "+++" "OFFICER " at 41 "          " skip. /* reserved space for officer */

end.
else do:
         find first swout no-lock where swout.rmz=s-remtrz and deluid = ? no-error.
         if avail swout then assign
                                tmpsent   = string(swout.rmzdate,"99/99/99") + " " + string(swout.rmztime,"HH:MM:SS")
                                tmpcreate = string(swout.credate,"99/99/99") + " " + string(swout.cretime,"HH:MM:SS").

         /*Возьмем код банка */
         run swiftext2(INPUT destination, INPUT-OUTPUT logic, INPUT-OUTPUT tmpwrit).

         put unformatted "+++ DESTINATION " destination + " " + tmpwrit format "x(62)" skip.

         run swiftext2(INPUT caps(trim(sysc.chval)), INPUT-OUTPUT logic, INPUT-OUTPUT tmpwrit).

         put unformatted "+++ SENDER      " caps(trim(sysc.chval))  + " " + tmpwrit format "x(62)" skip.
         
         put unformatted "+++ DATE AND TIME PRINT: " date1 " " string(time,"HH:MM:SS") skip.

         if tmpsent = ? then put unformatted "+++ DATE AND TIME CREATE:" tmpcreate format "x(20)" skip.
                        else put unformatted "+++ DATE AND TIME SENT:  " tmpsent   format "x(20)" skip.
end.

put unformatted 
"+++------------------------------ NORMAL -----------------------------------" skip.
l_71block = False.

if swmt = "202" then 
for each tmpswbody no-lock where tmpswbody.rmz = s-remtrz and tmpswbody.type <> "N" by tmpswbody.swfield by tmpswbody.type. /* sasco : ++sort by type для 71A, 71F */
if swmt = "103" and tmpswbody.swfield = "57" then next.
if swmt = "202" and lookup(tmpswbody.swfield, "20,21,13,32,52,53,54,56,57,58,72,9f,DS") = 0  then next.

 tmpwrit = tmpswbody.content[1] + tmpswbody.content[2] + tmpswbody.content[3] + tmpswbody.content[4] + tmpswbody.content[5] + tmpswbody.content[6].
 if trim(tmpwrit) = "" then next. /* Пропустим незаполненные поля */


 tmptype = if trim(tmpswbody.type)="" then " " else tmpswbody.type.
 find first swfield where swfield.swfld = tmpswbody.swfield no-lock.
 tmpdesc = swfield.descr.
 tmpfld  = tmpswbody.swfield.

 if tmpswbody.swfield = "71" and tmpswbody.type = "F" and swmt = "103" then tmpdesc = "/sender's charges".

 if what = "send" and tmpfld="52" and trim(tmpswbody.content[2]) = "TEXAKZKA" then next.
 if what = "send" and tmpfld="9f" then next.
 if tmpfld="DS" then next.

 case tmpfld:
        when "32" then do:
/*              if what = "send" then tmpwrit = tmpswbody.content[1],"/","")," ","").
                                 else tmpwrit = tmpswbody.content[1].*/
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" tmpswbody.content[1] skip.
        end.
        /* Для совместимости с филиалами подставляем свой RMZ*/
        when "20" then do:
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + (if crc.crc = 4 then "+" else "") + s-remtrz + "-S" skip.
        end.
        when "21" or when "23" or when "23" then do:
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + tmpswbody.content[1] skip.
        end.
        when "71" then do:
            if not l_71block then do:
                if swbody.type = 'A'
                   then put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                else
                if swbody.type = 'F' and trim (swbody.content[1]) <> ''
                   then put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + 
                                        trim(entry(1, swbody.content[1], ' ')) + 
                                        replace(trim(entry(2, swbody.content[1], ' ')), '.', ',')
                                        skip.
                else
                   put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                l_71block = True.
             end.

        end.
        when "33" then do:
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + 
                                trim(entry(1, tmpswbody.content[1], ' ')) + 
                                replace(trim(entry(2, tmpswbody.content[1], ' ')), '.', ',')
                                skip.
        end.
        otherwise do:
                case tmptype:
                        when "A" then do:
                                tmpdesc = substr(tmpdesc,1,23) + " - BIC  ".
                                if trim(tmpswbody.content[1]) ne "" then do:
                                        put unformatted bpref + tmpswbody.swfield + tmptype  tmpdesc format "x(31)" ":" + tmpswbody.content[1] skip.
                                        put unformatted tpref format "x(40)" tmpswbody.content[2] skip.
                                end.
                                else put unformatted bpref + tmpswbody.swfield + tmptype  tmpdesc format "x(31)" ":" + tmpswbody.content[2] skip.

                                /* Если распечатка, то напечатаем все поля */
                                if what <> "send" then do:
                                        repeat ii=3 to 6:
                                                if trim(tmpswbody.content[ii]) ne "" then put unformatted tpref format "x(40)" tmpswbody.content[ii] skip.
                                        end.
                                end.

                        end.
                        when "D" or when "K" then do:
                                tmpdesc = substr(tmpdesc,1,23) + " - addr ".
                                if trim(tmpswbody.content[1]) ne "" then do:
                                        
                                        tmpcont = replace (tmpswbody.content[1], '/RNN/', 'RNN').
                                        if tmpcont begins 'RNN' then tmpcont = replace (tmpcont, ' ', '').
                                        put unformatted bpref + tmpswbody.swfield + tmptype  tmpdesc format "x(31)" ":" + tmpcont skip.

                                        tmpcont = replace (tmpswbody.content[2], '/RNN/', 'RNN').
                                        if tmpcont begins 'RNN' then tmpcont = replace (tmpcont, ' ', '').
                                        put unformatted tpref format "x(40)" tmpcont skip.

                                end.
                                else do:
                                     tmpcont = replace (tmpswbody.content[2], '/RNN/', 'RNN').
                                     if tmpcont begins 'RNN' then tmpcont = replace (tmpcont, ' ', '').
                                     put unformatted bpref + tmpswbody.swfield + tmptype  tmpdesc format "x(31)" ":" + tmpcont skip.
                                end.

                                repeat ii=3 to 5:                       /* content[3-5] */
                                        if trim(tmpswbody.content[ii]) ne "" then do:
                                           tmpcont = replace (tmpswbody.content[ii], '/RNN/', 'RNN').
                                           if tmpcont begins 'RNN' then tmpcont = replace (tmpcont, ' ', '').
                                           put unformatted tpref format "x(40)" tmpcont skip.
                                        end.
                                end.
                        end.
                        when "B" then do:
                                tmpdesc = substr(tmpdesc,1,23) + " - acco ".
                                put unformatted bpref + tmpswbody.swfield + tmptype  tmpdesc format "x(31)" ":" + tmpswbody.content[1] skip.
                                if trim(tmpswbody.content[2]) ne "" then 
                                        put unformatted tpref format "x(40)" tmpswbody.content[2] skip.
                        end.
                        otherwise do:
                                put unformatted bpref + tmpswbody.swfield + tmptype  tmpdesc format "x(31)" ":" + tmpswbody.content[1] skip.
                                if trim(tmpswbody.content[2]) ne "" then 
                                        put unformatted tpref format "x(40)" tmpswbody.content[2] skip.
                                repeat ii=3 to 6:                       /* content[3-6] */
                                        if trim(tmpswbody.content[ii]) ne "" then put unformatted tpref format "x(40)" tmpswbody.content[ii] skip.
                                end.
                        end.
                end case.
        end.
 end case.
end. /* for each */

else
if swmt = "103" then   do:
   l_71block = False.
for each swbody no-lock where swbody.rmz = s-remtrz and swbody.type <> "N" by swbody.swfield by swbody.type. /* sasco : ++sort by type для 71A, 71F */
/*if swmt = "103" and swbody.swfield = "57" then next. */
if swmt = "202" and lookup(swbody.swfield, "20,21,13,32,52,53,54,56,57,58,72,9f,DS") = 0  then next.

if swmt = "103" and swbody.swfield = "58" then next.
if swmt = "103" and swbody.swfield = "21" then next.
if swmt = "103" and swbody.swfield = "33" and swbody.type = "B" then next.

 tmpwrit = swbody.content[1] + swbody.content[2] + swbody.content[3] + swbody.content[4] + swbody.content[5] + swbody.content[6].
 if trim(tmpwrit) = "" then next. /* Пропустим незаполненные поля */


 tmptype = if trim(swbody.type)="" then " " else swbody.type.
 find first swfield where swfield.swfld = swbody.swfield no-lock.
 tmpdesc = swfield.descr.
 tmpfld  = swbody.swfield.

 if swbody.swfield = "71" and swbody.type = "F" and swmt = "103" then tmpdesc = "/sender's charges".

 if what = "send" and tmpfld="52" and trim(swbody.content[2]) = "TEXAKZKA" then next.
 if what = "send" and tmpfld="9f" then next.
 if tmpfld="DS" then next.

 case tmpfld:
        when "32" then do:
/*              if what = "send" then tmpwrit = swbody.content[1],"/","")," ","").
                                 else tmpwrit = swbody.content[1].  */
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" swbody.content[1] skip.
        end.
        /* Для совместимости с филиалами подставляем свой RMZ */
        when "20" then do:
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + (if crc.crc = 4 then "+" else "") + s-remtrz + "-S" skip.
        end.
        when "21" or when "23" or when "23" then do:
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + swbody.content[1] skip.
        end.
        when "71" then do:
            if not l_71block then do:
                if swbody.type = 'A'
                   then put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                else
                if swbody.type = 'F' and trim (swbody.content[1]) <> ''
                   then put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + 
                                        trim(entry(1, swbody.content[1], ' ')) + 
                                        replace(trim(entry(2, swbody.content[1], ' ')), '.', ',')
                                        skip.
                else
                   put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                l_71block = True.
             end.

        end.
        when "33" then do:
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + 
                                trim(entry(1, swbody.content[1], ' ')) + 
                                replace(trim(entry(2, swbody.content[1], ' ')), '.', ',')
                                skip.
        end.
        otherwise do:
                case tmptype:
                        when "A" then do:
                                tmpdesc = substr(tmpdesc,1,23) + " - BIC  ".
                                if trim(swbody.content[1]) ne "" then do:
                                        put unformatted bpref + swbody.swfield + tmptype  tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                                        put unformatted tpref format "x(40)" swbody.content[2] skip.
                                end.
                                else put unformatted bpref + swbody.swfield + tmptype  tmpdesc format "x(31)" ":" + swbody.content[2] skip.

                                /* Если распечатка, то напечатаем все поля */
                                if what <> "send" then do:
                                        repeat ii=3 to 6:
                                                if trim(swbody.content[ii]) ne "" then put unformatted tpref format "x(40)" swbody.content[ii] skip.
                                        end.
                                end.

                        end.
                        when "D" or when "K" then do:
                                tmpdesc = substr(tmpdesc,1,23) + " - addr ".
                                if trim(swbody.content[1]) ne "" then do:
                                        
                                        tmpcont = replace (swbody.content[1], '/RNN/', 'RNN').
                                        if tmpcont begins 'RNN' then tmpcont = replace (tmpcont, ' ', '').
                                        put unformatted bpref + swbody.swfield + tmptype  tmpdesc format "x(31)" ":" + tmpcont skip.

                                        tmpcont = replace (swbody.content[2], '/RNN/', 'RNN').
                                        if tmpcont begins 'RNN' then tmpcont = replace (tmpcont, ' ', '').
                                        put unformatted tpref format "x(40)" tmpcont skip.

                                end.
                                else do:
                                     tmpcont = replace (swbody.content[2], '/RNN/', 'RNN').
                                     if tmpcont begins 'RNN' then tmpcont = replace (tmpcont, ' ', '').
                                     put unformatted bpref + swbody.swfield + tmptype  tmpdesc format "x(31)" ":" + tmpcont skip.
                                end.

                                repeat ii=3 to 5:                       /* content[3-5] */
                                        if trim(swbody.content[ii]) ne "" then do:
                                           tmpcont = replace (swbody.content[ii], '/RNN/', 'RNN').
                                           if tmpcont begins 'RNN' then tmpcont = replace (tmpcont, ' ', '').
                                           put unformatted tpref format "x(40)" tmpcont skip.
                                        end.
                                end.
                        end.
                        when "B" then do:
                                tmpdesc = substr(tmpdesc,1,23) + " - acco ".
                                put unformatted bpref + swbody.swfield + tmptype  tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                                if trim(swbody.content[2]) ne "" then 
                                        put unformatted tpref format "x(40)" swbody.content[2] skip.
                        end.
                        otherwise do:
                                put unformatted bpref + swbody.swfield + tmptype  tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                                if trim(swbody.content[2]) ne "" then 
                                        put unformatted tpref format "x(40)" swbody.content[2] skip.
                                repeat ii=3 to 6:                       /* content[3-6] */
                                        if trim(swbody.content[ii]) ne "" then put unformatted tpref format "x(40)" swbody.content[ii] skip.
                                end.
                        end.
                end case.
        end.
 end case.

end. /* for each */
end.
put "============================================================================" skip.


if what <> "send" then do:
         put skip(1).
/* 15.09.2003 nadejda
         put unformatted skip(1)
         '    Подпись банка:   ' ofc.name " ("  trim(ofc.ofc) ") " skip(1). */

         output close.      
         case what:
           when "print" then unix silent prit -t rpt.txt.
           when "view"  then run menu-prt("rpt.txt").
         end case.
end.
else do:
        put "~014".
        output close.
/*      run mail("ikoval@elexnet.kz","TEXAKABANK <" + userid("bank") + "@elexnet.kz>",
                                         "VALOUT " + s-remtrz + " " + string(day(today),'99.') + 
                                         string(month(today),'99.') + string(year(today),'9999'),
                                         "", "1", "", s-remtrz). */
        input through value("swsend -s -e -w " + s-remtrz). /*u00121 13/06/06 убрал параметр -p*/
        scod = "".
        repeat:
         import scod s-sqn .
         if scod = "ok" or scod = "bad" then leave.
        end.
        input close.
          if scod = "bad" then return.
          if scod = "ok" then do:
            unix silent value("/bin/mv -f " + s-remtrz + " " + s-remtrz + ".doc").
            pause 0.
          end. 
         /* Запишем время отправки */   
         find first swout share-lock where swout.rmz=s-remtrz and deluid = ? no-error.
         if avail swout then do:
                  assign
                  swout.rmzdate = today
                  swout.rmztime = time
                  swout.rmzuid = userid("bank").
         end.
         release swout.

         run swmt-cre1(s-remtrz,g-today,"file",swmt,s-sqn,scod).

         run sel('Что будем делать ?','Печать|Просмотр|Отправить на любой Email|Отправить на Email(физ)|Продолжить...').

         tmpfile = trim(s-remtrz) + ".doc".

         unix silent value("/bin/mv -f rpt.txt " + tmpfile).
         case return-value:
                 when "1" then unix silent value("prit -t " + tmpfile).
                 when "2" then run menu-prt(tmpfile).
                 when "3" then do:
                     update tmpemail label "E-mail" format "x(50)" with centered frame soap.

                     run mail(tmpemail + ",ps@metrocombank.kz","METROCOMBANK <abpk@metrocombank.kz>",
                                         "VALOUT " + s-remtrz + " " + string(day(today),'99.') + 
                                         string(month(today),'99.') + string(year(today),'9999'),
                                         "", "1", "", tmpfile).

                     v-text = s-remtrz + " (swmt-cre.p) копия SWIFT отправлена офицером " + userid("bank") + " на email: " + tmpemail.
                     run lgps . 

                     hide frame soap.
                 end.
                 when "4" then do:
                     run mail("fmanagers@metrocombank.kz","METROCOMBANK <" + userid("bank") + "@metrocombank.kz>",
                                         "VALOUT " + s-remtrz + " " + string(day(today),'99.') + 
                                         string(month(today),'99.') + string(year(today),'9999'),
                                         "", "1", "", tmpfile).
                     v-text = s-remtrz + " (swmt-cre.p) копия SWIFT отправлена офицером " + userid("bank") + " на fmanagers@metrocombank.kz".
                     run lgps . 
                 end.
        end case.
end.

/* Почистим мусор */
if what="send" then do:
 unix silent value("/bin/rm -f *.doc").
 unix silent value("/bin/rm -f *.txt").
end.

