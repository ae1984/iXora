/* sysc-ent.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        редактирует справочник Sysc
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
        06/05/04 sasco добавил маску для поиска (по клавише F)
        14/05/04 sasco добавил поиск по sysc
        05/10/06 u00568 Evgeniy - сделал чтобы обрабатывались sysc.sysc длиной более 6 символов
        08/11/06 u00121 - привел вывод и редактирование sysc.sysc в нормальный вид.
        23/06/2008 madiyar - расширил фрейм, вернул "человеческое" редактирование записей, без доп. фреймов
*/

{mainhead.i SSGEN}
for each sysc where sysc.sysc = "" .
 delete sysc .
end.
form sysc.chval format "x(312)"
 with frame y  overlay  row 14
  centered top-only no-label.

define variable s_rowid as rowid.

define variable s-mask as character format "x(20)" initial "*".

define variable s-entries as character initial "".
define variable srch as character format "x(40)" label "Строка поиска" initial "".
define variable srch2 as character.

/*{headln-w.i */
{jabrw.i 
&start     = " "
&head      = "sysc"
&headkey   = "sysc"
&index     = "sysc"

&formname  = "sysc"
&framename = "sysc"
&where     = " sysc.sysc matches s-mask and (s-entries = '' or lookup(sysc.sysc, s-entries) > 0) " /** SASCO **/

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = " update sysc.sysc sysc.des sysc.daval sysc.deval
 sysc.inval sysc.loval  with frame sysc .
 update sysc.chval with frame y. "
            
       
&prechoose = "message 'F4-Выход,INS-Вставка,P-Печать,F-Маска поиска,Ctrl-F поиск'."
                                                                   
&postdisplay = " "

&display   = "sysc.sysc sysc.des sysc.daval sysc.deval
 sysc.inval sysc.loval "

&highlight = " sysc.sysc sysc.des  "

                
&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                              update sysc.sysc sysc.des sysc.daval sysc.deval
                              sysc.inval sysc.loval  with frame sysc .
                              update sysc.chval with frame y scrollable.
                              hide frame y no-pause.
                      end.
              else if keyfunction(lastkey) = 'P' then
                      do:
                         s_rowid = rowid(sysc).
                         output to sysc.img .
                         for each sysc:
                             display sysc.sysc sysc.des sysc.daval sysc.deval
                             sysc.inval sysc.loval sysc.chval.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('sysc.img').
                         find sysc where rowid(sysc) = s_rowid no-lock.
                      end.
              else if keyfunction(lastkey) = 'F' then do:
                         update s-mask 
                         label 'Введите маску' skip
                         '(Последнюю * можно не писать)' with side-labels
                         color messages overlay row 5 centered frame maskfr.
                         hide frame maskfr.
                         if s-mask <> '' and substr (s-mask, length(s-mask), 1) <> '*' then
                         s-mask = s-mask + '*'.
                         find first sysc where sysc.sysc matches s-mask and (s-entries = '' or lookup(sysc.sysc, s-entries) > 0) use-index sysc no-lock no-error.
                         if not avail sysc then do:
                            message 'Не найдены записи в sysc по маске ' s-mask '. Возврат к default'
                                     view-as alert-box title ''.
                            s-mask = '*'.
                            find first sysc where sysc.sysc matches s-mask and (s-entries = '' or lookup(sysc.sysc, s-entries) > 0)  use-index sysc no-lock no-error.
                         end.
                         trec = recid(sysc).
                         next upper.
                     end.
              else if keylabel(lastkey) = 'ctrl-f' or keylabel(lastkey) = 'ctrl-а' then do:
                         run do_sysc_search.
                         find first sysc where sysc.sysc matches s-mask and
                                               (s-entries = '' or lookup(sysc.sysc, s-entries) > 0)
                                               use-index sysc no-lock no-error.
                         trec = recid(sysc).
                         next upper.
                     end.
                      "
&end = "hide frame sysc. 
hide frame y.
"
}
hide message.


procedure do_sysc_search.

     update srch with side-labels color messages overlay row 5 centered frame srchfr.
     hide frame srchfr.
     s-entries = "".

     if srch <> '' then do: /* создадим строку с найденными sysc */
        srch = "*" + trim (caps (srch)) + "*".
        for each sysc no-lock:
            srch2 = "".
            if sysc.chval <> ? then srch2 = srch2 + sysc.chval.
            if sysc.inval <> ? then srch2 = srch2 + string(sysc.inval).
            if sysc.deval <> ? then srch2 = srch2 + string(sysc.deval).
            if sysc.daval <> ? then srch2 = srch2 + string(sysc.daval, "99/99/99") + " " + string(sysc.daval, "99/99/9999").
            srch2 = caps(srch2).
            if srch2 matches srch then s-entries = s-entries + sysc.sysc + ",".
        end.
     end.

     if s-entries = "" then message 'Не найдены записи в sysc по строке ' skip srch skip
                'Возврат к default по маске~n' s-mask view-as alert-box title ''.
     else
     if s-mask <> "*" then message 'Внимание!~nНайденные записи в sysc показаны~nсогласно маске~n' +
                           s-mask view-as alert-box title "".

end procedure.
