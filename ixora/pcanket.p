/* pcanket.p
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Анкета клиента для установления кред.лимита
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
        17.07.2013 Lyubov - ТЗ 1968, поменяла and на or при проверке полей по КЛ
        17.09.2013 Lyubov - перекомпиляция в связи с изменением pcanket.f по тз 2081
        16.10.2013 Lyubov - перекомпиляция в связи с изменением pcanket.f
        07.11.2013 Lyubov - ТЗ №2187, добавлен if avail для таблицы cif при поиске карточки компании
        13.11.2013 Lyubov - ТЗ №1922, добавлена проверка наличия ограничений и блокровак по счету
*/

{global.i}

def shared var v-aaa      as char no-undo.
def shared var s-credtype as char init '4' no-undo.
def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var v-cls      as logi no-undo.

def var phand      as handle no-undo.
def var v-iin      as char no-undo.
def var v-sname    as char no-undo.
def var v-fname    as char no-undo.
def var v-mname    as char no-undo.
def var v-namelat1 as char no-undo.
def var v-namelat2 as char no-undo.
def var v-birth    as date no-undo.
def var v-mail     as char no-undo.
def var v-tel      as char no-undo extent 2.
def var v-addr     as char no-undo extent 2.
def var v-work     as char no-undo.
def var v-nomdoc   as char no-undo.
def var v-issdt    as date no-undo.
def var v-expdt    as date no-undo.
def var v-isswho   as char no-undo.
def var v-cword    as char no-undo.
def var v-crcname  as char no-undo.
def var v-pctype   as char no-undo.
def var v-rez      as logi no-undo format "Да/Нет".
def var v-country  as char no-undo.
def var v-cntr     as char no-undo init '398'.
def var v-migrn    as char no-undo.
def var v-migrdt1  as date no-undo.
def var v-migrdt2  as date no-undo.
def var v-publicf  as logi no-undo.
def var v-position as char no-undo.
def var v-offsh    as logi no-undo.
def var v-offshd   as char no-undo.
def var v-salary   as deci no-undo.
def var v-bplace   as char no-undo.
def var v-hdt      as date no-undo.
def var v-ofc1     as char no-undo.
def var v-ofc2     as char no-undo.
def var v-quest1   as logi no-undo format "Да/Нет".
def var v-quest2   as logi no-undo format "Да/Нет".
def var v-quest3   as logi no-undo format "Да/Нет".
def var v-upd      as logi no-undo.
def var v-sts      as char no-undo.
def var v-sms      as logi no-undo format "Да/Нет".
def var v-yesc     as logi no-undo.
def var v-yesa     as logi no-undo.
def var v-relative as char no-undo.
def var v-relfio   as char no-undo.
def var v-reladr   as char no-undo.
def var v-reltel   as char no-undo.
def var v-spouse   as char no-undo.
def var v-spofio   as char no-undo.
def var v-spotel   as char no-undo.
def var v-active   as char no-undo.
def var v-estate   as char no-undo.
def var v-car      as char no-undo.
def var v-sp       as char no-undo.
def var k          as inte no-undo.
def var l          as inte no-undo.

{nbankBik.i}
{pcanket.f}

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.

update v-cifcod help "Счет клиента; F2-помощь; F4-выход" with frame frpc.
find first pcstaff0 where pcstaff0.cif = v-cifcod no-lock no-error.

assign v-aaa      = pcstaff0.aaa
       v-iin      = pcstaff0.iin
       v-sname    = pcstaff0.sname
       v-fname    = pcstaff0.fname
       v-mname    = pcstaff0.mname
       v-namelat1 = if num-entries(pcstaff0.namelat,' ') = 2 then entry(1,pcstaff0.namelat,' ') else ''
       v-namelat2 = if num-entries(pcstaff0.namelat,' ') = 2 then entry(2,pcstaff0.namelat,' ') else ''
       v-birth    = pcstaff0.birth
       v-mail     = pcstaff0.mail
       v-cword    = pcstaff0.cword
       v-tel[1]   = pcstaff0.tel[1]
       v-tel[2]   = pcstaff0.tel[2]
       v-addr[1]  = pcstaff0.addr[1]
       v-addr[2]  = pcstaff0.addr[2]
       v-nomdoc   = pcstaff0.nomdoc
       v-isswho   = pcstaff0.issdoc
       v-issdt    = pcstaff0.issdt
       v-expdt    = pcstaff0.expdt
       v-rez      = pcstaff0.rez
       v-country  = pcstaff0.country
       v-migrn    = pcstaff0.migrn
       v-migrdt1  = pcstaff0.migrdt1
       v-migrdt2  = pcstaff0.migrdt2
       v-publicf  = pcstaff0.publicf
       v-position = pcstaff0.position
       v-offsh    = pcstaff0.offsh
       v-offshd   = pcstaff0.offshd
       v-sms      = pcstaff0.sms
       v-hdt      = pcstaff0.hdt
       v-bplace   = pcstaff0.bplace
       v-salary   = pcstaff0.salary
       v-yesc     = no
       v-yesa     = no .

find first crc where crc.crc = pcstaff0.crc no-lock no-error.
if avail crc then v-crcname = crc.code.
find first codfr where codfr.codfr = 'pctype' and codfr.code = pcstaff0.pctype no-lock no-error.
if avail codfr then v-pctype = codfr.name[1].
if pcstaff0.cifb = v-bank then do: message 'Сотруднику кредитный лимит устанавливается на портале!' view-as alert-box. return. end.
else do:
    find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
    if avail cif then v-work = cif.prefix + ' ' + cif.name.
end.

find last aas where aas.aaa = pcstaff0.aaa no-lock no-error.
if avail aas then do:
    message "Внимание, у " pcstaff0.sname ' ' pcstaff0.fname ' ' pcstaff0.mname " имеется ограничение " aas.payee " от " string(aas.whn,'99.99.9999')
    ", в связи с чем установление Кредитного лимита в настоящий момент не может быть рассмотрено, до момента фактического снятия ограничения"
    view-as alert-box.
    return.
end.

display v-cifcod v-iin v-aaa v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
        v-nomdoc v-isswho v-issdt v-expdt v-crcname v-pctype v-rez v-country v-migrn v-migrdt1
        v-migrdt2 v-publicf v-position v-offsh v-offshd v-sms v-hdt v-bplace v-salary v-quest1 with frame frpc.

if not v-cls then do:
    if pcstaff0.salary = 0 or pcstaff0.bplace = '' or pcstaff0.hdt = ? then do:
        repeat while v-salary = 0 or v-bplace = '' or v-hdt = ?:
            update v-hdt v-salary v-bplace with frame frpc.
        end.
        update v-quest2 with frame frpc.
        if v-quest2 then do:
            find current pcstaff0 exclusive-lock no-error.
            assign pcstaff0.salary  = v-salary
                   pcstaff0.bplace  = v-bplace
                   pcstaff0.hdt     = v-hdt
                   pcstaff0.salfile = no.
            find current pcstaff0 no-lock no-error.
        end.
    end.
end.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '4' and pkanketa.aaa = v-aaa no-lock no-error.
if not avail pkanketa then do:
    create pkanketa.
    assign pkanketa.bank     = v-bank
           pkanketa.cif      = v-cifcod
           pkanketa.credtype = '4'
           pkanketa.ln       = next-value(anknom)
           pkanketa.rnn      = v-iin
           pkanketa.aaa      = v-aaa
           pkanketa.docnum   = nomdoc
           pkanketa.name     = caps(v-sname) + ' ' + caps(v-fname) + ' ' + caps(v-mname)
           pkanketa.rdt      = g-today
           pkanketa.rwho     = g-ofc
           pkanketa.crc      = 1
           pkanketa.addr1    = v-addr[1]
           pkanketa.addr2    = v-addr[2]
           pkanketa.sts      = '01'.
           find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
           if avail cif then assign
           pkanketa.jobrnn   = cif.bin
           pkanketa.jobname  = cif.prefix + ' ' + cif.name
           pkanketa.jobaddr  = cif.addr[1] + cif.addr[2] + cif.addr[3].
end.
s-ln = pkanketa.ln.

if pcstaff0.salary > 0 then do:
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = s-ln and pkanketh.kritcod = 'salary' no-lock no-error.
    if not avail pkanketh then do:
        create pkanketh.
        assign pkanketh.bank      = pcstaff0.bank
               pkanketh.cif       = pcstaff0.cif
               pkanketh.credtype  = '4'
               pkanketh.ln        = pkanketa.ln
               pkanketh.kritcod   = 'salary'
               pkanketh.value1    = string(pcstaff0.salary)
               pkanketh.rdt       = g-today
               pkanketh.rwho      = g-ofc
               pkanketh.rescha[1] = string(pcstaff0.salary).
    end.

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = s-ln and pkanketh.kritcod = 'credlim' no-lock no-error.
    if not avail pkanketh then do:
        create pkanketh.
        assign pkanketh.bank      = pcstaff0.bank
               pkanketh.cif       = pcstaff0.cif
               pkanketh.credtype  = '4'
               pkanketh.ln        = pkanketa.ln
               pkanketh.kritcod   = 'credlim'
               pkanketh.value1    = string(pcstaff0.salary * 1.2)
               pkanketh.rdt       = g-today
               pkanketh.rwho      = g-ofc
               pkanketh.rescha[1] = string(pcstaff0.salary * 1.2).
    end.
end.

if v-cls and not can-do ('150,160,99',pkanketa.sts) then do:
    message 'Кредитный лимит не установлен! Закрытие незвозможно!' view-as alert-box.
    return.
end.
if v-cls and pkanketa.sts = '150' and pkanketa.sts = '160' then do:
    message 'Кредитный лимит уже закрыт!' view-as alert-box.
    return.
end.

if v-cls = no then do:
    update v-quest1 with frame frpc.
    if v-quest1 then do:
        find first pksysc where pksysc.sysc = 'credank' no-lock no-error.
        if avail pksysc then v-sp = pksysc.chval.
        find first pkanketa where pkanketa.aaa = pcstaff0.aaa and pkanketa.credtype = '4' no-lock no-error.
        k = 0.
        do l = 1 to num-entries(v-sp):
        k = k + 1.
            find first pkkrit where pkkrit.ln = int(entry(k,v-sp)) no-lock no-error.
            find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '4' and pkanketh.ln = s-ln and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.
            if avail pkanketh then do:
                case pkkrit.ln:
                    when 800 then v-relfio = pkanketh.value1.
                    when 801 then v-reladr = pkanketh.value1.
                    when 802 then v-reltel = pkanketh.value1.
                    when 803 then v-spofio = pkanketh.value1.
                    when 804 then v-spotel = pkanketh.value1.
                    when 805 then v-estate = pkanketh.value1.
                    when 806 then v-car    = pkanketh.value1.
                end case.
            end.
        end.
        displ v-relfio v-reladr v-reltel v-spofio v-spotel v-estate v-car v-quest3 with frame dopinfo.
        update v-relfio v-reladr v-reltel v-spofio v-spotel with frame dopinfo.
        update v-estate help 'Город, улица/проспект, дом №, квартира №' with frame dopinfo.
        update v-car    help 'Марка, год выпуска, тех. номер' with frame dopinfo.
        update v-quest3 with frame dopinfo.
        if v-quest3 then do:
            do k = 1 to num-entries(v-sp):
                find first pkkrit where pkkrit.ln = int(entry(k,v-sp)) no-lock no-error.
                if not avail pkkrit then next.
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '4' and pkanketh.ln = s-ln and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.
                if avail pkanketh then do:
                    find current pkanketh exclusive-lock no-error.
                    pkanketh.rdt  = g-today.
                    pkanketh.rwho = g-ofc.
                    case pkkrit.ln:
                        when 800 then pkanketh.value1 = v-relfio.
                        when 801 then pkanketh.value1 = v-reladr.
                        when 802 then pkanketh.value1 = v-reltel.
                        when 803 then pkanketh.value1 = v-spofio.
                        when 804 then pkanketh.value1 = v-spotel.
                        when 805 then pkanketh.value1 = v-estate.
                        when 806 then pkanketh.value1 = v-car.
                    end case.
                end.
                else do:
                    create pkanketh.
                    assign pkanketh.bank     = v-bank
                           pkanketh.cif      = pcstaff0.cif
                           pkanketh.credtype = '4'
                           pkanketh.ln       = pkanketa.ln
                           pkanketh.kritcod  = pkkrit.kritcod
                           pkanketh.value3   = pkkrit.priz
                           pkanketh.rdt      = g-today
                           pkanketh.rwho     = g-ofc.
                    case pkkrit.ln:
                        when 800 then pkanketh.value1 = v-relfio.
                        when 801 then pkanketh.value1 = v-reladr.
                        when 802 then pkanketh.value1 = v-reltel.
                        when 803 then pkanketh.value1 = v-spofio.
                        when 804 then pkanketh.value1 = v-spotel.
                        when 805 then pkanketh.value1 = v-estate.
                        when 806 then pkanketh.value1 = v-car.
                    end case.
                end.
            end.
        end.
    end.
end.