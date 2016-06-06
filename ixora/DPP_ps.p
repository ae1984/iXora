/* DPP_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Формирование файла OW по длительным платежным поручениям и RMZ на основе ответного файла.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню
 * AUTHOR
        16/07/2013 id00800
 * BASES
        BANK COMM
 * CHANGES
 */


def var v-inval as int no-undo.
def var v-loval as logic no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    run savelog( "PPOUT", " There in't parametr ourbnk sysc!").
    return.
end.

if sysc.chval = "TXB00" then do: /* файл OW формир-ся только в ЦО */

    /* проверка времени для отправки файла в 10-00 */
    find first sysc where sysc.sysc = "ppout10" no-lock no-error.
    if not avail sysc  then do:
        run savelog( "PPOUT", " There is not parameter ppout10 sysc!").
        return.
    end.
    v-inval = sysc.inval. /* запоминаем признак прогрузки ответного файла */
    v-loval = sysc.loval.
    if sysc.loval = no and time >= 36000 and time < 46800 then run a_ppsend.

    /* проверка времени для отправки файла в 13-00 */
    find first sysc where sysc.sysc = "ppout13" no-lock no-error.
    if not avail sysc  then do:
        run savelog( "PPOUT", " There is not parameter ppout13 sysc!").
        return.
    end.
    /* файл OW в 13-00 формир-ся только если прогружали ответный файл 10-часового запроса */
    if sysc.loval = no and time >= 50400 and ((v-inval = 1 or v-loval = yes) /* значит 10 часовой файл отправили и получили ответ)*/
        or (v-inval = 0 or v-loval = no)) /*значит 10 часовой файл не отправился и ответ не получали и время уже больше 13-00 */
        then run a_ppsend.
end.

/* создание RMZ на основе ответного файла */
if time > 36000 and time < 63000 then run a_pprmz.
