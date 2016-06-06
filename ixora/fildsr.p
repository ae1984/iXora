/* fildsr.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Просмтр досье любого филиала
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        BANK COMM 
 * AUTHOR
        23.06.2010 marinav
 * CHANGES
*/

{mainhead.i}
{dsr.i new}

def var v-cif-f as char.
def var v-bank as char.
def var v-cifname as char.
def var v-bankname as char.

v-bank = "".
v-cif-f = "".
v-cifname = "".
v-bankname = "".

def frame f-client skip(1)
  v-bank label "ФИЛИАЛ "  format "x(6)" help " Введите код банка (F2 - поиск)"
  v-bankname no-label format "x(45)"  skip
  v-cif-f label "КЛИЕНТ " format "x(6)" help " Введите код клиента (F2 - поиск)"  validate (v-cif-f ne "", " Введите код клиента ! ")
  v-cifname no-label format "x(45)" 
  with  centered side-label row 7 title 'Выберите филиал и клиента' .

on help of v-bank in frame f-client do:
{itemlist.i
       &file = "txb"
       &where = "txb.bank begins 'txb'"
       &form = "txb.bank txb.info form ""x(30)""  "
       &frame = "row 5 centered scroll 1 18 down overlay "
       &flddisp = "txb.bank txb.info"
       &chkey = "bank"
       &chtype = "string"
       &index  = "bank"
       &funadd = "if frame-value = '' then do:
		    message 'Банк не выбран'.
		    pause 1.
		    next.
		  end." }
  v-bank = frame-value.
  displ v-bank with frame f-client.
end.


  update v-bank with frame f-client.

  find first txb where txb.bank = v-bank no-lock no-error.
  if not avail txb then return.
  v-bankname = txb.info.
  displ v-bankname with frame f-client.

  if connected ("txb") then disconnect "txb".
  connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 

  update v-cif-f  with frame f-client.

  if connected ("txb") then disconnect "txb".


  run dsrview (v-cif-f, '', 1).


