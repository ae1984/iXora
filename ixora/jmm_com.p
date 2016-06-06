/* jmm_com.p
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
        19/09/05 nataly
 * CHANGES
        13/09/11 dmitriy - при коде комиссии 302, исключил возможность проставления суммы комиссии
*/

define shared buffer bcrc for crc.
define shared buffer ccrc for crc.

define shared variable v_doc like joudoc.docnum.

define shared variable loccrc1 as character format "x(3)".
define shared variable loccrc2 as character format "x(3)".
define shared variable f-code  like crc.code.
define shared variable t-code  like crc.code.

define variable banka   as character.
define variable vsum    like jl.dam.
define variable vgl     like gl.gl.
define variable vdes    as character.
define variable v-aaa   as char.
{mframe.i "shared"}

define frame f_cus
    joudoc.info   label "ПОЛУЧАТЕЛЬ " skip
    joudoc.passp  label "ПАСПОРТ    " skip
    joudoc.perkod label "ПЕРС.КОД   "
    with row 15 col 16 overlay side-labels.


on help of joudoc.comcur in frame f_main do:
    run help-crc1.
end.


D_1:
repeat transaction on endkey undo, return:
    find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error.
    joudoc.comacc = "".
    display joudoc.comacc with frame f_main.
    pause 0.
    if joudoc.dracctype ne joudoc.comacctype and
        joudoc.cracctype ne joudoc.comacctype then
            update joudoc.info joudoc.passp joudoc.perkod with frame f_cus.


    if joudoc.dramt ne 0 then do:
     message "  F2 - ПОМОЩЬ  ".

    D_2:

    repeat on endkey undo, return:
        update joudoc.comcur with frame f_main.
        leave.
    end.
    hide message.
    end.
    pause 0 .
    find ccrc where ccrc.crc eq joudoc.comcur no-lock no-error.
    display ccrc.des with frame f_main.

    find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
        if available aaa then do: banka = aaa.cif. v-aaa = aaa.aaa. end.
        else do: banka = "". v-aaa = "". end.

    run perev (input v-aaa, input joudoc.comcode, input joudoc.cramt, input joudoc.crcur,
        input joudoc.comcur, banka, output vsum, output vgl, output vdes).

    joudoc.comamt = vsum.
    joudoc.comacc = joudoc.dracc.

/* проверка: можно ли редактировать сумму комиссии - 21.07.2000 */

find sysc where sysc.sysc = 'ncom' no-lock no-error.
if avail sysc and index(sysc.chval,joudoc.comcode) <> 0
   then do:
     displ joudoc.comamt with frame f_main.
     leave D_1.
   end.
else
    repeat on endkey undo, next D_1:
        if joudoc.comcode <> '302' then
        update joudoc.comamt with frame f_main.
        leave D_1.
    end.
end.

