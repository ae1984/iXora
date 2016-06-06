/* jou_com.p
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
        19/09/2005 nataly  - добавлена возможность автоматического снятия комиссии с ARP
        17/02/2011 evseev - добавил Уведомление о задолженности {checkdebt.i} run checkdebt(g-today, joudoc.cracc, joudoc.comcode).
        01/03/2011 evseev - Коды комиссий 401 и 436 применимы только для ЮЛ и ИП соответственно
        15/03/2011 evseev - добавил условия ((cif.cgr = 403) or (cif.cgr = 405)) ((cif.cgr <> 403) or (cif.cgr <> 405))
        16/03/2011 evseev - изменил условие от 15/03/2011 на (lookup(string(cif.cgr), '403,405') > 0) и (lookup(string(cif.cgr), '403,405') <= 0)
*/

/** jou_com.p **/

define shared variable g-fname like nmenu.fname.

define shared buffer bcrc for crc.
define shared buffer ccrc for crc.

define new shared variable com_rec as recid.

define shared variable v_doc    like joudoc.docnum.

define variable nat_crc like crc.crc.
define variable com_prog as character.
define shared variable loccrc1 as character format "x(3)".
define shared variable loccrc2 as character format "x(3)".
define shared variable f-code  like crc.code.
define shared variable t-code  like crc.code.
{mframe.i "shared"}
{checkdebt.i &file = "bank"}

on help of joudoc.comcode in frame f_main do:
   run jcom_hlp.
end.

find crc where crc.crc = 1 no-lock.
nat_crc = crc.crc.


find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error.
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
   /*19/09/05 nataly*/
      find first arptarif where arptarif.arp = joudoc.dracc no-lock no-error.
      if avail arptarif then do:
        find arp where arp.arp = arptarif.arp no-lock no-error.
        find tarif2 where tarif2.num + tarif2.kod eq arptarif.kod and tarif2.stat = 'r' no-lock.
        joudoc.comcode  = arptarif.kod.

     if tarif2.ost > 0 then
         joudoc.comamt =  tarif2.ost.
    else joudoc.comamt = joudoc.dramt * tarif2.proc / 100.
       /*Уменьшаем сумму выдачи через кассу на сумму комиссии*/
         joudoc.dramt = joudoc.dramt - joudoc.comamt.
         joudoc.comcur = arp.crc.
         joudoc.comacc = arptarif.arp.
            joudoc.comacctype = "4".
            display  joudoc.dramt joudoc.comcode joudoc.comamt joudoc.comacc joudoc.comcur tarif2.pakalp
                with frame f_main.
        return.
     end.        /*19/09/05 nataly*/
        else do:
            joudoc.comcode = "".
            joudoc.comamt = 0.
            joudoc.comacctype = "".
            joudoc.comacc = "".
            joudoc.comcur = 0.
            display joudoc.comcode joudoc.comamt joudoc.comacc joudoc.comcur
                with frame f_main.
            return.
        end.
        end.

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

find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
if avail aaa then do:
  find first cif where cif.cif = aaa.cif no-lock no-error.
  if avail cif then do:
     if cif.type = 'b' and (lookup(string(cif.cgr), '403,405') > 0) and joudoc.comcode = '401' then do:
        message "К этому виду клиента (ИП) данный вид комиссии не применим!" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        undo, retry.
     end.
     else
     if cif.type = 'b' and (lookup(string(cif.cgr), '403,405') <= 0) and joudoc.comcode = '436' then do:
        message "К этому виду клиента (ЮЛ) данный вид комиссии не применим!" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        undo, retry.
     end.
  end.
end.

run checkdebt(g-today, joudoc.cracc, joudoc.comcode, "bank").

find tarif2 where tarif2.num + tarif2.kod eq joudoc.comcode and tarif2.stat = 'r' no-lock.
display joudoc.comcode tarif2.pakalp with frame f_main.


if joudoc.comacctype eq "" then do:
    find first jouset where jouset.drtype eq db_com and jouset.crtype eq ""
                                            no-lock no-error.
    if available jouset then do:
        com_com = db_com.
    end.
    else do:
        find first jouset where jouset.crtype eq "" no-lock no-error.
        if available jouset then do:
            find jounum where jounum.num eq jouset.drnum no-lock.
            com_com = jounum.num + "." + jounum.des.
        end.
        else do:
            message "В настройках комиссия отсутствует.".
            undo, return.
        end.
    end.
end.
else do:
    find jounum where jounum.num eq joudoc.comacctype no-lock.
    com_com = jounum.num + "." + jounum.des.
end.
if joudoc.dramt ne  0 then do:
 update com_com with frame f_main.
end.
else do:
 com_com = db_com .
 com_com:screen-value = db_com:screen-value.
 display com_com  with frame f_main .
end.
find jounum where jounum.num eq substring (com_com, 1, 1) no-lock.
joudoc.comacctype = jounum.num.


find first jouset where jouset.drnum eq joudoc.comacctype and
    jouset.crtype eq "" no-lock no-error.

    if not available jouset or jouset.proc eq "" then do:
        message "РЕЖИМ НЕ РАБОТАЕТ.".
        pause 3.
        undo, retry.
    end.
com_prog = jouset.proc.
run value (com_prog).

if keyfunction (lastkey) eq "end-error" then undo, retry.

