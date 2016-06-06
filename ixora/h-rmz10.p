/* h-rmz10.p
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
 display " This isn't record OURBNK in sysc file !!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

for each que where que.pid = m_pid and que.con = "W" no-lock,  
 each  remtrz of que where no-lock by remtrz.valdt2. 
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
           display remtrz.source remtrz.ptype remtrz.rdt
           remtrz.valdt1 remtrz.valdt2 remtrz.sbank remtrz.rbank
          with row 17  . pause 0 .
         if avail que then display que.pid  que.con
                              with row 17    . pause 0 . "
        &file = "w-rmz"
        &disp = "w-rmz.remtrz w-rmz.sqn w-rmz.fcrc
         w-rmz.amt w-rmz.tcrc w-rmz.payment "
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

