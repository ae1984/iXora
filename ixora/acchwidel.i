﻿/* acchwidel.i
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

/* ------------------------------------------------------------------------------
-                                                                                -
-                                Account Header                                        -
-                                                                                -
------------------------------------------------------------------------------- */


put fill("-",120) format "x(120)". run pwskip(0).
put "Дата  " at 1.
put "Операция   Nr." at 11.
put "Платежный док. Nr." at 26. 
put "ДЕБЕТ " to 99.
put "КРЕДИТ " to 119.
run pwskip(0).

put "Вид  " at 5.
put      "Сделка   Nr.                            ДЕБЕТ                 КРЕДИТ" 
at 11. 
/*
1234567890123456789012345678901234567890123456789012345678901234567890123456789
         1         1         1         1         1         1         1
*/
run pwskip(0).
put "Цель платежа    " at 11. run pwskip(0).
put "Получатель/отправитель           " at 11. run pwskip(0).
put fill("-",120) format "x(120)". run pwskip(0).

