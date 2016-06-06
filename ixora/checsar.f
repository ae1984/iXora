/* checsar.f
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* checsar.f
18.07.95
*/

form
g-today label "DATUMS"
c-non label "SAK.#" c-lid label "PЁD.#" ccc label "CENA" kk label "GR…MATAS
 SKAITS" skip(1)
with /*row 3 col 1*/ scroll 1 7 down overlay frame checsar.
