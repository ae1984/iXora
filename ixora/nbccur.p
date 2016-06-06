/* nbccur.p
 * MODULE
        Параметры системы
 * DESCRIPTION
        Курсы Нац. Банка
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT
        nbccur2fil.p
 * MENU
        9-1-2-2-2
 * BASES
        BANK COMM
 * AUTHOR
        30/01/2002 sasco
 * CHANGES
        01.10.2002 nadejda добавлены данные о замене неактуальной валюты
        21.11.2002 nadejda добавлено копирование на филиалы при изменении важных данных (курс, код...)
        24.05.2003 nadejda - убраны параметры -H -S из коннекта
        18.09.2003 nadejda - менять rate[1], десятичные доли и размерность разрешается только суперюзерам (на всех базах),
                             ДИТ и ВалКон (в Головном офисе)
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        18.03.2008 galina - убрана обработка по полю H/S;
        					автоматически присваивается значение полям ДЕС = 2 и РАЗМ = 1;
        					добавлено условие when avail ncrchis для параметра &postadd;
        					изменен путь к базе с /data/ на /data/b
        31.03.2008 galina - убраны параметры -H -S из коннекта
        05.05.2008 galina - псевдоним базы филиала изменен на txb
        08.04.2011 damir  - данные могут правиться только из центрального офиса.
        14.06.2012 damir  - корректировка, проблема с connect TXB, сделал поле ncrc.crc редактируемым.
*/


{mainhead.i}
{comm-txb.i}

for each ncrc where ncrc.des = "" exclusive-lock:
    delete ncrc.
end.

def new shared frame ncrc.

def buffer t12c for ncrc.
def var rr5 as int.

def var t5 as int.
def var t4 as char initial "F4-выход,INS-дополн.,P-печать".
def var v-center as logical.
def var v-chng as logical init no.
/*def var vp-t9 as char format "x(1)".*/
def var v-bank as char.


def temp-table t-ncrc like ncrc.

v-bank = comm-txb().
find txb where txb.bank = v-bank and txb.consolid no-lock no-error.
v-center = not txb.is_branch.

/* 18.09.2003 nadejda - менять rate[1], десятичные доли и размерность разрешается только суперюзерам (на всех базах),
                        ДИТ и ВалКон (в Головном офисе)
*/
def var v-availupd as logical.
find sysc where sysc.sysc = "SUPUSR" no-lock no-error.
v-availupd = (avail sysc and lookup(g-ofc, sysc.chval) > 0).

if v-center and not v-availupd then do:
  find ofc where ofc.ofc = g-ofc no-lock no-error.
  find sysc where sysc.sysc = "CURSDN" no-lock no-error.
  v-availupd = (avail ofc and lookup(ofc.titcd, sysc.chval) > 0).
end.

/*Данные могут правиться только из центрального офиса*/
def var v-txb00 as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc then v-txb00 = sysc.chval.
else message "Не найден параметр sysc.sysc!!!" view-as alert-box.

/*  */


{apbra.i
&head       = "ncrc"
&index      = "crc"
&formname   = "ncrc"
&framename  = "ncrc"
&where      = "ncrc.sts <> 9"
&addcon     = "true"
&deletecon  = "false"

&postadd    = " find last t12c where t12c.crc <> 0 no-lock no-error.
                rr5 = t12c.crc + 1.
                ncrc.crc = rr5. /*t9 = ' '.*/
                run crcupd-before.
                ncrc.rate[9] = 1.
                ncrc.decpnt = 2.
                do transaction on endkey undo, leave:
                    if v-txb00 = 'TXB00' then do:
                        update
                            ncrc.crc ncrc.des ncrc.rate[1] ncrc.code ncrc.stn /*t9*/
                            with frame ncrc.
                        update
                            ncrc.rate[2] ncrc.rate[3] ncrc.rate[4] ncrc.rate[5] ncrc.rate[6] ncrc.rate[7]
                            v-newval v-newvaldt v-newvalcurs
                            with frame rate.
                        run crcupd-after.
                    end.
                end.
                find last ncrchis where ncrchis.crc = ncrc.crc and ncrchis.rdt = ncrc.regdt no-lock no-error.
                display ncrchis.rdt when avail ncrchis with frame ncrc.
                display ncrc.rate[9] ncrc.decpnt with frame ncrc.
                /*run copy2fil.*/
              "

&prechoose  = "message t4."

&predisplay = " find last ncrchis where ncrchis.crc = ncrc.crc no-lock no-error.
                /*t9 = ' '.*/
                if ncrc.prefix <> '' then do: v-newval = entry(1, ncrc.prefix). v-newvaldt = date(entry(2, ncrc.prefix)).
                v-newvalcurs = decimal(entry(3, ncrc.prefix)). end. else do: v-newval = ''. v-newvaldt = ?. v-newvalcurs = ?. end.
              "
&display    = " ncrc.crc ncrc.des ncrc.rate[1] ncrc.rate[9] ncrc.decpnt
                ncrchis.rdt when available ncrchis  ncrc.code ncrc.stn /*t9*/"

&highlight  = " ncrc.crc ncrc.des "
&predelete  = " "
&postdelete = " "
&postkey    = " else if keyfunction(lastkey) = 'RETURN' then do:
                run crcupd-before.
                do transaction on endkey undo, leave:
                    if v-txb00 = 'TXB00' then do:
                        update
                            ncrc.crc ncrc.des
                            ncrc.rate[1] when v-availupd
                            /*ncrc.rate[9] when v-availupd
                            ncrc.decpnt when v-availupd */
                            ncrc.code ncrc.stn /*t9*/
                            with frame ncrc.
                        update
                            ncrc.rate[2] ncrc.rate[3] ncrc.rate[4] ncrc.rate[5] ncrc.rate[6] ncrc.rate[7]
                            v-newval v-newvaldt v-newvalcurs
                            with frame rate.
                        run crcupd-after.
                    end.
                    end.
                    find last ncrchis where ncrchis.crc = ncrc.crc and ncrchis.rdt = ncrc.regdt no-lock no-error.
                    display ncrchis.rdt with frame ncrc.
                    /*display ncrc.rate[9] ncrc.decpnt with frame ncrc.  */
                    /*run copy2fil.*/
                end.
               "
&end        = " hide frame ncrc.  "
}

hide message.

run pechncrc.

/* переписать важные изменения с головного на филиалы */
/*procedure copy2fil.*/
    if v-chng then do:
        if connected ("txb") then disconnect "txb".
        message "Синхронизация изменений с филиалами...".
        for each txb where txb.is_branch and txb.consolid no-lock:
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
            run nbccur2fil(ncrc.crc).
            disconnect "txb".
        end.
    end.
/*end procedure.*/


run menu-prt("rpt.img").


procedure crcupd-before.
  buffer-copy ncrc to t-ncrc.
  /*t9 = ' '.
  vp-t9 = t9.*/

  if ncrc.prefix <> "" then do:
    v-newval = entry(1, ncrc.prefix).
    v-newvaldt = date(entry(2, ncrc.prefix)).
    v-newvalcurs = decimal(entry(3, ncrc.prefix)).
  end.
  else do:
    v-newval = "".
    v-newvaldt = ?.
    v-newvalcurs = ?.
  end.

end procedure.

procedure crcupd-after.
    def var v-newhis as logical init false.
    ncrc.regdt = g-today.

    if trim(v-newval) = "" then ncrc.prefix = "".
    else ncrc.prefix = trim(v-newval) + "," + string(v-newvaldt, "99/99/9999") + "," + trim(string(v-newvalcurs, ">>>>>>>>>9.999999")).

    /*  find ncrchis where ncrchis.crc = ncrc.crc and ncrchis.rdt = ncrc.regdt no-error.
    if not available ncrchis then do:  */
    create ncrchis.
    /*v-newhis = true.*/
    /*  end.  */
    buffer-copy ncrc to ncrchis.

    ncrchis.rdt = ncrc.regdt.
    ncrchis.who = g-ofc.
    ncrchis.whn = g-today.
    ncrchis.tim = time.

    v-chng = v-center and
    (v-newhis or ncrc.rate[1] <> t-ncrc.rate[1] or ncrc.des <> t-ncrc.des or
    ncrc.rate[9] <> t-ncrc.rate[9] or ncrc.decpnt <> t-ncrc.decpnt or
    ncrc.code <> t-ncrc.code or ncrc.stn <> t-ncrc.stn or ncrc.prefix <> t-ncrc.prefix /*or
    vp-t9 <> t9*/).
end procedure.



