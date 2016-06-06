/* h-rmz8.p
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

/* h-rmz8.p */
{global.i}
{lgps.i }
def var h as int .
h = 12 .
def var bname as cha format "x(40)" label "Beneficiary BANK" . 
def new shared  var vsel6 as char format "x".
def new shared var vsel7 as char  format "x".
def shared var s-remtrz like que.remtrz .
def var v-amt like remtrz.amt .
def var v-cif like cif.cif .
def var v-date as  date .
def var v-ref like remtrz.ref.
def var ourbank like remtrz.sbank.
def var v-sqn like remtrz.sqn  .

 vsel7 = ''.
 vsel6 = ''.
message 
  "Ф)илиалы М)онитор S)wift Нац.вал. sW)ift не Нац.вал. А)бон. " 
update vsel6.

if vsel6 = 'Ф' then vsel7 = 'A'.
if vsel6 = 'М' then vsel7 = 'H'.
if vsel6 = 'S' then vsel7 = 'SW'.
if vsel6 = 'W' then vsel7 = 'SC'.
if vsel6 = 'А' then vsel7 = 'AB'.

if vsel7 = 'H' or vsel7 = '' then do :
       {browpnp.i
        &h = "h"
        &where = " que.pid = '3' and que.con <> 'F'         
        and  (can-find(remtrz where remtrz.remtrz = que.remtrz and 
         (remtrz.source  = vsel7 or vsel7 = '') )) use-index fprc "
        &frame-phrase = "row 1 centered scroll 1 h down"
         &predisp =  "find remtrz where remtrz.remtrz = que.remtrz
          no-lock no-error .
          display 
            remtrz.source column-label ""Источник""
            remtrz.ptype column-label ""Тип""
            remtrz.rdt column-label ""Рег.дата""
            remtrz.valdt1 column-label ""1Дата""
            remtrz.valdt2 column-label ""2Дата""
            remtrz.sbank column-label ""БанкО""
            remtrz.rbank column-label ""БанкП""
            with row 17. 
          pause 0 .
          display 
            que.pid column-label ""Код""
            que.con column-label ""Сост.""
            with row 17. 
          pause 0. "

        &seldisp = "que.remtrz"
        &file = "que"
        &disp = "
          que.remtrz  column-label ""Платеж""
          remtrz.ref column-label ""Nr."" format 'x(40)' 
          remtrz.payment column-label ""СуммаК""
          remtrz.tcrc column-label ""Вал"" "
        &addupd = " que.remtrz "
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
else if vsel7 = "SW" then run h-rmz8sw. 
else if vsel7 = "SC" then run h-rmz8sc.
else run h-rmz8s. 

