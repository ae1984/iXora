/* pcconcr.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Контроль кредита
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1-1
 * AUTHOR
        22.06.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
*/

{global.i}

def shared var v-aaa      as char no-undo.
def shared var v-bank     as char no-undo.

def var v-text  as char no-undo init ' Задолженность по состоянию на' .
def var v-text1 as char no-undo init 'г. отсутствует ' .
def var v-date  as date no-undo init today.
def var v-save  as logi no-undo.

def var v-maillist as char.
def var v-zag      as char.
def var v-str      as char.
def var i as int.

hide all.

find first codfr where codfr.codfr = 'clmail' and codfr.code = 'dpcmail' no-lock no-error.
if not avail codfr then do:
    message 'Нет справочника адресов рассылки' view-as alert-box.
    return.
end.
else do:
    i = 1.
    do i = 1 to num-entries(codfr.name[1],','):
        v-maillist = v-maillist + entry(i,codfr.name[1],',') + '@fortebank.com,'.
    end.
end.
form
    v-text  no-label format 'x(30)'
    v-date  no-label format "99.99.9999"
    v-text1 no-label format 'x(30)' skip(1)
    v-save  label " Подтвердить   " format "Да/Нет" skip
    with side-label row 4 title ' Контроль ' width 100 frame fank.

find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.aaa = v-aaa no-lock no-error.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '4' and pkanketa.aaa = v-aaa no-lock no-error.
if pkanketa.cwho <> '' and pkanketa.cdt <> ? then do:
    message ' Кредит уже отконтролирован! ' view-as alert-box.
    return.
end.

displ v-text v-text1 with frame fank.
update v-date v-save with frame fank.
displ v-date v-save with frame fank.

if v-save then do:
    v-zag = 'Закрытие кредитного лимита'.
    v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16.2.1.1. 'Контроль ДПК' Клиент: " + pcstaff0.cif + ", "
          + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: " + pcstaff0.iin
          + ". Дата поступления задачи: " + string(today) + ', ' + string(time,'hh:mm:ss')
          + ". Бизнес-процесс: Закрытие кредитного лимита".
    run mail2(trim(v-maillist,','),"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").

    find current pkanketa exclusive-lock no-error.
    pkanketa.sts = '130'.
    pkanketa.cwho = g-ofc.
    pkanketa.cdt = today.
    find current pkanketa no-lock no-error.
end.
