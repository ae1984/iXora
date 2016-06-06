/* ofctmpl.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{global.i}

define var i as integer.
define var s as char.
def var l as logical.
define temp-table tmp
       field ofc as char
       field tmpl as char.

message "Формируется отчет...".
       

for each ujosec no-lock:
    repeat i=1 to NUM-ENTRIES (ujosec.officers):
       s = ENTRY (i,ujosec.officers).
      
       if can-find (first tmp where tmp.tmpl = ujosec.template
                                    and tmp.ofc = s) then next.
       create tmp.
       update tmp.ofc = s
              tmp.tmpl = ujosec.template.
    end.
end.

for each tmp where tmp.ofc = ''. delete tmp. end.

output to ofctmpl.img.

PUT skip(1) "ПРАВА ДОСТУПА К ШАБЛОНАМ В СИСТЕМЕ 'PRAGMA'. "  g-today  "  "  
    string(time,"HH:MM:SS") SKIP(1).

for each tmp break by tmp.tmpl by tmp.ofc:
  if first-of (tmp.tmpl) then do:
    find trxhead where caps(trxhead.system + string(trxhead.code, "9999")) = caps(tmp.tmpl) no-lock no-error.
    l = available trxhead.
    if l then 
      put unformatted skip(1) "Шаблон : " tmp.tmpl "   " trxhead.des format "x(66)"  skip 
                    "-----------------------" skip.
  end.

  if l then do:
    find ofc where ofc.ofc = tmp.ofc no-lock no-error.
    if available ofc then s = ofc.name. else s = "(неизвестно)".
    put unformatted tmp.ofc s format "x(60)" at 12 skip.
  end.
end.

output close.

run menu-prt("ofctmpl.img").

