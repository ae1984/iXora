/* aaa-aas.p
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

/* aaa-aas.p
*/

define shared var s-aaa like aaa.aaa .

for each aas where aas.aaa eq s-aaa no-lock:

  find sic of aas.
  display aas.sic sic.des label "НАИМЕНОВАНИЕ" FORMAT "X(20)"
  aas.regdt LABEL "ДАТ.РЕГ." format "99/99/9999"
  aas.chkamt LABEL "СУММА"
  aas.payee format "x(20)"
  with row 9  9 down  overlay  top-only centered
    title " СПЕЦИАЛЬНОЕ СОСТОЯНИЕ СЧЕТА (" + string(aas.aaa) + ")" frame aas.

end.
/*
for each aas where aas.aaa eq s-aaa no-lock:
  find sic of aas.
  display aas.sic sic.des  aas.regdt
          aas.chkdt aas.chkno aas.chkamt
          with row 9 col 1 2 down no-label overlay top-only
               title " Special Instructions " frame aast.
end.
*/
