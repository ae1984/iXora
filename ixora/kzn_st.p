/* kzn_st.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK
 * AUTHOR
        30/06/04 dpuchkov
 * CHANGES
        29/07/04 перекомпиляция
        07.01.05 поправил поиск по департаментам по клавише F2
        22/08/08 marinav увеличила формат суммы
        30.01.2009 id00209 - нумерация распоряжений
        24/03/2009 madiyar - подправил нумерацию распоряжений
        26/03/2009 madiyar - сделал рассылку
        27/03/2009 madiyar - тема сообщения с указанием, что это льготные курсы
        22/04/2009 madiyar - рассылка делается на список пользователей из справочника ofcsend
        23/04/2009 madiyar - вернул рассылку, как было; добавил в рассылку свой адрес для отслеживания проблем
        06/08/2009 madiyar - добавил в рассылку еще один адрес
        09/09/2009 madiyar - подпись, копирование в реестр по обменным операциям
        15/09/2009 madiyar - добавил/убрал логины в рассылке
        22/10/2009 madiyar - изменения по тексту распоряжения
        09/11/2009 madiyar - изменения в формате текста распоряжения
        20/01/2010 galina - исключила id00086 и id00447, добавила id00504 и id00498
        12/05/2010 madiyar - в теме сообщения указываем наименование филиала
        12/11/2010 id00477 - изменил "Главный специалист Генеральной бухгалтерии" на "Директор департамента казначейства"
        27/01/2011 madiyar - изменил список рассылки
        25.03.2011 aigul - добавила статус льготного курса, оправку уведомления в ДК, вормирование распоряжения при согласовании с ДК
        20.04.2011 aigul - изменила fr1
        21.04.2011 aigul -  вывод подписи директора
        25.04.2011 aigul - внесла в рассылку глав бухов, отменила редакцию сумму и курса
        28.04.2011 aigul - изменила транзакции при формировании распоряжений
        03.05.2011 aigul - удаление только при статусе введен, при другом статусе удаление разрешено только для ДК
        10.05.2011 aigul - предлагать отправить форму сразу же после ее создания
        12.05.2011 aigul - разрещить редактирование для опред. ситуаций и людей
        13.05.2011 aigul - изменила email
        23/06/2011 madiyar - изменил список рассылки
        08/05/2012 evseev - rebranding
        13.09.2012 Lyubov - список адресов кассиров в рассылке заменила на группу
        17.07.2013 dmitriy - ТЗ 1929
*/

def var str_p as char.
def var v-numobm as char no-undo.
def var choice as logical initial no.
def var v-choice as logical initial no.
define frame getlist1
   crclg.crcpok label "Курс покупки" format '>>>,>>>,>>9.999' skip
   crclg.crcprod label "Курс продажи" format '>>>,>>>,>>9.999' skip
   crclg.name label "Клиент" skip
   crclg.sum label "Сумма" format '>>>,>>>,>>9.999' skip
   crclg.dateb label "Дата действия"  skip
   crclg.lock label "Блокировать" skip
   crclg.dep label "СПФ" skip
   crclg.whn label "Дата"   skip
   crclg.crcpr label "Валюта" format '99' skip
   with side-labels centered row 10.


function month-des returns char (num as date):
   case month(num):
       when  1 then return "января".
       when  2 then return "февраля".
       when  3 then return "марта".
       when  4 then return "апреля".
       when  5 then return "мая".
       when  6 then return "июня".
       when  7 then return "июля".
       when  8 then return "августа".
       when  9 then return "сентября".
       when 10 then return "октября".
       when 11 then return "ноября".
       when 12 then return "декабря".
   end case.
end function.

on help of crclg.dep in frame getlist1 do:
    def var i as integer init 0.
    i = 0.
    str_p = "".
    for each ppoint no-lock by ppoint.depart:
        str_p = str_p + string (ppoint.depart) + ". " + ppoint.name + "|".
    end.
    str_p = SUBSTR (str_p, 1, LENGTH(str_p) - 1).

    run sel ("Выберите департамент", str_p).

    for each ppoint no-lock by ppoint.depart:
        i = i + 1.
        if i = int(return-value) then do:
            crclg.dep = ppoint.depart.
            leave.
        end.
    end.
/*  crclg.dep = int(return-value). */
    display crclg.dep with frame getlist1.
end.

on help of crclg.crcpr in frame getlist1 do:
/*  run help-crc1.
    crclg.crcpr = int(frame-value).
    display crclg.crcpr with frame getlist1. */
end.

{yes-no.i}
{global.i}

def shared var v-crclgt as decimal.

def var filelg as char.
def var ch_crcName as char.
def var s-tempfolder as char.
def var v-crcpok like crclg.crcpok.
def var v-crcprod like crclg.crcprod.
def var v-crctxt like crclg.crctxt.
def var v-name like crclg.name.
def var v-sum like crclg.sum.
def var v-whn like crclg.whn.

define query q1 for crclg.
define buffer buf for crclg.

def browse b1 query q1 displ
    crclg.crcpok label "Курс пок." format '>>9.999'
    crclg.crcprod label "Курс прод." format '>>9.999'
    crclg.name label "Клиент" format 'x(12)'
    crclg.sum label "Сумма" format '>>>,>>>,>>9.999'
/*  crclg.dateb label "Срок дейст."  */
    crclg.lock label "Блокир."
    crclg.dep  label "СПФ:" format '99'
    crclg.crctxt label "Валюта"
    crclg.sts label "Статус" format 'x(20)'
with 7 down title "Льготные курсы обмена." overlay.

define button ball label "Все".
define button bv label "Введен".
define button bs label "Соглас".
define button ba label "Аннулир".
define button bg label "Заверш".
define button bedt label "См.\Изм.".
define button bnew label "Создать".
define button bdel label "Удал.".
define button buv label "Отправить уведомление в ДК".
define button brasp label "Сформирорвать распоряжение".
define button bext label "Выход".


def frame fr1 b1 skip
     bnew bedt bdel buv brasp bext
     "              "
     ball bv bs ba bg
with width 99  COLUMN 1 no-label  row 5 /*centered overlay row 5 top-only*/ NO-BOX.


on choose of bext in frame fr1 do:
    hide frame getlist1.
    apply "WINDOW-CLOSE" to browse b1.
end.

on choose of bdel in frame fr1 do:
    if crclg.sts = "Введен" then do:
        /*if yes-no ("Внимание!", "Вы действительно хотите удалить запись?") then do:*/
        choice = no.
        message "Внимание!" skip
        "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE "" UPDATE choice AS LOGICAL.
        if choice then do:
            find buf where rowid (buf) = rowid (crclg) exclusive-lock.
            delete buf.
            close query q1.
            open query q1 for each crclg.
            browse b1:refresh().
        end.
    end.
    else do:
        find first ofcsend where ofcsend.ofc = g-ofc and ofcsend.typ = "kzn_st" no-lock no-error.
        if avail ofcsend then do:
            v-choice = no.
            message "Внимание!" skip
            "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "" UPDATE v-choice AS LOGICAL.
            if v-choice then do:
                find buf where rowid (buf) = rowid (crclg) exclusive-lock.
                delete buf.
                close query q1.
                open query q1 for each crclg.
                browse b1:refresh().
            end.
        end.
        else do:
            message "Для удаления записи обратитесь в ДК" view-as alert-box.
            return.
        end.
    end.
end.

on choose of bedt in frame fr1 do:
    find first ofcsend where ofcsend.ofc = g-ofc and ofcsend.typ = "kzn_st" no-lock no-error.
    if avail ofcsend then do:
    /*if (g-ofc = "id00820" or g-ofc = "id00776" or g-ofc = "id00876") then do:*/
           do transaction:
                find buf where rowid (crclg) = rowid (buf) exclusive-lock.
                displ crclg.crcpok crclg.crcprod crclg.name crclg.sum crclg.dateb crclg.lock crclg.dep crclg.whn crclg.crcpr with frame getlist1.
                update crclg.name crclg.dateb crclg.lock crclg.dep crclg.whn crclg.crcpr with frame getlist1.
                if crclg.crcpr = 1 then crclg.crctxt = "KZT". else
                if crclg.crcpr = 2 then crclg.crctxt = "USD". else
                if crclg.crcpr = 4 then crclg.crctxt = "RUR". else
                if crclg.crcpr = 3 then crclg.crctxt = "EUR". else
                    crclg.crctxt = "".
                choice = no.
                message "Подтвердить курс покупки/продажи?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-CANCEL
                TITLE "" UPDATE choice AS LOGICAL.
                /*if choice then crclg.sts = "Согласован ДК".
                else crclg.sts = "Аннулирован ДК".*/
                CASE choice:
                     WHEN TRUE THEN /* Yes */ crclg.sts = "Согласован ДК".
                     WHEN FALSE THEN /* No */ crclg.sts = "Аннулирован ДК".
                     OTHERWISE /* Cancel */ leave.
                END CASE.
            end.
            close query q1.
            open query q1 for each crclg.
            browse b1:refresh().
    end.
    if crclg.sts = "Введен" then do:
        do transaction:
            find buf where rowid (crclg) = rowid (buf) exclusive-lock.
            displ crclg.crcpok crclg.crcprod crclg.name crclg.sum crclg.dateb crclg.lock crclg.dep crclg.whn crclg.crcpr with frame getlist1.
            update crclg.name crclg.dateb with frame getlist1.
            /*if (g-ofc = "id00820" or g-ofc = "id00776" or g-ofc = "id00876")*/
            find first ofcsend where ofcsend.ofc = g-ofc and ofcsend.typ = "kzn_st" no-lock no-error.
            if avail ofcsend then update crclg.lock with frame getlist1.
            update crclg.dep crclg.whn crclg.crcpr with frame getlist1.
            if crclg.crcpr = 1 then crclg.crctxt = "KZT". else
            if crclg.crcpr = 2 then crclg.crctxt = "USD". else
            if crclg.crcpr = 4 then crclg.crctxt = "RUR". else
            if crclg.crcpr = 3 then crclg.crctxt = "EUR". else
                crclg.crctxt = "".
        end.
        close query q1.
        open query q1 for each crclg.
        browse b1:refresh().
    end.
end.


on choose of bnew in frame fr1 do:
    do transaction:
        create crclg.
        crclg.whn = g-today.
        crclg.dateb = g-today.
        update crclg.crcpok  crclg.crcprod
        crclg.name crclg.sum  crclg.dateb crclg.lock crclg.dep crclg.whn crclg.crcpr with frame getlist1.
        v-crcpok = crclg.crcpok.
        v-crcprod = crclg.crcprod.
        v-name = crclg.name.
        v-sum = crclg.sum.
        v-whn = crclg.whn.
        crclg.sts = "Введен".
        crclg.whn = g-today.
        if g-today > today then crclg.tim = 60 .
                     else crclg.tim = time .
        if g-today < today then crclg.tim = 99999 .
        if crclg.crcpr = 1 then crclg.crctxt = "KZT". else
        if crclg.crcpr = 2 then crclg.crctxt = "USD". else
        if crclg.crcpr = 4 then crclg.crctxt = "RUR". else
        if crclg.crcpr = 3 then crclg.crctxt = "EUR". else
           crclg.crctxt = "НЕ ЗАДАНО".
        v-crctxt = crclg.crctxt.
    end.
    v-choice = no.
    message "Внимание!" skip
    "Отправить уведомление в ДК?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "" UPDATE v-choice AS LOGICAL.
    if v-choice then do:
        for each ofcsend where ofcsend.typ = "kzn_st" no-lock:
            find buf where rowid (crclg) = rowid (buf) no-lock no-error.
            if avail buf then do:
                run mail (ofcsend.ofc + "@metrocombank.kz",
                   "METROKOMBANK <abpk@metrocombank.kz>",
                   "Льготные курсы валют, " + cmp.name,
                   cmp.name +
                   "\n Курс покупки: " + string(buf.crcpok) +
                   "\n Курс продажи: " + string(buf.crcprod) +
                   "\n Клиент: " + buf.name +
                   "\n Сумма: " + string(buf.sum) +
                   "\n Дата: " +  string(buf.whn) +
                   "\n Валюта: " + buf.crctxt, "1", "", "").
            end.
        end.
        message "Уведомление отправлено успешно!" view-as alert-box.
    end.
    close query q1.
    open query q1 for each crclg.
    browse b1:refresh().
end.
on choose of bv in frame fr1 do:
    open query q1 for each crclg where crclg.sts = "Введен".
end.
on choose of bs in frame fr1 do:
    open query q1 for each crclg where crclg.sts = "Согласован ДК".
end.
on choose of ba in frame fr1 do:
    open query q1 for each crclg where crclg.sts = "Аннулирован ДК".
end.
on choose of bg in frame fr1 do:
    open query q1 for each crclg where crclg.sts = "V".
end.
on choose of ball in frame fr1 do:
    open query q1 for each crclg.
    browse b1:refresh().
end.
find first cmp no-lock no-error.
on choose of buv in frame fr1 do:
    find buf where rowid (crclg) = rowid (buf) no-lock no-error.
    if avail buf then do:
        for each ofcsend where ofcsend.typ = "kzn_st" no-lock:
            run mail (ofcsend.ofc + "@metrocombank.kz",
               "METROKOMBANK <abpk@metrocombank.kz>",
               "Льготные курсы валют, " + cmp.name,
               cmp.name +
               "\n Курс покупки: " + string(buf.crcpok) +
               "\n Курс продажи: " + string(buf.crcprod) +
               "\n Клиент: " + buf.name +
               "\n Сумма: " + string(buf.sum) +
               "\n Дата: " +  string(buf.whn) +
               "\n Валюта: " + buf.crctxt, "1", "", "").
        end.
        message "Уведомление отправлено успешно!" view-as alert-box.
    end.
end.

on choose of brasp in frame fr1 do:

    find buf where rowid (crclg) = rowid (buf) no-lock no-error.
    if avail buf then do:
        if buf.sts <> "Согласован ДК" and buf.sts <> "V" /*crclg.sts = "Введен" or crclg.sts = "Аннулирован ДК"*/ then do:
            message "Курс не согласован с Департаментом Казначейства! " view-as alert-box.
            leave.
        end.
        if buf.sts = "V" then do:
            message "Распоряжение уже было сформировано!"  view-as alert-box.
            leave.
        end.
        If buf.sts = "Согласован ДК" then do:
            /*номер распоряжения*/
            do transaction:
                find first sysc where sysc.sysc = 'numobm' exclusive-lock no-error.
                if not avail sysc then do:
                    create sysc.
                    assign sysc.sysc = "numobm" sysc.inval = 0 sysc.deval = 0 sysc.des = "номер распоряжения по обменному пункту" sysc.daval = g-today.
                end.
                sysc.deval = sysc.deval + 1.
                if sysc.deval ne 0 then v-numobm = string(sysc.inval) + "/" + string(sysc.deval).
                else v-numobm = string(sysc.inval).
                if sysc.chval ne "" then sysc.chval = sysc.chval + ",".
                sysc.chval = sysc.chval + v-numobm.

                find current sysc no-lock.

                for each exch_lst exclusive-lock:
                    exch_lst.numr = sysc.chval.
                end.
                find crclg where rowid (crclg) = rowid (buf) exclusive-lock.
                crclg.sts = "V".
                crclg.order = v-numobm.
                find crclg where rowid (crclg) = rowid (buf) no-lock.
            end.
            /*печать распоряжения*/
            input through localtemp.
            repeat:
                import s-tempfolder.
            end.
            if substr(s-tempfolder, length(s-tempfolder), 1) <> "\\" then s-tempfolder = s-tempfolder + "\\".
            filelg = "Kurslg.html".
            output to value(filelg).
            put unformatted
                "<HTML>" skip
                "<HEAD>" skip
                "<TITLE>" skip.
            put unformatted
                'Распоряжение по обменному пункту' skip.
            put unformatted
                "</TITLE>" skip
                "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
                "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
                "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size:14.0pt;" skip.
            put unformatted
                "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
                "</HEAD>" skip
                "<BODY>" skip
                "<P align=""center"" style=""font:bold;font-size:14.0pt""> F o r t e B a n k  </P>" skip
                "<P align=""center"" style=""font:bold;font-size:12.0pt"">" cmp.name " </P>" skip
                "<P align=""right""  style=""font:bold;font-size:small""> " day(g-today) " " month-des(g-today) " " year(g-today) " г.  </P>" skip
                "<P align=""center"" style=""font:bold;font-size:small"">  <u><span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier            New;mso-bidi-font-family:Times New Roman"">Р А С П О Р Я Ж Е Н И Е	N " + v-numobm + "</span></u></b></p>" skip
                "<P align=""center"" style=""font:bold;font-size:small"">  <span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman"">ПО ОБМЕННОМУ ПУНКТУ </span></b></p>" skip
                "<P align=""center"" style=""font:bold;font-size:14.0pt;mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman"">Установить следующие льготные курсы покупки и" skip
                "продажи наличных валют на совершение разовой обменной операции</p>" skip.
            put unformatted
                "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""70%"">" skip
                "<TR align=""center"" style=""font:bold;background:white "">"  skip.
            put unformatted
                "<td> <p> </p></td>" skip
                "<td align=""center""> <p><u><span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman""> Покупка </span></u></p></td>" skip
                "<td align=""center""> <p><u><span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman""> Продажа </span></u></p></td>" skip
                "<td align=""center""> <p><u><span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman""> Время </span></u></p></td>" skip
                "</TR>" skip
                "<tr>" skip.
            put unformatted "<td height=24>" + buf.crctxt + "</td>" skip.
            put unformatted "<td>" + string(buf.crcpok) + "</td>" skip
                "<td>" + string(buf.crcprod) + "</td>" skip
                "<td>" + string(time, "HH:MM:SS") + "</td>" skip
                "</tr>" skip.
            put unformatted
                "</table>" skip(3).
            put unformatted
                "<table cellpadding=0 cellspacing=0 align=left>" skip
                    "<tr>" skip
                        "<td width=25 height=36></td>" skip
                    "</tr>" skip
                    "<tr>" skip
                        "<td width=50></td>" skip
                        /*		12/11/2010 id00477 - изменил "Главный специалист Генеральной бухгалтерии" на "Директор департамента казначейства" */
                        /*25.03.2011 aigul - изменилa "Директор департамента казначейства" на "Директор Филиала"*/
                        "<td width=213  valign=""bottom"" ><p align=""left"" style=""font:bold;font-size:small;"">   Директор Филиала </p></td>" skip
                        "<td>               </td>" skip
                        "<td><IMG border=""0"" src=""" s-tempfolder "pkdogsgn.jpg"" width=""180"" height=""60"" v:shapes=""_x0000_s1026""></p></td>" skip
                    "</tr>" skip
                    "<tr>" skip
                        "<td height=20> </td>" skip
                        "<td> </td>" skip
                        "<td> </td>" skip
                        "<td> </td>" skip
                    "</tr>" skip
                "</table>" skip
                "</body>" skip
                "</html>"  skip.
            unix silent cptwin value(filelg) iexplore.
            run mail("Kassirs@fortebank.com", "BANK <abpk@fortebank.com>", "Льготные курсы валют, " + cmp.name, "", "", "",filelg).
            run mail("id00020@metrocombank.kz", "BANK <abpk@metrocombank.kz>", "Льготные курсы валют, " + cmp.name, "", "", "",filelg).
            /*run mail("gl.buh.branches@metrocombank.kz, id00163@metrocombank.kz", "BANK <abpk@metrocombank.kz>", "Льготные курсы валют, " + cmp.name, "", "", "",filelg).*/
            for each ofcsend where ofcsend.typ = "kurslg" no-lock:
                run mail(ofcsend.ofc + "@metrocombank.kz", "BANK <abpk@metrocombank.kz>", "Льготные курсы валют, " + cmp.name, "", "", "",filelg).
            end.
        end.
    end.
end.
open query q1 for each crclg.

b1:set-repositioned-row (1, "CONDITIONAL").

enable all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

wait-for window-close of frame fr1.

hide frame fr1.

