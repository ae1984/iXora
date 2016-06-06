/* h-rmz9.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* h-remtrz.p */
/*
{mainhead.i INWR2L}
  */          
{global.i}   
{lgps.i }
def var h as int .
h = 12 .

def shared var s-remtrz like remtrz.remtrz .
def shared var v-rsub like remtrz.rsub . 
def new shared var v-amt like remtrz.amt .
def new shared var v-cif like cif.cif .
def new shared var v-date as  date .
def new shared var v-ref like remtrz.ref.
def new shared var ourbank like remtrz.sbank.
def new shared var v-sqn like remtrz.sqn  .
def var v-cur as int .

def temp-table w-rmz
 field remtrz  like remtrz.remtrz 
 field  sqn  like remtrz.sqn
 field  fcrc  like remtrz.fcrc
 field  amt   like remtrz.amt
 field  tcrc   like remtrz.tcrc 
 field  payment  like remtrz.payment . 
 
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBNK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

for each que where que.pid = m_pid and que.con = "W" no-lock,  
 each  remtrz of que where no-lock by remtrz.payment. 
     create w-rmz.
     w-rmz.remtrz = remtrz.remtrz .
     w-rmz.sqn  =   substr(remtrz.sqn,19)   .
     w-rmz.fcrc =    remtrz.fcrc   .
     w-rmz.amt  =    remtrz.amt   .
     w-rmz.tcrc =    remtrz.tcrc .
     w-rmz.payment  =    remtrz.payment .
end.

       {browpnp.i
        &h = "h"
        &where = "true"
        &frame-phrase = "row 1 centered scroll 1 h down overlay"
        &seldisp = "w-rmz.remtrz" 
        &predisp = "
           find first remtrz where remtrz.remtrz = w-rmz.remtrz no-lock . 
           find que where que.remtrz = remtrz.remtrz
           no-lock no-error .
           display 
            remtrz.source column-label 'Ист.'
            remtrz.ptype column-label 'Тип'
            remtrz.rdt column-label 'Рег.дата'
            remtrz.valdt1 column-label 'Вал.дата1' 
            remtrz.valdt2 column-label 'Вал.дата2' 
            remtrz.sbank column-label 'Отпр.банк'
            remtrz.rbank column-label 'Получ.банк'
            with row 17 centered . pause 0 .
         if avail que then display 
           que.pid column-label 'Код'
           que.con column-label 'Сост.' 
           with row 17 centered   . pause 0 . "
        &file = "w-rmz"
        &disp = "w-rmz.remtrz label ""Платеж""
          w-rmz.sqn label ""Nr.""
          w-rmz.fcrc label ""Вал.Д""
          w-rmz.amt label ""СуммаД""
          w-rmz.tcrc label ""Вал.К""
          w-rmz.payment label ""СуммаК"" "
        &addupd = " w-rmz.remtrz " 
        &upd    = "  " 
        &addcon = "false"
        &updcon = "false" 
        &delcon = "false" 
        &retcon = "true"
        &enderr = " hide all . "
        &befret = " frame-value  = w-rmz.remtrz .  hide all .
            pause 0 .  " 
        &action = " " 
        }

