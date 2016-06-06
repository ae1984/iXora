/* check_ul_txb.p
 * MODULE
        Проверка срока УЛ
 * DESCRIPTION
        Проверка срока УЛ
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
        06.06.2011 aigul
 * BASES
        BANK TXB
 * CHANGES
*/
def input parameter p-aaa as char.
def var v-cif as char.
def var v-days as int.
def var v-buh  as char.
def var v-dr  as char.
def var ln as int.
ln = length(p-aaa).
if ln = 6 then v-cif = p-aaa.
else do:
    find first txb.aaa where txb.aaa.aaa = p-aaa no-lock no-error.
    if avail txb.aaa then v-cif = txb.aaa.cif.
end.
v-days = 0.
find first txb.cif where txb.cif.cif = v-cif no-lock no-error.
if avail txb.cif and txb.cif.type = "B" then do:
    find first txb.sub-cod where txb.sub-cod.acc = v-cif and txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'clnbk'
    and txb.sub-cod.ccod = 'mainbk' no-lock no-error.
    if avail txb.sub-cod then v-buh = txb.sub-cod.rcode.
    v-days = 0.
    find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = v-cif
    and txb.sub-cod.d-cod = "clnbkdtex" no-lock no-error.
    if avail txb.sub-cod then do:
        v-days = date(txb.sub-cod.rcode) - today.
        if v-days <= 30 then  message "Срок действия УЛ (" v-buh ") истекает через " v-days " дня(-ей)!"view-as alert-box.
    end.
    find first txb.sub-cod where txb.sub-cod.acc = v-cif and txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'clnchf'
    and txb.sub-cod.ccod = 'chief' no-lock no-error.
    if avail txb.sub-cod then v-dr = txb.sub-cod.rcode.
    v-days = 0.
    find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = v-cif
    and txb.sub-cod.d-cod = "clnchfddtex" no-lock no-error.
    if avail txb.sub-cod then do:
        v-days = date(txb.sub-cod.rcode) - today.
        if v-days <= 30 then  message "Срок действия УЛ (" v-dr ") истекает через " v-days " дня(-ей)!"view-as alert-box.
    end.
    v-days = 0.
    for each txb.founder where txb.founder.cif = v-cif no-lock:
        if txb.founder.dtsrokul <> ? then do:
            v-days = txb.founder.dtsrokul - today.
            if v-days <= 30 then
            message "Срок действия УЛ (" txb.founder.sname txb.founder.fname ") истекает через " v-days " дня(-ей)!"view-as alert-box.
        end.
    end.
end.
v-days = 0.
find first txb.cif where txb.cif.cif = v-cif no-lock no-error.
if avail txb.cif and cif.type = 'P' and txb.cif.dtsrokul <> ? then do:
    v-days = txb.cif.dtsrokul - today.
    if  v-days <= 30 then  message "Срок действия УЛ (" txb.cif.name ") истекает через " v-days " дня(-ей)!"view-as alert-box.
end.






