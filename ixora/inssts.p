/* inssts.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Определение статуса РПРО
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
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        10/12/2009 galina - отправляем статус счет не найден, только если все счета не найдены
        13/01/2010 galina - поменяла алгоритм определния статуса документа
        21/01/2010 galina - запись в историю при любом статусе документа
        12/05/2011 evseev - статус документа через getstatforinsin
        10/06/2011 evseev - решена проблема повторной отправки сообщений в НК
        14/06/2011 evseev - переход на ИИН/БИН
        20/06/2011 evseev - добавил логирование в _inssts
        20/06/2011 evseev - исправил v-bank1 на insin.bank1
        20/06/2011 evseev - исправил вывод в _inssts
        23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
        28/07/2011 evseev - изменил id00787 на id00787@metrocombank.kz
        10/05/2012 evseev - запрет отправки сообщения при статусе 0, уведомление о почту
        06.11.2012 evseev - изменил название файла
*/

{sysc.i}
{name-compare.i}
{chbin.i}
def shared var g-today as date.
def shared var g-ofc    like ofc.ofc.

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
def var v-ref       like insin.ref no-undo.
def var v-reflist as char no-undo.
def var k as integer no-undo.
def stream rstr.
def stream mt400.
def buffer b-cif for cif.
def buffer b-insin for insin.

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
   run savelog( "insps", "inssts: There is no record OURBNK in bank.sysc file!").
   return.
end.

s-vcourbank = trim(sysc.chval).
v-reflist = ''.
find first insin where insin.mnu = 'accept' and insin.stat = 0 and insin.bank = s-vcourbank no-lock no-error.
if avail insin then do:
    v-mt100out = "/data/export/insarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
    v-mt100err = "/data/export/insarc/err/".
    input through value( "find " + v-mt100out + ";echo $?").
    repeat:
        import unformatted v-exist1.
    end.
    if v-exist1 <> "0" then do:
        unix silent value ("mkdir " + v-mt100out).
        unix silent value("chmod 777 " + v-mt100out).
    end.

    for each insin where insin.mnu = 'accept' and insin.stat = 0 and insin.bank = s-vcourbank no-lock:
        /*статус документа*/
        run getstatforinsin (insin.ref, output v-stat).

        do transaction:
           find first b-insin where b-insin.ref = insin.ref exclusive-lock no-error.
           if avail b-insin then b-insin.stat = v-stat.
           find current b-insin no-lock.
           run savelog( "_inssts", " ref = " + insin.ref + " ; stat = " + string(b-insin.stat) + " ; v-stat = " + string(v-stat)).
        end.
        if v-reflist <> '' then v-reflist = v-reflist + ','.
        v-reflist = v-reflist + insin.ref.
    end.
   run savelog( "_inssts", " v-reflist = " + v-reflist).
   /*Налогоплательщик*/
    v-ref = ''.
    for each insin where insin.mnu = "accept" and insin.bank = s-vcourbank and insin.type = 'AC' no-lock:
      if lookup(insin.ref,v-reflist) = 0 then next.
      find first inshist where inshist.insref = insin.ref and inshist.outfile matches "TINS*" no-lock no-error.
      if not avail inshist then do:
         v-ref = insin.ref.
         leave.
      end.
    end.
    run savelog( "_inssts", " AC v-ref = " + v-ref).
    find first insin where insin.ref = v-ref no-lock no-error.
    if avail insin then do:
        do transaction:
            find first pksysc where pksysc.sysc = "insnum" exclusive-lock no-error.
            if avail pksysc then do:
                pksysc.inval = pksysc.inval + 1.
                v-counter = pksysc.inval.
                find current pksysc no-lock.
            end.
            else do:
                run savelog( "insps", "inssts: Ошибка определения текущего значения счетчика сообщений!").
                return.
            end.
        end.

        /* Формируем сообщение о получении инкассового распоряжения*/
        v-kref = string(v-counter, "999999").
        v-file = 'INS' + string(v-counter, "9999999999999") + ".txt".
        run savelog( "_inssts", " AC v-kref = " + v-kref + "; v-file = " + v-file).
        output stream mt400 to value(v-file).

        v-text = "\{1:F01K054700000000010" + v-kref + "\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{2:I998KNALOG000000N2020\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{4:".
        put stream mt400 unformatted v-text skip.

        v-text = ":20:INS" + string(v-counter, "9999999999999").
        put stream mt400 unformatted v-text skip.

        v-text = ":12:400".
        put stream mt400 unformatted v-text skip.

        v-text = ":77E:FORMS/PAC/" + substr(string(year(insin.rdt)),3,2) + string(month(insin.rdt),'99') + string(day(insin.rdt),'99') + replace(string(insin.rtm,'hh:mm'),':','') + '/Подт.получ.расп.о приост.расх.оп.н.'.
        put stream mt400 unformatted v-text skip.


        v-bankbik = get-sysc-cha("clecod").

        v-text = "/BANK/" + v-bankbik.
        put stream mt400 unformatted v-text skip.

        v-sumans = 0.
        v-kol = 0.

        for each insin where insin.mnu = "accept" and insin.bank = s-vcourbank and insin.type = 'AC' no-lock:
          if lookup(insin.ref,v-reflist) = 0 then do:
              run savelog( "_inssts", " AC insin.ref = " + insin.ref + " - отработал NEXT").
              next.
          end.

          if insin.stat = 0 then do:
              run savelog( "_inssts", " AC insin.ref = " + insin.ref + " ; insin.stat=" + string(insin.stat) + " - отработал NEXT").
              next.
          end.


          run savelog( "_inssts", " AC insin.ref = " + insin.ref + " - проверяем в inshist").
          find first inshist where inshist.insref = insin.ref and inshist.outfile matches "TINS*" no-lock no-error.
          if not avail inshist then do:
              if v-bin then v-text = "//07/" + insin.clbin + "/" + string(insin.numr) + "/" + substr(string(year(insin.dtr)),3,2) + string(month(insin.dtr),'99') + string(day(insin.dtr),'99') + "/" + insin.ref + "/" + string(insin.stat, "99").
              else v-text = "//07/" + insin.clrnn + "/" + string(insin.numr) + "/" + substr(string(year(insin.dtr)),3,2) + string(month(insin.dtr),'99') + string(day(insin.dtr),'99') + "/" + insin.ref + "/" + string(insin.stat, "99").
              put stream mt400 unformatted v-text skip.
              v-kol = v-kol + 1.
              /*if insin.stat = 1 then*/ do transaction:
                 create inshist.
                 assign inshist.outfile = "INS" + string(v-counter, "999999999")
                     inshist.insref = insin.ref
                     inshist.rdt = g-today
                     inshist.rtm = time.
              end.
              do transaction:
                 create inshist.
                 assign inshist.outfile = "TINS" + string(v-counter, "999999999")
                     inshist.insref = insin.ref
                     inshist.rdt = g-today
                     inshist.rtm = time.
              end.

          end. else run savelog( "_inssts", " AC insin.ref = " + insin.ref + " - в inshist есть запись").
        end.

        v-text = "/TOTAL/" + string(v-kol).
        put stream mt400 unformatted v-text skip
                                      "-\}" skip.

        output stream mt400 close.

        if v-kol > 0 then do:
            unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /*положили в терминал для отправки */
            unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
            run savelog( "_inssts", " AC v-file = " + v-file + " - отправлен").
        end. else do:
           /*
           do transaction:
                find first pksysc where pksysc.sysc = "insnum" exclusive-lock no-error.
                if avail pksysc then do:
                    pksysc.inval = pksysc.inval - 1.
                    find current pksysc no-lock.
                end.
                else do:
                    run savelog( "insps", "inssts: Ошибка определения текущего значения счетчика сообщений! (1)").
                    return.
                end.
           end.*/
           run savelog( "_inssts", " AC v-file = " + v-file + " - ошибка, пустое тело сообщения").
           run mail('id00787@metrocombank.kz', "METROCOMBANK <abpk@metrocombank.kz>", "Ошибка, пустое тело сообщения уведомления РПРО " + insin.bank1,
                   "Ошибка, пустое тело сообщения уведомления РПРО " + insin.bank1 + " ; ref = " + insin.ref, "1", "", "").
           unix silent value("mv " + v-file + " " + v-mt100err). /* положили в архив ошибок */
        end.

    end.

    /*ОПВ*/
    v-ref = ''.
    for each insin where insin.mnu = "accept" and insin.bank = s-vcourbank and insin.type = 'ACP' no-lock:
      if lookup(insin.ref,v-reflist) = 0 then next.
      find first inshist where inshist.insref = insin.ref and inshist.outfile matches "TINS*" no-lock no-error.
      if not avail inshist then do:
         v-ref = insin.ref.
         leave.
      end.
    end.
    run savelog( "_inssts", " ACP v-ref = " + v-ref).
    find first insin where insin.ref = v-ref no-lock no-error.
    if avail insin then do:
        do transaction:
            find first pksysc where pksysc.sysc = "insnum" exclusive-lock no-error.
            if avail pksysc then do:
                pksysc.inval = pksysc.inval + 1.
                v-counter = pksysc.inval.
                find current pksysc no-lock.
            end.
            else do:
                run savelog( "insps", "inssts: Ошибка определения текущего значения счетчика сообщений!").
                return.
            end.
        end.

        /* Формируем сообщение о получении инкассового распоряжения*/
        v-kref = string(v-counter, "999999").
        v-file = 'INS' + string(v-counter, "9999999999999") + ".txt".
        run savelog( "_inssts", " ACP v-kref = " + v-kref + "; v-file = " + v-file).
        output stream mt400 to value(v-file).

        v-text = "\{1:F01K054700000000010" + v-kref + "\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{2:I998KNALOG000000N2020\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{4:".
        put stream mt400 unformatted v-text skip.

        v-text = ":20:INS" + string(v-counter, "9999999999999").
        put stream mt400 unformatted v-text skip.

        v-text = ":12:400".
        put stream mt400 unformatted v-text skip.

        v-text = ":77E:FORMS/PAP/" + substr(string(year(insin.rdt)),3,2) + string(month(insin.rdt),'99') + string(day(insin.rdt),'99') + replace(string(insin.rtm,'hh:mm'),':','') + '/Подт.получ.расп.о приост.расх.оп.ОПВ'.
        put stream mt400 unformatted v-text skip.


        v-bankbik = get-sysc-cha("clecod").

        v-text = "/BANK/" + v-bankbik.
        put stream mt400 unformatted v-text skip.

        v-sumans = 0.
        v-kol = 0.

        for each insin where insin.mnu = "accept" and insin.bank = s-vcourbank and insin.type = 'ACP' no-lock:
          if lookup(insin.ref,v-reflist) = 0 then do:
              run savelog( "_inssts", " ACP insin.ref = " + insin.ref + " - отработал NEXT").
              next.
          end.
          if insin.stat = 0 then do:
              run savelog( "_inssts", " ACP insin.ref = " + insin.ref + " ; insin.stat=" + string(insin.stat) + " - отработал NEXT").
              next.
          end.

          run savelog( "_inssts", " ACP insin.ref = " + insin.ref + " - проверяем в inshist").
          find first inshist where inshist.insref = insin.ref and inshist.outfile matches "TINS*" no-lock no-error.
          if not avail inshist then do:
              if v-bin then v-text = "//07/" + insin.clbin + "/" + insin.numr + "/" + substr(string(year(insin.dtr)),3,2) + string(month(insin.dtr),'99') + string(day(insin.dtr),'99') + "/" + insin.ref + "/" + string(insin.stat, "99").
              else v-text = "//07/" + insin.clrnn + "/" + insin.numr + "/" + substr(string(year(insin.dtr)),3,2) + string(month(insin.dtr),'99') + string(day(insin.dtr),'99') + "/" + insin.ref + "/" + string(insin.stat, "99").
              put stream mt400 unformatted v-text skip.
              v-kol = v-kol + 1.
              /*if insin.stat = 1 then*/ do transaction:
                 create inshist.
                 assign inshist.outfile = "INS" + string(v-counter, "999999999")
                     inshist.insref = insin.ref
                     inshist.rdt = g-today
                     inshist.rtm = time.
              end.
              do transaction:
                 create inshist.
                 assign inshist.outfile = "TINS" + string(v-counter, "999999999")
                     inshist.insref = insin.ref
                     inshist.rdt = g-today
                     inshist.rtm = time.
              end.
          end. else run savelog( "_inssts", " ACP insin.ref = " + insin.ref + " - в inshist есть запись").
        end.

        v-text = "/TOTAL/" + string(v-kol).
        put stream mt400 unformatted v-text skip
                                 "-\}" skip.

        output stream mt400 close.


        if v-kol > 0 then do:
            unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /*положили в терминал для отправки */
            unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
            run savelog( "_inssts", " ACP v-file = " + v-file + " - отправлен").
        end. else do:
           /*do transaction:
                find first pksysc where pksysc.sysc = "insnum" exclusive-lock no-error.
                if avail pksysc then do:
                    pksysc.inval = pksysc.inval - 1.
                    find current pksysc no-lock.
                end.
                else do:
                    run savelog( "insps", "inssts: Ошибка определения текущего значения счетчика сообщений! (1)").
                    return.
                end.
           end.*/
           run savelog( "_inssts", " ACP v-file = " + v-file + " - ошибка, пустое тело сообщения").
           run mail('id00787@metrocombank.kz', "METROCOMBANK <abpk@metrocombank.kz>", "Ошибка, пустое тело сообщения уведомления РПРО " + insin.bank1,
                     "Ошибка, пустое тело сообщения уведомления РПРО " + insin.bank1 + " ; ref = " + insin.ref, "1", "", "").
           unix silent value("mv " + v-file + " " + v-mt100err). /* положили в архив ошибок */
        end.

    end.

       /*СО*/
    v-ref = ''.
    for each insin where insin.mnu = "accept" and insin.bank = s-vcourbank and insin.type = 'ASD' no-lock:
      if lookup(insin.ref,v-reflist) = 0 then next.
      find first inshist where inshist.insref = insin.ref and inshist.outfile matches "TINS*" no-lock no-error.
      if not avail inshist then do:
         v-ref = insin.ref.
         leave.
      end.
    end.
    run savelog( "_inssts", " ASD v-ref = " + v-ref).

    find first insin where insin.ref = v-ref no-lock no-error.
    if avail insin then do:
        do transaction:
            find first pksysc where pksysc.sysc = "insnum" exclusive-lock no-error.
            if avail pksysc then do:
                pksysc.inval = pksysc.inval + 1.
                v-counter = pksysc.inval.
                find current pksysc no-lock.
            end.
            else do:
                run savelog( "insps", "inssts: Ошибка определения текущего значения счетчика сообщений!").
                return.
            end.
        end.

        /* Формируем сообщение о получении инкассового распоряжения*/
        v-kref = string(v-counter, "999999").
        v-file = 'INS' + string(v-counter, "9999999999999") + ".txt".
        run savelog( "_inssts", " ASD v-kref = " + v-kref + "; v-file = " + v-file).

        output stream mt400 to value(v-file).

        v-text = "\{1:F01K054700000000010" + v-kref + "\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{2:I998KNALOG000000N2020\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{4:".
        put stream mt400 unformatted v-text skip.

        v-text = ":20:INS" + string(v-counter, "9999999999999").
        put stream mt400 unformatted v-text skip.

        v-text = ":12:400".
        put stream mt400 unformatted v-text skip.

        v-text = ":77E:FORMS/PAS/" + substr(string(year(insin.rdt)),3,2) + string(month(insin.rdt),'99') + string(day(insin.rdt),'99') + replace(string(insin.rtm,'hh:mm'),':','') + '/Подт.получ.расп.о приост.расх.оп.СО'.
        put stream mt400 unformatted v-text skip.

        v-bankbik = get-sysc-cha("clecod").

        v-text = "/BANK/" + v-bankbik.
        put stream mt400 unformatted v-text skip.

        v-sumans = 0.
        v-kol = 0.

        for each insin where insin.mnu = "accept" and insin.bank = s-vcourbank and insin.type = 'ASD' no-lock:
          if lookup(insin.ref,v-reflist) = 0 then do:
              run savelog( "_inssts", " ASD insin.ref = " + insin.ref + " - отработал NEXT").
              next.
          end.
          if insin.stat = 0 then do:
              run savelog( "_inssts", " ASD insin.ref = " + insin.ref + " ; insin.stat=" + string(insin.stat) + " - отработал NEXT").
              next.
          end.

          run savelog( "_inssts", " ASD insin.ref = " + insin.ref + " - проверяем в inshist").
          find first inshist where inshist.insref = insin.ref and inshist.outfile matches "TINS*" no-lock no-error.
          if not avail inshist then do:
              if v-bin then v-text = "//07/" + insin.clbin + "/" + insin.numr + "/" + substr(string(year(insin.dtr)),3,2) + string(month(insin.dtr),'99') + string(day(insin.dtr),'99') + "/" + insin.ref + "/" + string(insin.stat, "99").
              else v-text = "//07/" + insin.clrnn + "/" + insin.numr + "/" + substr(string(year(insin.dtr)),3,2) + string(month(insin.dtr),'99') + string(day(insin.dtr),'99') + "/" + insin.ref + "/" + string(insin.stat, "99").
              put stream mt400 unformatted v-text skip.
              v-kol = v-kol + 1.
              /*if insin.stat = 1 then*/ do transaction:
                 create inshist.
                 assign inshist.outfile = "INS" + string(v-counter, "999999999")
                     inshist.insref = insin.ref
                     inshist.rdt = g-today
                     inshist.rtm = time.
              end.
              do transaction:
                 create inshist.
                 assign inshist.outfile = "TINS" + string(v-counter, "999999999")
                     inshist.insref = insin.ref
                     inshist.rdt = g-today
                     inshist.rtm = time.
              end.
          end. else run savelog( "_inssts", " ASD insin.ref = " + insin.ref + " - в inshist есть запись").
        end.

        v-text = "/TOTAL/" + string(v-kol).
        put stream mt400 unformatted v-text skip
                                 "-\}" skip.

        output stream mt400 close.

        if v-kol > 0 then do:
            unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /*положили в терминал для отправки */
            unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
            run savelog( "_inssts", " ASD v-file = " + v-file + " - отправлен").
        end. else do:
           /*do transaction:
                find first pksysc where pksysc.sysc = "insnum" exclusive-lock no-error.
                if avail pksysc then do:
                    pksysc.inval = pksysc.inval - 1.
                    find current pksysc no-lock.
                end.
                else do:
                    run savelog( "insps", "inssts: Ошибка определения текущего значения счетчика сообщений! (1)").
                    return.
                end.
           end.*/
           run savelog( "_inssts", " ASD v-file = " + v-file + " - ошибка, пустое тело сообщения").
           run mail('id00787@metrocombank.kz', "METROCOMBANK <abpk@metrocombank.kz>", "Ошибка, пустое тело сообщения уведомления РПРО " + insin.bank1,
                    "Ошибка, пустое тело сообщения уведомления РПРО " + insin.bank1 + " ; ref = " + insin.ref, "1", "", "").
           unix silent value("mv " + v-file + " " + v-mt100err). /* положили в архив ошибок */
        end.


    end.
end. /*avail*/