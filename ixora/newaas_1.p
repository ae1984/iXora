/* newaas.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Новые специнструкции, наложенные сегодня
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
        02.07.2013 yerganat
 * BASES
        TXB COMM
 * CHANGES

*/



def shared temp-table t-aas
    field cif  like txb.cif.cif
    field name like txb.cif.name
    field aaa  like txb.aaa.aaa
    field tim  like txb.aas.tim
    field jss  like txb.cif.jss
    field bin  like txb.cif.bin
    field prim  as char
    field fnum like txb.aas.fnum
    field whn like txb.aas.whn
    field dt1 as char
    field regdt like txb.aas.regdt
    field prim1 as char
    field whn1 like txb.aas.whn1
    field sum as char format 'x(14)'
    field ost as char format 'x(14)'
    field gl  like txb.aaa.gl.

def shared var d_date as date.
def shared var d_date_fin as date.
def shared var v_type as char init "b".
def shared var ost as deci init '0'.




    for each txb.aas where txb.aas.regdt >= d_date and txb.aas.regdt <= d_date_fin and txb.aas.ln <> 7777777 and txb.aas.sta <> 0 /*and lookup(aas.payee,v-osn) > 0*/ no-lock:
    find txb.aaa where txb.aaa.aaa = txb.aas.aaa and txb.aaa.sta <> "c" no-lock no-error.
    if not avail txb.aaa then next.
    find txb.cif where txb.cif.cif = txb.aaa.cif and txb.cif.type = v_type no-lock no-error.
    if avail txb.cif then do: ost = 0.
    find last txb.histrxbal where txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.dt le d_date_fin and txb.histrxbal.subled = 'cif' and txb.histrxbal.level = 1 no-lock no-error.
    if avail txb.histrxbal then do:
        find last txb.crchis where txb.crchis.crc = txb.histrxbal.crc and txb.crchis.whn le txb.histrxbal.dt no-lock no-error.
        if avail txb.crchis then do:
         ost = (txb.histrxbal.cam - txb.histrxbal.dam) * txb.crchis.rate[1].
        end.
    end.

         create t-aas.
         assign
         t-aas.cif =  txb.cif.cif
         t-aas.name = txb.cif.name
         t-aas.aaa  = txb.aaa.aaa
         t-aas.jss  = txb.cif.jss
         t-aas.bin  = txb.cif.bin
         t-aas.prim  = txb.aas.payee
         t-aas.dt1 = string(txb.aas.docdat)
         t-aas.regdt = txb.aas.regdt
         t-aas.ost = "'" + string (ost).

         if aas.fnum <> "" then
            t-aas.fnum = txb.aas.fnum.
         else
            t-aas.fnum = txb.aas.docnum.

         if lookup(string(txb.aas.sta),"4,5,6,8,9,15") <> 0 then
            t-aas.sum = "'" + txb.aas.docprim.
         else
            t-aas.sum = "'" + string (txb.aas.chkamt).

         t-aas.whn = txb.aas.whn.
         t-aas.gl = txb.aaa.gl.
    end.
    end.


