/* ekanket.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Анкета
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        11.11.2013 Luiza - Дополнение к ТЗ 1932 от 23/10/2013 возможность редактирования данных анкеты, если контролер не подтвердил скоринг
*/

{global.i}

def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var v-cls      as logi no-undo.
def shared var s-credtype as char.

def var phand     as handle.
def var v-sname   as char no-undo.
def var v-fname   as char no-undo.
def var v-mname   as char no-undo.
def var v-iin     as char no-undo.
def var v-birth   as date no-undo.
def var v-bplace  as char no-undo.
def var v-nomdoc  as char no-undo.
def var v-isswho  as char no-undo.
def var v-issdt   as date no-undo.
def var v-expdt   as date no-undo.
def var v-addr    as char no-undo extent 2.
def var v-tel     as char no-undo extent 4.
def var v-mail    as char no-undo.
def var v-posit   as char no-undo.
def var v-educat  as char no-undo.
def var v-work    as char no-undo.
def var v-stajpos as inte no-undo.
def var v-stajob  as inte no-undo.
def var v-salary  as deci no-undo.
def var v-marsts  as char no-undo.
def var v-spsname as char no-undo.
def var v-spfname as char no-undo.
def var v-spmname as char no-undo.
def var v-spwork  as logi no-undo.
def var v-spwplc  as char no-undo.
def var v-spsal   as deci no-undo.
def var v-memnum  as inte no-undo.
def var v-depend  as inte no-undo.
def var v-depend1 as inte no-undo.
def var v-vidfin  as char no-undo.
def var v-sumtr   as deci no-undo.
def var v-sroktr  as inte no-undo.
def var v-gstav   as deci no-undo.
def var v-comorg  as deci no-undo.
def var v-metam   as char no-undo.
def var v-dattr   as inte no-undo.
def var v-issue   as char no-undo.
def var v-quest1  as logi no-undo format "Да/Нет".
def var v-quest2  as logi no-undo format "Да/Нет".
def var v-cbnomd  as char no-undo.
def var v-cbbank  as char no-undo.

def var v-crbank as char no-undo.
def var v-cdnom  as char no-undo.
def var v-bdat   as date no-undo.
def var v-edat   as date no-undo.
def var v-outam  as deci no-undo.
def var v-compan as inte no-undo.
def var v-cifb   as char no-undo.

def var v-sp     as char no-undo.
def var k        as inte no-undo.
def var l        as inte no-undo.

def var vday     as inte no-undo.
def var vmon     as inte no-undo.
def var vyear    as inte no-undo.
def var newmon   as inte no-undo.
def var vbyear1  as date no-undo.
def var vbyear2  as date no-undo.
def var newdt    as date no-undo.
def var v-sprcod as char no-undo.

def var v-errorDes as char.
def var v-operIdOnline as char.
def var v-operStatus as char.
def var v-operComment as char.

def var v-ans1  as logi no-undo format "Да/Нет".

{nbankBik.i}
{ekanket.f}

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.

hide all.

define button bt1 label "Создать новую анкету".
define button bt2 label "Найти анкету".
define button bt4 label "Выход".
define frame f1
bt1
bt2
bt4 with width 110 side-labels row 3 no-box.
enable bt1 bt2 bt4 with frame a1.

on choose of bt1 in frame a1 do:
    s-ln = 0.
    update v-cifcod help "Счет клиента; F2-помощь; F4-выход" with frame frpc.

    l = 0.
    for each pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '10' and pkanketa.cif = v-cifcod and pkanketa.sts <> '99' no-lock:
        l = l + 1.
    end.
    if l >= 3 then do:
        message 'Допустимо оформление клиентом не более 3 кредитов!' view-as alert-box.
        return.
    end.

    find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
    if not avail pcstaff0 then do:
        message 'Клиент не найден' view-as alert-box.
        v-cifcod = ''.
        return.
    end.

    find first hdbkcif where hdbkcif.cif = pcstaff0.cifb and not hdbkcif.del and hdbkcif.con no-lock no-error.
    if not avail hdbkcif and not pcstaff0.cifb begins 'TXB' then do:
        message 'Компания не привязана к условиям!' view-as alert-box.
        v-cifcod = ''.
        return.
    end.
    if pcstaff0.cifb begins 'TXB' then v-cifb = 'OURBNK'.
    else v-cifb = pcstaff0.cifb.

    find first bin where bin.bin = pcstaff0.iin and bin.bin <> '' no-lock no-error.
    if not avail bin then do:
        message 'Клиент находится в списке бездействующих налогоплательщиков' view-as alert-box.
        v-cifcod = ''.
        return.
    end.

    find first prisv where prisv.rnn = pcstaff0.iin and prisv.rnn <> '' no-lock no-error.
    if avail prisv then do:
        message 'Клиент связан с Банком особыми отношениями. Согласно условиям продукта финансирование не допустимо' view-as alert-box.
        v-cifcod = ''.
        return.
    end.

    find last aas where aas.aaa = pcstaff0.aaa no-lock no-error.
    if avail aas then do:
        message "Внимание, у " pcstaff0.sname ' ' pcstaff0.fname ' ' pcstaff0.mname " имеется ограничение " aas.payee " от " string(aas.whn,'99.99.9999')
        ", в связи с чем предоставление Экспресс кредита в настоящий момент не может быть рассмотрено, до момента фактического снятия ограничения"
        view-as alert-box.
        return.
    end.

    vbyear1 = date(month(pcstaff0.birth),day(pcstaff0.birth),year(pcstaff0.birth) + 57).
    vbyear2 = date(month(pcstaff0.birth),day(pcstaff0.birth),year(pcstaff0.birth) + 21).
    if today >= vbyear1 or today < vbyear2 then do:
        message " Предельный возраст ФЛ на момент выдачи кредита не должен быть меньше 21 года и превышать возраста 57 лет! " view-as alert-box.
        return.
    end.

    run kfmAMLOnline(pcstaff0.cif + '_' + string(next-value(ekipdl,bank)),'','','','1','1','',pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname,'',output v-errorDes,output v-operIdOnline,output v-operStatus,output v-operComment).
    if trim(v-errorDes) <> '' then do:
        message "Ошибка!~n" + v-errorDes + "~nПри необходимости обратитесь в ДИТ" view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.
    if v-operStatus = '0' then do:
        message "Проведение операции запрещено! Данные клиента отправлены на проверку в службу Комплаенс!" view-as alert-box information buttons ok title ' Внимание! '.
        v-cifcod = ''.
        return.
    end.
    if v-operStatus = '2' then do:
        message "Клиент является ИПДЛ/зарегистрирован в списке террористов. Финансирование не допустимо" view-as alert-box title ' Внимание! '.
        v-cifcod = ''.
        return.
    end.

    assign v-iin      = pcstaff0.iin
           v-sname    = pcstaff0.sname
           v-fname    = pcstaff0.fname
           v-mname    = pcstaff0.mname
           v-birth    = pcstaff0.birth
           v-bplace   = pcstaff0.bplace
           v-mail     = pcstaff0.mail
           v-tel[1]   = pcstaff0.tel[1]
           v-tel[2]   = pcstaff0.tel[2]
           v-addr[1]  = pcstaff0.addr[1]
           v-addr[2]  = pcstaff0.addr[2]
           v-nomdoc   = pcstaff0.nomdoc
           v-isswho   = pcstaff0.issdoc
           v-issdt    = pcstaff0.issdt
           v-expdt    = pcstaff0.expdt
           v-salary   = pcstaff0.salary.
    v-quest1 = no.
    run upd.
    if v-quest1 then do:
        run expreq.

        message "Отправить запрос в КБ и ГЦВП?" view-as alert-box question buttons yes-no title "" update v-ans1 as logical.
        if v-ans1 then do:
            run gcvp_send.
            run fcb_send.
        end.
    end.
end.

on choose of bt2 in frame a1 do:
    s-ln = 0.
    update v-cifcod help "Счет клиента; F2-помощь; F4-выход" with frame frpc.
    update s-ln help "Номер анкеты; F2-помощь; F4-выход" with frame frpc.
    find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
    assign v-iin      = pcstaff0.iin
           v-sname    = pcstaff0.sname
           v-fname    = pcstaff0.fname
           v-mname    = pcstaff0.mname
           v-birth    = pcstaff0.birth
           v-bplace   = pcstaff0.bplace
           v-mail     = pcstaff0.mail
           v-tel[1]   = pcstaff0.tel[1]
           v-tel[2]   = pcstaff0.tel[2]
           v-addr[1]  = pcstaff0.addr[1]
           v-addr[2]  = pcstaff0.addr[2]
           v-nomdoc   = pcstaff0.nomdoc
           v-isswho   = pcstaff0.issdoc
           v-issdt    = pcstaff0.issdt
           v-expdt    = pcstaff0.expdt
           v-salary   = pcstaff0.salary.

    find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
    if avail cif then v-work = cif.prefix + ' ' + cif.name.

    display v-cifcod v-iin v-sname v-fname v-mname v-birth v-bplace v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
            v-nomdoc v-isswho v-issdt v-expdt v-salary v-work with frame frpc.

    find first pksysc where pksysc.sysc = 'ekcrank' no-lock no-error.
    if avail pksysc then v-sp = pksysc.chval.

    find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '10' and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln no-lock no-error.
    if not avail pkanketa then do:
        message ' Нет анкеты с таким номером! ' view-as alert-box.
        return.
    end.

    v-cbnomd = pkanketa.rescha[4].
    v-cbbank = pkanketa.rescha[5].
    if v-cbnomd <> '' or v-cbbank <> '' then display v-cbnomd v-cbbank with frame info2.

    for each pkkrit where can-do(pkkrit.credtyp,"10") no-lock:

        find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.
        if avail pkanketh then do:
            case pkkrit.ln:
                when 810 then v-tel[3]  = pkanketh.value1.
                when 811 then v-educat  = pkanketh.value1.
                when 812 then v-work    = pkanketh.value1.
                when 813 then v-posit   = pkanketh.value1.
                when 814 then v-stajpos = inte(pkanketh.value1).
                when 815 then v-stajob  = inte(pkanketh.value1).
                when 816 then v-marsts  = pkanketh.value1.
                when 817 then v-spsname = pkanketh.value1.
                when 818 then v-spfname = pkanketh.value1.
                when 819 then v-spmname = pkanketh.value1.
                when 820 then v-spwork  = if pkanketh.value1 = 'да' then yes else no.
                when 821 then v-spwplc  = pkanketh.value1.
                when 822 then v-spsal   = deci(pkanketh.value1).
                when 823 then v-tel[4]  = pkanketh.value1.
                when 824 then v-memnum  = inte(pkanketh.value1).
                when 825 then v-depend  = inte(pkanketh.value1).
                when 826 then v-depend1 = inte(pkanketh.value1).
                when 827 then v-vidfin  = pkanketh.value1.
                when 828 then v-sumtr   = deci(pkanketh.value1).
                when 829 then v-sroktr  = inte(pkanketh.value1).
                when 830 then v-gstav   = deci(pkanketh.value1).
                when 831 then v-comorg  = deci(pkanketh.value1).
                when 832 then v-metam   = pkanketh.value1.
                when 833 then v-issue   = pkanketh.value1.
                when 834 then v-dattr   = inte(pkanketh.value1).
            end case.
        end.
    end.
    displ v-tel[3] v-educat v-work v-posit v-stajpos v-stajob v-salary v-marsts v-spsname v-spfname v-spmname v-spwork v-spwplc v-spsal v-tel[4] v-memnum v-depend v-depend1 v-vidfin v-sumtr v-sroktr v-gstav v-comorg v-metam v-issue v-dattr with frame frpc.

    find first codfr where codfr.codfr = 'clmail' and codfr.code = 'oomail' no-lock no-error.
    if not avail codfr then do:
        message 'Нет справочника адресов рассылки' view-as alert-box.
        return.
    end.
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
        and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" no-lock no-error.
    if (not available pkanketh or pkanketh.value1 = "01") and pkanketa.sts = '01' and can-do(codfr.name[1],g-ofc) then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
            and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" no-lock no-error.
        /* редактиование анкеты*/
        if available pkanketh and pkanketh.value1 = "01" and pkanketh.value2 <> "" then run upd.
        else do:
            update v-salary with frame frpc.
            if v-spwork then update v-spsal with frame frpc.
            update v-quest1 with frame quest1.
            if v-quest1 then do:
                find current pcstaff0 exclusive-lock no-error.
                pcstaff0.salary = v-salary.
                find current pcstaff0 no-lock no-error.

                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'espsal' exclusive-lock no-error.
                pkanketh.value1 = string(v-spsal).
                find current pkanketh no-lock no-error.
            end.
        end.
    end.


    if pkanketa.sts = '23' then update v-quest2 with frame quest2.
    if v-quest2 then run eknew.

    hide all.
end.

wait-for choose of bt4 or window-close of current-window.

procedure upd:
/* редактиование анкеты*/
    if not pcstaff0.cifb begins 'TXB' then do:
        find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
        if avail cif then do:
            v-work = cif.prefix + ' ' + cif.name.
            v-compan = (g-today - cif.expdt) / 30.
        end.
    end.
    else v-work = 'AO Fortebank'.

    display v-cifcod v-iin v-sname v-fname v-mname v-birth v-bplace v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
            v-nomdoc v-isswho v-issdt v-expdt v-salary v-work with frame frpc.

    /*find first pksysc where pksysc.sysc = 'ekcrank' no-lock no-error.
    if avail pksysc then v-sp = pksysc.chval.*/

    update v-tel[3] with frame frpc.
    replace(v-tel[3],'(','').
    replace(v-tel[3],')','').
    replace(v-tel[3],'-','').
    replace(v-tel[3],' ','').
    replace(v-tel[3],',','').
    if (v-tel[3] begins '+7' and length(substr(v-tel[3],3)) <> 10) or (v-tel[3] begins '+7' and length(substr(v-tel[3],3)) <> 10) then do:
        message " Введите номер телефона с кодом города " view-as alert-box.
        undo, retry.
    end.

    update v-educat v-work v-posit v-stajpos with frame frpc.
    if v-stajpos > v-compan and not pcstaff0.cifb begins 'TXB' then do:
        message 'Стаж на последнем месте работы не может быть больше срока действия этой Компании на рынке' view-as alert-box.
        undo, retry.
    end.

    update v-stajob with frame frpc.
    if v-stajpos > v-stajob then do:
        message 'Общий стаж не может быть меньше стажа на последнем месте работы' view-as alert-box.
        undo, retry.
    end.

    update v-salary v-marsts with frame frpc.
    if v-marsts = 'женат/замужем' or v-marsts = 'гражданский брак' then do:
        update v-spsname v-spfname v-spmname v-spwork v-tel[4] with frame frpc.
        replace(v-tel[4],'(','').
        replace(v-tel[4],')','').
        replace(v-tel[4],'-','').
        replace(v-tel[4],' ','').
        replace(v-tel[4],',','').
        if (v-tel[4] begins '+7' and length(substr(v-tel[4],3)) <> 10) or (v-tel[4] begins '+7' and length(substr(v-tel[4],3)) <> 10) then do:
            message " Введите номер мобильного телефона " view-as alert-box.
            undo, retry.
        end.
    end.
    else assign v-spsname = '' v-spfname = '' v-spmname = '' v-spwork = no v-tel[4] = ''.

    if v-spwork then update v-spwplc v-spsal with frame frpc.
    else assign v-spwplc = '' v-spsal = 0.
    update v-memnum v-depend v-depend1 v-vidfin with frame frpc.

    if v-vidfin = 'кредит' then v-sprcod = '1,2,3,4'.
    if v-vidfin = 'рефинансирование' then v-sprcod = '5,6,7,8,9,10,11,12,13,14,15,16,17'.
    if pcstaff0.cifb begins 'TXB' then v-cifb = 'OURBNK'.
    else v-cifb = pcstaff0.cifb.
    find first hdbkcif where can-do(v-sprcod,hdbkcif.hdbkcod) and hdbkcif.cif = v-cifb no-lock no-error.
    if not avail hdbkcif and not pcstaff0.cifb begins 'TXB' then do:
        message 'У компании нет привязки к условиям по виду финансирования ' + caps(v-vidfin) view-as alert-box.
        return.
    end.

    update v-sumtr with frame frpc.
    update v-sroktr with frame frpc.
    vday  = day(g-today).
    vmon  = month(g-today).
    vyear = year(g-today).
    newmon = vmon + v-sroktr.
    l = v-sroktr / 12.
    vyear = vyear + l.
    vmon = newmon - (l * 12).
    newdt = date(vmon,vday,vyear) no-error.
    repeat while error-status:error :
        vday = vday - 1.
        newdt = date(vmon,vday,vyear) no-error.
    end.
    vbyear1 = date(month(v-birth),day(v-birth),year(v-birth) + 57).
    if newdt >= vbyear1 /*or newdt < vbyear2*/ then do:
        message " Предельный возраст ФЛ на момент погашения кредита не должен превышать возраста 57 лет! " view-as alert-box.
        undo, retry.
    end.

    update v-metam with frame frpc.

    find first hdbkcif where can-do(v-sprcod,hdbkcif.hdbkcod) and hdbkcif.cif = v-cifb and not hdbkcif.del and hdbkcif.con no-lock no-error.
    find first credhdbk where credhdbk.hdbkcod = hdbkcif.hdbkcod no-lock no-error.
    if avail credhdbk then do:
        v-gstav = credhdbk.bazst.
        if v-metam = 'аннуитет' then v-comorg = credhdbk.comann.
        if v-metam = 'дифференцированные платежи' then v-comorg = credhdbk.comdif.
    end.
    displ v-gstav v-comorg with frame frpc.
    if v-vidfin = 'кредит' then update v-issue with frame frpc.
    if v-vidfin = 'рефинансирование' then v-issue = 'текущий счет'. displ v-issue with frame frpc.
    update v-dattr with frame frpc.
    update v-quest1 with frame quest1.

    hide all.

    if v-quest1 then do:
        find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '10' and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln exclusive-lock no-error.
        if not available pkanketa then do:
            create pkanketa.
            assign pkanketa.bank     = v-bank
            pkanketa.cif      = v-cifcod
            pkanketa.credtype = '10'
            pkanketa.ln       = next-value(expanknom,bank)
            pkanketa.rnn      = v-iin
            pkanketa.docnum   = nomdoc
            pkanketa.name     = caps(v-sname) + ' ' + caps(v-fname) + ' ' + caps(v-mname).
        end.
        assign pkanketa.rdt      = g-today
            pkanketa.rwho     = g-ofc
            pkanketa.crc      = 1
            pkanketa.addr1    = v-addr[1]
            pkanketa.addr2    = v-addr[2]
            pkanketa.sumq     = v-sumtr
            pkanketa.srok     = v-sroktr
            pkanketa.summa    = v-sumtr
            pkanketa.rateq    = v-gstav
            pkanketa.goal     = if v-vidfin = 'кредит' then 'Потребительские цели' else 'Рефинансирование'
            pkanketa.duedt    = newdt
            pkanketa.sts      = '01'.

        find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
        if avail cif then
        assign pkanketa.jobrnn   = cif.bin
               pkanketa.jobname  = cif.prefix + ' ' + cif.name
               pkanketa.jobaddr  = cif.addr[1] + cif.addr[2] + cif.addr[3].
        s-ln = pkanketa.ln.
        displ s-ln with frame frpc.

        find current pcstaff0 exclusive-lock no-error.
        pcstaff0.salary = v-salary.
        find current pcstaff0 no-lock no-error.

        for each pkkrit where can-do(pkkrit.credtyp,"10") no-lock:
            find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.
            if avail pkanketh then do:
                find current pkanketh exclusive-lock no-error.
                pkanketh.rdt  = g-today.
                pkanketh.rwho = g-ofc.
            end.
            else do:
                create pkanketh.
                assign pkanketh.bank     = v-bank
                       pkanketh.cif      = v-cifcod
                       pkanketh.credtype = '10'
                       pkanketh.ln       = pkanketa.ln
                       pkanketh.kritcod  = pkkrit.kritcod
                       pkanketh.value3   = pkkrit.priz
                       pkanketh.rdt      = g-today
                       pkanketh.rwho     = g-ofc.
            end.
            case pkkrit.ln:
                when 810 then pkanketh.value1 = v-tel[3]  .
                when 811 then pkanketh.value1 = v-educat  .
                when 812 then pkanketh.value1 = v-work    .
                when 813 then pkanketh.value1 = v-posit   .
                when 814 then pkanketh.value1 = string(v-stajpos) .
                when 815 then pkanketh.value1 = string(v-stajob)  .
                when 816 then pkanketh.value1 = v-marsts  .
                when 817 then pkanketh.value1 = v-spsname .
                when 818 then pkanketh.value1 = v-spfname .
                when 819 then pkanketh.value1 = v-spmname .
                when 820 then pkanketh.value1 = string(v-spwork)  .
                when 821 then pkanketh.value1 = v-spwplc  .
                when 822 then pkanketh.value1 = string(v-spsal)   .
                when 823 then pkanketh.value1 = v-tel[4]  .
                when 824 then pkanketh.value1 = string(v-memnum)  .
                when 825 then pkanketh.value1 = string(v-depend)  .
                when 826 then pkanketh.value1 = string(v-depend1) .
                when 827 then pkanketh.value1 = v-vidfin  .
                when 828 then pkanketh.value1 = string(v-sumtr)   .
                when 829 then pkanketh.value1 = string(v-sroktr)  .
                when 830 then pkanketh.value1 = string(v-gstav)   .
                when 831 then pkanketh.value1 = string(v-comorg)  .
                when 832 then pkanketh.value1 = v-metam   .
                when 833 then pkanketh.value1 = v-issue   .
                when 834 then pkanketh.value1 = string(v-dattr)   .
                when 835 then pkanketh.value1 = "".  /*возраст */
                when 750 then pkanketh.value1 = "".  /*Платеж по текущим (действующим) обязательства*/
                when 837 then pkanketh.value1 = "".  /*  Макс платеж по кредиту,тг(запрашив условия)  */
                when 838 then pkanketh.value1 = "".  /* Оценка платежеспособности (с учетом запрашив условий) */
                when 839 then pkanketh.value1 = "".  /* Максим сумма кредита, тг(исходя из доходов)  */
                when 840 then pkanketh.value1 = "".  /* Максимальный платеж по кредиту(исходя из доходов)  */
                when 841 then pkanketh.value1 = "".  /* Оценка платежеспособности (исходя из доходов)  */
            end case.
        end.
    end.
end procedure.