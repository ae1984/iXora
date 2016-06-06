/* jsa_jou.p
 * MODULE
        Комиссия с ARP
 * DESCRIPTION
        Комиссия с ARP
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
        18/01/06 marinav
 * CHANGES
        21.04.10 marinav - добавилось третье поле примечания
        01.07.11 damir - изменил отображение примечания.
*/


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

define frame f_cus
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

    find gl where gl.gl eq arp.gl no-lock no-error.
    if gl.type eq "A" or gl.type eq "E" then
        d_avail = string (arp.dam[1] - arp.cam[1], "z,zzz,zzz,zzz,zzz.99").
    else
        d_avail = string (arp.cam[1] - arp.dam[1], "z,zzz,zzz,zzz,zzz.99").

    dname_1 = arp.des.
    display dname_1 d_avail with frame f_main.
    color display input dname_1 with frame f_main.

    joudoc.drcur = arp.crc.
    find crc where crc.crc eq arp.crc no-lock no-error.
    f-code = crc.code.
    display joudoc.drcur crc.des with frame f_main.

    joudoc.remark[1] = "Kомиссия за ".
    pause 0 .
    update joudoc.info label "КЛИЕНТ     "
    joudoc.passp joudoc.perkod with frame f_cus.
    update joudoc.remark with frame f_main.
    update joudoc.rescha[3] with frame f_main.

    leave.
end.
pause 0 .
joudoc.dramt  = 0 .
joudoc.crcur =  joudoc.drcur .
joudoc.comcur = joudoc.crcur .

run jou_com.
joudoc.comacc = joudoc.dracc.
if keyfunction (lastkey) eq "end-error" then undo, return.
leave.
END.
