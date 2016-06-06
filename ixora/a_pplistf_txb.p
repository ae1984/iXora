/* a_pplistf_txb.p
 * MODULE
        Список длительных платежных поручений
 * DESCRIPTION

 * BASES
        BANK COMM TXB
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        16/07/2013 Luiza ТЗ № 1738
 * CHANGES

*/

def shared var vlst as int.

def shared temp-table t-pplist no-undo
    field id      as int
    field txb     as char
    field fil     as char
    field cif     as char
    field name    as char
    field bin     as char
    field aaa     as char
    field crc     as int
    field dtop    as int
    field crccode     as char
    field sum     as decim
    field opl     as char
    field who     as char
    field nom     as int
    field dtnom   as date
    field dtcl    as date
    field con     as logic.

def shared temp-table t-ppout no-undo
    field  id     as int
    field  txb    as char
    field  fil    as char
    field  nom    as int
    field  dtnom  as date
    field  aaa    as char
    field  cif    as char
    field  conwho as char
    field  vopl   as int
    field  opl    as char
    field  sum    as decim
    field  dt     as int
    field  dtc    as date
    field  rem    as char extent 3
    field  knp    as char
    field  kbe    as char
    field  ben    as char
    field  binb   as char
    field  bic    as char
    field  bankb  as char
    field  iikben as char
    field  crc    as int
    field  lname as char
    field  bin   as char
    field  con   as logic
    field  del   as logic.

def var v-bank as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
    return.
end.
v-bank = txb.sysc.chval.
find first txb where txb.bank = v-bank no-lock no-error.
if vlst  = 1 then do:
    for each txb.ppout where txb.ppout.del = no no-lock.
        create t-pplist.
           t-pplist.id        = txb.ppout.id.
           t-pplist.txb       = v-bank.
           if available txb then t-pplist.fil = txb.name.
           t-pplist.aaa       = txb.ppout.aaa.
           t-pplist.crc       = txb.ppout.crc.
           t-pplist.cif       = txb.ppout.cif.
           find first txb.cif where txb.cif.cif = txb.ppout.cif no-lock no-error.
           if available txb.cif then t-pplist.name = txb.cif.sname.
           t-pplist.sum       = txb.ppout.sum.
           find first txb.crc where txb.crc.crc = txb.ppout.crc no-lock no-error.
           if available txb.crc then t-pplist.crccode = txb.crc.code.
           t-pplist.opl       = txb.ppout.vopl.
           t-pplist.who       = txb.ppout.who.
           t-pplist.con       = txb.ppout.con.
           t-pplist.nom       = txb.ppout.nom.
           t-pplist.dtnom     = txb.ppout.dtnom.
           t-pplist.dtop      = txb.ppout.dtop.
           t-pplist.dtcl      = txb.ppout.dtcl.

        create t-ppout.
            t-ppout.id = txb.ppout.id.
            t-ppout.txb = v-bank.
            if available txb then t-ppout.fil = txb.name.
            t-ppout.nom = txb.ppout.nom.
            t-ppout.dtnom = txb.ppout.dtnom.
            t-ppout.aaa = txb.ppout.aaa.
            t-ppout.bin = txb.ppout.bin.
            t-ppout.cif = txb.ppout.cif.
            t-ppout.con = txb.ppout.con.
            find first txb.ofc where txb.ofc.ofc =  txb.ppout.conwho no-lock no-error.
            if available txb.ofc then t-ppout.conwho = txb.ofc.name.
            else t-ppout.conwho = txb.ppout.conwho.
            if txb.ppout.opl = 1 then t-ppout.opl = "Постоян" .
            else t-ppout.opl = "График".
            t-ppout.vopl = txb.ppout.opl.
            t-ppout.sum = txb.ppout.sum.
            t-ppout.dt = txb.ppout.dtop.
            t-ppout.dtc = txb.ppout.dtc.
            t-ppout.rem[1] = txb.ppout.rem[1].
            t-ppout.rem[2] = txb.ppout.rem[2].
            t-ppout.rem[3] = txb.ppout.rem[3].
            t-ppout.knp = txb.ppout.knp.
            t-ppout.kbe = txb.ppout.kbe.
            t-ppout.ben = txb.ppout.ben.
            t-ppout.binb = txb.ppout.binb.
            t-ppout.bic = txb.ppout.bic.
            t-ppout.bankb = txb.ppout.bankb.
            t-ppout.iikben = txb.ppout.iikben.
            t-ppout.crc = txb.ppout.crc.
            t-ppout.lname = t-pplist.name.
            t-ppout.del = txb.ppout.del.
    end.
end.
if vlst  = 3 then do:
    for each txb.ppout where txb.ppout.del no-lock.
        create t-pplist.
           t-pplist.id        = txb.ppout.id.
           t-pplist.txb       = v-bank.
           if available txb then t-pplist.fil = txb.name.
           t-pplist.aaa       = txb.ppout.aaa.
           t-pplist.crc       = txb.ppout.crc.
           t-pplist.cif       = txb.ppout.cif.
           find first txb.cif where txb.cif.cif = txb.ppout.cif no-lock no-error.
           if available txb.cif then t-pplist.name = txb.cif.sname.
           t-pplist.sum       = txb.ppout.sum.
           find first txb.crc where txb.crc.crc = txb.ppout.crc no-lock no-error.
           if available txb.crc then t-pplist.crccode = txb.crc.code.
           t-pplist.opl       = txb.ppout.vopl.
           t-pplist.who       = txb.ppout.who.
           t-pplist.con       = txb.ppout.con.
           t-pplist.nom       = txb.ppout.nom.
           t-pplist.dtnom     = txb.ppout.dtnom.
           t-pplist.dtop      = txb.ppout.dtop.

        create t-ppout.
            t-ppout.id = txb.ppout.id.
            t-ppout.txb = v-bank.
            if available txb then t-ppout.fil = txb.name.
            t-ppout.nom = txb.ppout.nom.
            t-ppout.dtnom = txb.ppout.dtnom.
            t-ppout.aaa = txb.ppout.aaa.
            t-ppout.bin = txb.ppout.bin.
            t-ppout.cif = txb.ppout.cif.
            t-ppout.con = txb.ppout.con.
            find first txb.ofc where txb.ofc.ofc =  txb.ppout.conwho no-lock no-error.
            if available txb.ofc then t-ppout.conwho = txb.ofc.name.
            else t-ppout.conwho = txb.ppout.conwho.
            if txb.ppout.opl = 1 then t-ppout.opl = "Постоян" .
            else t-ppout.opl = "График".
            t-ppout.vopl = txb.ppout.opl.
            t-ppout.sum = txb.ppout.sum.
            t-ppout.dt = txb.ppout.dtop.
            t-ppout.dtc = txb.ppout.dtc.
            t-ppout.rem[1] = txb.ppout.rem[1].
            t-ppout.rem[2] = txb.ppout.rem[2].
            t-ppout.rem[3] = txb.ppout.rem[3].
            t-ppout.knp = txb.ppout.knp.
            t-ppout.kbe = txb.ppout.kbe.
            t-ppout.ben = txb.ppout.ben.
            t-ppout.binb = txb.ppout.binb.
            t-ppout.bic = txb.ppout.bic.
            t-ppout.bankb = txb.ppout.bankb.
            t-ppout.iikben = txb.ppout.iikben.
            t-ppout.crc = txb.ppout.crc.
            t-ppout.lname = t-pplist.name.
            t-ppout.del = txb.ppout.del.
    end.
end.
if vlst  = 2 then do:
    for each pplist where pplist.txb = v-bank no-lock.
        find first txb.ppout where txb.ppout.id = pplist.id no-lock no-error.
        create t-ppout.
            t-ppout.id = txb.ppout.id.
            t-ppout.txb = v-bank.
            if available txb then t-ppout.fil = txb.name.
            t-ppout.nom = txb.ppout.nom.
            t-ppout.dtnom = txb.ppout.dtnom.
            t-ppout.aaa = txb.ppout.aaa.
            t-ppout.bin = txb.ppout.bin.
            t-ppout.cif = txb.ppout.cif.
            t-ppout.con = txb.ppout.con.
            find first txb.ofc where txb.ofc.ofc =  txb.ppout.conwho no-lock no-error.
            if available txb.ofc then t-ppout.conwho = txb.ofc.name.
            else t-ppout.conwho = txb.ppout.conwho.
            if txb.ppout.opl = 1 then t-ppout.opl = "Постоян" .
            else t-ppout.opl = "График".
            t-ppout.vopl = txb.ppout.opl.
            t-ppout.sum = txb.ppout.sum.
            t-ppout.dt = txb.ppout.dtop.
            t-ppout.dtc = txb.ppout.dtc.
            t-ppout.rem[1] = txb.ppout.rem[1].
            t-ppout.rem[2] = txb.ppout.rem[2].
            t-ppout.rem[3] = txb.ppout.rem[3].
            t-ppout.knp = txb.ppout.knp.
            t-ppout.kbe = txb.ppout.kbe.
            t-ppout.ben = txb.ppout.ben.
            t-ppout.binb = txb.ppout.binb.
            t-ppout.bic = txb.ppout.bic.
            t-ppout.bankb = txb.ppout.bankb.
            t-ppout.iikben = txb.ppout.iikben.
            t-ppout.crc = txb.ppout.crc.
            find first txb.cif where  txb.cif.cif = pplist.cif no-lock no-error.
            if available  txb.cif then assign t-ppout.lname = txb.cif.sname t-ppout.bin = txb.cif.bin .
            t-ppout.del = txb.ppout.del.
    end.
end.

