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

def buffer b-aas_hist for txb.aas_hist.

     for each txb.aas_hist where txb.aas_hist.regdt >= d_date and txb.aas_hist.regdt <= d_date_fin and txb.aas_hist.ln <> 7777777 and (txb.aas_hist.chgoper = 'A') and txb.aas_hist.sta <> 0 no-lock:

         find last b-aas_hist where b-aas_hist.aaa = txb.aas_hist.aaa and b-aas_hist.ln = txb.aas_hist.ln and (b-aas_hist.chgoper = 'D' or b-aas_hist.chgoper = 'O' or b-aas_hist.chgoper = 'X') no-lock no-error.
         if avail b-aas_hist then do:

             find txb.aaa where txb.aaa.aaa = b-aas_hist.aaa and txb.aaa.sta <> "c" no-lock no-error.
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
                t-aas.cif   = txb.cif.cif /*cif клиента*/
                t-aas.name  = txb.cif.name /*наименование клиента*/
                t-aas.aaa   = txb.aaa.aaa /*счет клиента*/
                t-aas.jss   = txb.cif.jss /*рнн клиента*/
                t-aas.bin   = txb.cif.bin /*рнн клиента*/
                t-aas.prim  = b-aas_hist.payee /*вид ограничения*/
                t-aas.dt1   = string(b-aas_hist.docdat) /*дата ограничения*/
                t-aas.regdt = b-aas_hist.regdt /**/
                t-aas.whn1  = b-aas_hist.whn
                t-aas.ost = "'" + string (ost).

                if b-aas_hist.fnum <> "" then
                    t-aas.fnum = b-aas_hist.fnum.
                else
                    t-aas.fnum = b-aas_hist.docnum.

                if lookup(string(b-aas_hist.sta),"4,5,6,8,9,15") <> 0 then
                   t-aas.sum = "'" + b-aas_hist.docprim.
                else
                   t-aas.sum = "'" + string (b-aas_hist.chkamt).
                t-aas.whn = b-aas_hist.whn.
                t-aas.gl = txb.aaa.gl.
                if b-aas_hist.who = "bankadm" or b-aas_hist.who = "superman" then do:
                     if b-aas_hist.docprim1 <> '' then t-aas.prim1 = b-aas_hist.docprim1.
                     else do:
                        find prev b-aas_hist where b-aas_hist.aaa = aas_hist.aaa and b-aas_hist.ln = txb.aas_hist.ln no-lock no-error.
                            if avail b-aas_hist then do:
                                if b-aas_hist.chgoper = 'A' then t-aas.prim1 = "Введено". else
                                if b-aas_hist.chgoper = 'E' then t-aas.prim1 = "Изменено  ". else
                                if b-aas_hist.chgoper = 'D' then t-aas.prim1 = "Удалено   ". else
                                if b-aas_hist.chgoper = 'P' then t-aas.prim1 = "Опл полн  ". else
                                if b-aas_hist.chgoper = 'L' then t-aas.prim1 = "Опл част  ". else
                                if b-aas_hist.chgoper = 'T' then t-aas.prim1 = "Приост-но ". else
                                if b-aas_hist.chgoper = 'O' then t-aas.prim1 = "Отозвано  ". else
                                if b-aas_hist.chgoper = 'X' then t-aas.prim1 = "Отк Акцепт". else
                                if b-aas_hist.chgoper = 'Q' then t-aas.prim1 = "Действует ".
                            end.
                     end.
                     /*else t-aas.prim1 = "Отзыв по электронному каналу связи".*/
                end.
                else
                    t-aas.prim1 = b-aas_hist.docprim1.
             end.
         end.
     end.

