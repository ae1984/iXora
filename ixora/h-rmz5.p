/* h-rmz5.p
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

/* h-rmz5.p */
{global.i}
{lgps.i }
def var h as int .
h = 12 .
def var bname as cha format "x(40)" label "Банк получателя" . 
def new shared  var vsel6 as char format "x".
def var vsel7 as char  format "x".
def shared var s-remtrz like que.remtrz .
def var v-amt like remtrz.amt .
def var v-cif like cif.cif .
def var v-date as  date .
def var v-ref like remtrz.ref.
def var ourbank like remtrz.sbank.
def var v-sqn like remtrz.sqn  .

 vsel7 = ''.
message "О)фис П)ункт М)онитор S)wift" update vsel6.

if vsel6 = 'О' then do :
 vsel6 = 'O' .
end .

if vsel6 = 'П' then do :
 vsel6 = 'P' .
end .

if vsel6 = 'М' then  do:
vsel6 = 'SVL'.
vsel7 = 'A'.
end.

if vsel6 = 'S' then do :
 vsel6 = 'SW' .
end .

if vsel6 = "SVL" or vsel6 = "P" or vsel7 = "A" or vsel6 = "SW" then
do:

       {browpnp.i
        &h = "h"
        &where = " que.pid = 'G' and que.con <> 'F'         
        and  (can-find(remtrz where remtrz.remtrz = que.remtrz and 
        ( remtrz.source begins  vsel6 or remtrz.source 
        = vsel7))) use-index fprc "
        &frame-phrase = "row 1 centered scroll 1 h down"
        &predisp =  "find remtrz where remtrz.remtrz = que.remtrz
          no-lock no-error .
          bname = trim(remtrz.bb[1]) + trim(remtrz.bb[2]) +
          trim(remtrz.bb[3]).  
          display 
            remtrz.source column-label 'Ист.'
            remtrz.ptype column-label 'Тип'
            remtrz.rdt column-label 'Рег.дата'
            remtrz.valdt1 column-label 'Вал.дата1' 
            remtrz.valdt2 column-label 'Вал.дата2' 
            remtrz.sbank column-label 'Отпр.банк'
            remtrz.rbank column-label 'Получ.банк' 
            with row 17 centered .  
          pause 0 .
          display 
            que.pid column-label 'Код'
            que.con column-label 'Сост.'
            with row 17. 
          pause 0. "

        &seldisp = "que.remtrz  label 'Платеж' "
        &file = "que"
        &disp = "que.remtrz  label 'Платеж' 
            bname  label 'Получатель'
            remtrz.payment  label 'Сумма' 
            remtrz.tcrc label 'Вал' "
        &addupd = " que.remtrz  label 'Платеж' "
        &upd    = "  "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &enderr = " hide all.  "
        &befret = " s-remtrz = que.remtrz .
                    frame-value = que.remtrz . 
                    hide all. "
                              }

end.

else run h-rmz7.
