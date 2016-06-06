/* vcreason.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Справочник Основание закрытия контракта
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
     28.03.2008 galina
 * CHANGES
     18.11.2008 galina - прогружаем все строки справочника на филиалы, даже если изменили одну
                         исправила - не нужно нажимать лишний пробел после надписи "Синхронизация с филиалами..."
     11.06.2009 galina - исправила синхронизацию с филиалами
     02/11/2010 galina - редактирование стправочников только из ЦО

*/


{mainhead.i}
{comm-txb.i}

def buffer v-vcreason for codfr.
def new shared frame vcreason.
def var t4 as char initial "F4-выход,INS-дополн.,P-печать, Ctrl+D-удалить".
def var v-center as logical.
def var v-chng as logical.
def var v-bank as char.


def temp-table t-vcreason like codfr.

v-bank = comm-txb().
find txb where txb.bank = v-bank and txb.consolid no-lock no-error.
v-center = not txb.is_branch.

def var v-availupd as logical.
find sysc where sysc.sysc = "SUPUSR" no-lock no-error.
v-availupd = (avail sysc and lookup(g-ofc, sysc.chval) > 0).

if v-center and not v-availupd then do:
  find ofc where ofc.ofc = g-ofc no-lock no-error.
  find sysc where sysc.sysc = "CURSDN" no-lock no-error.
  v-availupd = (avail ofc and lookup(ofc.titcd, sysc.chval) > 0).
end.



{apbra.i
&head = "codfr"
&index = "cdco_idx"
&formname = "vcreason"
&framename = "vcreason"
&where = "codfr.codfr = 'vcreason' and codfr.code <> 'msc'"
&addcon = "v-center"
&deletecon = "v-center"

&postadd = " buffer-copy codfr to t-vcreason.
            codfr.codfr = 'vcreason'. codfr.level = 1.
            codfr.tree-node = codfr.codfr + CHR(255) + codfr.code.
            if v-center then do transaction on endkey undo, leave:
              update codfr.code codfr.name[1] with frame vcreason.
              run crcupd-after.
            end.

            "

&prechoose = "message t4."

&predisplay = " "
&display = "codfr.code codfr.name[1]"
&highlight = "codfr.code"
&predelete = " "
&postdelete = " "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
              buffer-copy codfr to t-vcreason.
               if v-center then do transaction on endkey undo, leave:
                update codfr.code when v-availupd
                       codfr.name[1] when v-availupd
                       with frame vcreason.
                run crcupd-after.
              end.

             end. "

&end = " run copy2fil. hide frame vcreason. "
}

hide message.

procedure crcupd-after.
  v-chng = v-center and
    (codfr.code <> t-vcreason.code or codfr.name[1] <> t-vcreason.name[1]).
end procedure.

/* переписать важные изменения с головного на филиалы */
procedure copy2fil.
  if v-chng then do:
    message "Синхронизация с филиалами...".

    if connected ("txb") then disconnect "txb".
    for each txb where txb.is_branch and txb.consolid no-lock:
       if connected ("txb") then disconnect "txb".
      connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
      run vcfil1('vcreason').
      disconnect "txb".
    end.
    hide message no-pause.
  end.
end procedure.



