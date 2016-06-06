/* array-txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        09.04.2012 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        09.04.2012 aigul - в соответсвиис прогой s700new_txb.p
        10.04.2012 aigul - добавила проц ставку
        12.04.2012 aigul - добавила описание ГК
        24/09/2012 Luiza - дату закрытия ищем в талице пролонгации acvolt
        01/11/2012 Luiza - изменения сбора данных для fun
        20/12/2012 Luiza - изменения поиска сектора экономики
        14/02/2013 Luiza - ТЗ № 1667 для счет 2240 процент ставку берем из таблицы compens_data
        06/03/2013 Luiza - ТЗ № 1668 дату закрытия для гарантий берем из торгов финансирования
        24/04/2013 Luiza - ТЗ № 1587 добавление счетов 6 класса
        15.08.2013 evseev - перекомпиляция
*/

{conv.i}
def var v-scu as char.
define variable s-ourbank as character no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not available txb.sysc or txb.sysc.chval = "" then
do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(txb.sysc.chval).
function GetFilName returns character ( input txb_val as character ):
    define variable ListCod  as character init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
    define variable ListBank as character format "x(25)" extent 17 init ["         ЦО       ","       Актобе     ","      Костанай    ","       Тараз      ",
        "      Уральск     ","     Караганда    ","   Семипалатинск  ","      Кокшетау    ",
        "       Астана     ","      Павлодар    ","   Петропавловск  ","       Атырау     ",
        "       Актау      ","     Жезказган    "," Усть-Каменогорск ","      Шымкент     ",
        "Алматинский филиал"].
    if txb_val = "" then return "".
    return  ListBank[LOOKUP(txb_val , ListCod)].
end function.

define variable v-bankn as character no-undo.
v-bankn = GetFilName(s-ourbank).
display v-bankn no-labels format "x(20)"  with row 8 frame ww centered title "Обработка".

define shared variable v-gldate as date.
def shared var v-gl1 as int no-undo.
def shared var v-gl2 as int no-undo.
def shared var v-gl-cl as int no-undo.

define           variable      v-bilext as character    no-undo.
define           variable      v-err    as log     no-undo.
define           variable      v-str    as character    no-undo.

define           variable      v-name 	 as character    init "Массив данных" no-undo.
define           variable      v-gltot  as character    no-undo.
define           variable      i        as integer     no-undo.
define           variable      v-gl     as integer /*like gl.gl*/ 	no-undo.
define           variable      v-hs     as character    no-undo.
define           variable      v-cgr    as character    no-undo.
define           variable      v-r      as character    no-undo.
define           variable      v-code 	 as character    no-undo.
define           variable      v-geoi 	 as integer     no-undo.
define           variable      v-cgri 	 as integer     no-undo.
define           variable      v-bal    as decimal /*like glbal.bal*/ no-undo.
define           variable      v-bank 	 as character    no-undo.
define           variable      v-mfo    as character    no-undo.
define           variable      v-day    as character    no-undo.
define           variable      v-mon    as character    no-undo.
define           variable      v-god    as character    no-undo.
define           variable      j        as integer no-undo.
define           variable      sum1     as decimal no-undo.
define           variable      sum2     as decimal no-undo.

define stream errs.
define stream st-err.

def var v-prod as char.
define stream rpt1.
output stream rpt1 to 'rpt11.img'.
def var v-cls as char no-undo.
def var prstav as decim.
def var ccdt as date.

define shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .

define temp-table wt no-undo
    field code as character
    field amt  as decimal  decimals 10 format ">>>,>>>,>>>,>>9.99-"
    index wt-idx1 is unique primary code.

define temp-table wgl no-undo
    field gl     as integer /*like gl.gl*/
    field des as character
    field lev as integer
    field subled as character /*like gl.subled*/
    field type   as character /*like gl.type*/
    field code as char
    field grp as int
    index wgl-idx1 is unique primary gl
    index wgl-idx2  subled.



output stream errs to errs.img.
output stream st-err to rpt.err.

def buffer b-lch for lch.
/*******************************************************************************************************/
/* определение счета главной книги */
function fgl return integer (input v-gl as integer, input v-lev as integer).
    define variable v-glout as integer no-undo.
    v-glout = 0.
    find txb.gl where txb.gl.gl eq v-gl no-lock no-error.
    if available txb.gl then
    do :
        find txb.trxlevgl where txb.trxlevgl.gl eq v-gl
            and txb.trxlevgl.lev eq v-lev
            and txb.trxlevgl.sub eq gl.subled use-index glsublev no-lock no-error.
        if available txb.trxlevgl then v-glout = txb.trxlevgl.glr.
    end.
    return v-glout.
end function.
/*******************************************************************************************************/
function Igl return integer(input gl as integer, input v-lev as integer,
input acc as character,input des as character, input sub as character, input v-crc as integer,
input v-r as character, input v-cgr as character, input v-hs as character,
input odt as date, input cdt as date,
input perc as decimal, input prod as char).
    define variable v-gl   as integer.
    define variable v-code as character.
    define variable v-bal  as decimal.
    v-gl = fgl(gl,v-lev).
    if v-gl1 <> 0 and v-gl2 <> 0 then do:
        if not ( (substr(string(v-gl),1,4) >= substr(string(v-gl1),1,4)
        and substr(string(v-gl),1,4) <= substr(string(v-gl2),1,4)) or
        (v-gl >= v-gl1 and v-gl <= v-gl2) ) then next.
    end.

    if v-gl1 <> 0 and v-gl2 = 0 then do:
        if not ( (substr(string(v-gl),1,4) = substr(string(v-gl1),1,4))
        or (v-gl = v-gl1) ) then next.
    end.
    if v-gl1 = 0 and v-gl2 <> 0 then do:
        if not ( (substr(string(v-gl),1,4) = substr(string(v-gl2),1,4))
        or (v-gl = v-gl2) ) then next.
    end.
    if v-gl-cl <> 0 then do:
        if not ( substr(string(v-gl),1,1) = string(v-gl-cl) )then next.
    end.
    find wgl where wgl.gl = v-gl no-lock no-error.
    if available wgl then
    do :

        v-code = string(truncate(v-gl / 100, 0)) + v-r + v-cgr + v-hs.
        if v-code eq ? or index(v-code,"msc") > 0 then
        do :
           /* message gl v-gl v-code " Ошибка!" v-r  v-cgr  v-hs view-as alert-box.*/
            return 1.
        end.
       /*
        find wt where wt.code = v-code no-error.
        if not available wt then
        do:
            create wt.
            wt.code = v-code.
        end.
       */
        find last txb.histrxbal where txb.histrxbal.acc = acc and
            txb.histrxbal.lev = v-lev and
            txb.histrxbal.subled  = sub and
            txb.histrxbal.crc = v-crc and
            txb.histrxbal.dt <= v-gldate use-index trxbal no-lock no-error.
        if available txb.histrxbal then v-bal = txb.histrxbal.cam - txb.histrxbal.dam. else v-bal = 0.

        if wgl.type eq "A" or wgl.type eq "E" then v-bal = - v-bal.
        if perc = 0 then do:
            find first txb.deal where txb.deal.deal = acc no-lock no-error.
            if avail txb.deal then perc = txb.deal.intrate.
        end.
        if des = "" then des = wgl.des.
            /*FIND FIRST txb.gl where substr(string(txb.gl.gl),1,4) matches substr(string(wgl.gl),1,4) + "*" no-lock no-error.
            if avail txb.gl then des = txb.gl.des.*/

        create tgl.
            tgl.txb = s-ourbank.
            tgl.gl = wgl.gl.
            tgl.gl7 = integer(v-code).
            tgl.gl4 = integer(substring(v-code,1,4)).
            tgl.gl-des = wgl.des.
            tgl.level = v-lev.
            tgl.type = wgl.type.
            tgl.sub-type = sub. /*wgl.subled.*/
            tgl.code = wgl.code.
            tgl.grp = wgl.grp.
            tgl.acc = acc.
            tgl.crc = v-crc.
            tgl.acc-des = des.
            tgl.sum = CRC2KZT(v-bal, v-crc , v-gldate).
            tgl.sum-val = v-bal.
            tgl.geo = "02" + v-r.
            tgl.odt = odt.
            tgl.cdt = cdt.
            tgl.perc= perc.
            tgl.prod = prod.
        /*wt.amt = wt.amt + CRC2KZT(v-bal, v-crc , v-gldate).*/


    end.
end function.
/*******************************************************************************************************/

for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and (txb.gl.gl < 400000 or (txb.gl.gl > 600000 and txb.gl.gl <= 699999) ) no-lock:
    if v-gl1 <> 0 and v-gl2 <> 0 then do:
        if not ( (substr(string(txb.gl.gl),1,4) >= substr(string(v-gl1),1,4)
        and substr(string(txb.gl.gl),1,4) <= substr(string(v-gl2),1,4)) or
        (txb.gl.gl >= v-gl1 and txb.gl.gl <= v-gl2) ) then next.
    end.

    if v-gl1 <> 0 and v-gl2 = 0 then do:
        if not ( (substr(string(txb.gl.gl),1,4) = substr(string(v-gl1),1,4))
        or (txb.gl.gl = v-gl1) ) then next.
    end.
    if v-gl1 = 0 and v-gl2 <> 0 then do:
        if not ( (substr(string(txb.gl.gl),1,4) = substr(string(v-gl2),1,4))
        or (txb.gl.gl = v-gl2) ) then next.
    end.
    if v-gl-cl <> 0 then do:
        if not ( substr(string(txb.gl.gl),1,1) = string(v-gl-cl) )then next.
    end.
  create wgl. /* формируется рабочая таблица */
    wgl.gl = txb.gl.gl.
    wgl.subled = txb.gl.subled.
    wgl.des = txb.gl.des.
    wgl.lev = txb.gl.level.
    wgl.type   = txb.gl.type.
    wgl.code  = txb.gl.code.
    wgl.grp = txb.gl.grp.
end.



define buffer b-trxbal for txb.trxbal.


for each b-trxbal  no-lock :

    if b-trxbal.sub eq "ARP" then
    do:         /* разбор по типам счетов */

        find last txb.arp where txb.arp.arp eq b-trxbal.acc use-index arp no-lock no-error.
        if not available txb.arp then
        do:
            put stream errs skip 'Не найден txb.arp для trxbal  ' b-trxbal.acc b-trxbal.sub b-trxbal.lev.
            next.
        end.
        find last txb.crchs where txb.crchs.crc eq txb.arp.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
            else if txb.crchs.hs eq "S" then v-hs = "3".
        find last txb.cif where txb.cif.cif eq txb.arp.cif use-index cif no-lock no-error.
        if available txb.cif then
        do:
            v-geoi = integer(txb.cif.geo).
            find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
            if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
        end.
        else
        do :
            v-geoi = integer(txb.arp.geo).
            find last txb.sub-cod where txb.sub-cod.sub = 'arp' and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
            if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
        end.
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        /*{700txb.i &gl=arp.gl}*/
        v-cls = "".
        find last txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = "clsa" no-lock no-error .
        if available txb.sub-cod and (txb.sub-cod.ccode <> "msc" or trim(txb.sub-cod.ccode) = "") then v-cls = "(сч.закрыт)".
        Igl(txb.arp.gl, b-trxbal.lev ,b-trxbal.acc ,txb.arp.des + v-cls, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.arp.rdt, txb.arp.spdt, 0, "" ).
    end.

    if b-trxbal.sub eq "AST" then
    do:              /* основные средства */
        find last txb.ast where txb.ast.ast eq b-trxbal.acc use-index ast no-lock no-error.
        if not available txb.ast then
        do:
            put stream errs skip 'Не найден txb.ast для b-trxbal  ' b-trxbal.acc b-trxbal.sub b-trxbal.lev.
            next.
        end.

        Igl(txb.ast.gl, b-trxbal.lev ,b-trxbal.acc,txb.ast.name, b-trxbal.sub, b-trxbal.crc, "1" , "4" ,  "1", ast.rdt, ?, 0, "").
    end.
    if b-trxbal.sub eq "CIF" then
    do:                /* клиентские счета */
        prstav = 0.
        find last txb.aaa where txb.aaa.aaa eq b-trxbal.acc use-index aaa no-lock no-error.
        if not available txb.aaa then
        do:
            put stream errs skip 'Не найден txb.aaa для b-trxbal  ' b-trxbal.acc b-trxbal.sub b-trxbal.lev.
            next.
        end.
        find last txb.cif where txb.cif.cif eq txb.aaa.cif use-index cif no-lock no-error.
        if not available txb.cif then
        do:
            put stream errs 'Не найден код txb.cif для счета  ' txb.aaa.aaa.
            next.
        end.
        find last txb.crchs where txb.crchs.crc eq txb.aaa.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
            else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(integer(txb.cif.geo),"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
        if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.

        /*{700txb.i &gl=aaa.gl}*/
        v-cls = "".
        find last txb.sub-cod where txb.sub-cod.sub = "cif" and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clsa" no-lock no-error .
        if available txb.sub-cod and (txb.sub-cod.ccode <> "msc" or trim(txb.sub-cod.ccode) = "") then v-cls = "(сч.закрыт)".
        /* для гарантий  */
        find first txb.compens_data where txb.compens_data.acc = txb.aaa.aaa no-lock no-error.
        if string(txb.aaa.gl) begins '2240' and available txb.compens_data then prstav = txb.compens_data.rate.
        else prstav  =  txb.aaa.rate.

        if string(txb.aaa.gl) begins '2240' then do: /* дату закрытия ищем в табл торгов финансир-я */
            ccdt = txb.aaa.expdt.
            if txb.aaa.expdt = ? then ccdt = txb.aaa.regdt.

            for each lch where /*lch.lc begins 'PG' and*/ lch.kritcod = 'DtExp' and date(lch.value1) > ccdt no-lock.
                find first b-lch where b-lch.lc = lch.lc and b-lch.kritcode = 'DepAcc' and b-lch.value1 = txb.aaa.aaa no-lock no-error.
                if avail b-lch then do:
                    find last lcamendh where lcamendh.lc = b-lch.lc and lcamendh.kritcod = 'NewDtEx' no-lock no-error.
                    if avail lcamendh then do:
                        if date(lcamendh.value1) > ccdt then ccdt = date(lcamendh.value1).
                    end.
                    else do:
                        if date(lch.value1) > ccdt then ccdt = date(lch.value1).
                        else next.
                    end.
                end.
            end.
            Igl(txb.aaa.gl, b-trxbal.lev ,b-trxbal.acc,txb.cif.name + v-cls, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.aaa.regdt, ccdt, prstav, "").
        end.

        else do: /* если не гарантии */
            find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
            if available txb.acvolt then Igl(txb.aaa.gl, b-trxbal.lev ,b-trxbal.acc,txb.cif.name + v-cls, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.aaa.regdt, date(txb.acvolt.x3), prstav, "").
            else Igl(txb.aaa.gl, b-trxbal.lev ,b-trxbal.acc,txb.cif.name + v-cls, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.aaa.regdt, txb.aaa.expdt, prstav, "").
            if string(txb.aaa.gl) begins '2206' and v-r = "2" and v-cgr = "6" then  put stream rpt1 skip
            txb.aaa.aaa txb.aaa.gl txb.aaa.cif v-hs v-cgr v-bal * crchis.rate[1] / crchis.rate[9] format 'zzz,zzz,zzz,zz9.99'.
        end.
    end.

    if b-trxbal.sub eq "DFB" then
    do:              /* коррсчета */

        find last txb.dfb where txb.dfb.dfb eq b-trxbal.acc use-index dfb no-lock no-error.
        if not available txb.dfb then
        do:
            put stream errs skip 'Не найден lon для b-trxbal  ' b-trxbal.acc b-trxbal.sub b-trxbal.lev.
            next.
        end.
        find last txb.bankl where txb.bankl.bank eq txb.dfb.bank use-index bank no-lock no-error.
        if available txb.bankl then v-geoi = txb.bankl.stn.
        else
        do:
            put stream st-err b-trxbal.sub " " b-trxbal.acc " not found bank for " txb.dfb.bank skip "Summa " string(b-trxbal.dam - b-trxbal.cam,">>>,>>>,>>>,>>>,>>9.99-") " Crc " b-trxbal.crc skip.
        end.
        find last txb.crchs where txb.crchs.crc eq txb.dfb.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
            else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".

        if txb.dfb.gl ge 105100 and txb.dfb.gl lt 105200 then v-cgr = '3'.
        else v-cgr = '4'.

        /*{700txb.i &gl=dfb.gl}*/
        Igl(txb.dfb.gl, b-trxbal.lev ,b-trxbal.acc,txb.dfb.name, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.dfb.rdt, txb.dfb.duedt, 0, "").
    end.

    if b-trxbal.sub eq "FUN" then
    do:      /* межбанковские депозиты и кредиты */

        find last txb.fun where txb.fun.fun eq b-trxbal.acc use-index fun no-lock no-error.
        if not available txb.fun then
        do:
            put stream errs 'Не найден txb.fun для b-trxbal  ' b-trxbal.acc b-trxbal.sub b-trxbal.lev.
            next.
        end.
        find last txb.bankl where txb.bankl.bank eq txb.fun.bank use-index bank no-lock no-error.
        if available txb.bankl then v-geoi = txb.bankl.stn.
        else
        do:
            put stream st-err b-trxbal.sub " " b-trxbal.acc " not found bank for " txb.fun.bank skip "Summa " string(b-trxbal.dam - b-trxbal.cam,">>>,>>>,>>>,>>>,>>9.99-") " Crc " b-trxbal.crc skip.
        end.
        find last txb.crchs where txb.crchs.crc eq txb.fun.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
            else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".

        find last txb.sub-cod where txb.sub-cod.sub = 'fun' and txb.sub-cod.acc = txb.fun.fun and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
        if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
        else  v-cgr = '4'.

        /* {700txb.i &gl=fun.gl}*/
        Igl(txb.fun.gl, b-trxbal.lev ,b-trxbal.acc,txb.fun.cst, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.fun.rdt, txb.fun.duedt, 0, "").
    end.

    if b-trxbal.sub eq "SCU" then
    do:      /* Ценные бумаги */

        find last txb.scu where txb.scu.scu eq b-trxbal.acc use-index scu no-lock no-error.
        if not available txb.scu then
        do:
            put stream errs 'Не найден txb.scu для b-trxbal  ' b-trxbal.acc b-trxbal.sub b-trxbal.lev.
            next.
        end.
        /*
        find last txb.bankl where txb.bankl.bank eq txb.scu.bank no-lock no-error.
        if available txb.bankl then v-geoi = txb.bankl.stn.
           else do:
             put stream st-err b-trxbal.sub " " b-trxbal.acc " not found bank for " txb.scu.bank skip "Summa " string(trxbal.dam - b-trxbal.cam,">>>,>>>,>>>,>>>,>>9.99-") " Crc " b-trxbal.crc skip.
           end.
        */
        v-geoi = integer(scu.geo) no-error.
        if error-status:error then v-geoi = 21.

        find last txb.crchs where txb.crchs.crc eq txb.scu.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
            else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".

        /*
     find last txb.sub-cod where txb.sub-cod.sub = 'scu' and txb.sub-cod.acc = txb.scu.scu and txb.sub-cod.d-cod = 'secek' no-lock no-error.
         if avail txb.sub-cod then v-cgr = txb.sub-cod.ccode.
          else  v-cgr = '4'.
     */
        v-cgr = txb.scu.type. /* сектор экономики */

        /* {700txb.i &gl=scu.gl}*/
        v-scu = "SCU (Ценные бумаги)".
        find first txb.deal where txb.deal.deal = txb.scu.scu no-lock no-error.
        if available txb.deal then do:
            find first txb.dealref where txb.dealref.nin = txb.deal.nin no-lock no-error.
            if available txb.dealref then v-scu  = dealref.cb + " (Ценные бумаги)".
            Igl(txb.scu.gl, b-trxbal.lev ,b-trxbal.acc,v-scu, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.deal.regdt, txb.deal.maturedt, 0, "").

        end.
        else Igl(txb.scu.gl, b-trxbal.lev ,b-trxbal.acc,v-scu, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.scu.ddt[1], txb.scu.cdt[1], 0, "").
    end.

    if b-trxbal.sub eq "LON" then
    do:                  /* ссудные счета */

        find last txb.lon where txb.lon.lon eq b-trxbal.acc use-index lon no-lock no-error.
        if not available txb.lon then
        do:
            put stream errs 'Не найден txb.lon для b-trxbal  ' b-trxbal.acc b-trxbal.sub b-trxbal.lev.
            next.
        end.
        find last txb.cif where txb.cif.cif eq txb.lon.cif use-index cif no-lock no-error.
        if not available txb.cif then
        do:
            put stream errs 'Не найден код txb.cif для счета txb.lon  ' txb.lon.lon.
            next.
        end.
        /*03/11/03 nataly*/
        find last txb.crchs where txb.crchs.crc eq /*lon.crc*/ b-trxbal.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
            else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(integer(txb.cif.geo),"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
        if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.

        find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon
        and txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "lnprod" no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then v-prod = txb.codfr.name[1].
        end.
        /*{700txb.i &gl=lon.gl}*/
        Igl(txb.lon.gl, b-trxbal.lev ,b-trxbal.acc,txb.cif.name, b-trxbal.sub, b-trxbal.crc, v-r , v-cgr ,  v-hs, txb.lon.rdt, txb.lon.duedt, txb.lon.prem, v-prod).
    end.
end.
output close.

for each wgl where wgl.subled eq "" and (wgl.gl < 400000 or string(wgl.gl) begins "6625" or string(wgl.gl) begins "6055") no-lock: /* по всем счетам GL, не имеющим sub */
    if v-gl1 <> 0 and v-gl2 <> 0 then do:
        if not ( (substr(string(wgl.gl),1,4) >= substr(string(v-gl1),1,4)
        and substr(string(wgl.gl),1,4) <= substr(string(v-gl2),1,4)) or
        (wgl.gl >= v-gl1 and wgl.gl <= v-gl2) ) then next.
    end.

    if v-gl1 <> 0 and v-gl2 = 0 then do:
        if not ( (substr(string(wgl.gl),1,4) = substr(string(v-gl1),1,4))
        or (wgl.gl = v-gl1) ) then next.
    end.
    if v-gl1 = 0 and v-gl2 <> 0 then do:
        if not ( (substr(string(wgl.gl),1,4) = substr(string(v-gl2),1,4))
        or (wgl.gl = v-gl2) ) then next.
    end.
    if v-gl-cl <> 0 then do:
        if not ( substr(string(wgl.gl),1,1) = string(v-gl-cl) )then next.
    end.
    for each txb.crchs no-lock.
        find last txb.glday where txb.glday.gl = wgl.gl and txb.glday.crc = txb.crchs.crc and txb.glday.gdt <= v-gldate use-index glday no-lock no-error.
        if available txb.glday and txb.glday.bal <> 0  then
        do:

            if txb.crchs.hs eq "L" then v-hs = "1".
            else
                if txb.crchs.hs eq "H" then v-hs = "2".
                else if txb.crchs.hs eq "S" then v-hs = "3".

            if v-hs = "1" then v-r = "1".
            else v-r = "2".

            if txb.glday.gl lt 105000 then v-cgr = "3".
            else
                if string(glday.gl) begins "2551" then v-cgr = "4".
                else v-cgr = "6".

            v-code = string(truncate(glday.gl / 100, 0)) + v-r + v-cgr + v-hs.

           	/*
            find last wt where wt.code eq v-code no-error.
            if not available wt then
            do:
                create wt.
                wt.code = v-code.
            end.
            */

           	v-bal = txb.glday.cam - txb.glday.dam.
            if wgl.type eq "A" or gl.type eq "E" then v-bal = - v-bal.

            create tgl.
            tgl.txb = s-ourbank.
            tgl.gl = wgl.gl.
            tgl.gl7 = integer(v-code).
            tgl.gl4 = integer(substring(v-code,1,4)).
            tgl.gl-des = wgl.des.
            tgl.level = wgl.lev.
            tgl.type = wgl.type.
            tgl.sub-type = wgl.subled.
            tgl.code = wgl.code.
            tgl.grp = wgl.grp.
            /*tgl.acc = "".*/
            tgl.crc = txb.glday.crc.
            tgl.acc-des = wgl.des.
            tgl.sum = CRC2KZT(txb.glday.bal, txb.glday.crc, v-gldate).
            tgl.sum-val = txb.glday.bal.
            tgl.geo = "02" + v-r.
            /*
            wt.amt = wt.amt + CRC2KZT(txb.glday.bal, txb.glday.crc, v-gldate).
            */
        end.
    end.
end.


output to rpt.img.
for each wt :
    display wt.
end.
output close.

for each wgl no-lock :
    display stream st-err wgl .
end.

output stream st-err close.

output  stream rpt1 close.
output stream errs close .


hide frame ww no-pause.




