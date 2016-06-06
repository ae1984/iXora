/* cr-swthead.i
 * MODULE
        Trade Finance
 * DESCRIPTION
        Функция формирования заголовка swift сообщения (блоки 1,2)
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
        04/08/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        10/02/2012 id00810 - добавила функцию get-path, перенесла сюда функции datestr,numstr
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
 */

def var v-clecod as char no-undo.
v-clecod = "".
find sysc where sysc.sysc = "clecod" no-lock no-error.
if avail sysc then v-clecod = sysc.chval.

  function cr-swthead returns char (p-fmt as char, p-bic as char).
    def var v-head as char no-undo.
    v-head = "\{1:F01" + v-clecod + "AXXXXXXXXXXXXX}\{2:I" + p-fmt.
    if substr(p-bic,9,3) = 'XXX' then v-head = v-head + p-bic + "XN}".
    else v-head = v-head + substr(p-bic,1,8) + "X" + substr(p-bic,9,3) + "N}".
    return v-head.
  end function.

  function get-path returns char (input p-code as char).
    def var v-path as char no-undo.
    v-path = ''.
    find first pksysc where pksysc.credtype = '' and pksysc.sysc = p-code no-lock no-error.
    if avail pksysc then v-path = pksysc.chval.
    return v-path.
  end function.

  function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
    end function.

  function numstr returns char (input p-numin as char).
    def var v-num as char.
    v-num = replace(p-numin,'.',',').
    if index(v-num,',') = 0 then v-num = v-num + ',00'.
    return v-num.
  end function.


