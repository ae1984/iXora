/* cppssec2.p
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

/* export PS functions for one oficer */

{mainhead.i CPPS2}
{yes-no.i}

def var v-ofcexp as char init 'shelk'.
def var v-ofcimp as char init 'molga'.
define var i as integer.
define var s as char.
def var v-ans as logi init yes.

update "Введите логины пользователей" skip
        v-ofcexp label "От кого копировать функции "
              validate (can-find(ofc where ofc.ofc = v-ofcexp), "Нет такого юзера!")
        v-ofcimp label " кому "
              validate (can-find(ofc where ofc.ofc = v-ofcimp), "Нет такого юзера!")
        with row 5 centered side-labels color messages
        title "КОПИРОВАНИЕ ДОСТУПОВ К ФУНКЦИЯМ ПЛАТ.СИСТЕМЫ" frame getfr.
hide frame getfr.

if yes-no ( "ВЫ УВЕРЕНЫ?", "Копирование " + trim(v-ofcexp) + " -> " + trim(v-ofcimp)) then do:

  run cppssec2-0 (v-ofcexp, v-ofcimp).

  v-ans = yes.
  message "Показать протокол?".
  update v-ans with column 20 row 22 no-label no-box frame vv.
  hide frame vv.
  if v-ans then do:
    output to prot.txt.
    find ofc where ofc.ofc = v-ofcimp no-lock no-error.
    put "Доступные функции плат.системы пользователя" skip
        "на " g-today format "99/99/9999" skip(1)    
        "Пользователь : " trim(v-ofcimp) + " " + ofc.name format "x(60)" skip(1) 
        "Функция" skip
        "-----------------------------------------------------" skip.

    for each pssec where lookup(v-ofcimp, pssec.ofcs) > 0 no-lock by pssec.proc:
      put pssec.proc.
      put skip.
    end.

    put skip "-----------------------------------------------------" skip(2).
    output close.

    run menu-prt("prot.txt").
  end.
end.

