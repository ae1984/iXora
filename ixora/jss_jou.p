/* jss_jou.p
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
        21.04.10 marinav - добавилось третье поле примечания
*/

/** jdd_jou.p
    (D) KONTS -- (K) KONTS **/

/*
      01.10.02 nadejda - наименование клиента заменено на форма собств + наименование
      26.04.2011 damir - изменил отображение примечания.
      27.05.2011 damir - перекомпиляция
      01.07.2011 damir - изменил отображение примечания
      17/11/2011 evseev - переход на ИИН/БИН. Кр и Др вывод бин у счетов

*/

{mainhead.i}
{chbin.i}
define buffer xcif for cif.
define buffer xaaa for aaa.

define new shared variable s-jh like jh.jh.
define new shared variable s-aaa like aaa.aaa.

define shared buffer bcrc for crc.
define shared buffer ccrc for crc.

define shared variable v_doc like joudoc.docnum.
define shared variable loccrc1 as character format "x(3)".
define shared variable loccrc2 as character format "x(3)".
define shared variable f-code  like crc.code.
define shared variable t-code  like crc.code.

define variable nat_crc like crc.crc.
define variable amt_out as character.

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

define variable d_amt   like joudoc.dramt.
define variable c_amt   like joudoc.cramt.
define variable com_amt like joudoc.comamt.
define variable m_buy   as decimal.
define variable m_sell  as decimal.
def var v-cifname like cif.name.

{mframe.i "shared"}

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
    v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
    dname_1 = substring(v-cifname,  1, 38).
    dname_2 = substring(v-cifname, 39, 38).
    if v-bin then dname_3 = substring(v-cifname, 77, 17) + " (" + cif.bin + ")".
    else dname_3 = substring(v-cifname, 77, 17) + " (" + cif.jss + ")".
    d_avail = string (pbal, "z,zzz,zzz,zzz,zzz.99").
    d_izm   = string (pavl, "z,zzz,zzz,zzz,zzz.99").
    display d_cif dname_1 dname_2 dname_3 d_avail d_izm with frame f_main.
    color display input dname_1 dname_2 dname_3 with frame f_main.

    joudoc.drcur = aaa.crc.
    find crc where crc.crc eq aaa.crc no-lock no-error.
    f-code = crc.code.
    display joudoc.drcur crc.des with frame f_main.

    /*
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
    v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
    cname_1 = substring(v-cifname,  1, 38).
    cname_2 = substring(v-cifname, 39, 38).
    if v-bin then cname_3 = substring(v-cifname, 77, 17) + " (" + cif.bin + ")".
    else cname_3 = substring(v-cifname, 77, 17) + " (" + cif.jss + ")".
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

    /** MAKS…JUMA SUMMA **/
    repeat on endkey undo, next L_1:
        update joudoc.dramt with frame f_main.
        if joudoc.dramt eq 0 then update joudoc.cramt with frame f_main.
        if joudoc.dramt eq 0 and joudoc.cramt eq 0 then undo, retry.
        else do:
            if joudoc.dramt ne 0 then joudoc.bas_amt = "D".
            else if joudoc.cramt ne 0 then joudoc.bas_amt = "C".

            if joudoc.drcur eq joudoc.crcur then do:
                if joudoc.dramt ne 0 then joudoc.cramt = joudoc.dramt.
                else if joudoc.cramt ne 0 then joudoc.dramt = joudoc.cramt.

                display joudoc.dramt joudoc.cramt with frame f_main.
                pause 0 .
                joudoc.remark[1] = "Комиссия за ".
                pause 0 .
                update joudoc.remark with frame f_main.
                update joudoc.rescha[3] with frame f_main.

                leave.
            end.
            else do:
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

                run jdd_tmpl
                    (input joudoc.bas_amt, output vparam, output templ).

                if joudoc.bas_amt eq "D" then do:
                    run trxsim(templ, vdel, vparam, 5, output rcode,
                        output rdes, output jparr).
                        if rcode ne 0 then do:
                            message rdes.
                            pause 3.
                            undo, return.
                        end.

                    joudoc.cramt = decimal (jparr).
                    display joudoc.cramt with frame f_main.
                end.
                if joudoc.bas_amt eq "C" then do:
                    run trxsim(templ, vdel, vparam, 3, output rcode,
                        output rdes, output jparr).
                        if rcode ne 0 then do:
                            message rdes.
                            pause 3.
                            undo, return.
                        end.

                    joudoc.dramt = decimal (jparr).
                    display joudoc.dramt with frame f_main.
                end.
                /*
                d_izm = string (pavl - joudoc.dramt, "z,zzz,zzz,zzz,zzz.99").
                display d_izm with frame f_main.*/
                pause 0.
                joudoc.remark[1] = "Комиссия за ".
                pause 0.
                update joudoc.remark with frame f_main.
                update joudoc.rescha[3] with frame f_main.
            end.
        end.

        leave.
    end.

    leave.
end.

*/
leave .
end.

joudoc.remark[1] = "Комиссия за ".
update joudoc.remark with frame f_main.
update joudoc.rescha[3] with frame f_main.

find aaa where aaa.aaa eq joudoc.dracc no-lock.
find cif where cif.cif eq aaa.cif no-lock no-error.

/*
find aaa where aaa.aaa eq joudoc.cracc no-lock.
find xcif where xcif.cif eq aaa.cif no-lock no-error.

    if cif.cif eq xcif.cif then leave.
  */
run jou_com.
if keyfunction (lastkey) eq "end-error" then undo, return.

leave.
END.
