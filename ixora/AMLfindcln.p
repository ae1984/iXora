/* AMLfindcln.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Возвращает данные по клиенту
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
        29/06/2010 galina
 * BASES
        BANK COMM TXB
 * CHANGES
        30/06/2010 madiyar - перекомпиляция
*/

def input parameter p-cif as char.
def output parameter p-cif2 as char.
def output parameter p-clname as char.
def output parameter p-clcountry as char.
def output parameter p-urregdt as char.
def output parameter p-cltype as char.
def var v-country2 as char.
find first txb.cif where txb.cif.cif = p-cif no-lock no-error.
if avail txb.cif then do:
    p-cif2 = txb.cif.cif.
    if txb.cif.type = 'P' then p-cltype = '2'.
    else do:
        if txb.cif.cgr = 403 then  p-cltype = '3'.
        else do:
            p-cltype = '1'.
            p-urregdt = replace(string(txb.cif.expdt,'99/99/9999'),'/','.') + ' ' + '00:00:00'.
        end.
    end.
    p-clname = txb.cif.name.
    if num-entries(txb.cif.addr[1]) = 7 then do:
        v-country2 = entry(1,txb.cif.addr[1]).
        if num-entries(v-country2,'(') = 2 then p-clcountry = substr(entry(2,entry(1,txb.cif.addr[1]),'('),1,2).
    end.
    if p-clcountry <> '' then do:
        find first code-st where code-st.code = p-clcountry no-lock no-error.
        if avail code-st then p-clcountry = code-st.cod-ch.
    end.
end.
