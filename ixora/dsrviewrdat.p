/* dsrlist.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        просмотр досье
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * BASES
        BANK COMM TXB
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
*/

{dsr0.i}

def input parameter p-bank as char.

def shared var v-dtb as date.
def shared var v-dte as date.

def shared temp-table t-cif
  field cif as char
  field name as char
  index cif is primary unique cif.

for each dsrview where dsrview.bank = p-bank and dsrview.whn >= v-dtb and dsrview.whn <= v-dte no-lock break by dsrview.cif:
  if first-of (dsrview.cif) then do:
    find txb.cif where txb.cif.cif = dsrview.cif no-lock no-error.
    create t-cif.
    assign t-cif.cif = dsrview.cif
           t-cif.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
  end.
end.

def shared temp-table t-ofc
  field ofc as char
  field name as char
  index cif is primary unique ofc.

for each dsrview where dsrview.bank = p-bank and dsrview.whn >= v-dtb and dsrview.whn <= v-dte no-lock break by dsrview.who:
  if first-of (dsrview.who) then do:
    find txb.ofc where txb.ofc.ofc = dsrview.who no-lock no-error.
    create t-ofc.
    assign t-ofc.ofc = dsrview.who
           t-ofc.name = ofc.name.
  end.
end.

