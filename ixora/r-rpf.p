/* r-rpf.p
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
        19.08.2004 dpuchkov - добавил отчёт об ошибках при сверке реестров
*/

/* KOVAL Распечатка журнала ошибок и ленточки
         после приема пенсионок 
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

  run menu-prt("errors.img").
  run menu-prt("lnt.txt").

  if seltxb = 0 then 
  do:
     run menu-prt("err_reg.rpt").
  end.

