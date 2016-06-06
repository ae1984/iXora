/* garan_rem.p
 * MODULE
        Примечания для истории изменения гарантий
 * DESCRIPTION
        Сбор данных для поля rem таблицы gar%his
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
        30/09/2011 lyubov
 * BASES
        BANK
 * CHANGES
        07/03/2013 sayat(id01143) - ТЗ 1707 от 07/02/2013 добавлено поле "Страна бенефициара"
        12/04/2013 Sayat(id01143) - ТЗ 1762 от 13/03/2013 добавлены поля "N доп.согл.к договору" и "Дата доп.соглашения"
        02/09/2013 galina - ТЗ 1918 добавила обработку полей dtdop grafcom mcomsum mcom% mlastday

*/

{global.i}

def shared var v-cif like cif.cif init "".
def shared var v-name as char no-undo.
def shared var v-rnn as char no-undo.

def shared var vaaa like aaa.aaa.
def shared var vaaa2 like aaa.aaa.

def shared var dfrom as date no-undo.
def shared var dtdop as date no-undo.
def shared var dto as date no-undo.
def shared var v-garan as char no-undo.
def shared var v-gardop as char no-undo.
def shared var v-bankben as char no-undo.
def shared var v-naim as char no-undo.
def shared var v-address as char no-undo.
def shared var v-codfr as char no-undo.
def shared var vobes as char no-undo.

def shared var v-fname as char no-undo.
def shared var v-lname  as char no-undo.
def shared var v-mname as char no-undo.
def shared var v-benres as int no-undo.
def shared var v-benrdes as char no-undo.
def shared var v-bentdes as char no-undo.
def shared var v-bentype as int no-undo.
def shared var v-bencount as char no-undo.
def shared var v-bencountr as char no-undo.

def shared var sumtreb as decimal .
def shared var vcrc like crc.crc.

def shared var vaaa3 like aaa.aaa.
def shared var vcrc3 like crc.crc.
def shared var sumkom as decimal no-undo.
def shared var sumzalog as decimal no-undo.
def shared var v-crczal like crc.crc.

def shared var v-jh like jh.jh init 0.
def shared var v-jh2 like jh.jh init 0.

def shared var v-jdt as date no-undo.
def shared var v-our as log no-undo.
def shared var v-lon as log no-undo.
def shared var v-nomgar as char no-undo.

def shared var vsum as deci no-undo.
def shared var IntType as int init 2.

def shared var v-grcom as logi.
def shared var v-mcomsum as deci.
def shared var v-mcom% as deci.
def shared var v-mlstdate as logi.


def shared var remark as char.

find last gar%his where gar%his.garan = vaaa2 and gar%his.cif = v-cif and gar%his.whn <= g-today no-lock no-error.
if avail gar%his then do:

    /*if gar%his.jh <> v-jh then
    remark = " parm=" + "jh" + " oldval=" + string(gar%his.jh) + " newval=" + string(v-jh).*/

    if gar%his.jh2 <> v-jh2 then
    remark = remark + " parm=" + "jh2" + " oldval=" + string(gar%his.jh2) + " newval=" + string(v-jh2).

    if gar%his.sum <> vsum then
    remark = remark + " parm=" + "sum" + " oldval=" + string(gar%his.sum) + " newval=" + string(vsum).

    if gar%his.garnum <> v-garan then
    remark = remark + " parm=" + "garnum" + " oldval=" + string(gar%his.garnum) + " newval=" + string(v-garan).

    if gar%his.aaa2 <> vaaa then
    remark = remark + " parm=" + "aaa2" + " oldval=" + string(gar%his.aaa2) + " newval=" + string(vaaa).

    if gar%his.dtfrom <> dfrom then
    remark = remark + " parm=" + "dtfrom" + " oldval=" + string(gar%his.dtfrom) + " newval=" + string(dfrom).

    if gar%his.dtto <> dto then
    remark = remark + " parm=" + "dtto" + " oldval=" + string(gar%his.dtto) + " newval=" + string(dto).

    if gar%his.obesp <> v-codfr then
    remark = remark + " parm=" + "obesp" + " oldval=" + string(gar%his.obesp) + " newval=" + string(v-codfr).

    if gar%his.sumzalog <> sumzalog then
    remark = remark + " parm=" + "sumzalog" + " oldval=" + string(gar%his.sumzalog) + " newval=" + string(sumzalog).

    if gar%his.sumtreb <> sumtreb then
    remark = remark + " parm=" + "sumtreb" + " oldval=" + string(gar%his.sumtreb) + " newval=" + string(sumtreb).

    if gar%his.crc <> vcrc then
    remark = remark + " parm=" + "crc" + " oldval=" + string(gar%his.crc) + " newval=" + string(vcrc).

    if gar%his.crc2 <> vcrc3 then
    remark = remark + " parm=" + "crc2" + " oldval=" + string(gar%his.crc2) + " newval=" + string(vcrc3).

    if gar%his.sumkom <> sumkom then
    remark = remark + " parm=" + "sumkom" + " oldval=" + string(gar%his.sumkom) + " newval=" + string(sumkom).

    if gar%his.aaa3 <> vaaa3 then
    remark = remark + " parm=" + "aaa3" + " oldval=" + string(gar%his.aaa3) + " newval=" + string(vaaa3).

    if gar%his.bankben <> v-bankben then
    remark = remark + " parm=" + "bankben" + " oldval=" + string(gar%his.bankben) + " newval=" + string(v-bankben).

    if gar%his.benres <> v-benres then
    remark = remark + " parm=" + "benres" + " oldval=" + string(gar%his.benres) + " newval=" + string(v-benres).

    if gar%his.bentype <> v-bentype then
    remark = remark + " parm=" + "bentype" + " oldval=" + string(gar%his.bentype) + " newval=" + string(v-bentype).

    if gar%his.naim <> v-naim then
    remark = remark + " parm=" + "naim" + " oldval=" + gar%his.naim + " newval=" + v-naim.

    if gar%his.fname <> v-fname then
    remark = remark + " parm=" + "fname" + " oldval=" + gar%his.fname + " newval=" + v-fname.

    if gar%his.lname <> v-lname  then
    remark = remark + " parm=" + "lname" + " oldval=" + gar%his.lname + " newval=" + v-lname.

    if gar%his.mname <> v-mname  then
    remark = remark + " parm=" + "mname" + " oldval=" + gar%his.mname + " newval=" + v-mname.

    if gar%his.address <> v-address then
    remark = remark + " parm=" + "address" + " oldval=" + gar%his.address + " newval=" + v-address.

    if gar%his.info[1] <> v-nomgar then
    remark = remark + " parm=" + "info" + " oldval=" + string(gar%his.info[1]) + " newval=" + string(v-nomgar).

    if gar%his.gtype <> IntType then
    remark = remark + " parm=" + "gtype" + " oldval=" + string(gar%his.gtype) + " newval=" + string(IntType).

    if gar%his.crczal <> v-crczal then
    remark = remark + " parm=" + "crczal" + " oldval=" + string(gar%his.crczal) + " newval=" + string(v-crczal).

    if gar%his.bencountry <> v-bencount then
    remark = remark + " parm=" + "bencount" + " oldval=" + string(gar%his.bencount) + " newval=" + string(v-bencount).

    if gar%his.dopnum <> v-gardop then
    remark = remark + " parm=" + "dopnum" + " oldval=" + string(gar%his.dopnum) + " newval=" + string(v-gardop).

    if gar%his.dtdop <> dtdop then
    remark = remark + " parm=" + "dtdop" + " oldval=" + string(gar%his.dtdop) + " newval=" + string(dtdop).

    if gar%his.grafcom <> v-grcom then
    remark = remark + " parm=" + "grafcom" + " oldval=" + string(gar%his.grafcom) + " newval=" + string(v-grcom).

    if gar%his.mcomsum <> v-mcomsum then
    remark = remark + " parm=" + "mcomsum" + " oldval=" + string(gar%his.mcomsum) + " newval=" + string(v-mcomsum).

    if gar%his.mcom% <> v-mcom% then
    remark = remark + " parm=" + "mcom%" + " oldval=" + string(gar%his.mcom%) + " newval=" + string(v-mcom%).

    if gar%his.mlastday <> v-mlstdate then
    remark = remark + " parm=" + "mlastday" + " oldval=" + string(gar%his.mlastday) + " newval=" + string(v-mlstdate).

end.