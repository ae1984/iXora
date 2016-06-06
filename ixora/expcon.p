/* expcon.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Контроль Мидл офиса
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-2
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
*/


{global.i}

def var v-aaa      as char no-undo.
def var v-cif      as char no-undo init '*'.
def var phand      as handle no-undo.
def var v-iin      as char no-undo.
def var v-card     as char no-undo.
def var v-name     as char no-undo.
def var v-maillist as char.
def var v-zag      as char.
def var v-str      as char.
def var v-cname    as char no-undo.
def var v-crc      as char no-undo.
def var v-nomdoc   as char no-undo.
def var v-issdt    as date no-undo.
def var v-issdoc   as char no-undo.
def var v-expdt    as date no-undo.
def var v-ofc      as char no-undo.

def var v-nomKKF   as char no-undo.
def var v-datKKF   as date no-undo.
def var v-resKKF   as char no-undo.
def var v-sumKKF   as deci no-undo.
def var v-srkKKF   as inte no-undo.
def var v-msgKKF   as logi no-undo.
def var v-quest1   as logi no-undo.

def var v-nomMKK   as char no-undo.
def var v-datMKK   as date no-undo.
def var v-resMKK   as char no-undo.
def var v-sumMKK   as deci no-undo.
def var v-srkMKK   as inte no-undo.
def var v-quest2   as logi no-undo.

def var v-v1  as char.
def var v-v2  as char.
def var v-v3  as char.

def var v-comp   as char init '*'.
def var s-ln     as inte.
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
    v-cif       label " CIF-код клиента       " format "x(6)" help "Нажмите F2 для поиска клиента" skip
    s-ln        label " Номер анкеты          " format ">>>9" help "Нажмите F2 для выбора анкеты" skip
with side-labels centered row 3 title ' Поиск ' width 100 frame fsearch.

form v-cif      label " CIF-код клиента         " format "x(6)" skip
     s-ln       label " Номер анкеты            " format ">>>9" skip
     v-cname    label " Наименование компании   " format "x(20)" skip
     v-name     label " Ф.И.О. клиента          " format "x(50)" skip
     v-iin      label " ИИН                     " format "x(12)" skip
     v-crc      label " Валюта счета            " format "x(3)" skip
     v-aaa      label " Номер текущего счета    " format "x(20)" skip
     v-nomdoc   label " № документа уд. личность" format "x(12)" skip
     v-issdt    label " Дата выдачи док-та уд.л." format "99.99.9999" skip
     v-issdoc   label " Кем выдан док-т уд.л.   " format "x(10)" skip
     v-expdt    label " Срок действия уд.л.     " format "99.99.9999" skip
with side-labels centered row 3 title ' Анкета ' width 100 frame fank.

form v-nomKKF   label " Номер и дата прот. ККФ     " format "x(10)" validate(v-nomKKF <> '', 'Введите номер протокола ККФ') v-datKKF no-label format '99/99/9999' validate(v-datKKF <> ?, 'Введите дату принятия решения на ККФ') skip
     v-resKKF   label " Решение ККФ                " format "x(10)" validate(can-find(first codfr where codfr.codfr = 'decision' and codfr.name[1] = v-resKKF no-lock)," Выберите решение ККФ из списка по F2 ") skip
     v-sumKKF   label " Сумма, одобренная ККФ      " format ">,>>>,>>9.99" validate(v-resKKF = 'одобрить' and v-sumKKF <> 0, 'Введите сумму, одобренную ККФ') skip
     v-srkKKF   label " Срок, одобренный ККФ       " format ">>9"          validate(v-resKKF = 'одобрить' and v-srkKKF <> 0, 'Введите срок, одобренный ККФ') skip
     v-msgKKF	label " Требуется рассмотрение МКК?" format 'Да/Нет' skip
     v-quest1   label " Сохранить?                 " format 'Да/Нет' skip(1)

     v-nomMKK   label " Номер и дата прот. МКК     " format "x(10)" v-datMKK no-label format '99/99/9999' skip
     v-resMKK   label " Решение МКК                " format "x(10)" validate(v-resMKK = '' or can-find(first codfr where codfr.codfr = 'decision' and codfr.name[1] = v-resMKK no-lock)," Выберите решение МКК из списка по F2 ") skip
     v-sumMKK   label " Сумма, одобренная МКК      " format ">,>>>,>>9.99" skip
     v-srkMKK   label " Срок, одобренный МКК       " format ">>9"          skip
     v-quest2   label " Сохранить?                 " format 'Да/Нет'
with side-labels centered row 17 title ' Информация по Протоколу КК ' width 100 frame fprt.

form v-v1 label " Клиент подписал Кредитный Договор " format "x(3)" validate (v-v1 = 'Да' or v-v1 = 'Нет', ' Выберите Да или Нет ') skip
     v-v2 label " Клиент подписал График погашения  " format "x(3)" validate (v-v2 = 'Да' or v-v2 = 'Нет', ' Выберите Да или Нет ') skip
     v-v3 label " Кредитное досье сформировано      " format "x(3)" validate (v-v3 = 'Да' or v-v3 = 'Нет', ' Выберите Да или Нет ') skip
with side-labels centered row 17 title ' Информация по кредитному досье ' width 100 frame fcont.

form v-comment no-label validate(trim(v-comment) <> '', " Введите замечания по анкете ") VIEW-AS EDITOR SIZE 68 by 6

with frame comment row 5 overlay centered title "Комментарий" .

on help of v-resKKF in frame fprt do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 10 down width 30 overlay "
        &where   = " codfr.codfr = 'decision' and codfr.code <> 'msc'"
        &flddisp = " codfr.name[1] label ' Решение ККФ ' format 'x(25)' "
        &chkey   = "name[1]"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-resKKF = codfr.name[1].
    displ v-resKKF with frame fprt.
end.

on help of v-resMKK in frame fprt do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 10 down width 30 overlay "
        &where   = " codfr.codfr = 'decision' and codfr.code <> 'msc'"
        &flddisp = " codfr.name[1] label ' Решение КК ' format 'x(25)' "
        &chkey   = "name[1]"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-resMKK = codfr.name[1].
    displ v-resMKK with frame fprt.
end.

on help of s-ln in frame fsearch do:
    {itemlist.i
        &file    = "pkanketa"
        &set     = "2"
        &frame   = "row 8 scroll 1 5 down width 17 overlay "
        &where   = " pkanketa.bank = s-ourbank and pkanketa.credtype = '10' and pkanketa.cif = v-cif "
        &flddisp = " pkanketa.ln label ' Номер анкеты ' format '>>>>9' "
        &chkey   = "ln"
        &chtype  = "inte"
        &index   = "bankcred"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    s-ln = pkanketa.ln.
    displ s-ln with frame fsearch.
end.

update v-cif with frame fsearch.
update s-ln /*v-comp v-fio v-bin*/ with frame fsearch.

DEFINE BUTTON bcon LABEL "КОНТРОЛЬ МОФ".
DEFINE BUTTON bops LABEL "ОПИСЬ КРЕД.ДОСЬЕ".
DEFINE BUTTON bext LABEL "ВЫХОД".

def frame fr1
     bcon
     bops
     bext with centered row 3 width 45 .
enable bcon bops bext with frame fr1.

ON CHOOSE OF bcon IN FRAME fr1 do:
    for each pcstaff0 where pcstaff0.bank = s-ourbank and can-do(v-cif,pcstaff0.cif) and pcstaff0.sts = 'OK' /*and can-do(v-comp, pcstaff0.cifb)
         and pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname matches '*' + v-fio + '*' and can-do(v-bin,pcstaff0.iin)*/ no-lock.

        find first pkanketa where pkanketa.bank = pcstaff0.bank and pkanketa.credtype = '10' and pkanketa.cif = pcstaff0.cif and pkanketa.ln = s-ln and (pkanketa.sts = '110' or (pkanketa.sts = '30' and pkanketa.docdt <> ?)) no-lock no-error.
        if avail pkanketa then do:

            if pkanketa.sts = '111' then do:
                message ' Действия по анкете запрещены, по причине - отказ клиента от Экспресс-кредита ' view-as alert-box.
                return.
            end.

            if pcstaff0.cifb begins 'TXB' then v-cname = 'AO ForteBank'.
            else do:
                find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
                if avail cif then v-cname = cif.prefix + ' ' + cif.name.
            end.

            assign v-name     = pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname
                   v-cif      = pcstaff0.cif
                   v-iin      = pcstaff0.iin
                   v-aaa      = pkanketa.aaa
                   v-nomdoc   = pcstaff0.nomdoc
                   v-issdt    = pcstaff0.issdt
                   v-issdoc   = pcstaff0.issdoc.
                   find first crc where crc.crc = pcstaff0.crc no-lock no-error.
                   v-crc      = crc.code.

            display v-cif s-ln v-cname v-name v-iin v-aaa v-crc v-nomdoc v-issdt v-issdoc v-expdt with frame fank.

            if pkanketa.sts = '110' then do:

                find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'decisKKF' exclusive-lock no-error.
                if avail pkanketh then do:
                    v-resKKF = pkanketh.value1.
                    v-nomKKF = pkanketh.rescha[1].
                    if pkanketh.rescha[2] <> '' then v-datKKF = date(int(substr(pkanketh.rescha[2],4,2)), int(substr(pkanketh.rescha[2],1,2)),int(substr(pkanketh.rescha[2],7,4))).
                    if pkanketh.rescha[2] <> '' then v-sumKKF = deci(pkanketh.rescha[3]).
                    if pkanketh.rescha[2] <> '' then v-srkKKF = inte(pkanketh.rescha[4]).
                end.
                displ v-resKKF v-nomKKF v-sumKKF v-srkKKF with frame fprt.
                if v-resKKF = '' then do:
                    update v-nomKKF v-datKKF v-resKKF with frame fprt.
                    if v-resKKF = 'одобрить' then update v-sumKKF v-srkKKF with frame fprt.
                    update v-msgKKF v-quest1 with frame fprt.
                end.
                else update v-msgKKF with frame fprt.
                if v-msgKKF then do:
                    update v-nomMKK v-datMKK v-resMKK with frame fprt.
                    if v-resMKK = 'одобрить' then update v-sumMKK v-srkMKK with frame fprt.
                    update v-quest2 with frame fprt.
                end.
                if v-quest1 then do:
                    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'decisKKF' exclusive-lock no-error.
                    if not avail pkanketh then do:
                        create pkanketh.
                        assign pkanketh.bank      = pcstaff0.bank
                               pkanketh.cif       = pcstaff0.cif
                               pkanketh.credtype  = '10'
                               pkanketh.ln        = pkanketa.ln
                               pkanketh.kritcod   = 'decisKKF'
                               pkanketh.value1    = v-resKKF
                               pkanketh.rdt       = g-today
                               pkanketh.rwho      = g-ofc
                               pkanketh.rescha[1] = v-nomKKF
                               pkanketh.rescha[2] = string(v-datKKF,'99/99/9999')
                               pkanketh.rescha[3] = string(v-sumKKF)
                               pkanketh.rescha[4] = string(v-srkKKF).
                    end.
                    else assign
                    pkanketh.value1    = v-resKKF
                    pkanketh.rdt       = g-today
                    pkanketh.rwho      = g-ofc
                    pkanketh.rescha[1] = v-nomKKF
                    pkanketh.rescha[2] = string(v-datKKF,'99/99/9999')
                    pkanketh.rescha[3] = string(v-sumKKF)
                    pkanketh.rescha[4] = string(v-srkKKF).

                    release pkanketh.
                    pause.
                    hide frame fprt.
                end.
                if v-quest2 and (v-nomMKK <> '' or v-resMKK <> '') then do:
                    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'decisMKK' exclusive-lock no-error.
                    if not avail pkanketh then do:
                        create pkanketh.
                        assign pkanketh.bank      = pcstaff0.bank
                               pkanketh.cif       = pcstaff0.cif
                               pkanketh.credtype  = '10'
                               pkanketh.ln        = pkanketa.ln
                               pkanketh.kritcod   = 'decisMKK'
                               pkanketh.value1    = v-resMKK
                               pkanketh.rdt       = g-today
                               pkanketh.rwho      = g-ofc
                               pkanketh.rescha[1] = v-nomMKK
                               pkanketh.rescha[2] = string(v-datMKK,'99/99/9999')
                               pkanketh.rescha[3] = string(v-sumMKK)
                               pkanketh.rescha[4] = string(v-srkMKK).
                    end.
                    else assign
                    pkanketh.value1    = v-resMKK
                    pkanketh.rdt       = g-today
                    pkanketh.rwho      = g-ofc
                    pkanketh.rescha[1] = v-nomMKK
                    pkanketh.rescha[2] = string(v-datMKK,'99/99/9999')
                    pkanketh.rescha[3] = string(v-sumMKK)
                    pkanketh.rescha[4] = string(v-srkMKK).
                end.
                if (v-msgKKF = no and v-resKKF = 'одобрить') or v-resMKK = 'одобрить' then do:
                    v-zag = 'Решение кредитного комитета'.
                    v-str = "Здравствуйте! Выдача кредита одобрена. Вам назначена задача в АБС iXora в п.м. 3.2.7.1 «Анкета клиента» - формирование договоров. Клиент: "
                          + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                          + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". Дата поступления задачи: "
                          + string(today) + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                    find current pkanketa exclusive-lock no-error.
                    pkanketa.sts = '22'.
                    pkanketa.summa = if v-sumMKK > 0 then v-sumMKK else v-sumKKF.
                    find current pkanketa no-lock no-error.
                    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'esroktr' exclusive-lock no-error.
                    pkanketh.value1 = if v-srkMKK > 0 then string(v-srkMKK) else string(v-srkKKF).
                end.
                if (v-resMKK = '' and v-resKKF = 'отказать') or v-resMKK = 'отказать' then do:
                    v-zag = 'Решение кредитного комитета'.
                    v-str = "Здравствуйте! В выдаче кредита отказано. Необходимо уведомить клиента. Клиент: "
                          + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                          + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln)  + ". Дата поступления задачи: "
                          + string(today) + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                    find current pkanketa exclusive-lock no-error.
                    pkanketa.sts = '99'.
                    find current pkanketa no-lock no-error.
                end.
            end.

            if pkanketa.sts = '30' and pkanketa.docdt <> ? then do:
                find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'mofcont' no-lock no-error.
                if not avail pkanketh then do:
                    create pkanketh.
                    assign pkanketh.bank      = pcstaff0.bank
                           pkanketh.cif       = pcstaff0.cif
                           pkanketh.credtype  = '10'
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
                        v-zag = 'Информация по кредитному досье'.
                        v-str = "Здравствуйте! Заявка по клиенту направлена Контролеру на выдачу кредита. Клиент: "
                              + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                              + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln)  + ". Дата поступления задачи: "
                              + string(today) + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
                        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
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
                        v-zag = 'Информация по кредитному досье'.
                        v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 3.2.7.1 «Анкета клиента» - «Выдача кредита». Клиент: "
                              + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                              + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln)  + ". Дата поступления задачи: "
                              + string(today) + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
                        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                    end.

                    find current pkanketa exclusive-lock no-error.
                    pkanketa.cdt  = today.
                    pkanketa.cwho = g-ofc.
                    pkanketa.sts  = '23'.
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


                    if v-v1 = 'Нет' then do:
                        v-zag = 'Контроль МОФ'.
                        v-str = "Здравствуйте! Вам назначена задача! Проверьте подписание клиентом кредитного договора! Клиент: "
                              + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                              + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln)  + ". Дата поступления задачи: "
                              + string(today) + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
                        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                    end.

                    if v-v2 = 'Нет' then do:
                        v-zag = 'Контроль МОФ'.
                        v-str = "Здравствуйте! Вам назначена задача! Проверьте подписание клиентом Графика платежей! Клиент: "
                              + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                              + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln)  + ". Дата поступления задачи: "
                              + string(today) + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
                        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                    end.

                    if v-v3 = 'Нет' then do:
                        update v-comment
                        help "Введите данные (F1 - сохранение, F4 - отмена)" view-as editor size 50 by 5 " "
                        skip(1) with no-labels title " Замечания " row 5 centered overlay frame comment.
                        hide frame comment.

                        v-zag = 'Контроль МОФ'.
                        v-str = "Здравствуйте! Вам назначена задача! Проверьте кредитное досье на полноту формирования! Комментарий: " + v-comment
                              + ". Клиент: " + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                              + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". Дата поступления задачи: "
                              + string(today) + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
                        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                    end.
                end.
                hide frame fcont.
            end.
        end.
        if not avail pkanketa then next.
    end.
end.

ON CHOOSE OF bops IN FRAME fr1 do:
    for each pcstaff0 where pcstaff0.bank = s-ourbank and can-do(v-cif,pcstaff0.cif) and can-do(v-comp, pcstaff0.cifb)
         and pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname matches '*' + v-fio + '*' and can-do(v-bin,pcstaff0.iin) no-lock.

        for each pkanketa where pkanketa.bank = pcstaff0.bank and pkanketa.credtype = '10' and pkanketa.cif = pcstaff0.cif and pkanketa.sts = '23' /*and can-do(string(s-ln),string(pkanketa.ln))*/ and pkanketa.docdt <> ? no-lock:
        /*if avail pkanketa then do:*/

            if v-cif = '*' and v-comp = '*' and v-fio = '*' and v-bin = '*' and pkanketa.sts <> '23' then next.

            v-infile  = "/data/docs/ekinvent.htm".
            v-ofile = "ekinvent.htm".
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
                    if v-str matches "*vsum*" then do:
                       v-str = replace (v-str, "vsum", string(pkanketa.summa)).
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