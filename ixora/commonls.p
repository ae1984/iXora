/* commonls.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Настройка коммунальных платежей - выбор группы для редактирования
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        commoned.p
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        25.09.2003 sasco
 * CHANGES
        29/06/06 u00568 - по тз 369 пенсионные платежи отправляем в ГЦВП - добавил возможность править ГЦВП
*/


DEF BUTTON st1 LABEL  " Платежи по станциям диагностики ".
DEF BUTTON st2 LABEL  "       Астана Энергосервис       ".
DEF BUTTON st3 LABEL  "          Алматытелеком          ".
DEF BUTTON st4 LABEL  "         KCell и KMobile         ".
DEF BUTTON st5 LABEL  "             ИВЦ                 ".
DEF BUTTON st6 LABEL  "            Алсеко               ".
DEF BUTTON st7 LABEL  "          Водоканал              ".
DEF BUTTON st8 LABEL  "             АПК                 ".
DEF BUTTON st9 LABEL  "   Прочие коммунальные платежи   ".
DEF BUTTON st15 LABEL "            ГЦВП                 ".
DEF BUTTON stq LABEL  "              ВЫХОД              ".

define variable selgrp as integer initial 0.
define variable selabel as character.

def frame butframe
       skip(1)
   st1 skip
   st2 skip
   st3 skip
   st4 skip
   st5 skip
   st6 skip
   st7 skip
   st8 skip
   st9 skip
   st15 skip
       skip(1)
   stq skip
with centered row 2 title "ВЫБЕРИТЕ ГРУППУ ПЛАТЕЖЕЙ".
  
on choose of st1 do: selgrp = 1. selabel = SELF:LABEL. end.
on choose of st2 do: selgrp = 2. selabel = SELF:LABEL. end.
on choose of st3 do: selgrp = 3. selabel = SELF:LABEL. end.
on choose of st4 do: selgrp = 4. selabel = SELF:LABEL. end.
on choose of st5 do: selgrp = 5. selabel = SELF:LABEL. end.
on choose of st6 do: selgrp = 6. selabel = SELF:LABEL. end.
on choose of st7 do: selgrp = 7. selabel = SELF:LABEL. end.
on choose of st8 do: selgrp = 8. selabel = SELF:LABEL. end.
on choose of st9 do: selgrp = 9. selabel = SELF:LABEL. end.
on choose of st9 do: selgrp = 9. selabel = SELF:LABEL. end.
on choose of st15 do: selgrp = 15. selabel = SELF:LABEL. end.
on choose of stq do: selgrp = 0. selabel = SELF:LABEL. end.

ENABLE ALL WITH FRAME butframe.
WAIT-FOR CHOOSE OF st1, st2, st3, st4, st5, st6, st7, st8, st9, st15, stq.

if selgrp = 0 then return.

run commoned (selgrp, selabel).
