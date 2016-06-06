/* debls.f
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
        01/06/2006 u00600 - добавила фрейм get-grp-all0
*/

/* debls.p */
def buffer b-ls for debls.
def buffer b-grp for debgrp.

define var v-dat     as date init today.
define var v-d1      as date init today.
define var v-d2      as date init today.

define var v-grp     like debls.grp init 0.
define var v-ls      like debls.ls init 0.
define var v-amt     like debhis.amt init 0.
define var v-rem     like debhis.rem.

define var v-grp-des like debgrp.des.
define var v-ls-des  like debls.name.

/* - - - - - - - - - - - - - - - - - - - - - - - - - */

/* фрейм для существующей группы и дебитора (которые <> 0) */
define frame get-grp
       v-grp label  "Номер группы  "  help " F2 - ВЫБОР " 
                 validate (v-grp ne 0 and can-find(debgrp where debgrp.grp = v-grp no-lock),
                                    "Группа с таким номером не найдена!") skip
       v-ls label   "Номер дебитора"  help " F2 - ВЫБОР "
                 validate (v-ls ne 0 and can-find(debls where debls.grp = v-grp and debls.ls = v-ls no-lock),
                                    "Товар с таким номером не найден!") skip
       v-grp-des label "Группа" skip
       v-ls-des label "Дебитор" skip
       with row 8 centered side-labels color messages overlay.


/* фрейм для всех групп и дебиторов (номер может быть 0) */
define frame get-grp-all
       v-grp label  "Номер группы  "  help " F2 - ВЫБОР "
                 validate (can-find(debgrp where debgrp.grp = v-grp no-lock),
                                    "Группа с таким номером не найдена!") skip
       v-ls label   "Номер дебитора"  help " F2 - ВЫБОР "
                 validate (can-find(debls where debls.grp = v-grp and debls.ls = v-ls no-lock),
                                    "Товар с таким номером не найден!") skip
       v-grp-des label "Группа" skip
       v-ls-des label "Дебитор" skip
       with row 8 centered side-labels color messages overlay.

/* фрейм для всех групп и дебиторов (номер может быть 0) */
define frame get-grp-all0
       v-grp label  "Номер группы  "  help " F2 - ВЫБОР "
                 validate (can-find(debgrp where debgrp.grp = v-grp no-lock),
                                    "Группа с таким номером не найдена!") skip
       v-ls label   "Номер дебитора"  help " F2 - ВЫБОР "
                 /*validate (can-find(debls where debls.grp = v-grp and debls.ls = v-ls no-lock),
                                    "Товар с таким номером не найден!") skip*/
       v-grp-des label "Группа" skip
       v-ls-des label "Дебитор" skip
       with row 8 centered side-labels color messages overlay.

/* - - - - - - - - - - - - - - - - - - - - - - - - - */

define frame get-dat
       v-dat label "Задайте дату"
       with row 4 centered side-labels color messages overlay.

define frame get-dates
       v-d1 label "Начало периода"
       v-d2 label "Конец периода"
       with row 4 centered side-labels color messages overlay.

define frame get-amt
       v-amt label "Задайте сумму" validate (v-amt ne 0, "Сумма должна быть больше нуля!")
       with row 4 centered side-labels color messages overlay.

define frame get-rem
       v-rem[1]
       v-rem[2]
       v-rem[3]
       with row 4 centered no-label color messages overlay title "Назначение платежа".

/* - - - - - - - - - - - - - - - - - - - - - - - - - */

on help of v-grp in frame get-grp run help-debgrp (false). 
on help of v-grp in frame get-grp-all run help-debgrp (true).
on help of v-grp in frame get-grp-all0 run help-debgrp (true). 

on help of v-ls in frame get-grp do: 
                                       run help-debls (v-grp, false). 
                                       v-ls:screen-value = return-value. 
                                       v-ls = int(v-ls:screen-value).
                                 end.
on help of v-ls in frame get-grp-all do: run help-debls (v-grp, true).
                                         v-ls:screen-value = return-value. 
                                         v-ls = int(v-ls:screen-value).
                                     end.

on help of v-ls in frame get-grp-all0 do: run help-debls2 (v-grp).
                                      end.
/* - - - - - - - - - - - - - - - - - - - - - - - - - */


/* Возвращает название группы */
function get-grp-des returns char (dgrp as integer).
    find debgrp where debgrp.grp = dgrp
                      no-lock
                      no-error.
    if not avail debgrp then return ?.
                         else return debgrp.des.
end function.


/* Возвращает название дебитора */
function get-ls-name returns char (dgrp as integer, dls as integer).
    find debls where debls.grp = dgrp and
                     debls.ls = dls
                     no-lock
                     no-error.
    if not avail debls then return ?.
                        else return debls.name.
end function.
