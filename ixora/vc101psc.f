/* vc101psc.f
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

/* vc101psc.f Валютный контроль
   Форма к списку паспортов сделок

   27.12.2002 nadejda создан
*/


form
    t-ps.dndate  format "99/99/9999"
    t-ps.dnnum format "x(35)" label "НОМЕР ПС" 
    t-ps.sum format ">>>,>>>,>>>,>>9.99" label "СУММА ПС"
    t-ps.ncrccod format "xxx" label "ВАЛ"
    t-ps.expimp format "x" label "EI"
   with width 75 row 12 centered scroll 1 5 down overlay frame f-ps.
