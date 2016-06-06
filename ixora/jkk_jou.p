/* jkk_jou.p
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
        10.01.2008 id00004 Добавил маску для отображения отрицательного остатка по счету
        01.09.09   marinav - запрашивать плательщика и получателя , когда касса в пути
        21.04.10 marinav - добавилось третье поле примечания
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
*/

/** jkk_jou.p
    (D) ARP -- (K) ARP **/


{mainhead.i}

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

def var v-gldr like gl.gl.
def var v-glcr like gl.gl.

define frame f_cus
    joudoc.info   label "ПЛАТЕЛЬЩИК " skip
    joudoc.passp  label "ПАСПОРТ    " skip
    joudoc.perkod label "РНН        "
    with row 15 col 1 overlay side-labels.

define frame f_cus1
    joudoc.info   label "ПОЛУЧАТЕЛЬ " skip
    joudoc.passp  label "ПАСПОРТ    " skip
    joudoc.perkod label "РНН        "
    with row 15 col 1 overlay side-labels.


{mframe.i "shared"}

DO transaction:

find joudoc where joudoc.docnum eq v_doc exclusive-lock.
joudoc.chk   = 0.
d_atl = "АРП-ОСТ".  c_atl = "".
d_lab = "".
joudoc.info = "". joudoc.passp = "".  joudoc.perkod = "".
display joudoc.dracc joudoc.cracc joudoc.chk d_atl c_atl d_lab
    with frame f_main.

L_1:
repeat on endkey undo, return:
    repeat on endkey undo, return:
        message "ВВЕДИТЕ НОМЕР АРП КАРТОЧКИ ".
        update joudoc.dracc /*format "x(10)"*/ with frame f_main.

        find arp where arp.arp eq joudoc.dracc no-lock no-error.
            if not available arp then do:
                message "АРП не найден.".
                pause 3.
                undo, retry.
            end.
        leave.
    end.
    v-gldr = arp.gl.

    find gl where gl.gl eq arp.gl no-lock no-error.
    if gl.type eq "A" or gl.type eq "E" then
        d_avail = string (arp.dam[1] - arp.cam[1], "-z,zzz,zzz,zzz,zzz.99").
    else
        d_avail = string (arp.cam[1] - arp.dam[1], "-z,zzz,zzz,zzz,zzz.99").

    dname_1 = arp.des.
    display dname_1 d_avail with frame f_main.
    color display input dname_1 with frame f_main.

    joudoc.drcur = arp.crc.
    find crc where crc.crc eq arp.crc no-lock no-error.
    f-code = crc.code.
    display joudoc.drcur crc.des with frame f_main.

    repeat on endkey undo, return:
        message "ВВЕДИТЕ НОМЕР АРП КАРТОЧКИ ".
        update joudoc.cracc /*format "x(10)"*/ with frame f_main.

        find arp where arp.arp eq joudoc.cracc no-lock no-error.
            if not available arp then do:
                message "АРП не найден.".
                pause 3.
                undo, retry.
            end.
        leave.
    end.
    v-glcr = arp.gl.

    find gl where gl.gl eq arp.gl no-lock no-error.
    if gl.type eq "A" or gl.type eq "E" then
        c_avail = string (arp.dam[1] - arp.cam[1], "-z,zzz,zzz,zzz,zzz.99").
    else
        c_avail = string (arp.cam[1] - arp.dam[1], "-z,zzz,zzz,zzz,zzz.99").

    cname_1 = arp.des.
    display cname_1 c_avail with frame f_main.
    color display input cname_1 with frame f_main.


    joudoc.crcur = arp.crc.
    find bcrc where bcrc.crc eq arp.crc no-lock no-error.
    t-code = bcrc.code.
    display joudoc.crcur bcrc.des with frame f_main.

    if v-gldr = 100200 then
       update joudoc.info joudoc.passp joudoc.perkod with frame f_cus.
    if v-glcr = 100200 then
       update joudoc.info joudoc.passp joudoc.perkod with frame f_cus1.

    if f-code ne t-code then do:
        display loccrc1 loccrc2 f-code t-code with frame f_main.
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
                update joudoc.remark with frame f_main.
                update joudoc.rescha[3] with frame f_main.

                leave.
            end.
            else do:
                if joudoc.bas_amt eq "D" then do:
                    d_amt = joudoc.dramt.
                    c_amt = 0.
                end.
                if joudoc.bas_amt eq "C" then do:
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

                run jkk_tmpl
                    (input joudoc.bas_amt, output vparam, output templ).

                if joudoc.bas_amt eq "D" then do:
                    run trxsim("", templ, vdel, vparam, 5, output rcode,
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
                    run trxsim("", templ, vdel, vparam, 3, output rcode,
                        output rdes, output jparr).
                        if rcode ne 0 then do:
                            message rdes.
                            pause 3.
                            undo, return.
                        end.

                    joudoc.dramt = decimal (jparr).
                    display joudoc.dramt with frame f_main.
                end.
                pause 0.
                update joudoc.remark with frame f_main.
                update joudoc.rescha[3] with frame f_main.
            end.
        end.

        leave.
    end.

    leave.
end.

run jou_com.
if keyfunction (lastkey) eq "end-error" then undo, return.

leave.
END.
