/* excjou.p
 * MODULE
        Обменные операции в Offline PragmaTX
 * DESCRIPTION
        Формирование полей joudoc
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        exc2arp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        29/01/04 kanat
 * CHANGES
*/

def shared var g-today as date.
def shared var g-ofc like ofc.ofc.
def shared var s-jh like jh.jh.

def shared var vs-drcur as integer.
def shared var vs-crcur as integer.

def shared var vs-dramt as decimal.
def shared var vs-cramt as decimal.

def shared var vs-rate1 as decimal.
def shared var vs-rate2 as decimal.

def shared var vs-dracctype as char.
def shared var vs-cracctype as char.

def shared var vs-rem as char.

find first jh where jh.jh = s-jh.
if not avail jh then return.

find nmbr where nmbr.code eq "JOU" no-lock no-error.

create joudoc.
joudoc.docnum = 'jou' + string (next-value (journal), "999999") + nmbr.prefix.
joudoc.whn    = g-today.
joudoc.who    = g-ofc.
joudoc.tim    = time.
joudoc.drcur  = vs-drcur.
joudoc.crcur  = vs-crcur.
joudoc.jh  = s-jh.
joudoc.bas_amt = "D".

joudoc.dramt = vs-dramt.
joudoc.cramt = vs-cramt.

joudoc.brate = vs-rate1.  /* Дебит  */
joudoc.srate = vs-rate2.  /* Кредит */

joudoc.dracctype = vs-dracctype.
joudoc.cracctype = vs-cracctype.

joudoc.remark[1] = vs-rem.
joudoc.remark[2] = ''.
jh.ref = joudoc.docnum.
jh.party = joudoc.docnum.
jh.sub = 'jou'.

run chgsts('jou', joudoc.docnum, 'cas').

return joudoc.docnum.

