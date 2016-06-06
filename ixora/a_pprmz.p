/* a_pprmz.p
 * MODULE
        Формирование RMZ платежные карты
 * DESCRIPTION
        Формирование проводок по длительным платежным поручениям на основе ответного  файла
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню
 * AUTHOR
        16/07/2013 id00800
 * BASES
        BANK COMM
 * CHANGES
 */

{global.i}
def var v-bank      as char no-undo.
def var v-arp       as char format "x(20)" no-undo.
def var v-gl        as int  no-undo.
def var v-r         as char no-undo.
def var v-cgr       as char no-undo.
def var v-transp    as int  no-undo.
def var v-qq        as char  no-undo.
def var er          as char  no-undo.
def var v-rmzdoc    as char  no-undo.
def var i           as int  no-undo.
def var j           as int  no-undo.
def var v-txt       as char no-undo.
def var vv-bin      as char no-undo.

def new shared var s-jh like jh.jh.
def buffer b-pplist for pplist.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    run savelog( "PPOUT", " there in't parametr ourbnk sysc!").
    return.
end.
v-bank = sysc.chval.
find first cmp no-lock no-error.
/*if v-bank = "TXB00" then return. */ /* для ЦО не обрабатываем  */

v-gl = 186012.
i = 0.
j = 0.
for each pplist where pplist.txb = v-bank and pplist.stat = 'Обработан' and not pplist.remtrz begins "RMZ" no-lock.
    i = i + 1.
    v-r = "".
    v-cgr = "".
    /* поиск арп счета для 186012 */
    v-arp = "".
    for each arp where arp.gl = v-gl and arp.crc = pplist.crc no-lock.
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = "PPOUT" no-lock no-error.
        if avail sub-cod then do:
            v-arp = arp.arp.
            leave.
        end.
    end.
    if v-arp = '' then do:
        j = j + 1.
        pplist.remtrz =  "Нет АРП".
        next.
    end.
    find first cif where cif.cif = pplist.cif no-lock no-error.
    find first ppout where ppout.id = pplist.id no-lock no-error.
    if substring(string(integer(cif.geo),"999"),3,1) eq "1" then v-r = "1".
    else v-r = "2".
    find last sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
    if available sub-cod then v-cgr = sub-cod.ccode.
    if v-cgr = "" then do:
        j = j + 1.
        find first b-pplist where recid(b-pplist) = recid(pplist) exclusive-lock no-error.
        if available b-pplist then b-pplist.remtrz =  "Нет secek".
        find current b-pplist no-lock no-error.
        next.
    end.
    if time >= 52000 then v-transp = 2. else v-transp = 1.
    v-qq = "4N".
    find first txb where txb.bank = v-bank no-lock no-error.
    if available txb and NUM-ENTRIES(txb.params,",") > 2 then vv-bin = entry(3,txb.params,",").
    run rmzcre (1, pplist.sum, v-arp, trim(vv-bin), trim(cmp.name), trim(ppout.bic), trim(ppout.iikben), trim(ppout.benname), trim(ppout.binben),
    ' ', no, trim(ppout.knp), "14" , trim(ppout.kbe), trim(ppout.rem[1])  + " " + trim(ppout.rem[3]) + " " + trim(ppout.rem[3]), v-qq, 1, v-transp, g-today).

    v-rmzdoc = return-value.
    if v-rmzdoc = "" then do:
        j = j + 1.
        find first b-pplist where recid(b-pplist) = recid(pplist) exclusive-lock no-error no-wait.
        if available b-pplist then b-pplist.remtrz =  "Error".
        find current b-pplist no-lock no-error.
        next.
    end.

    find first remtrz where remtrz.remtrz = v-rmzdoc no-lock no-error.
    find first b-pplist where recid(b-pplist) = recid(pplist) exclusive-lock no-error .
    if available b-pplist then do:
        b-pplist.remtrz = v-rmzdoc.
        b-pplist.jh = remtrz.jh1.
    end.
    find current b-pplist no-lock no-error.


       /* remtrz.scbank = v_bank.*/
       /* remtrz.source = "O". *//* код создания платежа*/
       /* remtrz.ptype = "N".*/
    if v-rmzdoc <> '' then do:
        find first remtrz where remtrz.remtrz = v-rmzdoc exclusive-lock no-error no-wait.
        if avail remtrz then do:
            assign remtrz.rsub = 'arp'
                   remtrz.rcvinfo[1] = '/pplist/'
                   remtrz.rcvinfo[3] = v-rmzdoc.
                   remtrz.ref = string(pplist.id).
            find current remtrz no-lock no-error.
        end.
        find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v-rmzdoc and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
        if not avail sub-cod then do:
            create sub-cod.
            sub-cod.sub = 'rmz'.
            sub-cod.acc = v-rmzdoc.
            sub-cod.d-cod = 'pdoctng'.
            sub-cod.ccode = "01".
            sub-cod.rdt = g-today.
        end.
    end.
end.
if i <> 0 then do:
    v-txt = 'Автоматические проводки по длительным платежным поручениям. По ' +
    cmp.name  + ' всего проводок с статусом "Обработан"  = ' + string(i) + '\n из них созданы RMZ документы = ' + string(i - j) + '\n    не выполнено = ' + string(j).
    find first bookcod where bookcod.bookcod = 'pc'
                         and bookcod.code    = 'txb00'
                         no-lock no-error.
    if avail bookcod then run mail( entry(1,bookcod.name) + "@fortebank.com",g-ofc + "@fortebank.com", "Автоматические проводки по длительным платежным поручениям по " + cmp.name,v-txt, "1", "","").
end.
