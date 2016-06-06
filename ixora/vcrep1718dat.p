/* vcrep1718dat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 17 и 18 - все платежи за месяц по контрактам типа 2
        Сборка во временную таблицу
 * RUN

 * CALLER
        vcrep1718.p
 * SCRIPT

 * INHERIT

 * MENU
        15-5-4, 15-4-x-5, 15-4-x-6
 * AUTHOR
        19.11.2002 nadejda
 * BASES
         BANK COMM TXB
 * CHANGES
        18.01.2004 nadejda - добавлены код региона, адрес и вид платежа в соответствии с новым форматом сообщения МТ-106
        02.06.2005 saltanat - Для ИП "clnsts"-статус будет как для физ.лица
        08.03.2008 galina - добавлено поле cursdoc-usd в таблицу t-docs
                            клиент может быть ИП или юр.лицом
        06.08.2008 galina - расчитываем курс к доллару на дату платежа
        05.04.2011 damir  - добавлены новые переменные v-bin,v-iin,v-bnkbin
                            во временной t-docs bin,iin,bnkbin

        28.04.2011 damir - поставлены ключи. процедура chbin.i
        15.05.2012 damir - перекомпиляция.
    */


{vc.i}

{chbin_txb.i} /*переход на БИН и ИИН*/

define shared var g-ofc like txb.ofc.ofc.
define shared var g-today  as date.
{vc-crosscurs_txb.i}

def input parameter p-expimp as char.
def input parameter p-vcbank as char.
def input parameter p-depart as integer.

def shared var v-god    as integer format "9999".
def shared var v-month  as integer format "99".
def shared var v-dtb    as date.
def shared var v-dte    as date.

def var v-name          as char.
def var v-prefix        as char.
def var v-clnsts        as char.
def var v-okpo          as char.
def var v-partner       as char.
def var v-partnprefix   as char.
def var v-depart        as char.
def var v-addr          as char.
def var v-region        as char.
def var v-cursdoc-usd   as deci.
def var v-bincif        as char.
def var v-iincif        as char.
def var v-bnkbin        as char no-undo.

def shared temp-table t-docs
    field dndate        as date
    field sum           as deci
    field payret        as logi
    field docs          as inte
    field paykind       as char
    field cif           as char
    field prefix        as char
    field name          as char
    field okpo          as char
    field clnsts        as char
    field region        as char
    field addr          as char
    field ctnum         as char
    field ctdate        as date
    field cttype        as char
    field partnprefix   as char
    field partner       as char
    field codval        as char
    field info          as char
    field strsum        as char
    field bank          as char
    field depart        as char
    field cursdoc-usd   as deci
    field bnkbin        as char
    field bin           as char
    field iin           as char
    index main is primary cttype dndate payret sum docs.

find first txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
if avail txb.sysc then v-bnkbin = txb.sysc.chval.
else v-bnkbin = "".

for each vccontrs where vccontrs.bank = p-vcbank and vccontrs.cttype = "2" and vccontrs.expimp = p-expimp no-lock:
    find first vcdocs where vcdocs.contract = vccontrs.contract and (vcdocs.dntype = "02" or vcdocs.dntype = "03") and
    vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte no-lock no-error.
    if avail vcdocs then do:
        find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
        if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.
        if substr(txb.cif.geo, 3, 1) = "1" then do:

            assign v-bincif = "" v-iincif = "" v-bnkbin = "" v-clnsts = "" v-name = "" v-prefix = "" v-addr = "" v-clnsts = ""
            v-okpo = "".

            /* учитываются только резиденты - так сказала Линчевская в январе 2003 */
            v-name = trim(txb.cif.name).
            v-prefix = trim(txb.cif.prefix).
            v-addr = trim(txb.cif.addr[1]).
            if trim(txb.cif.addr[2]) <> "" then do:
                if v-addr <> "" then v-addr = v-addr + "; ".
                v-addr = v-addr + trim(txb.cif.addr[2]).
            end.
            v-addr = trim(substr(v-addr, 1, 100)).

            find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
            if avail txb.cif then do:
                if v-bin = yes then do:
                    if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then do:
                        v-clnsts = "1".
                        v-okpo = trim(txb.cif.ssn).
                        v-bincif = txb.cif.bin.
                    end.
                    if (txb.cif.type = 'B' and txb.cif.cgr = 403) then do:
                        v-clnsts = "2".
                        v-okpo =  string(txb.cif.jss, "999999999999").
                        v-iincif = txb.cif.bin.
                    end.
                end.
                else do:
                    if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then do:
                        v-clnsts = "1".
                        v-okpo = trim(txb.cif.ssn).
                    end.
                    if (txb.cif.type = 'B' and txb.cif.cgr = 403) then do:
                        v-clnsts = "2".
                        v-okpo =  string(txb.cif.jss, "999999999999").
                    end.
                end.
            end.

            assign v-partner = "" v-partnprefix = "" v-depart = "".

            find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "regionkz" and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
            if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-region = txb.sub-cod.ccode.
            else v-region = "".
            find first txb.ppoint where txb.ppoint.point = 1 and txb.ppoint.depart = integer(cif.jame) mod 1000 no-lock no-error.
            v-depart = txb.ppoint.name.
            find vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
            if avail vcpartner then do:
                v-partner = trim(vcpartner.name).
                v-partnprefix = trim(vcpartner.formasob).
            end.
            else do:
                v-partner = "".
                v-partnprefix = "".
            end.
            for each vcdocs where vcdocs.contract = vccontrs.contract and (vcdocs.dntype = "02" or vcdocs.dntype = "03") and
            vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte no-lock:
                find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
                run crosscurs(vcdocs.pcrc, 2, dndate, output v-cursdoc-usd).
                create t-docs.
                assign
                t-docs.dndate = vcdocs.dndate
                t-docs.sum = vcdocs.sum
                t-docs.strsum = trim(string(vcdocs.sum, ">>>>>>>>9.99"))
                t-docs.payret = vcdocs.payret
                t-docs.docs = vcdocs.docs
                t-docs.paykind = "1"
                t-docs.cif = vccontrs.cif
                t-docs.name = v-name
                t-docs.prefix = v-prefix
                t-docs.okpo = v-okpo
                t-docs.clnsts = v-clnsts
                t-docs.region = v-region
                t-docs.addr = v-addr
                t-docs.partner = v-partner
                t-docs.partnprefix = v-partnprefix
                t-docs.codval = txb.ncrc.code
                t-docs.ctnum = vccontrs.ctnum
                t-docs.ctdate = vccontrs.ctdate
                t-docs.cttype = vccontrs.expimp
                t-docs.bank = vccontrs.bank
                t-docs.depart = v-depart
                t-docs.info = vcdocs.info[1]
                t-docs.cursdoc-usd = v-cursdoc-usd.
                if v-bin = yes then do:
                    assign
                    t-docs.bnkbin = v-bnkbin.
                    t-docs.bin    = v-bincif.
                    t-docs.iin    = v-iincif.
                end.
            end.
        end.
    end.
end.

