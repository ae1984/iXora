/* chk_sndink.p
 * MODULE
        Проверка отправки уведомления о получении ИР РПРО
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        21/06/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        22/06/2011 evseev - проверять все записи позднее g-today - 10
        22/06/2011 evseev - добавил проверку по отзывам
        23/06/2011 evseev - 06/23/2011 -> 06/24/2011
        22/09/2011 evseev - исключение inc100.stat = 13 из проверки
        26/01/2012 evseev - добавил исключения из проверки
        13.06.2012 evseev - поправил алгоритм
*/
{global.i}

def var v-ink as char.
def var v-rpro as char.
def var v-insrec as char.
def var v-increc as char.
v-ink = ''.
v-rpro = ''.
v-insrec = ''.
v-increc = ''.

           /*9:30              18:00  */
if (time >= 34200) and (time < 64800) and (g-today = today) then do:

    for each inc100 where (inc100.rdt > g-today - 10) and ((inc100.rdt < g-today) or (time - inc100.rtm) > 1800) no-lock:
        find first inchist where inchist.incref = inc100.ref and inchist.ref matches "TINC*" no-lock no-error.
        if not avail inchist then do:
           if v-ink <> '' then v-ink = v-ink + ', '.
           v-ink = v-ink + inc100.ref.
        end.
    end.
    if v-ink <> '' then run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: уведомление о получении ИР не отправленно в НК",
                      "Референс документа: " + v-ink, "1", "", "").

    for each insin where (insin.rdt > g-today - 10) and ((insin.rdt < g-today) or (time - insin.rtm) > 1800) no-lock:
        find first inshist where inshist.insref = insin.ref and inshist.outfile matches "TINS*" no-lock no-error.
        if not avail inshist then do:
           if v-rpro <> '' then v-rpro = v-rpro + ', '.
           v-rpro = v-rpro + insin.ref.
        end.
    end.
    if v-rpro <> '' then run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: уведомление о получении РПРО не отправленно в НК",
                      "Референс документа: " + v-rpro, "1", "", "").

    for each insrec where (insrec.rdt > g-today - 10) and ((insrec.rdt < g-today) or (time - insrec.rtm) > 1800) no-lock:
        find first inshist where inshist.insref = insrec.ref and inshist.outfile matches "RINS*" no-lock no-error.
        if not  avail inshist then do:
           if v-insrec <> '' then v-insrec = v-insrec + ', '.
           v-insrec = v-insrec + insrec.ref.
        end.
    end.
    if v-insrec <> '' then run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: уведомление о получении отзыва РПРО не отправленно в НК",
                      "Референс документа: " + v-insrec, "1", "", "").

    for each inkor1 where (inkor1.rdt >= 06/24/2011) and (inkor1.rdt > g-today - 10) and ((inkor1.rdt < g-today) or (time - inkor1.rtm) > 1800) no-lock:
        find first pksysc where pksys.sysc = "inkor1ref" no-lock no-error.
        if avail pksysc and pksys.chval <> "" then do:
           if lookup (inkor1.ref, pksys.chval) > 0 then next.
        end.

        find first inc100 where inc100.ref = inkor1.inkref no-lock no-error.
        if avail inc100 then do:
            if inc100.stat <> 13 then do:
                find first inchist where inchist.incref = inkor1.ref and inchist.ref matches "RECINC*" no-lock no-error.
                if not  avail inchist then do:
                   if v-increc <> '' then v-increc = v-increc + ', '.
                   v-increc = v-increc + inkor1.ref.
                end.
            end.
        end. else do:
             run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: на уведомление о получении отзыва ИР не найден ИР",
                           "Референс отзыва ИР: " + inkor1.ref + "  Референс ИР: " + inkor1.inkref, "1", "", "").
        end.
    end.
    if v-increc <> '' then run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: уведомление о получении отзыва ИР не отправленно в НК",
                      "Референс документа: " + v-increc, "1", "", "").



end.