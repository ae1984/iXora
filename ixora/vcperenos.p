/* vcperenos.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Перенос контрактов в АФ из ЦО
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
        10/08/2010 galina
 * BASES
        BANK COMM
 * CHANGES
*/

def var v-cif as char.
def var v-cifname as char.
def new shared var v-cif-f as char.
def var v-accoldold as char.
def new shared var v-aaa-f as char.
def var v-q as logi.
def new shared var v-crc as integer.

form
    v-cif format "x(6)" label 'Код клиента по ЦО' validate(can-find(cif where cif.cif = v-cif no-lock),'Не верный код клиента!') help 'F2 - поиск' '  ' v-cifname no-label format "x(40)" skip
    v-accoldold format "x(20)" label 'Счет клиента в ЦО' validate(can-find(aaa where aaa.aaa = v-accoldold and aaa.cif = v-cif no-lock),'Счет не найден!') skip
    v-cif-f format "x(6)" label 'Код клиента АФ' validate(v-cif-f <> '','Введите код клиента!') help 'F2 - поиск' skip
    v-aaa-f format "x(20)" label 'Счет клиента в АФ' validate(v-aaa-f <> '','Счет не найден!') skip
with side-label row 10 width 75 centered title "ПЕРЕНОС КОНТРАКТОВ"  frame cif.

update v-cif with frame cif.
find first cif where cif.cif = v-cif no-lock no-error.
if avail cif then v-cifname = cif.pref + ' ' + trim(cif.name).
display v-cifname with frame cif.
update v-accoldold with frame cif.
find first aaa where aaa.aaa = v-accoldold and aaa.cif = v-cif no-lock no-error.
if avail aaa then v-crc = aaa.crc.
find first txb where txb.bank = 'TXB16' no-lock no-error.
if not avail txb then return.

if connected ("txb") then disconnect "txb".
connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
update v-cif-f with frame cif.
repeat ON ENDKEY UNDO, RETURN:
    update v-aaa-f with frame cif.
    run vcchkaaa.
    if v-aaa-f <> '' then leave.
end.
if connected ("txb") then disconnect "txb".
/*if v-aaa-f = '' then return.*/
MESSAGE skip " Перенести контракты? " VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ВНИМАНИЕ ! "
update v-q.

/*message v-q view-as alert-box.
return.*/


if not v-q then return.

find first vccontrs where vccontrs.cif = v-cif and vccontrs.sts <> 'C' no-lock no-error.
if not avail vccontrs then do:
    message 'У данного клиента нет контрактов!' view-as alert-box.
    return.
end.

for each vccontrs where vccontrs.cif = v-cif and vccontrs.sts <> 'C' exclusive-lock:
    if vccontrs.cttype = '1' then do:
        find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
        if avail vcps then run mt111_1(vcps.dnnum + string(vcps.num),vcps.dndate).
    end.
    vccontrs.cif = v-cif-f.
    vccontrs.bank = 'TXB16'.
    if vccontrs.aaa = v-accoldold then vccontrs.aaa = v-aaa-f.
end.