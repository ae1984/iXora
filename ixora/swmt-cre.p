/* swmt-cre.p                                                                                              ,
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Формирование сообщения для дальнейшего формирования из него макета 100
 * RUN
        SYNOPSYS:
          send - отправка
          print - печать сразу в принтер
          view - выбор просмoтра menu-prt
          file - просто формирование в домашнем каталоге файла
          email - отправка на емайл

        s-remtrz,g-today,what,swmt,s-sqn,scod
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        10.11.2002 koval
 * CHANGES
        15.09.2003 nadejda  - убрана подпись офицера
        15.10.2003 sasco    - добавил "+" перед RMZ в Russian Wooden Rubles
        16.01.2004 nadejda  - отправитель письма по эл.почте на внешний адрес изменен на общий адрес abpk@elexnet.kz
        31.03.2005 dpuchkov - добавил переменную l_71block чтобы не дублировалось 71 поле
        13.06.2006 u00121   - убрал параметр -p
	    10.05.2010 k.gitalov полностью новая версия
        26/05/2011 madiyar - отправка в зависимости от суммы по адресам из дополнительных справочников
        18.07.2011 Luiza    - для платежей в российских рублях SWIFT файл формируется в формате SWIFT-RUR MT103 (ТЗ 796)
                            мои изменения по условию if v-rub then do: .... end.
                            для else do: ... end - как было по старому.
        24.08.2011 id00004 изменил e-mail с @elexnet.kz на @metrocombank.kz
        14.02.2012 aigul - исправила вывод 71 поля, с данными "OUR" выводить 1 раз,
                           в полях 33,71 суммы выводить с разделителем ",": 22.00 - 22,00
        20.02.2012 aigul - исправила вывод 71 поля, с данными "BEN" выводить 1 раз
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
        28/10/2013 galina - ТЗ1891 добавила формирование МТ202 и добавила вывод полй 21, 23 и 58
        29/10/2013 galina - ТЗ1891
        01.11.2013 evseev - tz926

*/


def input parameter s-remtrz like remtrz.remtrz.
def input parameter g-today as date.
def input parameter what as char.               /* send - отправка, иначе просмотр в joe */
def input parameter swmt as char format "x(3)".
def input parameter s-sqn as char.
def input parameter scod as char.

run savelog("swmt-cre","54. " + s-remtrz + "; " + string(g-today) + "; " + what + "; " + swmt + "; " + s-sqn + "; " + scod ).
find first remtrz where remtr.remtrz = s-remtrz no-lock no-error.
if not avail remtrz then do:
   message 'Не найден RMZ!' view-as alert-box.
   run savelog("swmt-cre","57. " + s-remtrz ).
   return.
end.


def var ValData as char.
def var ValData1 as char.
def var tmpval as char.
{comm-txb.i}

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

def var v-list as char no-undo.
def var v-amt as deci no-undo.
def var v-rub as logic init no.
def var v-dd as char format "x(6)".
def var v-nn as int.
def var v-71 as logical initial yes.

function To35Len returns char (input InStr as char):
  if length(InStr) > 35 then return substr(InStr,1,35).
  else return InStr.
end.

/*
find sysc where sysc.sysc = "swicod" no-lock no-error.
if avail sysc then MYBIC =  caps(trim(sysc.chval)).
else message "Бик по умолчанию - " MYBIC view-as alert-box.
*/
/************************************************************************************************************/
case swmt:
  when "103" or when "202" then do:
     /*
      find remtrz where remtrz.remtrz = s-remtrz no-lock.
      find first cmp.
      find crc where crc.crc = remtrz.tcrc no-lock.
     */
       /* Luiza -------------------------------------------------------------------------------*/
       find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "32" no-lock no-error.
       /*if avail swbody and substring(swbody.content[2],1,3) = "RUB" then v-rub = yes.*/
       if avail swbody and index(swbody.content[1],"RUB") > 0 then v-rub = yes.

       if v-rub then do:
           find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "DS" no-lock no-error.
           if avail swbody then ValData = "\{1:F01" + v-clecod + "AXXXXXXXXXXXXX}\{2:I" + swmt + trim(swbody.content[2]) + "XN}\{3:\{113:RUR6}\}\{4:\r\n".
           else do:
             message "       Не найдено поле DS... \nБудут взяты тестовые данные по умолчанию!" view-as alert-box.
             ValData = "\{1:F21MEOKKZK0AXXXXXXXXXXXXX}\{2:I" + swmt + "MEOKKZK0XXXXN}\{3:\{113:RUR6}\}\{4:\r\n".
           end.
       end.
       /*--------------------------------------------------------------------------------------*/
       else do:
           find first swbody where swbody.rmz = s-remtrz and swbody.swfield = "DS" no-lock no-error.
           if avail swbody then
           do:
             /*put unformatted  "\{1:F21FOBAKZKAAXXX}\{2:I103" trim(swbody.content[2]) "X}\{4:" skip.*/
             /*{1:F01FOBAKZKAAXXXXXXXXXXXXX}*/
             ValData = "\{1:F01" + v-clecod + "AXXXXXXXXXXXXX}\{2:I" + swmt + trim(swbody.content[2]) + "XN}\{4:\r\n".
           end.
           else do:
             message "       Не найдено поле DS... \nБудут взяты тестовые данные по умолчанию!" view-as alert-box.
             /*put unformatted "\{1:F21MEOKKZK0AXXX}\{2:I103MEOKKZK0XXXX}\{4:" skip.*/
             ValData = "\{1:F21MEOKKZK0AXXXXXXXXXXXXX}\{2:I" + swmt + "MEOKKZK0XXXXN}\{4:\r\n".
           end.
       end.

       /*find remtrz where remtrz.remtrz = s-remtrz no-lock.
       for each swbody no-lock where swbody.rmz = s-remtrz  by swbody.swfield by swbody.type.
          if index(remtrz.sqn,"IBH") = 0 and swbody.type = "N" then next.*/

       for each swbody no-lock where swbody.rmz = s-remtrz and swbody.type <> "N" by swbody.swfield by swbody.type.
          run savelog("swmt-cre", "122. " + s-remtrz + " " + swbody.swfield + " " + swbody.type  ).
          case swbody.swfield:
            when "20" then do:
               if v-rub then ValData = ValData + ":20:+" + s-remtrz + "\r\n".
               else do:
                  /*put unformatted ":20:" s-remtrz skip.*/
                  ValData = ValData + ":20:" + s-remtrz + "\r\n".
              end.
            end.
            when "21" then do:
                ValData = ValData + ":21:" + swbody.content[1] + "\r\n".
            end.
            when "23" then do:
              /*put unformatted ":23B:" swbody.content[1] skip.*/
              ValData = ValData + ":23B:" + swbody.content[1] + "\r\n".
            end.
            when "32" then do:
              tmpval = trim(swbody.content[1]).
              tmpval = replace(tmpval,"/","").
              tmpval = replace(tmpval," ","").
              /*put unformatted ":32A:" tmpval skip.*/
              ValData = ValData + ":32A:" + tmpval + "\r\n".
              v-dd = substring(tmpval,1,6).
            end.
            when "33" then do:
              if length(swbody.content[1]) > 0  then
              do:
                tmpval = trim(swbody.content[1]).
                tmpval = replace(swbody.content[1],".",",").
                tmpval = replace(tmpval," ","").
                /*put unformatted ":33B:" tmpval skip.*/
                ValData = ValData + ":33B:" + tmpval + "\r\n".
              end.
            end.
            when "50" or when "52" or when "53" or when "56" or when "57" or when "59" or when "70" or when "58"  then
            do:
                if v-rub then do:
                    if swbody.swfield = "70" and index(swbody.content[1],")") > 0 and substring(swbody.content[1],1,3) = "(VO" then do:
                        v-nn = index(swbody.content[1],")").
                        ValData1 = ":" + swbody.swfield + trim(swbody.type) + ":'".
                        if length(swbody.content[1]) > 0  then  ValData1 = ValData1 + substring(swbody.content[1],1,v-nn)
                         + "'" + substring(swbody.content[1],v-nn + 1,33 - v-nn).
                        if length(swbody.content[1]) > 33 then ValData1 = ValData1 + substring(swbody.content[1],34,2) + " ".
                        if length(swbody.content[2]) > 0  then  ValData1 = ValData1 + (swbody.content[2]).
                        if length(swbody.content[3]) > 0  then  ValData1 = ValData1 + To35Len(swbody.content[3]).
                        if length(swbody.content[4]) > 0  then  ValData1 = ValData1 + To35Len(swbody.content[4]).
                        if length(swbody.content[5]) > 0  then  ValData1 = ValData1 + To35Len(swbody.content[5]).
                        /* добавляем ValData1 к ValData  */
                        repeat:
                            if length(ValData1) <= 0 then leave.
                            if length(ValData1) > 140  then ValData1 = substring(ValData1,1,140).
                            else do:
                                if length(ValData1) > 35 then do:
                                    ValData = ValData + substring(ValData1,1,35) + "\r\n".
                                    ValData1 = substring(ValData1,36,length(ValData1) - 35).
                                end.
                                else do:
                                    ValData = ValData + substring(ValData1,1,length(ValData1)) + "\r\n".
                                    leave.
                                end.
                            end.
                        end.
                    end.
                    else do:
                        ValData = ValData + ":" + swbody.swfield + trim(swbody.type) + ':'.
                        if length(swbody.content[1]) > 0  then  ValData = ValData + To35Len(swbody.content[1]) + "\r\n".
                        if length(swbody.content[2]) > 0  then  ValData = ValData + To35Len(swbody.content[2]) + "\r\n".

                        if swbody.type <> "A" then
                        do:
                            if length(swbody.content[3]) > 0  then  ValData = ValData + To35Len(swbody.content[3]) + "\r\n".
                            if length(swbody.content[4]) > 0  then  ValData = ValData + To35Len(swbody.content[4]) + "\r\n".
                            if length(swbody.content[5]) > 0  then  ValData = ValData + To35Len(swbody.content[5]) + "\r\n".
                        end.
                    end.
                end.
                else do:
                    /*put unformatted ":" swbody.swfield  trim(swbody.type) ':'.*/
                    ValData = ValData + ":" + swbody.swfield + trim(swbody.type) + ':'.
                    if length(swbody.content[1]) > 0  then  ValData = ValData + To35Len(caps(swbody.content[1])) + "\r\n".
                    /*put unformatted caps(swbody.content[1]) skip.*/
                    if length(swbody.content[2]) > 0  then  ValData = ValData + To35Len(caps(swbody.content[2])) + "\r\n".
                    /*put unformatted caps(swbody.content[2]) skip.*/

                    if swbody.type <> "A" then
                    do:
                        if length(swbody.content[3]) > 0  then  ValData = ValData + To35Len(caps(swbody.content[3])) + "\r\n".
                        /*put unformatted caps(swbody.content[3]) skip.*/
                        if length(swbody.content[4]) > 0  then  ValData = ValData + To35Len(caps(swbody.content[4])) + "\r\n".
                        /*put unformatted caps(swbody.content[4]) skip.*/
                        if length(swbody.content[5]) > 0  then  ValData = ValData + To35Len(caps(swbody.content[5])) + "\r\n".
                        /*put unformatted caps(swbody.content[5]) skip.*/
                    end.
                end.
            end.

            when "71" then do:
                  if index(remtrz.sqn, "IBH") > 0 and trim(swbody.type) = "F" then do:
                     ValData = ValData + ":" + swbody.swfield + trim(swbody.type) + ':' + replace(trim(swbody.content[1]),".",",") + "\r\n".
                  end. else if v-71 = yes then do:
                      tmpval = trim(swbody.content[1]).
                      tmpval = replace(swbody.content[1],".",",").
                      tmpval = replace(tmpval," ","").
                      if length(tmpval) > 0 then do:
                        ValData = ValData + ":" + swbody.swfield + trim(swbody.type) + ':' + tmpval + "\r\n".
                        /*put unformatted ":" swbody.swfield  trim(swbody.type) ':' tmpval skip.  */
                      end.
                      if trim(swbody.content[1]) = "OUR" then v-71 = no.
                      find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
                      if avail remtrz then do:
                          find first netbank where netbank.rmz = substr(remtrz.sqn,7,10) no-lock no-error.
                          if avail netbank then do:
                            if trim(swbody.content[1]) = "BEN" then v-71 = no.
                          end.
                      end.
                  end.
            end.

            OTHERWISE  do:
                if v-rub then do:
                    if swbody.swfield = "72" and trim(swbody.content[1]) <> "" then do:
                        ValData = ValData + ":" + swbody.swfield + ':' + trim(swbody.content[1]) + "\r\n".
                        ValData = ValData + trim(swbody.content[2]) + "\r\n".
                    end.
                    else do:
                        ValData = ValData + ":72:/RPP/" + /*string(NEXT-VALUE(rppnum),"999")*/ "XXX"  + "." + v-dd + ".6.ELEK" + "\r\n".
                        ValData = ValData + "/DAS/" + v-dd + "\r\n".
                    end.
                end.
                else if swbody.swfield = "72" and trim(swbody.content[1]) <> "" then do:
                     ValData = ValData + ":" + swbody.swfield + ':'.
                     if length(swbody.content[1]) > 0  then  ValData = ValData + To35Len(swbody.content[1]) + "\r\n".
                     if length(swbody.content[2]) > 0  then  ValData = ValData + To35Len(swbody.content[2]) + "\r\n".
                     if length(swbody.content[3]) > 0  then  ValData = ValData + To35Len(swbody.content[1]) + "\r\n".
                     if length(swbody.content[4]) > 0  then  ValData = ValData + To35Len(swbody.content[2]) + "\r\n".
                     if length(swbody.content[5]) > 0  then  ValData = ValData + To35Len(swbody.content[1]) + "\r\n".
                end.
            end.
          end case.
       end.

       ValData = ValData + "-}".
       /*put unformatted "-}".*/

     scod = "ok".

  end. /* when "103" then do: */
  otherwise do:
      message "MT" + swmt + " не может быть экспортирован!" view-as alert-box.
  end.
end case.
/************************************************************************************************************/




    case what:
    when "send" then
    do:
     if comm-txb() = "TXB00" then
     do:
       /**************************  Сохраняем  **********************************/
       output to value(s-remtrz).
      /* put chr(1).*/

       put unformatted ValData.

      /* put chr(3).*/
       output close.
      /***************************** Перемещаем  *********************************/
      tmpval = "".
      input through value ("mv " + s-remtrz + " /data/export/mt103/" + s-remtrz ).
      repeat:
       import unformatted tmpval.
      end.
      if tmpval <> "" then do:
        message "Произошла ошибка при перемещении файла "  tmpval view-as alert-box.
        scod = "bad".
        return.
      end.
      /********************** Изменяем статус *************************************/
      find first swout share-lock where swout.rmz=s-remtrz and deluid = ? no-error.
      if avail swout then do:
                  assign
                  swout.rmzdate = today
                  swout.rmztime = time
                  swout.rmzuid = userid("bank").
      end.
      release swout.
     end.
      /* Если не ЦО то просто уведомление */
      /******************** Отправляем уведомления  ********************************/
       v-list = ''. v-amt = 0.
       find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
       if avail remtrz then do:
           v-amt = remtrz.amt.
           if remtrz.fcrc <> 2 then do:
                find first crc where crc.crc = remtrz.fcrc no-lock no-error.
                if avail crc then v-amt = v-amt * crc.rate[1].
                find first crc where crc.crc = 2 no-lock no-error.
                if avail crc then v-amt = v-amt / crc.rate[1].
                v-amt = round(v-amt,2).
           end.
       end.

       find sysc where sysc.sysc = "swmail" no-lock no-error.
       if avail sysc then v-list = trim(sysc.chval).

       if v-amt >= 100000 then do:
           find sysc where sysc.sysc = "swmail100" no-lock no-error.
           if avail sysc and trim(sysc.chval) <> '' then do:
               if v-list <> '' then if substring(v-list,length(v-list),1) <> ';' then v-list = v-list + "; ".
               v-list = v-list + trim(sysc.chval).
           end.
       end.

       if v-amt >= 500000 then do:
           find sysc where sysc.sysc = "swmail500" no-lock no-error.
           if avail sysc and trim(sysc.chval) <> '' then do:
               if v-list <> '' then if substring(v-list,length(v-list),1) <> ';' then v-list = v-list + "; ".
               v-list = v-list + trim(sysc.chval).
           end.
       end.
       if v-list <> '' then do:
          run mail(v-list ,"bankadm@metrocombank.kz" , "Подготовлен к отправке МТ103 " + s-remtrz ,
          "Создал - " + userid('bank') + "\n" +  ValData , "1" , "" , "/data/export/mt103/" + s-remtrz ).
       end.
       else do:
          run mail( userid('bank') + "@metrocombank.kz" ,"bankadm@metrocombank.kz" , "Подготовлен к отправке МТ103 " + s-remtrz ,
           "Создал - " + userid('bank') + "\n" +  ValData  , "1" , "" , "" ).
       end.
      /* inessa.filatova@metrocombank.kz; luiza.abdymomunova@metrocombank.kz*/
      /*****************************************************************************/
      message "SWIFT файл сформирован!" .
      pause 1.

    end.
    when "view" then
    do:
        output to value(s-remtrz + ".txt") .
      /* put chr(1).*/

       put unformatted ValData.

      /* put chr(3).*/
       output close.

       find sysc where sysc.sysc = "swmail" no-lock no-error.
       if avail sysc then
       do:
          run mail(sysc.chval ,"bankadm@metrocombank.kz" , "Подготовлен к отправке МТ103 " + s-remtrz ,
          "Создал - " + userid('bank') + "\n" +  ValData , "1" , "" , s-remtrz + ".txt" ).
       end.
       else do:
          run mail( userid('bank') + "@metrocombank.kz" ,"bankadm@metrocombank.kz" , "Подготовлен к отправке МТ103 " + s-remtrz ,
           "Создал - " + userid('bank') + "\n" +  ValData  , "1" , "" , s-remtrz + ".txt" ).
       end.
    end.
    otherwise do:
      message "Неизвестный параметр - " + what view-as alert-box.



    end.
    end case.












/*------------------------------------------------------------------------------------------------*/
/**/
/**/
/**/
/**/
/*                                     Ниже старая версия                                         */
/**/
/**/
/**/
/**/
/**/
/*------------------------------------------------------------------------------------------------*/


/* /data/export/mt103 */
/*
for each  swbody where swbody.rmz="RMZA134461" and swbody.type <> 'N' by swbody.swfield.

what = send swmt = 103 s-sqn = scod = ok


displ swbody
*/
return.



/*
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
def var l_71block as logical init false.

/* Определяем где запускам печать
ourcode=comm-cod().
&scoped-define bnkf if ourcode<>0 then 'txb.' else ''
if ourcode<>0 then  */



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
find first swbody no-lock where swbody.rmz = s-remtrz and swbody.swfield='DS' no-error.
if avail swbody then destination=caps(trim(swbody.content[1])).
                else do:
                     message "Платеж еще не отправлен! (пустое поле Destination)". pause. leave.
                end.

find sysc where sysc.sysc = "swicod" no-lock. /* Возьмем наш свифт-код */

/* HEADER SEND */
if what = "send" then do:
        put unformatted
        "+++ DESTINATION  " destination format "x(12)" "DATE SENT " at 41 date1 skip
        "+++ SENDER       ".

                 put caps(trim(sysc.chval)) format "x(12)".
                 put "TIME SENT " at 41.
                 put string(time,"HH:MM:SS") skip.

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

for each swbody no-lock where swbody.rmz = s-remtrz and swbody.type <> "N" by swbody.swfield by swbody.type. /* sasco : ++sort by type для 71A, 71F */
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
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" swbody.content[1] skip.
        end.
        /* Для совместимости с филиалами подставляем свой RMZ*/
        when "20" then do:
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + (if crc.crc = 4 then "+" else "") + s-remtrz + "-S" skip.
        end.
        when "21" or when "23" or when "23" then do:
                put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + swbody.content[1] skip.
        end.
        when "71" then do:
            if not l_71block then do:
                if swbody.type = 'A' then do:
                   put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                   l_71block = True.
                end.
                else if swbody.type = 'F' and trim (swbody.content[1]) <> '' then do:
                    put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" +
                    trim(entry(1, swbody.content[1], ' ')) +
                    replace(trim(entry(2, swbody.content[1], ' ')), '.', ',') skip.
                    l_71block = True.
                end.
                else do:
                    put unformatted bpref + tmpfld + tmptype tmpdesc format "x(31)" ":" + swbody.content[1] skip.
                    l_71block = True.
                end.
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

put "============================================================================" skip.


if what <> "send" then do:
         put skip(1).


         output close.

         case what:
           when "print" then unix silent prit -t rpt.txt.
           when "view"  then run menu-prt("rpt.txt").
         end case.
end.
else do:
        put "~014".
        output close.
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


         run swmt-cre(s-remtrz,g-today,"file",swmt,s-sqn,scod).

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


*/


