/* tdaaabhist.f
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

form /*hisfun.fun  label "ACC" */
     vbal  label " Сумма   "  format 'z,zzz,zzz,zz9.99'
     temp.rdt  label "Дата рег"
     temp.duedt label "Дата окон"
     v-day label "Дн"
     temp.rate label "Ст-ка"
     temp.dam[2] label "Начисл % "
     temp.cam[2] label "Погашен %"
with row 5 COLUMN 1 7 down centered title " История изменения % ставки " overlay frame aab.
