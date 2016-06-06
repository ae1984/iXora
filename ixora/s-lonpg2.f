/* s-lonpg2.f
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

/*-----------------------------------
  #3.Procentu izmai‡as
-----------------------------------*/
define shared variable s-lon    as character.
define shared variable g-today  as date.
define shared variable s-dt     as date.


define temp-table w-pg
       field    dt      as date
       field    amt     as decimal
       field    dn      as integer
       field    prc     as decimal
       field    iem     as character
       field    who     as character
       field    whn     as character.

form
    w-pg.dt       format "99/99/99"       label "Дата"
    help "Вверх/вниз - поиск; F1 - вперед !!!"
    w-pg.amt      format ">>,>>>,>>9.99"  label "Сумма"
    w-pg.dn       format "zzz9"           label "Дней"
    w-pg.prc      format "zz9.99"         label "Проц."
    w-pg.iem      format "x(41)"          label "Причина изменений"
    help "Вверх/вниз - поиск; F1 - вперед !!!"
    with 6 down row 7 overlay scroll 1
    title "Изменения процентов " + s-lon frame pg.

form
    w-pg.who                           label "Исполнитель"
    w-pg.whn  format "x(10)"           label "Дата"
    with row 17 overlay title "Кредит " +
         s-lon frame br.
