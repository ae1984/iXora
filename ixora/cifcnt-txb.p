/* cifcnt-txb.p
 * MODULE
        Клиенты
 * DESCRIPTION
        Подсчет количества клиентов
 * RUN

 * CALLER
        cifcnt.p
 * SCRIPT

 * INHERIT

 * MENU
        Пункт меню
 * AUTHOR
        15/07/05 sasco
 * CHANGES
*/

/* 90, 92 - быстрые деньги */

{msg-box.i}

def shared temp-table tmp

    field txb    as char /* филиал */
    field type   as char /* юр - физ */
    field rko    as char /* СПФ */
    field depart as int  /* номер СПФ */

    field cifall as int  /* всего клиентов */
    field cifaaa as int  /* с действующими счетами */
    field cifact as int  /* активных клиентов */
    field cifbd  as int  /* клиенты быстрых денег */
    field ioall  as int  /* всего в интернет офисе */
    field ioact  as int  /* открытых договоров в интернет офисе */
    field iodoc  as int  /* с оборотами */

    index itmp is primary txb depart type.

def shared var vdt as date.
def shared var ftime as int.

def var vtxb as char.
def var vpoint as int.
def var vdep as int.
def var vrko as char. 
def var was as logical.

find txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
vtxb = caps (txb.sysc.chval).

for each txb.cif no-lock:

    /* пропустим неизвестных науке личностей */
    if cif.type <> "B" and cif.type <> "P" then next.

    run SHOW-MSG-BOX (substr (string (time - ftime, "HH:MM:SS"), 4) + " " + vtxb + " " + txb.cif.cif).

    /* определение подразделения */
    vpoint = 1.
    vdep = 1.
    if txb.cif.jame <> '' then do :
       vpoint = integer(txb.cif.jame) / 1000 - 0.5.
       vdep = integer(txb.cif.jame) - vpoint * 1000.
    end.
    else do:
       find last txb.ofchis where txb.ofchis.ofc = txb.cif.who no-lock.
       vpoint = txb.ofchis.point. 
       vdep = txb.ofchis.dep.
    end.

    find txb.ppoint where txb.ppoint.point = 1 and txb.ppoint.depart = vdep no-lock no-error.
    if not avail txb.ppoint then next.
    vrko = txb.ppoint.name.

    /* создание записи в отчете */
    find first tmp where tmp.txb = vtxb and tmp.type = txb.cif.type and tmp.depart = vdep no-error.
    if not avail tmp then do:
       create tmp.
       assign tmp.txb = vtxb
              tmp.type = txb.cif.type
              tmp.rko = vrko
              tmp.depart = vdep
              .
    end.
    
    /* общее количество клиентов */

    tmp.cifall = tmp.cifall + 1.


    /* с действующими счетами */

    run SHOW-MSG-BOX (substr (string (time - ftime, "HH:MM:SS"), 4) + " " + vtxb + " " + txb.cif.cif + " ... поиск счетов").

    find first txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> "C" no-lock no-error.
    if avail txb.aaa then tmp.cifaaa = tmp.cifaaa + 1.


    /* поиск активности по кредиту хотя бы одного счета */

    run SHOW-MSG-BOX (substr (string (time - ftime, "HH:MM:SS"), 4) + " " + vtxb + " " + txb.cif.cif + " ... поиск активности по кредиту").

    was = no. /* нет активности */
    for each txb.aaa where txb.aaa.cif = txb.cif.cif no-lock:

        find last txb.jl where txb.jl.acc =  txb.aaa.aaa and 
                               txb.jl.dc = "C" and 
                               txb.jl.cam > 0 and 
                               txb.jl.jdt >= vdt
                               use-index accdcjdt no-lock no-error.
        if avail txb.jl then was = yes. /* была активность */
    end.
    if was then tmp.cifact = tmp.cifact + 1.


    /* поиск по базе быстрых денег */

    run SHOW-MSG-BOX (substr (string (time - ftime, "HH:MM:SS"), 4) + " " + vtxb + " " + txb.cif.cif + " ... поиск быстрых денег").

    find first txb.lon where txb.lon.cif = txb.cif.cif and (txb.lon.grp = 90 or txb.lon.grp = 92) no-lock no-error.
    if avail txb.lon then tmp.cifbd = tmp.cifbd + 1.

    /* поиск договоров по Интернету */

    run SHOW-MSG-BOX (substr (string (time - ftime, "HH:MM:SS"), 4) + " " + vtxb + " " + txb.cif.cif + " ... поиск по Интернет Офису").

    for each ib.usr where ib.usr.bnkplc = vtxb and ib.usr.cif = txb.cif.cif no-lock:
        tmp.ioall = tmp.ioall + 1.
        if ib.usr.perm[6] = 0 then tmp.ioact = tmp.ioact + 1.
        find first ib.doc where ib.doc.id_usr = ib.usr.id and ib.doc.valdate >= vdt no-lock use-index idx_uvsn no-error.
        if avail ib.doc then tmp.iodoc = tmp.iodoc + 1.
    end.

end.

run HIDE-MSG-BOX.


