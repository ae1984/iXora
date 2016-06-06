/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--
 * BASES
        TXB
 * CHANGES
*/

/*{global.i}*/

/* galina - мои переменные*/

def input parameter p-iik like txb.aaa.aaa.

def shared var v-chief as char no-undo.
def shared var v-clOKED as char no-undo.
def shared var v-clOKPO as char no-undo.
def shared var v-clbin as char no-undo.
def shared var v-clphone as char no-undo.
def shared var v-clemail as char no-undo.
def shared var v-bdt  as date no-undo.
def shared var v-bplace as char no-undo.
def shared var v-cladru as char no-undo.
def shared var v-cladrf as char no-undo.
def shared var v-res2 as char no-undo.
def shared var v-res as char no-undo.
def shared var v-cltype as char no-undo.
def shared var v-publicf as char no-undo.
def  shared var v-pss as char no-undo format "x(30)".
def var v-country2 as char no-undo.
/***********/

/**/
assign v-chief = ''
       v-clOKED = ''
       v-clOKPO = ''
       v-clbin = ''
       v-clphone = ''
       v-clemail = ''

       v-bdt = ?
       v-bplace = ''
       v-cladru = ''
       v-cladrf = ''
       v-res2 = ''
       v-res = ''
       v-cltype = ''
       v-publicf = ''.
find first txb.aaa where txb.aaa.aaa = p-iik no-lock no-error.
find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
v-clbin = txb.cif.bin.
v-clphone = txb.cif.tel.
v-cladru = txb.cif.addr[1].
v-cladrf = txb.cif.addr[2].
if trim(v-pss) = '' then v-pss = txb.cif.pss.
find first txb.cif-mail where txb.cif-mail.cif = txb.cif.cif no-lock no-error.
if avail txb.cif-mail then v-clemail = txb.cif-mail.mail.

find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error.
if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then v-clOKED = txb.sub-cod.ccode.

if txb.cif.type = 'P' then do:
    v-cltype = '02'.
    find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "publicf" use-index dcod no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then v-publicf = txb.sub-cod.ccode.
    v-bdt = txb.cif.expdt.
    v-bplace = txb.cif.bplace.
end.
if txb.cif.type = 'B' then do:
    if txb.cif.cgr = 403 then do:
        v-cltype = '03'.
        find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "publicf" use-index dcod no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then v-publicf = txb.sub-cod.ccode.
        v-bdt = txb.cif.expdt.
        v-bplace = txb.cif.bplace.
    end.
    else do:
        v-cltype = '01'.
        v-clOKPO = txb.cif.ssn.
    end.
    find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then v-chief = txb.sub-cod.rcode.
end.
if txb.cif.geo = '021' then do:
    v-res = 'KZ'.
    v-res2 = '1'.

end.
else do:
    v-res2 = '0'.
    if num-entries(txb.cif.addr[1]) = 7 then do:
         v-country2 = entry(1,cif.addr[1]).
         if num-entries(v-country2,'(') = 2 then v-res = substr(entry(2,v-country2,'('),1,2).
    end.

end.

/**/
