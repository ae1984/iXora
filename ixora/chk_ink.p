/* chk_ink.p
 * MODULE
        Проверка процессов ИР РПРО
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
        20/06/2011 evseev
 * BASES
        COMM TXB
 * CHANGES
        21/06/2011 evseev - исправил metrobank.kz на metrocombank.kz
        22/06/2011 evseev - проверка с 9:30 до 18:00
        22/06/2011 evseev - увеличил время простоя с 1500 на 1800 и с 1200 на 1500
*/
{global.i}

           /*9:30              18:00  */
if (time >= 34200) and (time < 64800) and (g-today = today) then do:

        find last txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.

        find first txb.dproc where txb.dproc.pid = "INKP" no-lock no-error.
        if not avail txb.dproc then
           run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Процесс INKP не найден" + txb.sysc.chval,
                    "Необходимо стартовать процесс INKP на " + txb.sysc.chval, "1", "", "").

        else if (time - txb.dproc.l_time) > 1800 then
                 run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Процесс INKP не отвечает" + txb.sysc.chval,
                          "Необходимо перестартовать процесс INKP на " + txb.sysc.chval, "1", "", "").


        find first txb.dproc where txb.dproc.pid = "INSP" no-lock no-error.
        if not avail txb.dproc then
           run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Процесс INSP не найден" + txb.sysc.chval,
                    "Необходимо стартовать процесс INSP на " + txb.sysc.chval, "1", "", "").
        else if (time - txb.dproc.l_time) > 1800 then
                 run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Процесс INSP не отвечает" + txb.sysc.chval,
                          "Необходимо перестартовать процесс INSP на " + txb.sysc.chval, "1", "", "").

        if txb.sysc.chval = "TXB00" then do:
            find first txb.dproc where txb.dproc.pid = "INKM" no-lock no-error.
            if not avail txb.dproc then run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Процесс INKM не найден" + txb.sysc.chval,
                    "Необходимо стартовать процесс INKM на " + txb.sysc.chval, "1", "", "").
            else if (time - txb.dproc.l_time) > 1500 then
                 run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Процесс INKM не отвечает" + txb.sysc.chval,
                          "Необходимо перестартовать процесс INKM на " + txb.sysc.chval, "1", "", "").

            find first txb.dproc where txb.dproc.pid = "INSM" no-lock no-error.
            if not avail txb.dproc then
               run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Процесс INSM не найден" + txb.sysc.chval,
                        "Необходимо стартовать процесс INSM на " + txb.sysc.chval, "1", "", "").
            else if (time - txb.dproc.l_time) > 1500 then
                    run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Процесс INSM не отвечает" + txb.sysc.chval,
                            "Необходимо перестартовать процесс INSM на " + txb.sysc.chval, "1", "", "").
        end.

end.