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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        Необходимо прогрузить таблицу aaaperost(Автоматический перевод остатков). Поля cif aaacif1(счет1) aaacif2(счет2) aaacomis(logical) who(UPDT BY) whn(UPDT ON).

*/

def shared var s-cif like cif.cif.
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.

def var v-aaacif1 as char no-undo.
def var v-aaacif2 as char no-undo.
def var v-comis   as logi no-undo.
def var v-cif1    as char no-undo.
def var v-cif2    as char no-undo.
def var v-crc1    as inte no-undo.
def var v-crc2    as inte no-undo.
def var v-sts1    as char no-undo.
def var v-sts2    as char no-undo.
def var v-err     as logi init no.

find cif where cif.cif = s-cif no-lock no-error.

form

    v-aaacif1 label "счет для списания   (Дт)" format "x(20)"
    validate(can-find(aaa where aaa.aaa = v-aaacif1 no-lock), "Такого счета не существует !") skip
    v-aaacif2 label "счет для зачисления (Кт)" format "x(20)"
    validate(can-find(aaa where aaa.aaa = v-aaacif2 no-lock), "Такого счета не существует !") skip

with column 30 row 10 side-label title trim(trim(cif.prefix) + " " + trim(cif.name)) width 70 frame cifostatok.

update v-aaacif1 v-aaacif2 with frame cifostatok.
displ  v-aaacif1 v-aaacif2 with frame cifostatok.

find first aaa where aaa.aaa = v-aaacif1 no-lock no-error.
if avail aaa then do:
    v-cif1 = aaa.cif.
    v-crc1 = aaa.crc.
    v-sts1 = aaa.sta.
end.
find first aaa where aaa.aaa = v-aaacif2 no-lock no-error.
if avail aaa then do:
    v-cif2 = aaa.cif.
    v-crc2 = aaa.crc.
    v-sts2 = aaa.sta.
end.
if v-cif1 <> v-cif2 then do:
    v-err = yes.
    message " Введенные вами счета не принадлежат одному и тому же клиенту " view-as alert-box buttons ok title "Ошибка ! ".
    next.
end.
if v-crc1 <> v-crc2 then do:
    v-err = yes.
    message "Валюта счетов не совпадает ! " view-as alert-box buttons ok title "Ошибка ! ".
    next.
end.
if v-sts1 = "C" then do:
    v-err = yes.
    message "Статус счета для списания(Дт) закрытый ! " view-as alert-box buttons ok title "Ошибка ! ".
    next.
end.
if v-sts2 = "C" then do:
    v-err = yes.
    message "Статус счета для зачисления(Кт) закрытый ! " view-as alert-box buttons ok title "Ошибка ! ".
    next.
end.

if v-err = no then do:
    if v-cif1 = v-cif2 then do:
        find cif where cif.cif = v-cif1 exclusive-lock no-error.
        if avail cif then do:
            cif.crg = "".
        end.
        find cif where cif.cif = v-cif1 no-lock no-error.
    end.
end.

message "Необходимо проакцептовать данные по клиенту до закрытия опер.дня в п.м.1.1.4 !" view-as alert-box buttons ok.

do transaction:
    create aaaperost.
    if v-cif1 = v-cif2 then do:
        aaaperost.cif = v-cif1.
    end.
    aaaperost.aaacif1 = v-aaacif1.
    aaaperost.aaacif2 = v-aaacif2.
    aaaperost.who = g-ofc.
    aaaperost.whn = g-today.
    aaaperost.sts = no.
    aaaperost.getcom = 0.
end.





































