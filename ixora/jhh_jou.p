/* jhh_jou.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        13/09/2011 dmitriy - при коде комиссии 302, исключил возможность проставления суммы комиссии
        17/11/2011 evseev - переход на ИИН/БИН. Кр и Др вывод бин у счетов
*/

/** jhh_jou.p
    (D) KONTS->0 -- (K) KONTS **/
/* 01.10.02 nadejda - наименование клиента заменено на форма собств + наименование */

{mainhead.i}
{chbin.i}

define buffer xcif for cif.
define buffer xaaa for aaa.

define new shared variable s-jh like jh.jh.
define new shared variable s-aaa like aaa.aaa.
define new shared variable com_rec as recid.

define shared buffer bcrc for crc.
define shared buffer ccrc for crc.

define shared variable v_doc like joudoc.docnum.
define shared variable loccrc1 as character format "x(3)".
define shared variable loccrc2 as character format "x(3)".
define shared variable f-code  like crc.code.
define shared variable t-code  like crc.code.

define variable nat_crc like crc.crc.

define variable rcode   as integer.
define variable rdes    as character.
define variable vdel    as character initial "^".
define variable vparam  as character.
define variable templ   as character.
define variable jparr   as character format "x(20)".

define variable card_dt as character.
define variable vvalue  as character.
define variable fname   as character.
define variable lname   as character.
define variable crccode like crc.code.
define variable cardsts as character.
define variable cardexp as character.

define variable pbal     like jl.dam.   /*Full balance*/
define variable pavl     like jl.dam.   /*Available balance*/
define variable phbal    like jl.dam.   /*Hold balance*/
define variable pfbal    like jl.dam.   /*Float balance*/
define variable pcrline  like jl.dam.   /*Credit line*/
define variable pcrlused like jl.dam.   /*Used credit line*/
define variable pooo     like aaa.aaa.

define variable a   as decimal format "zzz,zzz,zzz,zzz.99" .
define variable s   as decimal format "zzz,zzz,zzz,zzz.99".
define variable ds  as decimal.
define variable eps as decimal decimals 4 initial 0.001.
define variable hh  as decimal decimals 4 format "-zzz,zzz.9999".

define variable vgl     like gl.gl.
define variable vdes    as character.

define variable d_amt   like joudoc.dramt.
define variable c_amt   like joudoc.cramt.
define variable com_amt like joudoc.comamt.
define variable m_buy   as decimal.
define variable m_sell  as decimal.

{mframe.i "shared"}

on help of joudoc.comcode in frame f_main do:
   run jcom_hlp.
end.

DO transaction:

find joudoc where joudoc.docnum eq v_doc exclusive-lock.
joudoc.chk   = 0.
d_atl = "СЧТ-ОСТ".  c_atl = "".
d_lab = "ИСП-ОСТ".
joudoc.info = "". joudoc.passp = "".  joudoc.perkod = "".
display joudoc.dracc joudoc.cracc joudoc.chk d_atl c_atl d_lab
    with frame f_main.

L_1:
repeat on endkey undo, return:
    repeat on endkey undo, return:
        message "ВВЕДИТЕ НОМЕР СЧЕТА.".
        update joudoc.dracc /*format "x(10)"*/ with frame f_main.
        find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
            if not available aaa then do:
                message "Счет не найден.".
                pause 3.
                undo, retry.
            end.
        leave.
    end.

    s-aaa = joudoc.dracc.
    run aaa-aas.

    if aaa.sta = "C" then do:
        message "Счет закрыт.".
        pause 3.
        undo, retry.
    end.

    find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
        if available aas then do:
            message "ОСТАНОВКА ПЛАТЕЖЕЙ!".
            pause 3.
            undo,retry.
        end.

    run aaa-bal777 (input aaa.aaa, output pbal, output pavl, output phbal,
        output pfbal, output pcrline, output pcrlused, output pooo).

    find cif of aaa no-lock.
    d_cif = cif.cif.
    dname_1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),  1, 38).
    dname_2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 39, 38).

    if v-bin then dname_3 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 77, 17) + " (" + cif.bin + ")".
    else dname_3 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 77, 17) + " (" + cif.jss + ")".
    d_avail = string (pbal, "z,zzz,zzz,zzz,zzz.99").
    d_izm   = string (pavl, "z,zzz,zzz,zzz,zzz.99").
    joudoc.dramt = pavl.
    display d_cif dname_1 dname_2 dname_3 d_avail d_izm joudoc.dramt
        with frame f_main.
    color display input dname_1 dname_2 dname_3 with frame f_main.

    joudoc.drcur = aaa.crc.
    find crc where crc.crc eq aaa.crc no-lock no-error.
    f-code = crc.code.
    display joudoc.drcur crc.des with frame f_main.

    repeat on endkey undo, return:
        message "ВВЕДИТЕ НОМЕР СЧЕТА.".
        update joudoc.cracc /*format "x(10)"*/ with frame f_main.
        find aaa where aaa.aaa eq joudoc.cracc no-lock no-error.
            if not available aaa then do:
                message "Счет не найден.".
                pause 3.
                undo, retry.
            end.
        if joudoc.dracc eq joudoc.cracc then do:
            message "Одинаковые номера счетов по дебету и кредиту.".
            pause 3.
            undo, retry.
        end.
        leave.
    end.

    s-aaa = joudoc.cracc.
    run aaa-aas.

    if aaa.sta = "C" then do:
        message "Счет закрыт.".
        pause 3.
        undo, retry.
    end.

    find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
        if available aas then do:
            message "ОСТАНОВКА ПЛАТЕЖЕЙ!".
            pause 3.
            undo,retry.
        end.

    find cif of aaa no-lock.
    c_cif = cif.cif.
    cname_1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),  1, 38).
    cname_2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 39, 38).
    if v-bin then cname_3 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 17) + " (" + cif.bin + ")".
    else cname_3 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)), 17) + " (" + cif.jss + ")".
    display c_cif cname_1 cname_2 cname_3 with frame f_main.
    color display input cname_1 cname_2 cname_3 with frame f_main.

    joudoc.crcur = aaa.crc.
    find bcrc where bcrc.crc eq aaa.crc no-lock no-error.
    t-code = bcrc.code.
    display joudoc.crcur bcrc.des with frame f_main.

    if f-code ne t-code then do:
        /*joudoc.brate = crc.rate[4].
        joudoc.srate = bcrc.rate[5].
        joudoc.bn = crc.rate[9].
        joudoc.sn = bcrc.rate[9].*/

        display loccrc1 loccrc2 /*crc.rate[9] bcrc.rate[9]*/ f-code t-code
            /*joudoc.brate joudoc.srate*/ with frame f_main.
        hide message.
    end.
    else do:
        joudoc.brate = 0.
        joudoc.srate = 0.
        joudoc.bn = 0.
        joudoc.sn = 0.

        display "" @ loccrc1 "" @ loccrc2 joudoc.bn joudoc.sn
            "" @ f-code "" @ t-code joudoc.brate joudoc.srate with frame f_main.
        hide message.
    end.

    leave.
end.
find aaa where aaa.aaa eq joudoc.dracc no-lock.
find cif where cif.cif eq aaa.cif no-lock no-error.
find aaa where aaa.aaa eq joudoc.cracc no-lock.
find xcif where xcif.cif eq aaa.cif no-lock no-error.

/*    if cif.cif eq xcif.cif then leave.*/

find jouset where jouset.drnum eq joudoc.dracctype and
    jouset.crnum eq joudoc.cracctype and jouset.fname eq g-fname
    no-lock no-error.

    if ambiguous jouset then do:
        if joudoc.crcur eq nat_crc then
            find jouset where jouset.drnum eq joudoc.dracctype and
                jouset.crnum eq joudoc.cracctype and jouset.natcur
                and jouset.fname eq g-fname no-lock.
        else if joudoc.crcur ne nat_crc then
            find jouset where jouset.drnum eq joudoc.dracctype and
                jouset.crnum eq joudoc.cracctype and not jouset.natcur
                and jouset.fname eq g-fname no-lock.
    end.

    find first joucom where joucom.fname eq jouset.fname and joucom.comtype eq
        jouset.proc and joucom.comnat eq jouset.natcur no-lock no-error.

        if not available joucom then do:
            joudoc.comcode = "".
            joudoc.comamt = 0.
            joudoc.comacctype = "".
            joudoc.comacc = "".
            joudoc.comcur = 0.

            if joudoc.drcur eq joudoc.crcur then joudoc.cramt = joudoc.dramt.
            else do:
                joudoc.bas_amt = "D".

                if joudoc.bas_amt eq "D" then do:
                    d_amt = joudoc.dramt.
                    c_amt = 0.
                end.
                else if joudoc.bas_amt eq "C" then do:
                    d_amt = 0.
                    c_amt = joudoc.cramt.
                end.

                run conv (input joudoc.drcur, input joudoc.crcur, input false,
                    input false, input-output d_amt, input-output c_amt,
                    output joudoc.brate, output joudoc.srate,
                    output joudoc.bn, output joudoc.sn,
                    output m_buy, output m_sell).

                display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
                    with frame f_main.

                run jhh_tmpl (input joudoc.bas_amt,
                    output vparam, output templ).

                run trxsim("", templ, vdel, vparam, 5, output rcode,
                    output rdes, output jparr).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 3.
                        undo, return.
                    end.

                joudoc.cramt = decimal (jparr).
            end.
            display joudoc.comcode joudoc.comamt joudoc.comacc joudoc.comcur
                joudoc.cramt with frame f_main.
            return.
        end.

if cif.cif eq xcif.cif then leave.

com_rec = recid (jouset).

find joucom where joucom.fname eq jouset.fname and joucom.comtype eq
    jouset.proc and joucom.comnat eq jouset.natcur and joucom.comprim
    no-lock no-error.
    if not available joucom then
        message "УКАЖИТЕ КОД КОМИССИИ,  F2 - ПОМОЩЬ  ".
    else joudoc.comcode = joucom.comcode.

update joudoc.comcode with frame f_main.
find joucom where joucom.fname eq jouset.fname and joucom.comtype eq
    jouset.proc and joucom.comnat eq jouset.natcur and joucom.comcode eq
    joudoc.comcode no-lock no-error.

    if not available joucom then do:
        message "КОД КОМИССИИ НЕ РАЗРЕШЕН...  F2 - ПОМОЩЬ ".
        pause 3.
        undo, retry.
    end.

find tarif2 where tarif2.num + tarif2.kod eq joudoc.comcode and tarif2.stat = 'r'.
display joudoc.comcode tarif2.pakalp with frame f_main.

find first jouset where jouset.proc eq "jdd_jou" no-lock no-error.
joudoc.comacctype = jouset.drnum.
joudoc.comacc     = joudoc.dracc.
joudoc.comcur     = joudoc.drcur.
find jounum where jounum.num eq joudoc.comacctype no-lock.
com_com = joudoc.comacctype + "." + jounum.des.
find ccrc where ccrc.crc eq joudoc.comcur no-lock no-error.
display com_com joudoc.comacc joudoc.comcur ccrc.des with frame f_main.

a = joudoc.dramt.

s = a.
repeat:
    run perev (input aaa.aaa, input joudoc.comcode, input s, input joudoc.drcur,
        input joudoc.comcur, "", output ds, output vgl, output vdes).
    hh = a - s - ds.
        if hh > (- eps) and hh < eps then leave.
    s = s + hh.
end.

joudoc.comamt = ds.
display joudoc.comamt with frame f_main.
if joudoc.comcode <> '302' then
update joudoc.comamt with frame f_main.

if joudoc.drcur ne joudoc.crcur then do:
    joudoc.bas_amt = "D".
    joudoc.dramt = joudoc.dramt - joudoc.comamt.

    if joudoc.bas_amt eq "D" then do:
        d_amt = joudoc.dramt.
        c_amt = 0.
    end.
    else if joudoc.bas_amt eq "C" then do:
        d_amt = 0.
        c_amt = joudoc.cramt.
    end.

    run conv (input joudoc.drcur, input joudoc.crcur, input false,
        input false, input-output d_amt, input-output c_amt,
        output joudoc.brate, output joudoc.srate,
        output joudoc.bn, output joudoc.sn, output m_buy, output m_sell).

    display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
        with frame f_main.

    run jhh_tmpl (input joudoc.bas_amt, output vparam, output templ).

    run trxsim("", templ, vdel, vparam, 5, output rcode,
        output rdes, output jparr).
        if rcode ne 0 then do:
            message rdes.
            pause 3.
            undo, return.
        end.

    joudoc.cramt = decimal (jparr).
    display joudoc.cramt joudoc.dramt with frame f_main.
end.
else do:
    joudoc.cramt = joudoc.dramt - joudoc.comamt.
    joudoc.dramt = joudoc.dramt - joudoc.comamt.
    display joudoc.cramt with frame f_main.
end.

leave.
END.
