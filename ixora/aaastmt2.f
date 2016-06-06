/* aaastmt2.f
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

display
  "ACCOUNT SUMMARY" at 33 skip(1)
  "BEGINNING   BALANCE" aaa.lstmgbal
  "AVG GROSS BALANCE" at 42 gavg  skip
  "TOTAL" nocr "CREDITS" vcr
  "AVG NET   BALANCE" at 42 aaa.lstmavl  skip
  "TOTAL" nodr " DEBITS"  vdr  skip
  "ENDING      BALANCE" vbal
  "TOTAL DAYS OF THIS PERIOD" at 42 space(5) vday "DAYS"  skip
  fill("_",80) format "x(80)" skip(1)
  "ACCOUNT ACTIVITY" at 32 skip(1)
  "DATE      DESCRIPTION                       DEBIT" +
  "             CREDT      BALANCE"
skip(1)
  with no-box no-label frame summary width 96.
