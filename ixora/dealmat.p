/* dealmat.p
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
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/


 {proghead.i "FUND MATURITY PROCESS"} 

def new shared var s-fun like fun.fun.
def new shared var vans as log.

def var vfun like fun.fun.
def var fv as cha.
def var inc as int.
def var vdealmat like fun.fun.
def var vlev like gl.level.
def var ms as char.


repeat:
  vfun = "".
  prompt "Введите номер сделки" vdealmat with frame fun row 5 no-label centered.
  find fun where fun.fun eq input vdealmat no-lock no-error.
  if not avail fun 
  then do:
       {mesg.i 0265}.
       pause.
       undo, retry.
  end.

  if fun.sts = 0
  then do:
       message "Не проведена операция по дате валютирования".
       pause.
       undo, retry.
  end.
  s-fun = fun.fun.
  run funedt.
  if not vans 
  then undo, next.
end.  /* repeat */
