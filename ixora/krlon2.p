/* krlon2.p
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
        28/01/04 nataly был добавлен признак отрасли
        28/05/2004 madiyar - проверяется признак закрытия счета. Если признак отсутствует или он "msc" - счет открыт, не "msc" - счет закрыт
             и в отчет не включается (сделано для кред. линий - v-bal может быть >0, а кредит уже закрыт).
        02/06/2004 madiyar - создал отдельный признак - признак закрытия счета для отчетов (clsarep). Теперь проверка идет по нему.
        11/10/2004 madiyar - расчет остатка на 15 уровне до 15/03/2004 по проводкам, после - по histrxbal
        30/05/2005 madiyar - добавил поля "Выбрать до" и "Ответственный менеджер"
        04/10/2005 madiyar - не смотреть признак "clsarep"
        28/12/2010 evseev - добавил входящий параметр название филиала, поля Филиал, Номер соглашения, Тип лимита (возобновляемый или не возобновляемый),
                            Одобренная сумма лимита, Одобренная сумма лимита в тенге.
        06/01/2011 evseev - уровень 34 исправил на 35
                            В графе «Ответственный» прописывать ФИО ответственного, вместо id.
        14/02/2011 madiyar - подправил расчет
        10/06/2011 evseev - поправил неверное отображение даты по не возобновляемой КЛ
        31.10.2013 evseev - tz1744
*/


def input parameter datums as date.
def input parameter v-fil as char.

define variable v-bal like txb.lon.opnamt.
def var dlong as date.
def var ecdivis as char.
/* def var include_this_lon as logi. */

def shared temp-table  wrk
    field filial as char
    field lon    like txb.lon.lon
    field gua    as char
    field ecdivis  as  char
    field crc    like txb.lon.crc
    field cif    like txb.lon.cif
    field name   like txb.cif.name
    field lcnt   like txb.loncon.lcnt
    field typelimit as char
    field bal    like txb.lon.opnamt
    field opnamt like txb.lon.opnamt
    field duedt  like txb.lon.duedt
    field dt_do  as   date init ?
    field who    as   char
    field rdt  as   date.

for each txb.lon no-lock.

    run lonbalcrc_txb('lon',txb.lon.lon,datums,"15",txb.lon.crc,yes,output v-bal).
    v-bal = - v-bal.

    if v-bal > 0 then do:
        find txb.cif where txb.cif.cif = txb.lon.cif no-lock.
        dlong = txb.lon.duedt.
        find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = txb.lon.cif  and  txb.sub-cod.d-cod = 'ecdivis'  no-lock no-error.
        if avail txb.sub-cod then ecdivis = txb.sub-cod.ccod. else ecdivis = 'N/A'.
        if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
        if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].

        find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.


        create wrk.
        if txb.lon.gua = 'СL' then wrk.typelimit = 'возобновляемый'.
        else
        if txb.lon.gua = 'LO' and txb.lon.clmain = '' then wrk.typelimit = 'не возобновляемый'.
        else wrk.typelimit = 'возобновляемый'.
        wrk.filial =  v-fil.
        wrk.lon = txb.lon.lon.
        wrk.gua = txb.lon.gua.
        wrk.ecdivis = ecdivis.
        wrk.crc = txb.lon.crc.
        wrk.cif = txb.cif.cif.
        wrk.name = trim(txb.cif.prefix) + " " + txb.cif.name.
        wrk.bal = v-bal.
        wrk.opnamt = txb.lon.opnamt.
        wrk.duedt = dlong.
        wrk.rdt = txb.lon.rdt.
        wrk.dt_do = txb.lon.idt15.

        if avail txb.loncon then do:
            wrk.lcnt = txb.loncon.lcnt.
            find first txb.ofc where txb.ofc.ofc = txb.loncon.pase-pier no-lock no-error.
            if avail txb.ofc then wrk.who = txb.ofc.name.
            else wrk.who = txb.loncon.pase-pier.
        end.
    end.


    run lonbalcrc_txb('lon',txb.lon.lon,datums,"35",txb.lon.crc,yes,output v-bal).
    v-bal = - v-bal.

    if v-bal > 0 then do:
        find txb.cif where txb.cif.cif = txb.lon.cif no-lock.
        dlong = txb.lon.duedt.
        find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = txb.lon.cif  and  txb.sub-cod.d-cod = 'ecdivis'  no-lock no-error.
        if avail txb.sub-cod then ecdivis = txb.sub-cod.ccod. else ecdivis = 'N/A'.
        if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
        if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].

        find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.

        create wrk.
        wrk.typelimit = 'не возобновляемый'.
        wrk.filial =  v-fil.
        wrk.lon = txb.lon.lon.
        wrk.gua = txb.lon.gua.
        wrk.ecdivis = ecdivis.
        wrk.crc = txb.lon.crc.
        wrk.cif = txb.cif.cif.
        wrk.name = trim(txb.cif.prefix) + " " + txb.cif.name.
        wrk.bal = v-bal.
        wrk.opnamt = txb.lon.opnamt.
        wrk.duedt = dlong.
        wrk.rdt = txb.lon.rdt.
        /*if txb.lon.gua = 'СL' then wrk.dt_do = txb.lon.idt35.
        else wrk.dt_do = txb.lon.idt15.*/
        wrk.dt_do = txb.lon.idt35.


        if avail txb.loncon then do:
            wrk.lcnt = txb.loncon.lcnt.
            find first txb.ofc where txb.ofc.ofc = txb.loncon.pase-pier no-lock no-error.
            if avail txb.ofc then wrk.who = txb.ofc.name.
            else wrk.who = txb.loncon.pase-pier.
        end.
    end.

end.


