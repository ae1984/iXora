/* r-quer.p
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


def var i5 as int init 0.
def var t1 as int init 0.
def var t2 as int init 0.
def var t3 as int init 0.
def var i as int init 0.
def var aa as char format "x(20)".
def var ir like que.pid.
 
form 
      space (10) ir column-label 'Код' format "x(5)"
      '   ' aa format "x(30)" label 'Описание' '  '
      i5 format "zzzz9"  label 'Количество' 
       with down no-box centered frame rr.


  
find first  que   use-index fprc no-lock.
  repeat:
   if que.pid = 'ARC' then do:
     find last  que where que.pid = "ARC"  use-index fprc no-lock .
     find next que  use-index fprc no-lock no-error.
     if not avail que then leave .
   end .


  if  ir  ne que.pid and i5 > 0 then do:
  find fproc where fproc.pid = ir no-lock no-error.
  if avail fproc then aa = fproc.des.
  disp  ir    aa  i5     with  frame rr.
  down with frame rr.      
     i5 =  0.
   end.     
        i5 = i5 + 1.
        t3 = t3 + 1.
        ir = que.pid.
    find next que  use-index fprc no-lock no-error .
    if not avail que then leave .
  end. 

  if  i5 > 0 then do:
  find fproc where fproc.pid = ir no-lock no-error.
  if avail fproc then aa = fproc.des.
  disp  ir    aa  i5     with  frame rr.
  down with frame rr.      
   end.     



hide frame rr.
   pause  0.

