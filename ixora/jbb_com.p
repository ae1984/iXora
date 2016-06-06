/* jbb_com.p
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
        13/09/11 dmitriy - при коде комиссии 302, исключил возможность проставления суммы комиссии
*/

/**
    jbb_com.p
    Комиссия со счета клиента
    изменения от 21.07.2000
**/


{mainhead.i}

define buffer xaaa for aaa.

define new shared variable s-aaa like aaa.aaa.

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

define variable pbal     like jl.dam.   /*Full balance*/
define variable pavl     like jl.dam.   /*Available balance*/
define variable phbal    like jl.dam.   /*Hold balance*/
define variable pfbal    like jl.dam.   /*Float balance*/
define variable pcrline  like jl.dam.   /*Credit line*/
define variable pcrlused like jl.dam.   /*Used credit line*/
define variable pooo     like aaa.aaa.

define variable jou_cif like cif.cif.
{mframe.i "shared"}

on help of joudoc.comcur in frame f_main do:
    run help-crc1.
end.

m_atl = "KNT-ATL".

D_1:
REPEAT on endkey undo, return:

find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error.

if db_com eq com_com then do:
    joudoc.comacc = joudoc.dracc.
    find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
    find cif where cif.cif eq aaa.cif no-lock no-error.
    jou_cif = cif.cif.
end.
else if cr_com eq com_com then do:
    joudoc.comacc = joudoc.cracc.
    find aaa where aaa.aaa eq joudoc.cracc no-lock no-error.
    find cif where cif.cif eq aaa.cif no-lock no-error.
    jou_cif = cif.cif.
end.
if joudoc.dramt > 0 then do:
message "IEVADIET KONTA Nr.".
update joudoc.comacc with frame f_main.
find aaa where aaa.aaa eq joudoc.comacc no-lock no-error.
    if not available aaa then do:
        message "Konts neeksistё.".
        pause 3.
        undo, retry.
    end.

find cif of aaa no-lock.
    if cif.cif ne jou_cif then do:
        message "KONTS PIEDER CITAM KLIENTAM.".
        pause 3.
        undo, retry.
    end.

s-aaa = joudoc.comacc.
run aaa-aas.

    if aaa.sta = "C" then do:
        message "Konts aizvёrts.".
        pause 3.
        undo, retry.
    end.

find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
    if available aas then do:
        message "STOP PAYMENT".
        pause 3.
        undo, retry.
    end.
                      end.
                      else
                      do:
                      display joudoc.comacc with frame f_main .
                      end.
if joudoc.dracc ne joudoc.comacc then do:
    run aaa-bal777 (input aaa.aaa, output pbal, output pavl, output phbal,
        output pfbal, output pcrline, output pcrlused, output pooo).

    m_avail = string (pavl, "z,zzz,zzz,zzz,zzz.99").
    display m_atl m_avail with frame f_main.
end.

joudoc.comcur = aaa.crc.
display joudoc.comcur with frame f_main.

find ccrc where ccrc.crc eq joudoc.comcur no-lock no-error.
display ccrc.des with frame f_main.

if joudoc.comacctype eq joudoc.dracctype then banka = aaa.cif.
/*else banka = "".*/
else banka = aaa.cif.
if joudoc.crcur = 0 then joudoc.crcur = joudoc.drcur .
/*message joudoc.comacctype joudoc.dracctype
 joudoc.comcode joudoc.cramt joudoc.crcur joudoc.comcur banka.
pause 5.    */
run perev (input aaa.aaa, input joudoc.comcode, input joudoc.cramt, input joudoc.crcur,
    input joudoc.comcur, banka, output vsum, output vgl, output vdes).

joudoc.comamt = vsum.

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
END.
