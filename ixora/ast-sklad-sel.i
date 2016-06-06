/* ast-sklad-sel.i
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

/* sasco - for ASTREM.P - выбор товара на складе */
/* для списания основных средств */


procedure help-skpid.
def var choice as int format "9" init 2.
def var str as char format "x(60)" init ''.
message "Поиск по номеру (1) или поиск по части названия (2)" update choice. 
if choice = 2 then message "Часть названия" update str.
{aapbra.i
      &head      = "skladb"
      &index     = "iid no-lock"
      &formname  = "help-sklad"
      &framename = "hpid"
      &where     = " skladb.sid = v-sid and caps(skladb.des) matches '*' + caps(trim(str)) + '*' "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "skladb.pid skladb.des"
      &highlight = "skladb.pid skladb.des"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           /* frame-value = skladb.pid. */
                           hide frame hpid.
                           return string(skladb.pid).  
                    end."
      &end = "hide frame hpid."
}          
end procedure.

procedure help-sksid.
{aapbra.i
      &head      = "sklada"
      &index     = "iid no-lock"
      &formname  = "help-sklad"
      &framename = "hsid"
      &where     = " "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "sklada.sid sklada.des"
      &highlight = "sklada.sid sklada.des"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           hide frame hsid.
                           return string(sklada.sid).  
                    end."
      &end = "hide frame hsid."
}          
end procedure.


procedure help-curskl.
find first wcho no-error.
if not avail wcho then
do:
    displ "На складе нет товаров, подлежащих списанию"
    with centered row 10 frame fff.
    pause 60.
    hide frame fff.
    return.
end.
{aapbra.i
      &head      = "wcho"
      &index     = "iid no-lock"
      &formname  = "help-sklad2"
      &framename = "hcurr"
      &where     = " "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "wcho.des wcho.amt wcho.cost wcho.dpr"
      &highlight = "wcho.des wcho.amt wcho.cost wcho.dpr"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           sk_cost = wcho.cost.
                           v-dpr = wcho.dpr.
                           hide frame hcurr.
                           return.  
                    end."
      &end = "hide frame hcurr."
}          

end procedure.




define frame getsklad
            v-sid label "Выберите группу (F2 - помощь)" 
            validate (can-find (sklada where sklada.sid = v-sid), "Нет такой группы!") SKIP
            v-sdes no-label format "x(40)" view-as text SKIP
            v-pid label "Выберите товар (F2 - помощь) " 
            validate (can-find (sklada where sklada.sid = v-sid), "Нет такой группы!") SKIP
            v-pdes no-label format "x(40)" view-as text 
            with row 4 centered side-labels overlay.

ON HELP OF v-sid IN FRAME getsklad do: run help-sksid. 
                                       v-sid:screen-value = return-value.
                                       v-sid = int (return-value).
                                   end.
ON HELP OF v-pid IN FRAME getsklad do: run help-skpid. 
                                       v-pid:screen-value = return-value.
                                       v-pid = int (return-value).
                                   end.

ON "value-changed" of v-sid in frame getsklad
DO:
   v-sid = int(v-sid:screen-value).
   find sklada where sklada.sid = v-sid no-lock no-error.
   if avail sklada then v-sdes = sklada.des.
                   else v-sdes = ''.
   displ v-sdes with frame getsklad.
END.

ON "value-changed" of v-pid in frame getsklad
DO:
   v-sid = int(v-sid:screen-value).
   v-pid = int(v-pid:screen-value).
   find skladb where skladb.sid = v-sid and skladb.pid = v-pid no-lock no-error.
   if avail skladb then v-pdes = skladb.des.
                   else v-pdes = ''.
   displ v-pdes with frame getsklad.
END.

update v-sid v-pid with frame getsklad
                   editing:
                           readkey.
                           apply lastkey.
                           if frame-field = "v-sid" then apply "value-changed" to v-sid in frame getsklad.
                           if frame-field = "v-pid" then apply "value-changed" to v-pid in frame getsklad.
                   end.

hide frame getsklad no-pause.

for each wcho: delete wcho. end.

for each skladc where skladc.sid = v-sid and
                      skladc.pid = v-pid
                      no-lock:
    /* создать с текущим складом */
    create wcho.
    wcho.amt = skladc.amt.
    wcho.cost = skladc.cost.
    wcho.dpr = skladc.dpr.
    find first skladb where skladb.sid = skladc.sid and
                            skladb.pid = skladc.pid
                            no-lock no-error.
    if avail skladb then wcho.des = skladb.des.

    /* отнять значения списываемых товаров из списка */
    for each skladt where skladt.cost = wcho.cost and
                          skladt.dpr = wcho.dpr and
                          skladt.sid = skladc.sid and
                          skladt.pid = skladc.pid no-lock:

        wcho.amt = wcho.amt - skladt.amt.
    end.                      
end.

sk_cost = ?.

pause 0.
run help-curskl.
pause 0.

if sk_cost = ? then 
do: 
    message "Ошибка! Не выбран товар на складе!" view-as alert-box title "".
    v-sum = 0.
end.

define var sk_flag as logical.

find wcho where wcho.cost = sk_cost and wcho.dpr = v-dpr no-error.
repeat while true:
   sk_flag = no.
   update sk_amt label "Введите количество товара" 
          with row 5 centered overlay color messages frame getlist
          editing:
                  readkey.
                  apply lastkey.
                  if key-function (lastkey) = "return" then sk_flag = yes.
                  if key-function (lastkey) = "go" then sk_flag = yes.
          end.

   if sk_amt le 0 or sk_amt > wcho.amt then
      do:
         message "Количество должно быть от 1 до" wcho.amt.
         pause 50.
     end.
     else leave.
end.
hide frame getlist.

if sk_flag = no then sk_amt = 0.
sk_total = sk_amt * sk_cost.

v-sum = sk_total.
v-sum:screen-value = string(v-sum).

if sk_flag then message "Выбрано списание со склада~nГруппа: " + v-sdes + "~nТовар: " + v-pdes + 
                        "~nКоличество: " + string(sk_amt) + "~nЦена: " + string(sk_cost) + 
                        "~nИТОГО: " + string(v-sum)
                        view-as alert-box title "С К Л А Д".

