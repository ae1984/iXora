/* pccondpc.p
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
        16-2-3-2
 * AUTHOR
        08.02.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        28.05.2013 damir - Внедрено Т.З. № 1819.
        13.06.2013 damir - Внедрено Т.З. № 1876.
        05/08/2013 galina - ТЗ1912 выводим не полный номер карточки согласно требованиям безопасности
        10.10.2013 Lyubov - ТЗ 1966, сохраняем номер договора в pc_lncontr
*/
{global.i}
{comm-txb.i}

def var v-aaa      as char no-undo.
def var v-cifcod   as char no-undo init '*'.
def var phand      as handle no-undo.
def var v-iin      as char no-undo.
def var v-card     as char no-undo.
def var v-name     as char no-undo.

def var v-crc      as char no-undo.
def var v-telm     as char no-undo.
def var v-pctype   as char no-undo.
def var v-nomdoc   as char no-undo.
def var v-issdt    as date no-undo.
def var v-issdoc   as char no-undo.
def var v-expdt    as date no-undo.
def var v-cexpdt   as date no-undo.
def var v-fundec   as char no-undo.
def var v-fddt     as date no-undo.
def var v-crlim    as deci no-undo.
def var v-save     as logi no-undo.

def var v-maillist as char.
def var v-zag      as char.
def var v-str      as char.
def var v-comment  as char.

def var v-comp  as char init '*'.
def var v-fio   as char init '*'.
def var v-bin   as char init '*'.
def var v-dt1   as date init today.
def var v-dt2   as date init today.
def var i as int.
def var v-ourbnk as char.

form
    v-cifcod label " CIF-код клиента       " format "x(6)"  skip
    v-comp   label " Наименование Компании " format "x(6)"  skip
    v-fio    label " ФИО физ. лица         " format "x(30)" skip
    v-bin    label " ИИН физ.лица          " format "x(12)" skip(1)
    v-dt1    label " С " format "99.99.9999" v-dt2 label " По " format "99.99.9999" skip
with side-labels centered row 3 title ' Поиск ' width 100 frame fsearch.

form
    v-cifcod   label " CIF-код клиента            " format "x(6)"  skip
    v-iin      label " ИИН                        " format "x(12)" skip
    v-name     label " Ф.И.О.                     " format "x(50)" skip
    v-aaa      label " Номер текущего счета       " format "x(20)" skip
    v-crc      label " Валюта текущего счета      " format "x(3)"  skip
    v-card     label " Номер карты                " format "x(16)" skip
    v-telm     label " Номер моб. телефона        " format "x(20)" skip
    v-pctype   label " Вид карты                  " format "x(1)"  skip
    v-nomdoc   label " Удостоверение личности     " format "x(12)" skip
    v-issdt    label " Дата выдачи                " format "99.99.9999" skip
    v-issdoc   label " Кем выдан                  " format "x(10)" skip
    v-expdt    label " Срок действия уд.л.        " format "99.99.9999" skip
    v-cexpdt   label " Срок действия карты        " format "99.99.9999" skip
    v-fundec   label " Решение о финансировании № " format "x(20)" v-fddt label " От " format "99.99.9999" skip(1)
    v-crlim    label " КЛ на плат. карту          " format ">>,>>>,>>9.99" skip
    v-save     label " Кред. лимит установлен     " format "Да/Нет" skip
with side-labels centered row 3 title ' Анкета ' width 100 overlay frame fank.

form
     v-comment no-label VIEW-AS EDITOR SIZE 68 by 6
     with frame comment row 5 overlay centered title "Комментарий" .

v-ourbnk = comm-txb().

update v-cifcod v-comp v-fio v-bin v-dt1 v-dt2 with frame fsearch.

for each pcstaff0 where can-do(v-cifcod,pcstaff0.cif) and can-do(v-comp, pcstaff0.cifb)
     and pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname matches '*' + v-fio + '*'
     and can-do(v-bin,pcstaff0.iin) no-lock.
    find first pkanketa where pkanketa.bank = pcstaff0.bank and pkanketa.credtype = '4'
                          and pkanketa.aaa = pcstaff0.aaa and pkanketa.rnn = pcstaff0.iin
                          and pkanketa.sts = '140' no-lock no-error.
    if not avail pkanketa then message ' Нет данных на контроль! ' view-as alert-box.
    else do:
        find first pccards where pccards.aaa = pcstaff0.aaa and pccards.pcard = pcstaff0.pcard no-lock no-error.
        if avail pccards then do:
            assign v-iin      = pcstaff0.iin
                   v-name     = pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname
                   v-aaa      = pcstaff0.aaa
                   v-card     = /*pcstaff0.pcard*/ substr(pcstaff0.pcard,1,6) + '******' + substr(pcstaff0.pcard,13,4)
                   v-telm     = pcstaff0.tel[2]
                   v-pctype   = pcstaff0.pctype
                   v-nomdoc   = pcstaff0.nomdoc
                   v-issdt    = pcstaff0.issdt
                   v-issdoc   = pcstaff0.issdoc
                   v-expdt    = pcstaff0.expdt
                   v-cexpdt   = pccards.expdt
                   v-crlim    = pkanketa.summa
                   v-fundec   = pkanketa.rescha[1]
                   v-fddt     = pkanketa.resdat[1].

                   find first crc where crc.crc = pcstaff0.crc no-lock no-error.
                   v-crc      = crc.code.


            display v-cifcod v-iin v-name v-aaa v-crc v-card v-telm v-pctype v-nomdoc v-issdt v-issdoc v-expdt v-cexpdt v-crlim v-fundec v-fddt with frame fank.
            update v-save with frame fank.
            if v-save then do:
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

                v-zag = 'Контроль ДПК'.
                v-str = "Здравствуйте! Клиенту: " + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                      + pcstaff0.iin + " установлен кредитный лимит! Дата поступления задачи: " + string(today)
                      + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
                run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").

                find current pkanketa exclusive-lock no-error.
                pkanketa.sts = '150'.
                find current pkanketa no-lock no-error.

                find first pc_lncontr where pc_lncontr.acc = pkanketa.aaa and pc_lncontr.contr = pkanketa.rescha[1] no-lock no-error.
                if not avail pc_lncontr then do:
                    create pc_lncontr.
                    assign pc_lncontr.acc      = pkanketa.aaa
                           pc_lncontr.iin      = pkanketa.rnn
                           pc_lncontr.contr    = pkanketa.rescha[1]
                           pc_lncontr.stdate   = pkanketa.rdt
                           pc_lncontr.amt      = pkanketa.summa
                           pc_lncontr.prem     = 24
                           pc_lncontr.eff_%    = pkanketa.rateq
                           pc_lncontr.whn      = g-today
                           pc_lncontr.who      = g-ofc
                           pc_lncontr.ow_limdt = g-today
                           pc_lncontr.crtype   = '4'
                           pc_lncontr.edate    = pccards.expdt.
                end.

                /*-------------------------------------------------------------------------*/
                def buffer b-cif for cif.
                find b-cif where b-cif.cif = pcstaff0.cif no-lock no-error.
                if avail b-cif then do:
                    run addatk(yes,"Vam ustanovlen kreditniy limit. Blagodarim za Vash vybor. ForteBank.Tel.88000707007",b-cif.fax,v-ourbnk,pcstaff0.cif,next-value(smsbatch)).
                    message "SMS-уведомление создано!" view-as alert-box information buttons ok.
                end.
                else message "SMS-уведомление не создано! CIF-код клиента не найден!" view-as alert-box information buttons ok.
                /*-------------------------------------------------------------------------*/
            end.
            else do:
                find first codfr where codfr.codfr = 'clmail' and codfr.code = 'mofmail' no-lock no-error.
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

                update v-comment validate (trim(v-comment) <> '', " Введите замечания по анкете ")
                help "Введите данные (F1 - сохранение, F4 - отмена)" view-as editor size 50 by 5 " "
                skip(1) with no-labels title " Замечания по анкете " row 5 centered overlay frame comment.
                hide frame comment.

                v-zag = 'Контроль ДПК'.
                v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16.2.3.1. 'Контрль МИДЛ-ОФИСА'. Комментарий: " + v-comment
                      + ". Клиент: " + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                      + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                      + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
                run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
            end.
        end.
    end.
end.

procedure addatk.
    define input parameter v-sendtxt as logi.
    define input parameter v-txt as char.
    define input parameter v-mob as char.
    define input parameter v-bank as char.
    define input parameter v-cif as char.
    define input parameter v-batchid as inte.

    def buffer b-smspool for comm.smspool.

    create b-smspool.
    b-smspool.bank = v-bank.
    b-smspool.id = next-value(smsid).
    b-smspool.tell = v-mob.
    b-smspool.pdate = today.
    b-smspool.ptime = time.
    b-smspool.pwho = g-ofc.
    b-smspool.state = 2.
    b-smspool.cif = v-cif.
    b-smspool.batchid = v-batchid.
    if v-sendtxt then b-smspool.mess = v-txt.
    b-smspool.source = "CredLimit".
end procedure.

pause.