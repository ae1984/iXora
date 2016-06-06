/* garan_view1.p
 * MODULE
        Отчет принятых гарантий
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        garan_view.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.4.2.16.18
 * AUTHOR
        14/09/2010 aigul
 * BASES
        BANK COMM
 * CHANGES
        07/06/2013 galina - ТЗ 1835
*/

def input parameter p-bank as char.
def shared var g-today as date.
def shared var vasof  as date.
def shared var vasof2 like vasof.
def shared var vglacc as char format "x(6)".

def shared temp-table wrk
    field nn as integer
    field gl as char
    field fil as char
    field gname as char format "x(50)"
    field zname as char format "x(50)"
    field cif as char
    field lon_no like txb.lon.lon
    field lonrdt as date
    field londuedt as date
    field lonamt as decimal format ">>>,>>>,>>>,>>9.99"
    field loncrc as char
    field gamt as decimal format ">>>,>>>,>>>,>>9.99"
    field gcrc as char
    field kurs as decimal
    field kurs_dt as date
    field gamt_kzt as decimal format ">>>,>>>,>>>,>>9.99"
    field sec_econ as char
    field numdog like txb.loncon.lcnt.

def var i as integer.
i = 0.
def var v-obesp as char.

find first txb.cmp.

for each txb.lon /*where (vglacc = "" or string(txb.lon.gl) = vglacc )*/ no-lock:
v-obesp = "".
    for each  txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon /*and txb.lonsec1.whn < vasof*/
   /* and txb.lonsec1.lonsec = 6*/ no-lock break by txb.lonsec1.crc :
   /* if txb.lonsec1.pielikums[1] <> "" then do:
                if trim(v-obesp) <> '' then  v-obesp = v-obesp + ','.
                v-obesp = v-obesp + txb.lonsec1.pielikums[1].
            end.
            else do:
                find first txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
                if avail txb.lonsec then do:
                    if trim(v-obesp) <> '' then  v-obesp = v-obesp + ','.
                    v-obesp = v-obesp + txb.lonsec.des.
                end.
            end.*/
        if last-of(txb.lonsec1.crc) then do:

            find last txb.histrxbal where txb.histrxbal.subled = "lon" and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.lev = 34
            and txb.histrxbal.dt < vasof and txb.histrxbal.crc = txb.lonsec1.crc  no-lock no-error.
            if avail txb.histrxbal then do:
                i = i + 1.
                create wrk.
                wrk.fil = txb.cmp.name.
                if txb.lonsec1.pielikums[1] <> "" then wrk.gname = txb.lonsec1.pielikums[1].
                else do:
                    find first txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
                    if avail txb.lonsec then wrk.gname = txb.lonsec.des.
                end.
                find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
                if avail txb.cif then wrk.zname =  trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name)).
                wrk.cif = txb.lon.cif.
                wrk.lon_no = txb.lon.lon.
                wrk.lonrdt = txb.lon.rdt.
                wrk.londuedt = txb.lon.duedt.
                wrk.lonamt = txb.lon.opnamt.
                find txb.trxlevgl where txb.trxlevgl.gl eq txb.lon.gl and txb.trxlevgl.subled eq "lon"
                and txb.trxlevgl.level eq txb.histrxbal.level no-lock no-error.
                if avail txb.trxlevgl then do:
                    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
                    if avail txb.gl then do:
                        wrk.gl = string(txb.gl.gl).
                        if txb.gl.type eq "A" or txb.gl.type eq "E" then wrk.gamt = txb.histrxbal.dam - txb.histrxbal.cam.
                        else wrk.gamt = txb.histrxbal.cam - txb.histrxbal.dam.
                    end.
                end.
                find last txb.crchis where txb.crchis.crc = txb.histrxbal.crc and txb.crchis.rdt < vasof no-lock no-error.
                if avail txb.crchis then  do:
                    find first txb.crc where txb.crc.crc = txb.crchis.crc no-lock no-error.
                    if avail txb.crc then do:
                        wrk.loncrc = txb.crc.code.
                        wrk.gcrc = txb.crc.code.
                    end.
                    wrk.kurs = txb.crchis.rate[1].
                    wrk.kurs_dt = txb.crchis.rdt.
                    wrk.gamt_kzt = wrk.gamt * txb.crchis.rate[1].
                end.
                find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis'
                no-lock no-error.
                if avail txb.sub-cod then do:
                    find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                    if avail txb.codfr then wrk.sec_econ = txb.sub-cod.ccode /*+ " - " + txb.codfr.name[1]*/ .
                end.
                find first txb.loncon where txb.loncon.lon  = txb.lon.lon no-lock no-error.
                if avail txb.loncon then wrk.numdog = txb.loncon.lcnt.
            end.
        end.

    end.

end.
hide all.
