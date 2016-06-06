/* h-tarif.f
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

form
     tarif2.str5
                  label "Nr." format "x(4)"
     tarif2.kont validate (can-find(gl where gl.gl = tarif2.kont no-lock),
                 "Код")
     tarif2.pakalp  format "x(34)"
/*     tarif2.ost  format "zzzzz9" validate(tarif2.ost >= 0," >=0 !")
     tarif2.proc
     tarif2.min1 format "zzzzz9"
     tarif2.max1 format "zzzzz9" */
     with overlay   column 1 row 3 15 down
     title "Справочник комиссий за услуги"  frame tarif .



