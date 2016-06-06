/* cpupsec1.p
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

/* export users for one added proc */

{mainhead.i CPPS1}
{yes-no.i}

def var v-exp as char init "vcctac".
def var v-imp as char init "vcctacal".
define var i as integer.
define var s as char.
def var v-ans as logi init yes.

update skip
        v-exp format "x(30)" label "С какого пункта копировать "
              validate (can-find(optitsec where trim(optitsec.proc) = trim(v-exp)), 
              "Нет такого пункта в списке пунктов верхнего меню с разграничением прав!") skip
        v-imp format "x(30)" label "            на какой пункт "
              validate (can-find(optitem where trim(optitem.proc) = trim(v-imp)), 
              "Нет такого пункта в списке пунктов верхнего меню!")
        with row 5 centered side-labels color messages
        title "КОПИРОВАНИЕ ДОСТУПА К ПУНКТАМ ВЕРХНЕГО МЕНЮ" frame getfr.
hide frame getfr.

if yes-no ( "ВЫ УВЕРЕНЫ?", "Копирование " + trim(v-exp) + " -> " + trim(v-imp)) then do:

  find first optitsec where optitsec.proc = v-exp no-lock no-error.
  s = optitsec.ofcs.
  find first optitsec where optitsec.proc = v-imp no-error.
  if not avail optitsec then do:
    create optitsec.
    assign optitsec.proc = v-imp.
  end.
  /* import procs for another proc */
  update optitsec.ofcs = s.

  v-ans = yes.
  message "Показать протокол?".
  update v-ans with column 20 row 22 no-label no-box frame vv.
  hide frame vv.

  if v-ans then do:
    output to prot.txt.
    find first optitem where optitem.proc = v-imp no-lock no-error.
    find first optlang where optlang.lang = "rr" and optlang.optmenu = optitem.optmenu and
         optlang.ln = optitem.ln no-lock no-error.
    put "Пользователи пункта верхнего меню с разграничением прав " skip
        "на " g-today format "99/99/9999" skip(1)    
        "Пункт : " + v-imp + "  " + trim(optlang.menu) + "  " + trim(optlang.des) format "x(70)" skip(1) 
        " Логин     Пользователь" skip
        "-----------------------------------------------------" skip.

    find first optitsec where optitsec.proc = v-imp no-lock no-error.
    repeat i = 1 to NUM-ENTRIES (optitsec.ofcs):
      s = ENTRY (i, optitsec.ofcs).
      put " " s format "x(8)".
      find ofc where ofc.ofc = s no-lock no-error.
      if avail ofc then 
        put ofc.name at 12 format "x(60)".
      put skip.
    end.
    put skip "-----------------------------------------------------" skip(2).
    output close.

    run menu-prt("prot.txt").
  end.
end.


