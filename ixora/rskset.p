/* rskset.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Риски ссудного портфеля
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
        18/10/2004 madiar
 * CHANGES
*/

{mainhead.i}

def var krit_name as char extent 6 init ["Отрасль","Срок до погашения","Среднемес.об./сумма займа","Обеспечение","Кредитная история","Фин. состояние"].
def var krit_opt as deci extent 6 init [80,80,40,60,100,80].
def var krit_weight as deci extent 6 init [10,10,10,25,15,30].

def var ch as deci.
def var i as integer.

find sysc where sysc.sysc = "rskkri" no-lock no-error.
if avail sysc then do:
  do i = 1 to 6:
    krit_opt[i] = decimal(entry(i,sysc.chval)).
    krit_weight[i] = decimal(entry(6 + i,sysc.chval)).
  end.
end.

form
    "Критерий" "Порог        Вес" at 35 skip
    bar as char format "x(50)" skip
    krit_name[1] format "x(25)"
    krit_opt[1] at 30 validate (krit_opt[1] >= 0 and krit_opt[1] <= 100, " Значение от 0 до 100! ")
    krit_weight[1] validate (krit_weight[1] >= 0 and krit_weight[1] <= 100, " Значение от 0 до 100! ") skip
    krit_name[2] format "x(25)"
    krit_opt[2] at 30 validate (krit_opt[2] >= 0 and krit_opt[2] <= 100, " Значение от 0 до 100! ")
    krit_weight[2] validate (krit_weight[2] >= 0 and krit_weight[2] <= 100, " Значение от 0 до 100! ") skip
    krit_name[3] format "x(25)"
    krit_opt[3] at 30 validate (krit_opt[3] >= 0 and krit_opt[3] <= 100, " Значение от 0 до 100! ")
    krit_weight[3] validate (krit_weight[3] >= 0 and krit_weight[3] <= 100, " Значение от 0 до 100! ") skip
    krit_name[4] format "x(25)"
    krit_opt[4] at 30 validate (krit_opt[4] >= 0 and krit_opt[4] <= 100, " Значение от 0 до 100! ")
    krit_weight[4] validate (krit_weight[4] >= 0 and krit_weight[4] <= 100, " Значение от 0 до 100! ") skip
    krit_name[5] format "x(25)"
    krit_opt[5] at 30 validate (krit_opt[5] >= 0 and krit_opt[5] <= 100, " Значение от 0 до 100! ")
    krit_weight[5] validate (krit_weight[5] >= 0 and krit_weight[5] <= 100, " Значение от 0 до 100! ") skip
    krit_name[6] format "x(25)"
    krit_opt[6] at 30 validate (krit_opt[6] >= 0 and krit_opt[6] <= 100, " Значение от 0 до 100! ")
    krit_weight[6] validate (krit_weight[6] >= 0 and krit_weight[6] <= 100, " Значение от 0 до 100! ") skip
    with no-label no-hide centered no-box row 4 frame krit.

displ krit_name krit_opt krit_weight fill("-",50) @ bar with frame krit.
repeat while ch <> 100:
  update krit_opt krit_weight with frame krit.
  ch = 0.
  do i = 1 to 6: ch = ch + krit_weight[i]. end.
  if ch <> 100 then do:
    message " Ошибка! Веса в сумме не равны 100 ! ".
    pause.
    hide message no-pause.
  end.
end.

find sysc where sysc.sysc = "rskkri" no-error.
if not avail sysc then do:
  create sysc.
  sysc.sysc = "rskkri".
  sysc.des = "Риски кредитного портфеля: пороговое значение и вес".
end.
sysc.chval = "".
do i = 1 to 6:
  if sysc.chval <> "" then sysc.chval = sysc.chval + ",".
  sysc.chval = sysc.chval + string(krit_opt[i],">>9.99").
end.
do i = 1 to 6:
  sysc.chval = sysc.chval + "," + string(krit_weight[i],">9.99").
end.


