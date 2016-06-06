/* pcconfin.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Контроль ДПК
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
        25.06.2013 Lyubov - перекомпиляция
*/

{global.i}

def shared var v-aaa      as char no-undo.
def shared var v-bank     as char no-undo.

def var v-text  as char no-undo init ' Задолженность по состоянию на' .
def var v-text1 as char no-undo init 'г. отсутствует ' .
def var v-date  as date no-undo init today.
def var v-save  as logi no-undo.
def var v-comment  as char extent 2.
def var v-sum as deci.
def var v-maillist as char.
def var v-zag      as char.
def var v-str      as char.
def var i as int.

hide all.

find first codfr where codfr.codfr = 'clmail' and codfr.code = 'oomail' no-lock no-error.
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
    v-save  label " Подтвердить   " format "Да/Нет" skip
    with side-label row 4 title ' Закрытие кредитного лимита ' width 100 frame fank.

form
     v-comment[1] no-label format 'x(25)'
     v-sum no-label format '>>>,>>>,>>>,>>9.99'
     v-comment[2] no-label format 'x(60)'
     with frame comment row 10 width 110 overlay title "Комментарий" .

find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.aaa = v-aaa no-lock no-error.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '4' and pkanketa.aaa = v-aaa no-lock no-error.
if pkanketa.sts = '99' then do:
    message ' Кредит уже закрыт! ' view-as alert-box.
    return.
end.
else if pkanketa.sts <> '130' then do:
    message ' Не проставлен контроль кредита! ' view-as alert-box.
    return.
end.
else do:
    update v-save with frame fank.
    if v-save then do:
        v-zag = 'Закрытие кредитного лимита'.
        v-str = "Здравствуйте! Клиенту: " + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
              + pcstaff0.iin + " закрыт кредитный лимит! Дата поступления задачи: " + string(today)
              + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Закрытие кредитного лимита".
        run mail2(trim(v-maillist,','),"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").

        find current pkanketa exclusive-lock no-error.
        pkanketa.sts = '99'.
        pkanketa.cwho = g-ofc.
        pkanketa.cdt = today.
        find current pkanketa no-lock no-error.
    end.
    else do:
        v-comment[1] = 'Задолженность составляет: '.
        v-comment[2] = 'тенге'.
        displ v-comment[1] v-sum v-comment[2] with frame comment.
        update v-sum v-comment[2] with frame comment.
        hide frame comment.
        v-zag = 'Закрытие кредитного лимита'.
        v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16.2.1.1. 'Контроль Кредита'. " + v-comment[1] + ' ' + string(v-sum)
              + ' ' + v-comment[2] + ". Клиент: " + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname
              + ", ИИН: " + pcstaff0.iin + ". Дата поступления задачи: " + string(today)
              + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Закрытие кредитного лимита".
        run mail2(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
    end.
end.
hide all.