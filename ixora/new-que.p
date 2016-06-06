/* new-que.p
 * MODULE

 * DESCRIPTION

 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15.8
 * AUTHOR
        28.12.2005 tsoy
 * CHANGES
*/
def var v-select as integer.
repeat:
  
  v-select = 0.

  run sel2 (" Очереди ", " 1. Изменить очередь по подразд. | 2. Изменить очередь по подразд. и дату | ВЫХОД ", output v-select).

  if v-select = 0 then return.

  case v-select:
    when 1 then run ch-que1.
    when 2 then run ch-que2.
    when 3 then return.
  end.
end.

