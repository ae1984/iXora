/* snd_rasp.p
 * MODULE
        Казначейство
 * DESCRIPTION
        При старте процессов отправляем распоряжение по курсам валют
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
        26/03/2009 madiyar
 * BASES
        BANK
 * CHANGES
        27/03/2009 madiyar - исправления; на алматинском филиале рассылку не делаем, приходят из ЦО
*/

{global.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then return.
else s-ourbank = trim(sysc.chval).

find first tcrc where tcrc.whn = g-today and tcrc.dtime = 32400 no-lock no-error.
if avail tcrc then return.

def buffer b-crc for crc.

for each crc no-lock:
    /* курсы на начало дня 9-00 */
    if crc.crc = 2 or crc.crc = 3 or crc.crc = 4 then do:
        find last tcrc where tcrc.whn = g-today and tcrc.crc = crc.crc no-lock no-error.
        if not avail tcrc then do transaction:
            create tcrc.
            assign
                tcrc.crc = crc.crc
                tcrc.rate[2] = crc.rate[2]
                tcrc.rate[3] = crc.rate[3]
                tcrc.dtime = 32400.
                tcrc.whn = g-today.
        end. /* transaction */
    end.
end. /* for each crc */

if s-ourbank <> "txb16" then run rasp.

