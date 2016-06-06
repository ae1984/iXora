/* fiobyiin.i
 * MODULE
        Используется в ИБ для формирования заявления
 * DESCRIPTION
        Получает ФИО по ИИНу
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
        26.09.2013 yerganat
 * BASES
        COMM
 * CHANGES
*/

define variable v-iin          as char.
define variable v-fio          as char.
v-iin = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "IIN").

find first rnn where rnn.bin = v-iin no-lock no-error.
if avail rnn then do:
    v-fio = rnn.lname + ' ' + rnn.fname + ' ' + rnn.mname.
end.

run setText in replyH (v-fio).
run deleteMessage in requestH.

/***********************************************************************************/
