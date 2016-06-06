/* ch-que1.p
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
        28/12/04 pragma
 * CHANGES
        21/01/05 tsoy Добавил все подразделения 
        05/10/06 suchkov - добавил логи
*/

{global.i}   
{get-dep.i}
{lgps.i "new" }
m_pid = "6.3.3".

def var v-pid1 like que.pid.
def var v-pid2 like que.pid.
def var v-depo as char.

def var v-depi as integer.
def var v-dep  as char.
def var v-name  as char.

def var kol    as integer init 0.

def var v-que as char init "STW,F,ARC".



def frame vv
     v-pid1 format "x(5)"  label " Укажите текущую очередь "  skip
     v-pid2 format "x(5)"  label "         новую очередь   "  skip
     v-dep  format "x(5)"  label " Подразделение           "  skip
with side-label row 5 centered.

on help of v-dep in frame vv do.
   run h-dep2.
       v-dep              = return-value.
       v-dep:screen-value = v-dep.
end.

update v-pid1 format 'x(5)'
    label " Укажите текущую очередь "  skip
    with side-label row 5 centered frame vv.

update v-pid2 format 'x(5)'
    label "         новую очередь   "  skip
    with side-label row 5 centered frame vv.

update v-dep format 'x(25)'
    label " Подразделение           "  skip
    with side-label row 5 centered frame vv.

if index (v-que,v-pid1) > 0 then do:

   message "Неверная текущая очередь !" view-as alert-box.
   undo, retry.

end. 

for each que where que.pid = v-pid1 exclusive-lock.  

            /* Проверим на департамент */
if v-dep <> "ALL" then do:
            find remtrz where remtrz.remtrz = que.remtrz exclusive-lock no-error.
            if avail remtrz then do:
                if v-dep begins "I" then do:
                     /* Интернет-платежи ищем по источнику и обслуживающему департаменту */
                     if remtrz.source = "IBH" then do:
                       find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
                       find first cif where cif.cif = aaa.cif no-lock no-error.

                       if cif.fname = "" then do:
                         if cif.jame <> "" then v-depi = integer(cif.jame) mod 1000.
                                           else v-depi = get-dep("superman", remtrz.rdt).
                       end.
                       else do:
                         v-name = trim(substr(trim(cif.fname),1,8)).
                         v-depi = get-dep(v-name, remtrz.rdt).
                       end.

                       if (int(substr(v-dep, 2)) <> v-depi) then next.

                  end.
                end.  /* end-of do I */
                else 
                  /* филиальные платежи - по банку-отправителю */
                  if v-dep begins "TXB" then do: 
                      if  (v-dep <> remtrz.sbank) then next.
                  end.
                  else do:
                    /* другие строки из справочника depsibh - по очереди-источнику платежа */
                    find first codfr where codfr.codfr = "depsibh" and codfr.code = v-dep no-lock no-error.
                    if avail codfr then do:
                      if v-dep <> remtrz.source then next.
                    end. 
                    else
                      /* все остальные платежи разбираем по департаменту офицера */
                      if not ( (lookup(remtrz.source, "IBH,A") = 0) and 
                         (not can-find (first codfr where codfr.codfr = "depsibh" and codfr.code = remtrz.source no-lock)) and
                         (remtrz.sbank = "TXB00") and
                         (remtrz.rwho <> "") and 
                         (get-dep(remtrz.rwho, remtrz.rdt) = int(v-dep))) then next.
                  end.

            end. 
            else next.
            /* Если  LB LBG то чистим таблицу отправленных */
end.
            if v-pid2 = "LB" then do:
               
               find clrdoc where clrdoc.rem = remtrz.remtrz exclusive-lock no-error.
               if avail clrdoc then delete clrdoc.

               find clrdog where clrdog.rem = remtrz.remtrz exclusive-lock no-error.
               if avail clrdog then delete clrdog.


               if avail remtrz then do:
                  remtrz.cover  = 1.
               end.

            end.

            if v-pid2 = "LBG" then do:

               find clrdoc where clrdoc.rem = remtrz.remtrz exclusive-lock no-error.
               if avail clrdoc then delete clrdoc.

               find clrdog where clrdog.rem = remtrz.remtrz exclusive-lock no-error.
               if avail clrdog then delete clrdog.

               if avail remtrz then do:
                  remtrz.cover  = 2.
               end.

            end.

            kol = kol + 1.
            v-text = que.remtrz + " перенесена " + que.pid + " -> " + v-pid2 + " подразделение " + v-dep .
            run lgps .
            que.pid = v-pid2.


end.    
if kol > 0 then message 'Перенесено платежей: ' kol.

