/* trx-deblist.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Выбор из списка приходов для списания
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
        08/01/04 sasco исправил поиcк debhis
        13/01/04 sasco ПЕРЕКОМПИЛЯЦИЯ

*/



{yes-no.i}

define input parameter v-grp as int.
define input parameter v-ls as int.
define output parameter v-refwhn as date.
define output parameter v-refjh as int.
define output parameter v-reftime as int.
define output parameter v-refost as decimal.

define temp-table tmp like debop.

define query qt for tmp.

define browse bt query qt 
              displ tmp.date label "Дата"
                    tmp.jh  label "Проводка"
                    tmp.ost column-label "Остаток"
                    tmp.period label "Срок" format "x(15)"
                    with row 1 centered 10 down title "Выберите сумму".

define frame ft bt help "ENTER - выбрать сумму; F4 - отмена"
             with row 2 centered no-label no-box overlay.

/* ------------------------------------------------- */
/* обнулим переменные */

v-refwhn = ?.
v-refjh = ?.
v-reftime = ?.

/* ------------------------------------------------- */
/* создадим временную таблицу */

for each debop where debop.grp = v-grp and
                     debop.ls = v-ls and
                     debop.closed = no and
                     debop.type = 1
                     no-lock use-index closed:

    find debhis where debhis.date = debop.date and 
                      debhis.grp = v-grp and
                      debhis.ls = v-ls and
                      debhis.jh = debop.jh and
                      debhis.ctime = debop.ctime and
                      debhis.type < 3
                      no-lock no-error.

    if not available debhis then do:
       message "Нет записи debhis для проводки " debop.jh " за " debop.date view-as alert-box title ' '.
       return.
    end.

    find codfr where codfr.codfr = 'debsrok' and
                     codfr.code = debop.period 
                     no-lock no-error.

    create tmp.
    tmp.date = debop.date.
    tmp.ost = debop.ost.
    tmp.jh = debhis.jh.
    tmp.ctime = debop.ctime.
    tmp.ost = debop.ost.
    tmp.period = if available codfr then codfr.name[1] else '<СРОК НЕ ОПРЕДЕЛЕН>'.

end.
                     
/* ------------------------------------------------- */
/* триггеры */

on "return" of browse bt do:
   if not available tmp then leave.
   if not yes-no (' ', 'Выбрать остаток ' + trim (string (tmp.ost)) + ' за ' + string (tmp.date)) then do:
      v-refjh = ?.
      v-refwhn = ?.
      v-reftime = ?.
      leave.
   end.
   v-refwhn = tmp.date.
   v-refjh = tmp.jh.
   v-reftime = tmp.ctime.
   v-refost = tmp.ost.
   apply "go" to frame ft.
end.
                    
on "end-error" of browse bt do:
   hide frame ft.
   return.
end.

/* ------------------------------------------------- */
/* Основная часть */


open query qt for each tmp use-index type.
enable all with frame ft.
wait-for window-close of current-window or "go" of frame ft or window-close of frame ft focus browse bt.

hide frame ft.
        