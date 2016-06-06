/* vincheck_sps.i
 * MODULE
        Проверяет VIN код
 * DESCRIPTION
        Описание программы
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
        04.07.2013 yerganat
 * BASES
        COMM
 * CHANGES
*/

define variable v-vin          as char.
v-vin = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "vin").

find first vincode where vincode.vin = v-vin use-index vinbinidx no-lock no-error.
if not avail vincode then do:
  find first vincode where vincode.f45 = v-vin use-index F45idx no-lock no-error.
  if not avail vincode then do:
    r-code = '1'.
    r-des = 'VIN-код не найден в базе'.
  end.
end.

run setText in replyH (r-code).
run deleteMessage in requestH.

/***********************************************************************************/
