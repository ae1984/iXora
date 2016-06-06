/* check_ul.p
 * MODULE
        проверка срока действия УЛ
 * DESCRIPTION
        проверка срока действия УЛ
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
        BANK
 * CHANGES
        10.08.2011 aigul - добавила сообщение о истечении сроков
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
    find first aaa where aaa.aaa = p-aaa no-lock no-error.
    if avail aaa then v-cif = aaa.cif.
end.
v-days = 0.
find first cif where cif.cif = v-cif no-lock no-error.
if avail cif and cif.type = "B" then do:
    find first sub-cod where sub-cod.acc = v-cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnbk'
    and sub-cod.ccod = 'mainbk' no-lock no-error.
    if avail sub-cod then v-buh = sub-cod.rcode.
    v-days = 0.
    find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif
    and sub-cod.d-cod = "clnbkdtex" no-lock no-error.
    if avail sub-cod then do:
        v-days = date(sub-cod.rcode) - today.
        if v-days < 0 then  message "Срок действия УЛ (" v-buh ") истек!"view-as alert-box.
        if (v-days <= 30) and (v-days > 0) then  message "Срок действия УЛ (" v-buh ") истекает через " v-days " дня(-ей)!"view-as alert-box.
    end.
    find first sub-cod where sub-cod.acc = v-cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchf'
    and sub-cod.ccod = 'chief' no-lock no-error.
    if avail sub-cod then v-dr = sub-cod.rcode.
    v-days = 0.
    find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif
    and sub-cod.d-cod = "clnchfddtex" no-lock no-error.
    if avail sub-cod then do:
        v-days = date(sub-cod.rcode) - today.
        if v-days < 0 then  message "Срок действия УЛ (" v-dr ") истек!"view-as alert-box.
        if (v-days <= 30) and (v-days > 0) then  message "Срок действия УЛ (" v-dr ") истекает через " v-days " дня(-ей)!"view-as alert-box.
    end.
    v-days = 0.
    for each founder where founder.cif = v-cif no-lock:
        if founder.dtsrokul <> ? then do:
            v-days = founder.dtsrokul - today.
            if v-days < 0 then  message "Срок действия УЛ (" founder.sname founder.fname ") истек!"view-as alert-box.
            if (v-days <= 30) and (v-days > 0) then
            message "Срок действия УЛ (" founder.sname founder.fname ") истекает через " v-days " дня(-ей)!"view-as alert-box.

        end.
    end.
end.
v-days = 0.
find first cif where cif.cif = v-cif no-lock no-error.
if avail cif and cif.type = 'P' and cif.dtsrokul <> ? then do:
    v-days = cif.dtsrokul - today.
    if v-days < 0 then  message "Срок действия УЛ (" cif.name ") истек!"view-as alert-box.
    if (v-days <= 30) and (v-days > 0) then  message "Срок действия УЛ (" cif.name ") истекает через " v-days " дня(-ей)!"view-as alert-box.
end.






