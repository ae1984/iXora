/* s-lonpg3.f
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/*---------------------------------
  #3.PiezЁmes
---------------------------------*/
define shared variable s-lon    as character.
define shared variable g-today  as date.
define shared variable s-dt     as date.


define temp-table w-pg
       field    dt      as date
       field    iem     as character
       field    who     as character
       field    whn     as character
       field    ln      as integer.

form
    w-pg.dt       format "99/99/99"       label "С...."
    w-pg.iem      format "x(49)"          label "Примечание"
    help "Вверх/вниз - поиск; F1 - вперед !!!"
    w-pg.who      format "x(8)"           label "Исполн."
    w-pg.whn      format "x(10)"          label "Дата"
    with 6 down row 7 overlay scroll 1
    title "Примечания " + s-lon frame pg.
