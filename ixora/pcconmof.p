/* pcconmof.p
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Контроль МИДЛ-ОФИСА при установлении КЛ на ПК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-3-1
 * AUTHOR
        14.05.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        04.06.2013 Lyubov - ТЗ №1874, выбираем заявки только своего филиала
        13.06.2013 Lyubov - ТЗ №1820, добавила опись кредитного досье
        05/08/2013 galina - ТЗ1912 выводим не полный номер карточки согласно требованиям безопасности
        22.08.2013 Lyubov - ТЗ 2027, сохраняеим id последнего редактировавшего анкету
*/


{global.i}

def var v-aaa      as char no-undo.
def var v-cif   as char no-undo init '*'.
def var phand      as handle no-undo.
def var v-iin      as char no-undo.
def var v-card     as char no-undo.
def var v-name     as char no-undo.
def var v-maillist as char.
def var v-zag      as char.
def var v-str      as char.
def var v-cname    as char no-undo.
def var v-crc      as char no-undo.
def var v-telm     as char no-undo.
def var v-nomdoc   as char no-undo.
def var v-issdt    as date no-undo.
def var v-issdoc   as char no-undo.
def var v-expdt    as date no-undo.
def var v-addr1    as char no-undo.
def var v-addr2    as char no-undo.
def var v-ofc      as char no-undo.

def var v-v1  as char.
def var v-v2  as char.
def var v-v3  as char.

def var v-comp   as char init '*'.
def var v-fio    as char init '*'.
def var v-bin    as char init '*'.
def var v-comment as char.

def stream out.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var i as int.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

find first ofc where ofc.ofc = g-ofc no-lock no-error.
v-ofc = ofc.name.

form
    v-cif    label " CIF-код клиента       " format "x(6)" skip
    v-comp      label " Наименование Компании " format "x(6)" skip
    v-fio       label " ФИО физ. лица         " format "x(30)" skip
    v-bin       label " ИИН физ.лица          " format "x(12)" skip
with side-labels centered row 3 title ' Поиск ' width 100 frame fsearch.

form v-cif   label " CIF-код клиента         " format "x(6)" skip

     v-cname    label " Наименование компании   " format "x(20)" skip
     v-name     label " Ф.И.О.                  " format "x(50)" skip
     v-iin      label " ИИН                     " format "x(12)" skip
     v-aaa      label " Номер счета             " format "x(20)" skip
     v-crc      label " Валюта счета            " format "x(3)" skip
     v-card     label " Номер карты             " format "x(16)" skip
     v-telm     label " Номер моб. телефона     " format "x(20)" skip
     v-nomdoc   label " Удостоверение личности  " format "x(12)" skip
     v-issdt    label " Дата выдачи уд.л.       " format "99.99.9999" skip
     v-issdoc   label " Кем выдан               " format "x(10)" skip
     v-expdt    label " Срок действвия уд.л.    " format "99.99.9999" skip
     v-addr1    label " Адрес проживания        " format "x(60)" skip
     v-addr2    label " Адрес регистрации       " format "x(60)" skip
with side-labels centered row 3 title ' Анкета ' width 100 frame fank.

form v-v1 label " Клиент получил платежную карту    " format "x(3)" validate (v-v1 = 'Да' or v-v1 = 'Нет', ' Выберите Да или Нет ') skip
     v-v2 label " Клиент подписал кредитный договор " format "x(3)" validate (v-v2 = 'Да' or v-v2 = 'Нет', ' Выберите Да или Нет ') skip
     v-v3 label " Кредитное досье сформировано      " format "x(3)" validate (v-v3 = 'Да' or v-v3 = 'Нет', ' Выберите Да или Нет ') skip
with side-labels centered row 19 title ' Контроль ' width 100 frame fcont.

form v-comment no-label validate(trim(v-comment) <> '', " Введите замечания по анкете ") VIEW-AS EDITOR SIZE 68 by 6

with frame comment row 5 overlay centered title "Комментарий" .

update v-cif v-comp v-fio v-bin with frame fsearch.

DEFINE BUTTON bcon LABEL "КОНТРОЛЬ МОФ".
DEFINE BUTTON bops LABEL "ОПИСЬ КРЕД.ДОСЬЕ".
DEFINE BUTTON bext LABEL "ВЫХОД".

def frame fr1
     bcon
     bops
     bext with centered row 3 width 45 .
enable bcon bops bext with frame fr1.

ON CHOOSE OF bcon IN FRAME fr1 do:
    for each pcstaff0 where pcstaff0.bank = s-ourbank and can-do(v-cif,pcstaff0.cif) and can-do(v-comp, pcstaff0.cifb)
         and pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname matches '*' + v-fio + '*' and can-do(v-bin,pcstaff0.iin) no-lock.

        find first pkanketa where pkanketa.bank = pcstaff0.bank and pkanketa.credtype = '4'
                              and pkanketa.aaa = pcstaff0.aaa and pkanketa.rnn = pcstaff0.iin and pkanketa.sts = '20' no-lock no-error.
        if avail pkanketa then do:
            find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
            if avail cif then v-cname = cif.prefix + ' ' + cif.name.
            assign v-name     = pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname
                   v-cif   = pcstaff0.cif
                   v-iin      = pcstaff0.iin
                   v-aaa      = pcstaff0.aaa
                   v-card     = /*pcstaff0.pcard*/ substr(pcstaff0.pcard,1,6) + '******' + substr(pcstaff0.pcard,13,4)
                   v-telm     = pcstaff0.tel[2]
                   v-nomdoc   = pcstaff0.nomdoc
                   v-issdt    = pcstaff0.issdt
                   v-issdoc   = pcstaff0.issdoc
                   v-expdt    = pcstaff0.expdt
                   v-addr1    = pcstaff0.addr[1]
                   v-addr2    = pcstaff0.addr[2].
                   find first crc where crc.crc = pcstaff0.crc no-lock no-error.
                   v-crc      = crc.code.


            display v-cif v-cname v-name v-iin v-aaa v-crc v-card v-telm v-nomdoc v-issdt v-issdoc v-expdt v-addr1 v-addr2 with frame fank.

            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'mofcont' no-lock no-error.
            if not avail pkanketh then do:
                create pkanketh.
                assign pkanketh.bank      = pcstaff0.bank
                       pkanketh.cif       = pcstaff0.cif
                       pkanketh.credtype  = '4'
                       pkanketh.ln        = pkanketa.ln
                       pkanketh.kritcod   = 'mofcont'
                       pkanketh.value1    = 'no'
                       pkanketh.rdt       = g-today
                       pkanketh.rwho      = g-ofc
                       pkanketh.rescha[1] = 'Нет;Нет;Нет'.
            end.
            else assign v-v1 = entry(1,pkanketh.rescha[1],';')
                        v-v2 = entry(2,pkanketh.rescha[1],';')
                        v-v3 = entry(3,pkanketh.rescha[1],';').

            update v-v1 v-v2 v-v3 with frame fcont.

            find current pkanketh exclusive-lock no-error.
            pkanketh.rescha[1] = v-v1 + ';' + v-v2 + ';' + v-v3.
            if v-v1 = 'Да' and v-v2 = 'Да' and v-v3 = 'Да' then pkanketh.value1 = 'yes'.
            else pkanketh.value1 = 'no'.
            pkanketh.rdt       = g-today.
            pkanketh.rwho      = g-ofc.
            find current pkanketh no-lock no-error.

            if v-v1 = 'Да' and v-v2 = 'Да' and v-v3 = 'Да' then do:

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

                v-zag = 'Контроль ДПК'.
                v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16-2-3-2 'Контроль ДПК'. Клиент: "
                      + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                      + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                      + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
                run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").

                find current pkanketa exclusive-lock no-error.
                pkanketa.sts = '140'.
                find current pkanketa no-lock no-error.
            end.

            else do:

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

                if v-v1 = 'Нет' and v-v2 = 'Нет' then do:
                    v-zag = 'Контроль МОФ'.
                    v-str = "Здравствуйте! Вам назначена задача! Проверить получение клиентом платежной карты и подписание кредитного договора! Клиент: "
                          + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                          + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                          + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                end.

                if v-v1 = 'Нет' and v-v2 = 'Да' then do:
                    v-zag = 'Контроль МОФ'.
                    v-str = "Здравствуйте! Вам назначена задача! Проверить получение клиентом платежной карты! Клиент: "
                          + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                          + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                          + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                end.

                if v-v2 = 'Да' and v-v2 = 'Нет' then do:
                    v-zag = 'Контроль МОФ'.
                    v-str = "Здравствуйте! Вам назначена задача! Проверить подписание кредитного договора! Клиент: "
                          + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                          + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                          + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                end.

                if v-v3 = 'Нет' then do:
                    update v-comment
                    help "Введите данные (F1 - сохранение, F4 - отмена)" view-as editor size 50 by 5 " "
                    skip(1) with no-labels title " Замечания " row 5 centered overlay frame comment.
                    hide frame comment.

                    v-zag = 'Контроль МОФ'.
                    v-str = "Здравствуйте! Вам назначена задача! Проверить кредитное досье на полноту формирования! Комментарий: " + v-comment
                          + ". Клиент: " + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                          + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                          + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                end.
            end.
        end.
        if not avail pkanketa then next.
    end.
end.

ON CHOOSE OF bops IN FRAME fr1 do:
    for each pcstaff0 where pcstaff0.bank = s-ourbank and can-do(v-cif,pcstaff0.cif) and can-do(v-comp, pcstaff0.cifb)
         and pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname matches '*' + v-fio + '*' and can-do(v-bin,pcstaff0.iin) no-lock.

        find first pkanketa where pkanketa.bank = pcstaff0.bank and pkanketa.credtype = '4'
                              and pkanketa.aaa = pcstaff0.aaa and pkanketa.rnn = pcstaff0.iin no-lock no-error.
        if avail pkanketa then do:

            if v-cif = '*' and v-comp = '*' and v-fio = '*' and v-bin = '*' and pkanketa.sts <> '20' then next.

            v-infile  = "/data/docs/inventory.htm".
            v-ofile = "inventory.htm".
            output stream out to value(v-ofile).
            input from value(v-infile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*vname*" then do:
                       v-str = replace (v-str, "vname", pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname).
                       next.
                    end.
                    if v-str matches "*vcrlim*" then do:
                       v-str = replace (v-str, "vcrlim", string(pkanketa.summa)).
                       next.
                    end.
                    if v-str matches "*vmof*" then do:
                       v-str = replace (v-str, "vmof", v-ofc).
                       next.
                    end.
                    leave.
                end. /* repeat */
                put stream out unformatted v-str skip.
            end. /* repeat */
            input close.
            /********/

            output stream out close.

            unix silent value("cptwin " + v-ofile + " winword").
            unix silent value("rm -r " + v-ofile).
        end.
    end.
end.
wait-for choose of bext or window-close of current-window.