/* ch-que.p
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

/* ch-que.p 
   05.01.2001 
   изменение очереди */
   
def var v-pid1 like que.pid.
def var v-pid2 like que.pid.
def var kol as integer init 0.

    update v-pid1 format 'x(5)'
        label ' Укажите текущую очередь '  skip
        with side-label row 5 centered frame vv .

    update v-pid2 format 'x(5)'
        label '         новую очередь   '  skip
        with side-label row 5 centered frame vv .

for each que where que.pid = v-pid1 exclusive-lock.  
    find first route where route.pid   =  v-pid2 
                       and route.ptype =  que.ptype 
                       no-lock no-error.
         if avail route then do. 
            kol = kol + 1.
           que.pid = v-pid2.
         end.
end.    
if kol > 0 then message 'Перенесено платежей: ' kol.

