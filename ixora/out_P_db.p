/* out_P_db.p
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
        18.09.2006 u00600 - автоматическое проставление реквизитов для п.8.3.3 - дебиторы
 * CHANGES
        27.09.2006 u00600 - наименование формы &formname c psror-2deb на psror-2 (возвращение к старой форме)
        17.11.09 marinav v-pnp as cha format "x(20)"
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        03.09.2012 evseev - иин/бин
        09.01.2013 evseev - тз-1623
*/

{mainhead.i OUTRMZ}
{chk12_innbin.i}

def new shared var v-grp like debgrp.grp.
def new shared var v-ls like debls.ls.

def new shared var v-ref as cha format "x(10)".
def new shared var v-pnp as cha format "x(20)" .
def new shared var v-reg5 as cha .
def new shared var v-bin5 as cha .
def new shared var pakal as cha .
def new shared var v-chg  as int .
def new shared var v-option as cha .
def new shared var remtrz like remtrz.remtrz.
def new shared var v-dfbname as char .
def new shared var v-bankname as char.

def buffer tgl for gl.

def var t-pay like remtrz.amt no-undo.
def var acode like crc.code no-undo.
def var bcode like crc.code no-undo.
def var ourbank like bankl.bank  no-undo.
def var v-priory as char no-undo.
def var s-cif as char no-undo.
def var s-rnn as char no-undo.


{lgps.i "new"}
m_pid = "P" .
u_pid = "out_P_db" .
v-option = "remsubk".
find last sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " This isn't record OURBNK in sysc file !!".
   pause .
     undo .
    return .
   end.
 ourbank = sysc.chval.

{main_ps.i
 &head = remtrz
 &headkey = remtrz
 &framename = remtrz
 &option = REMTRZ
 &formname = psror-2
 &findcon = true
 &addcon = true
 &numprg = "n-remtrz"
 &keytype = string
 &nmbrcode = remtrz
 &subprg = s-rotrz_deb  /*disp remtrz поиск*/
 &clearframe = " "
 &viewframe = " "
 &postfind = "{posfnd.i}"
 &preadd = " "
 &postadd = " remtrz.rwho = g-ofc .
              remtrz.sbank = ourbank.
              remtrz.scbank = ourbank.
              remtrz.rtim = time.
 find ofc where ofc.ofc eq g-ofc no-lock.
 remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999').
              if remtrz.source <> 'SCN' then remtrz.source = m_pid +
              string(integer(truncate(ofc.regno / 1000 , 0)),'99') .
              run psroup-deb . s-newrec = false .    /*run psroup-2 - новый платеж*/
 if keyfunction(lastkey) = ""end-error""
   then do :
   delete remtrz .
   return .
  end .
  "
 &end = " "
 &postadd1 = " do transaction : run rmzoutg. pause 0. end. "
}
