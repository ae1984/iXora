/* cpupsec2.p
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

/* export added functions for one oficer */

{mainhead.i CPUP2}
{yes-no.i}

def var v-ofcexp as char init "tule".
def var v-ofcimp as char init "linch".
define var i as integer.
define var s as char.
def var v-ans as logi init yes.

update "Введите логины пользователей" skip
        v-ofcexp label "От кого копировать доступ "
              validate (can-find(ofc where ofc.ofc = v-ofcexp), "Нет такого юзера!")
        v-ofcimp label " кому "
              validate (can-find(ofc where ofc.ofc = v-ofcimp), "Нет такого юзера!")
        with row 5 centered side-labels color messages
        title "КОПИРОВАНИЕ ДОСТУПОВ К ПУНКТАМ ВЕРХНЕГО МЕНЮ" frame getfr.
hide frame getfr.

if yes-no ( "ВЫ УВЕРЕНЫ?", "Копирование " + trim(v-ofcexp) + " -> " + trim(v-ofcimp)) then do:

  run cpupsec2-0 (v-ofcexp, v-ofcimp).

  v-ans = yes.
  message "Показать протокол?".
  update v-ans with column 20 row 22 no-label no-box frame vv.
  hide frame vv.
  if v-ans then do:
    output to prot.txt.
    find ofc where ofc.ofc = v-ofcimp no-lock no-error.
    put "Доступные пункты верхнего меню с разграничением прав пользователя" skip
        "на " g-today format "99/99/9999" skip(1)    
        "Пользователь : " trim(v-ofcimp) + " " + ofc.name format "x(60)" skip(1) 
        "Пункт" skip
        "-----------------------------------------------------" skip.

    for each optitsec no-lock by optitsec.proc:
      i = index(optitsec.ofcs, "," + v-ofcimp + ",").
      if i <> 0 then do:
        find first optitem where optitem.proc = optitsec.proc no-lock no-error.
        find optlang where optlang.optmenu = optitem.optmenu and optlang.ln = optitem.ln 
            and optlang.lang = "rr" no-lock no-error.
        put optitsec.proc optlang.menu at 15 optlang.des at 30 skip.
      end.
    end.

    put skip "-----------------------------------------------------" skip(2).
    output close.

    run menu-prt("prot.txt").
  end.
end.
