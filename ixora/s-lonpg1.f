/* s-lonpg1.f
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

/*-----------------------
  #3.Pamatsummu izmai‡as
------------------------*/
define shared variable s-lon    as character.
define shared variable g-today  as date.
define shared variable s-dt     as date.


define temp-table w-pg
       field    dt      as date
       field    rdt     as date
       field    duedt   as date
       field    opnamt  as decimal
       field    atl     as decimal
       field    prem    as decimal
       field    who     as character
       field    whn     as date
       field    nr      as character
       field    iem     as character.

form
    w-pg.nr       format "x(2)"           label "Nr"
    help "Вверх/вниз - поиск; F1 - вперед !!!"
    w-pg.dt       format "99/99/99"       label "Дата"
    w-pg.duedt    format "99/99/99"       label "Срок"
    w-pg.atl      format ">>,>>>,>>9.99"  label "Остаток"
    w-pg.iem      format "x(43)"          label "Причина изменения"
    help "Вверх/вниз - поиск; F1 - вперед !!!"
    with 6 down row 7 overlay scroll 1
    title "Изменение осн.суммы" + s-lon frame pg.

form
    w-pg.rdt                           label "С...."
    w-pg.duedt                         label "По..."
    w-pg.opnamt format ">>,>>>,>>9.99" label "Догов.сумма"
    w-pg.prem   format ">>9.99"        label "% ставка"
    w-pg.who                           label "Исполн."
    w-pg.whn    format "99/99/99"      label "Дата"
    with row 17 column 10 overlay title "Кредит " +
         s-lon frame br.
