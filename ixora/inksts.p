/* inksts.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Пункт меню
 * AUTHOR
        27/11/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        02/12/2008 alex - убрал перикодировку в DOS
        25/12/2008 alex - добавил валюту счета (если была указана)
        10/06/2009 galina - добавила обработку ОПВ и СО
        11.06.2009 galina - небольшие корректировки условий для ОПВ и СО
        13/01/2010 galina - поменяла алгоритм определния статуса документа
        10/06/2011 evseev - решена проблема повторной отправки сообщений в НК
        14/06/2011 evseev - переход на ИИН/БИН
        23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
        24/06/2011 evseev - добавил пробел между комментом и unix silent
*/

{sysc.i}
{chbin.i}
def shared var g-today as date.
def shared var g-ofc like ofc.ofc.

def var v-sumans    as dec no-undo.
def var v-kol       as int no-undo.
def var v-kref      as char no-undo.
def var v-text      as char no-undo.
def var v-file      as char no-undo.
def var v-str       as char no-undo.
def var v-stat      as integer no-undo.
def var v-bankbik   as char no-undo.
def var v-counter   as int no-undo.
def var v-exist1    as char no-undo.
def var s-vcourbank as char no-undo.
def var v-ref       like inc100.ref no-undo.
def var v-reflist as char no-undo.
def stream rstr.
def stream mt400.
def buffer b-cif for cif.
def buffer b-inc100 for inc100.

def var v-mt100out  as char no-undo.
def var v-mt100err  as char no-undo.

def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.
v-term = sysc.chval.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   run savelog( "inkps", "inksts: There is no record OURBNK in bank.sysc file!").
   return.
end.

s-vcourbank = trim(sysc.chval).
v-reflist = ''.
find first inc100 where inc100.mnu = 'accept' and inc100.stat = 0 and inc100.bank = s-vcourbank  no-lock no-error.
if avail inc100 then do:
    v-mt100out = "/data/export/inkarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
    v-mt100err = "/data/export/inkarc/err/".
    input through value( "find " + v-mt100out + ";echo $?").
    repeat:
        import unformatted v-exist1.
    end.
    if v-exist1 <> "0" then do:
        unix silent value ("mkdir " + v-mt100out).
        unix silent value("chmod 777 " + v-mt100out).
    end.

    for each inc100 where inc100.mnu = 'accept' and inc100.stat = 0 and inc100.bank = s-vcourbank no-lock:
        /*
        v-stat = 11.
        for each cif where cif.jss = inc100.jss no-lock:
            find first aaa where aaa.cif = cif.cif and aaa.aaa = inc100.iik no-lock no-error.
            if avail aaa then do:
                if (aaa.sta ne "C") and (aaa.sta ne "E") then v-stat = 1.
                else v-stat = 13.
                leave.
            end.
            else v-stat = 12.
            --проверка резидентства и сектора экономики клиента--
            if inc100.vo = '07' or inc100.vo = '09' then do:
               if cif.geo = '021' and substr(inc100.irsseco,1,1) <> '1' then v-stat = 24.
               find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' no-lock no-error.
               if avail sub-cod and substr(inc100.irsseco,2,1) <> sub-cod.ccode then v-stat = 24.
            end.
        end.
        */
        /*************/
        v-stat = 12.
        find first aaa where aaa.aaa = inc100.iik no-lock no-error.
        if avail aaa then do:
           find first cif where cif.cif = aaa.cif no-lock no-error.
           if not avail cif then do:
             if v-bin then find first b-cif where b-cif.bin = inc100.bin no-lock no-error. else find first b-cif where b-cif.jss = inc100.jss no-lock no-error.
             if avail b-cif then v-stat = 16.
             else v-stat = 11.
           end.
           else do:
             if v-bin then do:
                 if cif.bin <> inc100.bin then v-stat = 16.
                 else do:
                   if (aaa.sta ne "C") and (aaa.sta ne "E") then v-stat = 1.
                   else v-stat = 13.
                 end.
             end.
             else do:
                 if cif.jss <> inc100.jss then v-stat = 16.
                 else do:
                   if (aaa.sta ne "C") and (aaa.sta ne "E") then v-stat = 1.
                   else v-stat = 13.
                 end.
             end.
           end.
        end.
        if v-stat = 1 then do:
           /*проверка резидентства и сектора экономики клиента*/
           if inc100.vo = '07' or inc100.vo = '09' then do:
              if cif.geo = '021' and substr(inc100.irsseco,1,1) <> '1' then v-stat = 24.
              find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' no-lock no-error.
              if avail sub-cod and substr(inc100.irsseco,2,1) <> sub-cod.ccode then v-stat = 24.
           end.
        /*end.*/



        /***************/

        /*if v-stat = 1 then do:*/
            find first codfr where codfr.codfr = 'spnpl' and codfr.child = false and codfr.code ne 'msc' and codfr.code matches '*' and codfr.code eq string(inc100.knp, "999") no-lock no-error.
            if not avail codfr then v-stat = 15.
            if avail codfr then do:
              if inc100.vo = '07' or inc100.vo = '09' then do:
                if inc100.vo = '07' and inc100.knp <> 10 and inc100.knp <> 19 then v-stat = 15.
                if inc100.vo = '09' and inc100.knp <> 12 and inc100.knp <> 17 then v-stat = 15.
              end.
              if inc100.vo <> '07' and inc100.vo <> '09' then do:
                 find first budcodes where budcodes.code eq inc100.kbk no-lock no-error.
                 if not avail budcodes then v-stat = 14.
              end.
            end.
        end.
        do transaction:
            find first b-inc100 where b-inc100.ref = inc100.ref exclusive-lock no-error.
            if avail b-inc100 then do:
                b-inc100.stat = v-stat.
                find current b-inc100 no-lock.
            end.
        end.
        if v-reflist <> '' then v-reflist = v-reflist + ','.
        v-reflist = v-reflist + inc100.ref.
    end.

   /*налоговые*/
    v-ref = ''.
    for each inc100 where inc100.mnu = "accept" and inc100.bank = s-vcourbank and inc100.vo <> '07' and inc100.vo <> '09' no-lock:
      if lookup(inc100.ref,v-reflist) = 0 then next.
      find first inchist where inchist.incref = inc100.ref and inchist.ref matches "TINC*" no-lock no-error.
      if not avail inchist then do:
         v-ref = inc100.ref.
         leave.
      end.
    end.
    find first inc100 where inc100.ref = v-ref no-lock no-error.
    if avail inc100 then do:
        v-str = "".

        do transaction:
            find first pksysc where pksysc.sysc = "inccou" exclusive-lock no-error.
            if avail pksysc then do:
                pksysc.inval = pksysc.inval + 1.
                v-counter = pksysc.inval.
                find current pksysc no-lock.
            end.
            else do:
                run savelog( "inkps", "inksts: Ошибка определения текущего значения счетчика сообщений!").
                return.
            end.
        end.

        /* Формируем сообщение о получении инкассового распоряжения*/
        v-kref = string(v-counter, "999999").
        v-file = 'INC' + string(v-counter, "9999999999999") + ".txt".

        output stream mt400 to value(v-file).

        v-text = "\{1:F01K054700000000010" + v-kref + "\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{2:I998KNALOG000000N2020\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{4:".
        put stream mt400 unformatted v-text skip.

        v-text = ":20:INC" + string(v-counter, "9999999999999").
        put stream mt400 unformatted v-text skip.

        v-text = ":12:400".
        put stream mt400 unformatted v-text skip.

        v-text = ":77E:FORMS/P01/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Подтверждение о принятии инк. распоряжений".
        put stream mt400 unformatted v-text skip.


        v-bankbik = get-sysc-cha("clecod").

        v-text = "/BANK/" + v-bankbik.
        put stream mt400 unformatted v-text skip.

        v-sumans = 0.
        v-kol = 0.

        for each inc100 where inc100.mnu = "accept" and inc100.bank = s-vcourbank and inc100.vo <> '07' and inc100.vo <> '09' no-lock:
            if lookup(inc100.ref,v-reflist) = 0 then next.
            find first inchist where inchist.incref = inc100.ref and inchist.ref matches "TINC*" no-lock no-error.
            if not avail inchist then do:
                if v-bin then v-text = "//07/" + inc100.bin + "/" + string(inc100.iik,"x(20)") + inc100.reschar[5] + "/" + inc100.crc + "/" + replace(trim(string(inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(inc100.num) + "/" + inc100.ref + "/" + string(inc100.stat, "99").
                else v-text = "//07/" + inc100.jss + "/" + string(inc100.iik,"x(20)") + inc100.reschar[5] + "/" + inc100.crc + "/" + replace(trim(string(inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(inc100.num) + "/" + inc100.ref + "/" + string(inc100.stat, "99").
                put stream mt400 unformatted v-text skip.
                v-sumans = v-sumans + inc100.sum.
                v-kol = v-kol + 1.
                if inc100.stat = 1 then do transaction:
                    find first b-inc100 where b-inc100.ref = inc100.ref exclusive-lock no-error.
                    if avail b-inc100 then do:
                        b-inc100.mnu = "pay".
                        find current b-inc100 no-lock.
                    end.
                end.
                do transaction:
                    create inchist.
                    assign inchist.ref = "TINC" + string(v-counter, "9999999999999")
                           inchist.incref = inc100.ref
                           inchist.rdt = g-today
                           inchist.rtm = time.
                end. /* transaction */
            end.
        end.

        v-text = "/TOTAL/" + string(v-kol) + "/KZT/" + replace(trim(string(v-sumans, ">>>>>>>>>>>>9.99")), ".", ",").
        put stream mt400 unformatted v-text skip
                                 "-\}" skip.

        output stream mt400 close.

        do transaction:
            create inchist.
            assign inchist.ref = "INC" + string(v-counter, "9999999999999")
                inchist.incref = "TOTAL"
                inchist.rdt = g-today
                inchist.rtm = time.
        end. /* transaction */



        /*unix silent value('echo "" >> ' + v-file).
        unix silent value("/pragma/bin9/win2dos mt.txt " + v-file).*/
        if v-kol > 0 then do:
            unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /* положили в терминал для отправки */
            unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
        end. else unix silent value("mv " + v-file + " " + v-mt100err). /* положили в архив ошибок */
    end.

    /*пенсионные*/
    v-ref = ''.
    for each inc100 where inc100.mnu = "accept" and inc100.bank = s-vcourbank and inc100.vo = '07' no-lock:
      if lookup(inc100.ref,v-reflist) = 0 then next.
      find first inchist where inchist.incref = inc100.ref and inchist.ref matches "TINC*" no-lock no-error.
      if not avail inchist then do:
         v-ref = inc100.ref.
         leave.
      end.
    end.
    find first inc100 where inc100.ref = v-ref no-lock no-error.
    if avail inc100 then do:
        v-str = "".

        do transaction:
            find first pksysc where pksysc.sysc = "inccou" exclusive-lock no-error.
            if avail pksysc then do:
                pksysc.inval = pksysc.inval + 1.
                v-counter = pksysc.inval.
                find current pksysc no-lock.
            end.
            else do:
                run savelog( "inkps", "inksts: Ошибка определения текущего значения счетчика сообщений!").
                return.
            end.
        end.

        /* Формируем сообщение о получении инкассового распоряжения*/
        v-kref = string(v-counter, "999999").
        v-file = 'INC' + string(v-counter, "9999999999999") + ".txt".
        message v-file  view-as alert-box.
        output stream mt400 to value(v-file).

        v-text = "\{1:F01K054700000000010" + v-kref + "\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{2:I998KNALOG000000N2020\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{4:".
        put stream mt400 unformatted v-text skip.

        v-text = ":20:INC" + string(v-counter, "9999999999999").
        put stream mt400 unformatted v-text skip.

        v-text = ":12:400".
        put stream mt400 unformatted v-text skip.

        v-text = ":77E:FORMS/P1P/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Подтверждение получения инк. расп. по ОПВ".
        put stream mt400 unformatted v-text skip.

        v-bankbik = get-sysc-cha("clecod").

        v-text = "/BANK/" + v-bankbik.
        put stream mt400 unformatted v-text skip.

        v-sumans = 0.
        v-kol = 0.

        for each inc100 where inc100.mnu = "accept" and inc100.bank = s-vcourbank and inc100.vo = '07' no-lock:
            if lookup(inc100.ref,v-reflist) = 0 then next.
            find first inchist where inchist.incref = inc100.ref and inchist.ref matches "TINC*" no-lock no-error.
            if not avail inchist then do:
                if v-bin then v-text = "//07/" + inc100.bin + "/" + string(inc100.iik,"x(20)") + "/" + inc100.crc + "/" + replace(trim(string(inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(inc100.num) + "/" + inc100.ref + "/" + string(inc100.stat, "99").
                else v-text = "//07/" + inc100.jss + "/" + string(inc100.iik,"x(20)") + "/" + inc100.crc + "/" + replace(trim(string(inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(inc100.num) + "/" + inc100.ref + "/" + string(inc100.stat, "99").
                put stream mt400 unformatted v-text skip.
                v-sumans = v-sumans + inc100.sum.
                v-kol = v-kol + 1.
                if inc100.stat = 1 then do transaction:
                    find first b-inc100 where b-inc100.ref = inc100.ref exclusive-lock no-error.
                    if avail b-inc100 then do:
                        b-inc100.mnu = "pay".
                        find current b-inc100 no-lock.
                    end.
                end.
                do transaction:
                    create inchist.
                    assign inchist.ref = "TINC" + string(v-counter, "9999999999999")
                           inchist.incref = inc100.ref
                           inchist.rdt = g-today
                           inchist.rtm = time.
                end. /* transaction */
            end.
        end.

        v-text = "/TOTAL/" + string(v-kol) + "/KZT/" + replace(trim(string(v-sumans, ">>>>>>>>>>>>9.99")), ".", ",").
        put stream mt400 unformatted v-text skip
                                 "-\}" skip.

        output stream mt400 close.

        do transaction:
            create inchist.
            assign inchist.ref = "INC" + string(v-counter, "9999999999999")
                inchist.incref = "TOTAL"
                inchist.rdt = g-today
                inchist.rtm = time.
        end. /* transaction */

        if v-kol > 0 then do:
            unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /* положили в терминал для отправки */
            unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
        end. else unix silent value("mv " + v-file + " " + v-mt100err). /* положили в архив ошибок */

    end. /*vo = 07*/
    /*социальные*/
    v-ref = ''.
    for each inc100 where inc100.mnu = "accept" and inc100.bank = s-vcourbank and inc100.vo = '09' no-lock:
      if lookup(inc100.ref,v-reflist) = 0 then next.
      find first inchist where inchist.incref = inc100.ref and inchist.ref matches "TINC*" no-lock no-error.
      if not avail inchist then do:
         v-ref = inc100.ref.
         leave.
      end.
    end.
    find first inc100 where inc100.ref = v-ref no-lock no-error.
    if avail inc100 then do:
        v-str = "".

        do transaction:
            find first pksysc where pksysc.sysc = "inccou" exclusive-lock no-error.
            if avail pksysc then do:
                pksysc.inval = pksysc.inval + 1.
                v-counter = pksysc.inval.
                find current pksysc no-lock.
            end.
            else do:
                run savelog( "inkps", "inksts: Ошибка определения текущего значения счетчика сообщений!").
                return.
            end.
        end.

        /* Формируем сообщение о получении инкассового распоряжения*/
        v-kref = string(v-counter, "999999").
        v-file = 'INC' + string(v-counter, "9999999999999") + ".txt".

        output stream mt400 to value(v-file).

        v-text = "\{1:F01K054700000000010" + v-kref + "\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{2:I998KNALOG000000N2020\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{4:".
        put stream mt400 unformatted v-text skip.

        v-text = ":20:INC" + string(v-counter, "9999999999999").
        put stream mt400 unformatted v-text skip.

        v-text = ":12:400".
        put stream mt400 unformatted v-text skip.

        v-text = ":77E:FORMS/P1S/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Подтверждение получения инк. расп. по СО".
        put stream mt400 unformatted v-text skip.

        /*{sysc.i}*/
        v-bankbik = get-sysc-cha("clecod").

        v-text = "/BANK/" + v-bankbik.
        put stream mt400 unformatted v-text skip.

        v-sumans = 0.
        v-kol = 0.

        for each inc100 where inc100.mnu = "accept" and inc100.bank = s-vcourbank  and inc100.vo = '09' no-lock:
            if lookup(inc100.ref,v-reflist) = 0 then next.
            find first inchist where inchist.incref = inc100.ref and inchist.ref matches "TINC*" no-lock no-error.
            if not avail inchist then do:
                if v-bin then v-text = "//07/" + inc100.bin + "/" + string(inc100.iik,"x(20)") + "/" + inc100.crc + "/" + replace(trim(string(inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(inc100.num) + "/" + inc100.ref + "/" + string(inc100.stat, "99").
                else v-text = "//07/" + inc100.jss + "/" + string(inc100.iik,"x(20)") + "/" + inc100.crc + "/" + replace(trim(string(inc100.sum, ">>>>>>>>>>>>9.99")), ".", ",") + "/" + string(inc100.num) + "/" + inc100.ref + "/" + string(inc100.stat, "99").
                put stream mt400 unformatted v-text skip.
                v-sumans = v-sumans + inc100.sum.
                v-kol = v-kol + 1.
                if inc100.stat = 1 then do transaction:
                    find first b-inc100 where b-inc100.ref = inc100.ref exclusive-lock no-error.
                    if avail b-inc100 then do:
                        b-inc100.mnu = "pay".
                        find current b-inc100 no-lock.
                    end.
                end.
                do transaction:
                    create inchist.
                    assign inchist.ref = "TINC" + string(v-counter, "9999999999999")
                           inchist.incref = inc100.ref
                           inchist.rdt = g-today
                           inchist.rtm = time.
                end. /* transaction */
            end.
        end.

        v-text = "/TOTAL/" + string(v-kol) + "/KZT/" + replace(trim(string(v-sumans, ">>>>>>>>>>>>9.99")), ".", ",").
        put stream mt400 unformatted v-text skip
                                 "-\}" skip.

        output stream mt400 close.

        do transaction:
            create inchist.
            assign inchist.ref = "INC" + string(v-counter, "9999999999999")
                inchist.incref = "TOTAL"
                inchist.rdt = g-today
                inchist.rtm = time.
        end. /* transaction */

        if v-kol > 0 then do:
            unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /* положили в терминал для отправки */
            unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
        end. else unix silent value("mv " + v-file + " " + v-mt100err). /* положили в архив ошибок */

    end. /*vo = 09*/

end. /*avail*/