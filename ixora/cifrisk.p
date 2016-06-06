/* cifrisk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        проставление уровня риска клиента
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
        01/11/2013 galina ТЗ1442
 * BASES
        BANK
 * CHANGES
*/

{global.i}
def shared var s-cif   like cif.cif.
def var v-title as char.
def var v-riskcode as int.
def var v-riskname as char.

def var v-risknote1 as char.
def var v-risknote2 as char.
def var v-risknote3 as char.
def var v-risknote4 as char.
def var v-risknote5 as char.
def var v-save as logi.
def var v-sel as int.
def var v-sellist as char.
v-sellist = ' Низкий | Средний | Высокий'.
def frame frisk
v-riskcode format '>9' label 'Код риска' validate(v-riskcode > 0 and v-riskcode < 4, 'Значение должно быть от 1 до 3') help 'F2  - Справочник'  v-riskname format "x(20)"  no-label
v-risknote1  label 'Примечание' format "x(68)" skip
v-risknote2 label 'Примечание' format "x(68)" skip
v-risknote3 label 'Примечание' format "x(68)" skip
v-risknote4 label 'Примечание' format "x(68)" skip
v-risknote5 label 'Примечание' format "x(68)" skip (2)
v-save label 'Сохранить изменения?' format 'Yes/No'
with side-label column 2 row 8 centered overlay  title v-title width 90.

on help of v-riskcode in frame frisk do:
    v-sel = 0.
    run sel2 ("ВЫБЕРИТЕ КОД РИСКА :",v-sellist, output v-sel).
    if v-sel > 0 then do:
        v-riskcode = v-sel.
        v-riskname = entry(v-riskcode,v-sellist,'|').
    end.
    display v-riskcode v-riskname with frame frisk.
end.

v-title = ''.
v-save = yes.

find first cif where cif.cif = s-cif no-lock no-error.
if not avail cif then do:
    message 'Не найден клиент' view-as alert-box.
    return.
end.
v-title = 'КЛИЕНТ: ' + cif.cif + ' ' + cif.prefix + ' ' + cif.name.

find first cifrsk where cifrsk.cif = s-cif no-lock no-error.
if avail cifrsk then do:
    assign v-riskcode = cifrsk.risk
           v-riskname = entry(v-riskcode,v-sellist,'|').
    if trim(cifrsk.note) <> '' then do:
        v-risknote1 = substr(cifrsk.note,1,68).
        if length(trim(cifrsk.note)) > 69 then v-risknote2 = substr(cifrsk.note,69,68).
        if length(trim(cifrsk.note)) > 137 then v-risknote3 = substr(cifrsk.note,138,68).
        if length(trim(cifrsk.note)) > 206 then v-risknote4 = substr(cifrsk.note,207,68).
        if length(trim(cifrsk.note)) > 275 then v-risknote4 = substr(cifrsk.note,276,68).
    end.
end.
display v-riskcode v-riskname v-risknote1 v-risknote2 v-risknote3 v-risknote4 v-risknote5 v-save with frame frisk.
update v-riskcode with frame frisk.
v-riskname = entry(v-riskcode,v-sellist,'|').
display v-riskname with frame frisk.
update v-risknote1 v-risknote2 v-risknote3 v-risknote4 v-risknote5 v-save with frame frisk.
if v-save then do:
    find first cifrsk where cifrsk.cif = s-cif no-lock no-error.
    if not avail cifrsk then do:
        create cifrsk.
        cifrsk.cif = s-cif.
    end.
    else find current cifrsk exclusive-lock no-error.
    cifrsk.risk = v-riskcode.
    cifrsk.who = g-ofc.
    cifrsk.whn = g-today.
    if trim(v-risknote1) <> '' then cifrsk.note = trim(v-risknote1) + ' '.
    if trim(v-risknote2) <> '' then cifrsk.note = trim(cifrsk.note) + trim(v-risknote2) + ' '.
    if trim(v-risknote3) <> '' then cifrsk.note = trim(cifrsk.note) + trim(v-risknote3) + ' '.
    if trim(v-risknote4) <> '' then cifrsk.note = trim(cifrsk.note) + trim(v-risknote4) + ' '.
    if trim(v-risknote5) <> '' then cifrsk.note = trim(cifrsk.note) + trim(v-risknote5).
    find current cifrsk no-lock no-error.
    message 'Данные сохранены' view-as alert-box title "ВНИМАНИЕ".
    hide frame frisk no-pause.
end.
