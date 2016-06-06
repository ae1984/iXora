 /* pccrlim.p
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Расчет суммы КЛ от суммы ЗП
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1
 * AUTHOR
        14.05.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        18.06.2013 Lyubov - ТЗ №1896, в письмо сотруднику МОФ после контроля расчитанной суммы добавлено ФИО менеджера-исполнителя
        20.06.2013 Lyubov - Перекомпиляция
        11.09.2013 Lyubov - ТЗ 2066, добавила в выборку из pccstaff0 поиск по CIF
        06.11.2013 evseev - tz1952
*/

{global.i}

def shared var v-aaa      as char no-undo.
def shared var s-credtype as char init '4' no-undo.
def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
run savelog("pccrlim", "32. " + v-aaa  + " | " + s-credtype + " | " + v-bank + " | " + v-cifcod  + " | " + string(s-ln)).
def var v-salary as deci extent 3.
def var v-crlim  as deci extent 3.
def var v-save   as logi extent 3.
def var v-savec  as logi extent 3.
def var v-contr  as logi extent 3.
def var v-date   as date extent 3.
def var v-ofc    as char.
def var v-con    as char.
def var v-maillist as char.
def var v-maillist1 as char.
def var v-zag    as char.
def var v-str    as char.
def var v-reason as char.
def var i        as int.
def var l        as int.
def var chrctr   as char.
def var v-man    as char.

form
skip
v-date[1]   label 'Дата расчета              ' format '99/99/9999' skip
v-salary[1] label 'Размер з/платы            ' format '>>>,>>>,>>9.99' skip
v-crlim[1]  label 'Размер кредитного лимита  ' format '>>>,>>>,>>9.99' skip
v-save[1]   label 'Сохранить                 ' format "Да/Нет" skip
v-contr[1]  label 'Подтвердить               ' format "Да/Нет" skip(1)

v-date[2]   label 'Дата расчета              ' format '99/99/9999' skip
v-salary[2] label 'Размер з/платы-2          ' format '>>>,>>>,>>9.99' skip
v-crlim[2]  label 'Размер кредитного лимита-2' format '>>>,>>>,>>9.99' skip
v-save[2]   label 'Сохранить                 ' format "Да/Нет" skip
v-contr[2]  label 'Подтвердить               ' format "Да/Нет" skip(1)

v-date[3]   label 'Дата расчета              ' format '99/99/9999' skip
v-salary[3] label 'Размер з/платы-3          ' format '>>>,>>>,>>9.99' skip
v-crlim[3]  label 'Размер кредитного лимита-3' format '>>>,>>>,>>9.99' skip
v-save[3]   label 'Сохранить                 ' format "Да/Нет" skip
v-contr[3]  label 'Подтвердить               ' format "Да/Нет" skip
with side-labels centered row 3 title ' Размер заработной платы и расчет кредитного лимита '  width 109 frame flim.

form
v-reason no-label VIEW-AS EDITOR SIZE 68 by 6
with frame fres row 23 overlay centered title " Причина отказа " .

find first codfr where codfr.codfr = 'clmail' and codfr.code = 'dmomail' no-lock no-error.
if not avail codfr then do:
    message 'Нет справочника адресов рассылки' view-as alert-box.
    return.
end.
else do:
    i = 1.
    do i = 1 to num-entries(codfr.name[1],','):
        v-maillist1 = v-maillist1 + entry(i,codfr.name[1],',') + '@fortebank.com,'.
    end.
end.

find first pcstaff0 where pcstaff0.aaa = v-aaa and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
if pcstaff0.salary = 0 then do:
    message 'Не указана сумма заработной платы!' view-as alert-box button Ok title "Внимание!".
    return.
end.
v-salary[1] = pcstaff0.salary.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '4' and pkanketa.aaa = v-aaa no-lock no-error.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'salary' no-lock no-error.
if index(pkanketh.rescha[1],';') = 0 then do:
    v-salary[1] = deci(pkanketh.rescha[1]).

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'credlim' no-lock no-error.
    v-crlim[1] = deci(pkanketh.rescha[1]).
    v-date[1] = g-today.
    displ v-salary[1] v-crlim[1] v-date[1] with frame flim.
end.

else do i = 1 to num-entries(pkanketh.rescha[1],';'):
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'salary' no-lock no-error.
    chrctr = entry(i,pkanketh.rescha[1],';').
    v-salary[i] = deci(chrctr).

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'credlim' no-lock no-error.
    chrctr = entry(i,pkanketh.rescha[1],';').
    v-crlim[i] = deci(chrctr).

    if i = num-entries(pkanketh.rescha[1],';') then v-date[i] = g-today.
    else do:
        /*chrctr = entry(i,pkanketh.rescha[2],';').
        v-date[i] = date(int(substr(chrctr,3,2)),int(substr(chrctr,1,2)),int(substr(chrctr,5))).*/
    end.
    if v-crlim[i] <> 0 then l = i + 1.

    displ v-salary[i] v-crlim[i] v-date[i] with frame flim.
end.

pause.

find first sysc where sysc.sysc = 'pcacpt' no-lock no-error.
if not avail sysc then do:
    message 'Не найден список менеджеров. Обратитесь в ДИТ' view-as alert-box button Ok title "Внимание!".
    return.
end.
v-ofc = sysc.chval.
find first sysc where sysc.sysc = 'pcctrl' no-lock no-error.
if not avail sysc then do:
    message 'Не найден список контролеров. Обратитесь в ДИТ.' view-as alert-box button Ok title "Внимание!".
    return.
end.
v-con = sysc.chval.

message "Установить/изменить размер заработной платы или размер кредитного лимита?" view-as alert-box question buttons yes-no title "" update v-ans as logical.
if v-ans then do:

    /*для менеджеров ОО*/
    if can-do(v-ofc,g-ofc) then do:

        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'salary' no-lock no-error.
        i = num-entries(pkanketh.rescha[1],';').
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'credlim' no-lock no-error.
        if pkanketa.summa = deci(pkanketh.value1) then do:
            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'salary' no-lock no-error.
            if pkanketa.sumq = deci(pkanketh.value1) then i = i + 1.
        end.
        if i <> 1 then update v-salary[i] with frame flim.
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'credlim' no-lock no-error.
        if num-entries(pkanketh.rescha[1],';') = i then v-crlim[i] = deci(entry(num-entries(pkanketh.rescha[1],';'),pkanketh.rescha[1],';')).
        else v-crlim[i] = v-salary[i] * 1.2.
        displ v-salary[i] v-crlim[1] with frame flim.
        update v-crlim[i] with frame flim.
        if v-crlim[i] > (v-salary[i] * 1.2) then do:
            message ' Сумма кредитного лимита не должна превышать 120% от суммы заработной платы! ' view-as alert-box button Ok title "Внимание!".
            v-crlim[i] = v-salary[i] * 1.2.
        end.
        if v-crlim[i] > 1500000 then do:
            v-crlim[i] = 1500000.
            message ' Максимальная сумма кредитного лимита 1,500,000! ' view-as alert-box button Ok title "Внимание!".
        end.
        displ v-salary[i] v-crlim[1] with frame flim.
        update v-save[i] with frame flim.
        if v-save[i] then do:
            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'salary' no-lock no-error.
            if avail pkanketh then do:
                if num-entries(pkanketh.rescha[1],';') <> i then do:
                    find current pkanketh exclusive-lock no-error.
                    assign pkanketh.rdt      = g-today
                           pkanketh.rwho     = g-ofc
                           pkanketh.value1   = string(v-salary[i]).
                           pkanketh.rescha[1] = pkanketh.rescha[1] + ';' + string(v-salary[i]).
                    find current pkanketh no-lock no-error.
                end.
                else if entry(i,pkanketh.rescha[1],';') <> string(v-salary[i]) then do:
                    find current pkanketh exclusive-lock no-error.
                    assign pkanketh.rdt      = g-today
                           pkanketh.rwho     = g-ofc
                           pkanketh.value1   = string(v-salary[i]).
                           pkanketh.rescha[1] = substr(pkanketh.rescha[1],1,r-index(pkanketh.rescha[1],';')) + string(v-salary[i]).
                    find current pkanketh no-lock no-error.
                end.
            end.
            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'credlim' no-lock no-error.
            if avail pkanketh then do:
                if num-entries(pkanketh.rescha[1],';') <> i then do:
                    find current pkanketh exclusive-lock no-error.
                    assign pkanketh.rdt      = g-today
                           pkanketh.rwho     = g-ofc
                           pkanketh.value1   = string(v-crlim[i]).
                           pkanketh.rescha[1] = pkanketh.rescha[1] + ';' + string(v-crlim[i]).
                    find current pkanketh no-lock no-error.
                end.
                else if entry(i,pkanketh.rescha[1],';') <> string(v-crlim[i]) then do:
                    find current pkanketh exclusive-lock no-error.
                    assign pkanketh.rdt      = g-today
                           pkanketh.rwho     = g-ofc
                           pkanketh.value1   = string(v-crlim[i]).
                           pkanketh.rescha[1] = substr(pkanketh.rescha[1],1,r-index(pkanketh.rescha[1],';')) + string(v-crlim[i]).
                    find current pkanketh no-lock no-error.
                end.
            end.

            find current pkanketa exclusive-lock no-error.
                pkanketa.rdt      = g-today.
                pkanketa.rwho     = g-ofc.
            find current pkanketa no-lock no-error.
            message "Отправить запрос в КБ и ГЦВП?" view-as alert-box question buttons yes-no title "" update v-ans1 as logical.
            if v-ans1 then do:
               run savelog("pccrlim", "216. " + v-aaa  + " | " + s-credtype + " | " + v-bank + " | " + v-cifcod  + " | " + string(s-ln)).
               run pcgcvp_send.
               run savelog("pccrlim", "218. ").
               /*ПКБ*/
                /*find first pkanketa where pkanketa.aaa = v-aaa and pkanketa.credtype = s-credtype no-lock no-error.*/
                if not avail pkanketa then do:
                   message "Анкета не найдена!" view-as alert-box question buttons ok.
                   return.
                end.
                find first cif where cif.cif = pkanketa.cif no-lock no-error.
                if avail cif then do:
                   def var fcb_id as int  no-undo.
                   def var v-day  as int  no-undo.
                   def var v-count as int no-undo.
                   def var v-code as char no-undo.

                   run savelog("pccrlim", "232. (" + trim(cif.bin) + ")").
                   run 1CB_RequestReport(input trim(cif.bin), input s-credtype, output fcb_id).
                   run 1CB_getOverdue(input fcb_id, output v-day, output v-count).
                   run credcontract(input fcb_id).
                   run savelog("pccrlim", "236. (" + trim(cif.bin) + ") " + string(fcb_id) + " " + string(v-day) + " " + string(v-count)).
                   if v-day >=0 and v-day <=14 and v-count <= 3   then  v-code = "100".
                   if v-day >=1 and v-day <=14 and v-count > 3 then  v-code = "110".
                   if v-day >=15 and v-day <=19  then  v-code = "120".
                   if v-day >=20 and v-day <=24  then  v-code = "130".
                   if v-day >=25 and v-day <=30  then  v-code = "140".
                   if v-day >=31                 then  v-code = "150".

                   find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype
                        and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "credhistbvuauto123" exclusive-lock no-error.

                   if not avail pkanketh then create pkanketh.
                   pkanketh.bank = pkanketa.bank.
                   pkanketh.credtype = s-credtype.
                   pkanketh.ln = pkanketa.ln.
                   pkanketh.kritcod = "credhistbvuauto123".
                   pkanketh.value1 = v-code.
                   pkanketh.rescha[1] = string(v-day).
                   pkanketh.rescha[2] = string(v-count).
                end. else do:
                   message "Клиент не найден!" view-as alert-box question buttons ok.
                   return.
                end.
               /*******/
               /*run pcgcvp.*/
            end.

            find first codfr where codfr.codfr = 'clmail' and codfr.code = 'conmail' no-lock no-error.
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

            v-zag = 'Контроль кредитного лимита'.
            v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16-2-1-1 'Стандартный процесс' - п.в.м. 'Расчет ЗП/Расчет КЛ'. Клиент: "
                  + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                  + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today) + ', ' + string(time,'hh:mm:ss')
                  + ". Бизнес-процесс: Установление кредитного лимита.".
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
            l = l + 1.
        end.
        else return.
    end.

    /*для контролеров*/
    if can-do (v-con,g-ofc) then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'credlim' no-lock no-error.
        if pkanketa.summa = deci(pkanketh.value1) then do:
            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'salary' no-lock no-error.
            if pkanketa.sumq = deci(pkanketh.value1) then do:
                message ' Нет данных на контроль! ' view-as alert-box button Ok title "Внимание!".
                return.
            end.
        end.
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

        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'salary' no-lock no-error.
        i = num-entries(pkanketh.rescha[1],';').
        update v-contr[i] with frame flim.
        if not v-contr[i] then do:
            update v-reason validate (trim(v-reason) <> '', " Введите замечания по анкете ")
            help "Введите данные (F1 - сохранение, F4 - отмена)" view-as editor size 70 by 10 " "
            skip(1) with no-labels title " Замечания менеджера по анкете " row 5 centered overlay frame fres.
            hide frame fres.

            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'reasncon' no-lock no-error.
            if not avail pkanketh then do:
                create pkanketh.
                assign pkanketh.bank     = v-bank
                       pkanketh.cif      = v-cifcod
                       pkanketh.credtype = '4'
                       pkanketh.ln       = pkanketa.ln
                       pkanketh.kritcod  = 'reasncon'
                       pkanketh.value1   = v-reason
                       pkanketh.rdt      = g-today
                       pkanketh.rwho     = g-ofc.
            end.
            else do:
                find current pkanketh exclusive-lock no-error.
                assign pkanketh.value1 = pkanketh.value1 + ';' + v-reason
                       pkanketh.rdt    = g-today
                       pkanketh.rwho   = g-ofc.
                find current pkanketh no-lock no-error.
            end.
            v-zag = 'ЗАЯВКА БЕЗ АКЦЕПТА'.
            v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16-2-1-1 'Стандартный процесс' - п.в.м. 'Расчет ЗП/Расчет КЛ'. Клиент: "
                  + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                  + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". По причине: " + v-reason + ". Дата поступления задачи: " + string(today)
                  + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита.".
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
        end.
        else do:
            v-zag = 'Подтверждение кредитного лимита'.
            v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16.2.1.1. 'Стандартный процесс' - п.в.м. 'Размер ЗП/Расчет КЛ'. Клиент: "
                  + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                  + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                  + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита." + v-man.
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").

            find first ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
            v-man = ofc.name.

            v-zag = 'Подтверждение кредитного лимита'.
            v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16.2.1.1. 'Отчет ГЦВП и КБ'. Клиент: "
                  + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                  + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                  + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита. Менеджер проекта: " + v-man.
            run mail(v-maillist1,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").

            find first pkanketa where pkanketa.aaa = v-aaa and pkanketa.credtype = '4' exclusive-lock no-error.
            pkanketa.summa = v-crlim[i].
            pkanketa.sumq  = v-salary[i].
            pkanketa.sts   = '18'.
            find current pkanketa no-lock.
        end.
    end.
end.
else pause.