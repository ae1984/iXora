/* pcstedit.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Staff, Salary: Редактирование данных, открытие карточек и счетов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-1-3
 * AUTHOR
        08/06/2012 id00810
 * BASES
 		BANK COMM
 * CHANGES
        16/07/2012 id00810 - корректировка уже открытой карточки клиента по данным заявления
        23/08/2012 id00810 - доработка для Salary, переход на ИИН
        31/08/2012 id00810 - добавлен вызов bnkrel-chk.p (проверка клиентов, связанных с банком особыми отношениями)
        11/09/2012 id00810 - если карточка и счет уже открыты, то до выхода из программы присваивается статус = aaa
        12/10/2012 madiyar - обработка статуса 2 kfmAMLOnline
        15/10/2012 madiyar - подправил по статусу 2 kfmAMLOnline
        23/11/2012 id00810 - цифровой код страны для kfmAMLOnline
        28/11/2012 id00810 - ТЗ 1600: в условие выбора РНН(ИИН) добавлена проверка филиала, где он был загружен
        25/12/2012 id00810 - перекомпиляция
        26/12/2012 id00810 - v-work (место работы) - добавила орг.-прав.форму клиента
        04.01.2013 Lyubov  - исправила проверку по базе НК МФ, теперь поиск осуществляется по ИИН
        06.03.2013 Lyubov  - ТЗ 1745 - проверка длины Embossing name, в сумме не более 25 символов
        11.03.2013 Lyubov  - ТЗ 1742 - поле Кодовое слово обязятельно к заполнению
        13.03.2013 damir   - Внедрено Т.З. № 1558,1582.
        31.05.2013 Lyubov  - ТЗ №1864, в поиск добавлен прзнак физ/юр для корректного отбора карты
        10/06/2013 yerganat - в процедуру cif-kart добавил параметр
        10.06.2013 Lyubov  - ТЗ №1787, ищем запись со статусом отличным от Closed
        19.06.2013 Lyubov  - ТЗ №1899, поля embossing name обязятельны к заполнению
        05/08/2013 Luiza   - ТЗ 1728 проверка клиентов связан-х с банком
        16.08.2013 Lyubov  - ТЗ 2035, перенесла проверку связанности на момент открытия счета
        23.09.2013 Lyubov  - ТЗ 2050, добавила отправку письма если у клиента в базе НК МФ признак ИП
        17.10.2013 evseev - tz2128
        29.10.2013 Lyubov - ТЗ №2158, сохраняем ФИО в новые поля таблицы cif
        12.11.2013 Lyubov - ТЗ 2193, в поле Expdt таблицы cif сохраняем данные из pcstaff0.expdt
*/

def var v-bank     as char no-undo.
def var v-rnn      as char no-undo.
def var v-cif      as char no-undo.
def var v-iin      as char no-undo.
def var v-aaa      as char no-undo.
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
def var v-ofc1     as char no-undo.
def var v-ofc2     as char no-undo.
def var v-quest1   as logi no-undo format "Да/Нет".
def var v-quest2   as logi no-undo format "Да/Нет".
def var v-sts      as char no-undo.
def var v-yesc     as logi no-undo.
def var v-yesa     as logi no-undo.
def var vdep       as int  no-undo.
def var vpoint     as int  no-undo.
def var v-err      as char no-undo.
def var v-ref      as char no-undo.
def var s-accont   as char no-undo.
def var v-label    as char no-undo.
def var v-errorDes    as char no-undo.
def var v-operId      as char no-undo.
def var v-operStatus  as char no-undo.
def var v-operComment as char no-undo.

def new shared var s-aaa like aaa.aaa.
def new shared var s-lgr like lgr.lgr.
def new shared var s-cif like cif.cif.
def new shared var v-aaa9 as char.
def new shared var v-rate as decimal.
def new shared var in_command as decimal .
def new shared var V-sel As Integer FORMAT "9" init 1.
def new shared var st_period as integer initial 30.
def new shared var s-okcancel as logical initial False.
def new shared var s-cword as char.
def var v-resp as int.

{global.i}
{chbin.i}
{chk12_innbin.i}
{nbankBik.i}

   form
        v-label no-label format 'x(26)' v-rnn no-label colon 26 format "x(12)" validate(can-find(first pcstaff0 where pcstaff0.rnn = v-rnn and pcstaff0.bank = v-bank no-lock), "Нет такого РНН в базе Платежных карт вашего филиала! F2-помощь")
                                                                    v-cif       label "                  Код клиента " format "x(06)" skip
        v-iin      label " ИИН                     " format "x(12)" validate(can-find(first pcstaff0 where pcstaff0.iin = v-iin and pcstaff0.bank = v-bank no-lock), "Нет такого ИИН в базе Платежных карт вашего филиала! F2-помощь")
                                                                    v-aaa       label "    Тек.счет по платежн.карте " format "x(20)" skip(1)
        v-sname    label " Фамилия                 " format "x(30)" skip
        v-fname    label " Имя                     " format "x(20)" skip
        v-mname    label " Отчество                " format "x(20)" skip
        v-namelat1 label " Фамилия (лат.)          " format "x(20)" validate (v-namelat1 <> '', "Поле обязательно к заполнению!") v-namelat2  label "  Имя (лат.) " format "x(20)" validate (v-namelat2 <> '', "Поле обязательно к заполнению!") skip
        v-birth    label " Дата рождения           " format "99/99/9999" v-cword  label "                   Кодовое слово " format 'x(15)' validate (v-cword <> '', "Поле обязательно к заполнению!") skip(1)
        v-mail     label " E-mail                  " format "x(50)" skip
        v-work     label " Место работы            " format "x(30)" skip
        v-tel[1]   label " Телефон домашний        " format 'x(12)'  v-tel[2] label "                  Телефон моб. " format 'x(12)' skip
        v-addr[1]  label " Адрес регистрации       " format "x(50)"  skip
        v-addr[2]  label " Адрес проживания        " format "x(50)"  skip(1)
        v-nomdoc   label " Документ,удост.личность " format "x(15)"  v-isswho label "                  Кем выдан " format 'x(15)' skip
        v-issdt    label " Когда выдан             " format "99/99/9999"  v-expdt  label "                   Срок действия " format '99/99/9999' skip(1)
        v-crcname  label " Вид валюты              " format "x(03)" skip
        v-pctype   label " Вид карты               " format "x(10)" validate(can-find(first codfr where codfr.codfr = 'pctype' and codfr.name[1] = v-pctype no-lock), "Нет такого вида платежных карт! F2-помощь") skip(1)
        v-rez      label " Резидент да/нет         " format "Да/нет" skip
        v-country  label " Страна                  " format "x(03)" validate(can-find(first codfr where codfr.codfr = 'iso3166' and codfr.name[2] = v-country no-lock), "Нет такой страны в справочнике кодов стран! F2-помощь") skip(1)
        v-migrn    label " Миграционная карта №    " format "x(10)" skip
        v-migrdt1  label " Срок пребывания с       " format '99/99/9999' v-migrdt2 label "                              по " format '99/99/9999'skip
        v-publicf  label " Публич.должн.лицо да/нет" format "Да/нет" skip
        v-position label " Должность               " format "x(30)" skip
        v-offsh    label " Счета в оффшорных зонах " format "Да/нет" skip
        v-offshd   label " Доп.информация по счетам" format "x(30)" skip(1)
        v-quest1   label " Сохранить изменения?    " format "Да/нет" skip
        with side-labels centered row 3 title ' STAFF: заявление на выпуск ПК ' width 100 frame frpc.

    form
        v-quest2   label " Открыть карточку и счет?" format "Да/нет" skip
        with side-labels centered row 15 width 100 frame frpc1.

on "END-ERROR" of frame frpc do:
  hide frame frpc no-pause.
end.

on "END-ERROR" of frame frpc1 do:
  hide frame frpc1 no-pause.
end.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.

on help of v-rnn in frame frpc do:
    {itemlist.i
         &file    = "pcstaff0"
         &set     = "1"
         &frame   = "row 2 centered scroll 1 10 down width 55 overlay "
         &where   = " pcstaff0.bank = v-bank "
         &flddisp = " pcstaff0.rnn label 'РНН' format 'x(12)' pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname label 'ФИО клиента' format 'x(40)' "
         &chkey   = "rnn"
         &index   = "rnn"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
    v-rnn = pcstaff0.rnn.
    displ v-rnn with frame frpc.
end.
on help of v-iin in frame frpc do:
    {itemlist.i
         &file    = "pcstaff0"
         &set     = "1a"
         &frame   = "row 2 centered scroll 1 10 down width 55 overlay "
         &where   = " pcstaff0.bank = v-bank "
         &flddisp = " pcstaff0.iin label 'ИНН' format 'x(12)' pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname label 'ФИО клиента' format 'x(40)' "
         &chkey   = "iin"
         &index   = "iin"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
    v-iin = pcstaff0.iin.
    displ v-iin with frame frpc.
end.

on help of v-country in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 20 centered scroll 1 10 down width 50 overlay "
        &where   = " codfr.codfr = 'iso3166' and codfr.name[2] ne '' "
        &flddisp = " codfr.code label ' Код1 ' codfr.name[2] label ' Код2 ' format 'x(03)' codfr.name[1] label ' Название страны ' format 'x(25)' "
        &chkey   = "code"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-country = codfr.name[2].
    displ v-country with frame frpc.
end.

function GetLgrAcc returns char(input p-type as char,input p-crc as inte).
    def var v-res as char.
    def var v-lgr_B as char init "143,144,145". /*KZT,USD,EUR*/
    def var v-lgr_P as char init "138,139,140". /*KZT,USD,EUR*/

    p-type = trim(p-type).
    v-res = "".
    if num-entries(v-lgr_B) eq num-entries(v-lgr_P) and p-crc le num-entries(v-lgr_B) then do:
        if p-type eq "P" then v-res = trim(entry(p-crc,v-lgr_P)).
        else v-res = trim(entry(p-crc,v-lgr_B)).
    end.
    else message "Группа лицевого счета не найдена!!! ОШИБКА!!!" view-as alert-box.

    return v-res.
end function.

displ v-label v-rnn with frame frpc.
update v-iin help "ИИН клиента; F2-помощь; F4-выход" with frame frpc.
find first pcstaff0 where pcstaff0.iin = v-iin and pcstaff0.sts <> 'Closed' no-lock no-error.

    assign v-cif      = pcstaff0.cif
           v-aaa      = pcstaff0.aaa
           v-iin      = pcstaff0.iin
           v-sname    = pcstaff0.sname
           v-fname    = pcstaff0.fname
           v-mname    = pcstaff0.mname
           v-namelat1 = if num-entries(pcstaff0.namelat,' ') = 2 then  entry(1,pcstaff0.namelat,' ') else ''
           v-namelat2 = if num-entries(pcstaff0.namelat,' ') = 2 then  entry(2,pcstaff0.namelat,' ') else ''
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
           v-yesc     = no
           v-yesa     = no .
    find first crc where crc.crc = pcstaff0.crc no-lock no-error.
    if avail crc then v-crcname = trim(crc.code).
    find first codfr where codfr.codfr = 'pctype' and codfr.code = pcstaff0.pctype no-lock no-error.
    if avail codfr then v-pctype = codfr.name[1].
    if pcstaff0.cifb = v-bank then do:
        find first cmp no-lock no-error.
        v-work = cmp.name.
    end.
    else do:
        if pcstaff0.cifb begins 'txb' then v-work = v-nbankru.
        else do:
            find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
            if avail cif then v-work = cif.prefix + ' ' + cif.name.
        end.
    end.
    /*v-work = v-nbankru.*/

display v-cif v-iin v-aaa v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
        v-nomdoc v-isswho v-issdt v-expdt v-crcname v-pctype v-rez v-country v-migrn v-migrdt1
        v-migrdt2 v-publicf v-position v-offsh v-offshd v-quest1 with frame frpc.
if can-do('open,OK,closed',pcstaff0.sts) then do:
  message "Данное заявление недоступно для редактирования! Информация передана в карточную систему!" view-as alert-box error title ' Внимание '.
  return.
end.
if v-cif ne '' then do:
    find first cif where cif.cif = v-cif no-lock no-error.
    if not avail cif then return.
    v-yesc = yes.
    if cif.crg ne '' then do:
        message "Для редактирования заявления необходимо снять отметку о контроле карточки клиента " + v-cif + " (п.16.1.4)!" view-as alert-box error title " Внимание ".
        return.
    end.
    if v-aaa ne '' then do:
        find first aaa where aaa.aaa = pcstaff0.aaa no-lock no-error.
        if not avail aaa then return.
        v-yesa = yes.
    end.
end.
if not v-bin then update v-iin with frame frpc.
update v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-tel[1] v-tel[2]  v-addr[1] v-addr[2]
       v-nomdoc v-isswho v-issdt v-expdt v-rez with frame frpc.

repeat while length(trim(v-namelat1)) + length(trim(v-namelat2)) + 1 > 25:
    message 'Превышен лимит символов Embossing name. Вместо имени необходимо набрать первую букву имени' view-as alert-box.
    update v-namelat1 v-namelat2 with frame frpc.
end.

if not v-rez then do:
    update v-country v-migrn with frame frpc.
    if v-migrn ne '' then update v-migrdt1 v-migrdt2 with frame frpc.
    update v-publicf with frame frpc. if v-publicf then update v-position with frame frpc.
    update v-offsh with frame frpc. if v-offsh then update v-offshd with frame frpc.
end.
update v-quest1 with frame frpc.

if not v-quest1 then return.
pause 0.
find current pcstaff0 exclusive-lock.
assign pcstaff0.sname    = caps(v-sname)
       pcstaff0.fname    = caps(v-fname)
       pcstaff0.mname    = caps(v-mname)
       pcstaff0.namelat  = caps(v-namelat1) + ' ' + caps(v-namelat2)
       pcstaff0.birth    = v-birth
       pcstaff0.mail     = v-mail
       pcstaff0.cword    = v-cword
       pcstaff0.tel[1]   = v-tel[1]
       pcstaff0.tel[2]   = v-tel[2]
       pcstaff0.addr[1]  = v-addr[1]
       pcstaff0.addr[2]  = v-addr[2]
       pcstaff0.nomdoc   = v-nomdoc
       pcstaff0.issdoc   = v-isswho
       pcstaff0.issdt    = v-issdt
       pcstaff0.expdt    = v-expdt
       pcstaff0.rez      = v-rez
       pcstaff0.country  = v-country
       pcstaff0.migrn    = v-migrn
       pcstaff0.migrdt1  = v-migrdt1
       pcstaff0.migrdt2  = v-migrdt2
       pcstaff0.publicf  = v-publicf
       pcstaff0.position = v-position
       pcstaff0.offsh    = v-offsh
       pcstaff0.offshd   = v-offshd
       pcstaff0.who      = g-ofc
       pcstaff0.whn      = g-today.
if can-do('new,print',pcstaff0.sts) then pcstaff0.sts = 'edit'.
find first pcprod where pcprod.pcode  = pcstaff0.pcprod
                    and pcprod.pctype = pcstaff0.pctype
                    and pcprod.rez    = pcstaff0.rez
                    and pcprod.crc    = pcstaff0.crc
no-lock no-error.
if avail pcprod then do:
    assign pcstaff0.ccode = pcprod.ccode
           pcstaff0.acode = pcprod.acode.
end.
find current pcstaff0 no-lock no-error.
pause 0.
if v-cif = '' then do:
    find first cif where cif.bin = pcstaff0.iin and cif.type = 'P' no-lock no-error.
    if avail cif then do:
        v-cif = cif.cif.
        if cif.crg ne '' then do:
            create crg.
            assign crg.crg  = string(next-value(crgnum))
                   crg.des  = cif.cif
                   crg.who  = g-ofc
                   crg.whn  = g-today
                   crg.stn  = 0
                   crg.tim  = time
                   crg.regdt = today.
            find current cif exclusive-lock.
            cif.crg = "".
            find current cif no-lock no-error.
        end.
    end.
end.
if v-cif ne '' then do:
    find current cif exclusive-lock.
    assign cif.name       = caps(pcstaff0.sname) + ' ' + caps(pcstaff0.fname) + ' ' + caps(pcstaff0.mname)
           cif.sname      = caps(pcstaff0.sname) + ' ' + substr(pcstaff0.fname,1,1) + '.' + substr(pcstaff0.mname,1,1) + '.'
           cif.addr[1]    = pcstaff0.addr[1]
           cif.addr[2]    = pcstaff0.addr[2]
           cif.geo        = if pcstaff0.rez then '021' else '022'
           cif.tel        = pcstaff0.tel[1]
           cif.who        = g-ofc
           cif.whn        = g-today
           cif.tim        = time
           cif.pss        = pcstaff0.nomdoc + ' ' + string(pcstaff0.issdt) + ' '  + pcstaff0.issdoc
           cif.jss        = pcstaff0.rnn
           cif.ref[8]     = v-work
           cif.expdt      = pcstaff0.expdt
           cif.fax        = pcstaff0.tel[2]
           cif.birth      = pcstaff0.birth
           cif.mail       = pcstaff0.mail
           cif.namelat    = pcstaff0.namelat
           cif.registrcrd = pcstaff0.migrn
           cif.irs        = if pcstaff0.rez then 1 else 2
           cif.bin        = pcstaff0.iin
           cif.dtsrokul   = pcstaff0.expdt
           cif.reschar[1] = string(g-today)
           cif.famil      = pcstaff0.sname
           cif.imya       = pcstaff0.fname
           cif.otches     = pcstaff0.mname.
    find current cif no-lock no-error.
end.
pause 0.
if v-yesc and v-yesa then do:
    find current pcstaff0 exclusive-lock.
    pcstaff0.sts = 'aaa'.
    find current pcstaff0 no-lock no-error.
    return.
end.
message 'Открыть карточку клиента и текущий счет?'
view-as alert-box question buttons YES-NO title " Внимание !" update v-quest2.

if v-quest2 then do:
    /* проверка - связан ли с банком оо */
    /*v-resp = 0.
    run bnkrel-chk1(v-cif,output v-resp).
    if v-resp > 0 then return.*/

    /* проверка 1 - бездействующие налогоплательщики */
    /*if v-bin then find first inacttaxpayer where inacttaxpayer.bin = pcstaff0.iin no-lock no-error.
             else find first inacttaxpayer where inacttaxpayer.rnn = pcstaff0.rnn no-lock no-error.
    if avail inacttaxpayer then v-err = 'Налогоплательщик является бездействующим!'.
    else do:
        if v-bin then find first rnn where rnn.bin = pcstaff0.iin no-lock no-error.
        else find first rnn where rnn.trn = pcstaff0.rnn no-lock no-error.
        if not avail rnn then v-err = "Данный ИИН отсутствует в НК МФ!".
        else if (rnn.info[2] = '1' or  rnn.info[4] > '0') and rnn.info[5] = '1' and rnn.rwho = ''
        then v-err = 'Налогоплательщик является бездействующим!'.
    end.*/
    v-err = ''.
    find first bin where bin.bin = pcstaff0.iin no-lock no-error.
    if not avail bin then  v-err = 'Налогоплательщик является бездействующим!'.
    if avail bin and bin.f11 = '1' then  v-err = 'Налогоплательщик является бездействующим!'.
    if v-err ne '' then do:
        find current pcstaff0 exclusive-lock.
        assign pcstaff0.sts     = 'reject'
               pcstaff0.who     = g-ofc
               pcstaff0.whn     = g-today
               pcstaff0.info[1] = v-err.
        find current pcstaff0 no-lock no-error.
        message v-err + ' Платежная карточка не может быть выпущена!' view-as alert-box error title ' Внимание! '.
        return.
    end.
    pause 0.
    /* проверка2 -  в AML */
    find first codfr where codfr.codfr = 'iso3166' and codfr.name[2] = v-country no-lock no-error.
    if avail codfr then find first code-st where code-st.code = codfr.code no-lock no-error.
    if avail code-st then v-cntr = code-st.cod-ch.
    /*if pcstaff0.rez then v-country = 'Казахстан'.*/
    v-ref = if pcstaff0.sts = 'finmon' then (if v-bin then pcstaff0.iin else pcstaff0.rnn) + "_" + substr(string(year(pcstaff0.whn)),3,2) + string(month(pcstaff0.whn),'99') + string(day(pcstaff0.whn),'99')
                                       else (if v-bin then pcstaff0.iin else pcstaff0.rnn) + "_" + substr(string(year(g-today)),3,2) + string(month(g-today),'99') + string(day(g-today),'99').
    pause 0.
    run kfmAMLOnline(v-ref, /* номер операции: РНН_дата */
                 v-cntr,  /*страна*/
                 pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname,   /*ФИО*/
                 "",
                 '1',
                 '1',
                 "",
                 "",
                 "",
                 output v-errorDes,
                 output v-operId,
                 output v-operStatus,
                 output v-operComment).
    pause 0.
    if trim(v-errorDes) <> '' then do:
        message "Ошибка!~n" + v-errorDes + "~nПри необходимости обратитесь в ДИТ" view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.

    if v-operStatus = '0' then do:
        message "Проведение операции запрещено! Данные клиента отправлены на проверку в службу Комплаенс!" view-as alert-box information buttons ok title ' Внимание! '.
        run mail("cs@fortebank.com", g-ofc + "@fortebank.com", "Необходима проверка клиента",
                 "Необходима проверка клиента " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", дата рождения " + string(pcstaff0.birth) + ", ИИН " + pcstaff0.iin + ", страна " + v-cntr, "0", "", "").
        find current pcstaff0 exclusive-lock.
        assign pcstaff0.sts = 'finmon'
               pcstaff0.who = g-ofc
               pcstaff0.whn = g-today
               pcstaff0.info[1] = 'Отправлено на проверку в службу комплаенс'.
        find current pcstaff0 no-lock no-error.
        return.
    end.

    if v-operStatus = '2' then do:
        message "Проведение операции запрещено службой Комплаенс!"  + "~n Платежная карточка не может быть выпущена!" view-as alert-box title ' Внимание! '.
        find current pcstaff0 exclusive-lock.
        assign pcstaff0.sts = 'reject'
               pcstaff0.who = g-ofc
               pcstaff0.whn = g-today
               pcstaff0.info[1] = 'Отказано службой комплаенс'.
        find current pcstaff0 no-lock no-error.
        return.
    end.


    find current pcstaff0 exclusive-lock.
        assign pcstaff0.sts = 'contr'
               pcstaff0.who = g-ofc
               pcstaff0.whn = g-today
               .
    find current pcstaff0 no-lock no-error.
    message "Контроль пройден успешно!" view-as alert-box  title ' Внимание! '.

    pause 0.

    if v-bin then find first cif where cif.bin = v-iin and cif.type = 'P' no-lock no-error.
             else find first cif where cif.jss = v-rnn and cif.type = 'P' no-lock no-error.
    if avail cif then message "Карточка клиента " + cif.cif + " была открыта ранее!" view-as alert-box  information buttons ok title " Внимание" .
    else do:
            find nmbr where nmbr.code = "CIF" exclusive-lock.
            v-cif = string(nmbr.prefix + string(nmbr.nmbr + 1) + nmbr.sufix).
            nmbr.nmbr = nmbr.nmbr + 1.
            release nmbr.
            create cif.
            cif.cif = v-cif.
            assign cif.type    = 'P'
                   cif.name    = caps(pcstaff0.sname) + ' ' + caps(pcstaff0.fname) + ' ' + caps(pcstaff0.mname)
                   cif.sname   = caps(pcstaff0.sname) + ' ' + substr(pcstaff0.fname,1,1) + '.' + substr(pcstaff0.mname,1,1) + '.'
                   cif.addr[1] = pcstaff0.addr[1]
                   cif.addr[2] = pcstaff0.addr[2]
                   cif.geo     = if pcstaff0.rez then '021' else '022'
                   cif.tel     = pcstaff0.tel[1]
                   cif.regdt   = g-today
                   cif.who     = g-ofc
                   cif.whn     = g-today
                   cif.tim     = time
                   cif.pss     = pcstaff0.nomdoc + ' ' + string(pcstaff0.issdt) + ' '  + pcstaff0.issdoc
                   cif.jss     = pcstaff0.rnn
                   cif.ofc     = g-ofc
                   cif.cgr     = 501
                   cif.ref[8]  = v-work  /*!!!!*/
                   cif.expdt   = pcstaff0.expdt
                  /* cif.attn    = pcstaff0.cword*/
                   cif.fax     = pcstaff0.tel[2]
                   cif.fname   = g-ofc
                   cif.mname   = if pcstaff0.pcprod = 'staff' then 'EMP' else 'CLN'
                   cif.birth   = pcstaff0.birth
                   cif.mail    = pcstaff0.mail
                   cif.namelat = pcstaff0.namelat
                   cif.registrcrd = pcstaff0.migrn
                   cif.irs        = if pcstaff0.rez then 1 else 2
                   cif.bin        = pcstaff0.iin
                   cif.dtsrokul   = pcstaff0.expdt
                   cif.reschar[1] = string(g-today)
                   cif.famil      = pcstaff0.sname
                   cif.imya       = pcstaff0.fname
                   cif.otches     = pcstaff0.mname.
           find first ofc where ofc.ofc = g-ofc no-lock no-error.
           if avail ofc then cif.jame = string(ofc.regno).
           vpoint = integer(cif.jame) / 1000 - 0.5.
           vdep = integer(cif.jame) - vpoint * 1000.
           pause 0.
           run cifproft.
           pause 0.
           run avto_p.
           pause 0.
           find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'publicf' no-lock no-error.
           if not avail sub-cod then do:
                create sub-cod.
                assign sub-cod.acc   = cif.cif
                       sub-cod.sub   = 'cln'
                       sub-cod.d-cod = 'publicf'
                       sub-cod.ccode = if pcstaff0.publicf then '2' else '1'
                       sub-cod.rdt   = g-today.
          end.
          find first cif-mail where cif-mail.cif = cif.cif no-lock no-error.
          if not avail cif-mail then do:
            create cif-mail.
            assign cif-mail.cif = cif.cif
                   cif-mail.mail = pcstaff0.mail.
          end.

        message 'Открыта карточка клиента ' + cif.cif view-as alert-box information buttons ok title ' Внимание! '.
        pause 0.
    end.

    find first aaa where aaa.cif = cif.cif and aaa.gl = 220430 and aaa.sta ne 'C' no-lock no-error.
    if not avail aaa then do:
        s-cif = cif.cif.
        s-lgr = GetLgrAcc(trim(cif.type),pcstaff0.crc).
        pause 0.
        run bnkrel-chk. /*Признак связанности с банком особыми отношениями*/

        v-resp = 0.
        run bnkrel-chk1(v-cif,output v-resp).
        if v-resp > 0 then return.

        pause 0.
        run new-acc.
        pause 0.
        if s-aaa eq "" then do:
            message "Account number generation error.".
            pause 5.
            return.
        end.
        s-accont  =  s-aaa.
        pause 0.
        run  cif-new2.
        s-aaa = s-accont.
        s-cword = pcstaff0.cword.
        pause 0.
        run pcstdog. /*Договор текущего счета по ПК*/
        pause 0.
        run cif-kart(0). /*Документ с образцом подписи*/
        pause 0.
        run cif-title.
        pause 0.
        hide  all.
        find first aaa where aaa.aaa = s-aaa no-lock no-error.

        find first rnn where rnn.bin = cif.bin no-lock no-error.
        if rnn.info[2] = "1" or rnn.info[4] = "1" or rnn.info[4] = "2" or rnn.info[4] = "3" or rnn.info[4] = "4" then do:
           find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
           if avail sysc then run mail(entry(5, sysc.chval, "|"), "ACC <acc@metrocombank.kz>",
               "Клиент состоит на регистрационном учете.", "Клиент " + cif.cif + " " + trim(cif.name) + " " +  s-aaa
               + " состоит на регистрационном учете. Необходимо проверить формирование уведомления в НК","", "", "").
        end.

        message 'Открыт счет ' + s-aaa view-as alert-box information buttons ok title ' Внимание! '.
        pause 0.
    end.
    pause 0.
/*    message 'Открыт счет ' + aaa.aaa view-as alert-box title ' Внимание! '.*/
    find current pcstaff0 exclusive-lock no-error.
        assign pcstaff0.cif = cif.cif
               pcstaff0.aaa = aaa.aaa
               pcstaff0.sts = /*'ready'*/ 'aaa'.
    find current pcstaff0 no-lock no-error.
    /*pcstaff0.sts = 'ready'.*/
    /*find first pcprod where pcprod.pcode  = pcstaff0.pcprod
                        and pcprod.pctype = pcstaff0.pctype
                        and pcprod.rez    = pcstaff0.rez
                        and pcprod.crc    = pcstaff0.crc
    no-lock no-error.
    if avail pcprod then do:
        find current pcstaff0 exclusive-lock.
        assign pcstaff0.ccode = pcprod.ccode
               pcstaff0.acode = pcprod.acode
               .
        find current pcstaff0 no-lock no-error.
    end.*/
end.
hide frame frpc no-pause.

procedure cifproft.
def var prof-prefix as char.
  find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = cif.cif no-error.
  if not available sub-cod then do:
    create sub-cod.
    assign sub-cod.sub = "cln"
           sub-cod.d-cod = "sproftcn"
           sub-cod.acc = cif.cif
           sub-cod.ccode = ofc.titcd
           sub-cod.rdt = g-today
           sub-cod.ccode = "msc".
  end.

  if sub-cod.ccode = "msc" /*or vdep0 <> vdep*/ then do:
    /* по департаменту - если центр.офис, то 103 */
    if vdep = 1 then
      sub-cod.ccode = "103".
    else do:
      /* коды РКО в зависимости от филиала - Алматы A, Астана B, Уральск C */
      find sysc where sysc.sysc = "PCRKO" no-lock no-error.
      if not available sysc then prof-prefix = "U".
      else prof-prefix = trim(sysc.chval).
      sub-cod.ccode = prof-prefix + string(vdep, '99').
    end.
  end.
end procedure.

procedure avto_p.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnsts' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.acc = cif.cif.
        sub-cod.sub = 'cln'.
        sub-cod.d-cod = 'clnsts'.
        sub-cod.ccode = '1'.
        sub-cod.rdt = g-today.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'ecdivis' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.acc = cif.cif.
        sub-cod.sub = 'cln'.
        sub-cod.d-cod = 'ecdivis'.
        sub-cod.ccode = '0'.
        sub-cod.rdt = g-today.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'regionkz' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.acc = cif.cif.
        sub-cod.sub = 'cln'.
        sub-cod.d-cod = 'regionkz'.
        sub-cod.rdt = g-today.
        find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
        if avail sysc then do:
            if sysc.chval = 'RKC00' or sysc.chval = 'TXB00' then sub-cod.ccode = '75'.
            if sysc.chval = 'TXB01' then sub-cod.ccode = '15'.
            if sysc.chval = 'TXB02' then sub-cod.ccode = '39'.
            if sysc.chval = 'TXB03' then sub-cod.ccode = '31'.
            if sysc.chval = 'TXB04' then sub-cod.ccode = '27'.
            if sysc.chval = 'TXB05' then sub-cod.ccode = '35'.
            if sysc.chval = 'TXB06' then sub-cod.ccode = '63'.
            if sysc.chval = 'TXB07' then sub-cod.ccode = '11'.
            if sysc.chval = 'TXB08' then sub-cod.ccode = '71'.
            if sysc.chval = 'TXB09' then sub-cod.ccode = '55'.
            if sysc.chval = 'TXB10' then sub-cod.ccode = '59'.
            if sysc.chval = 'TXB11' then sub-cod.ccode = '23'.
            if sysc.chval = 'TXB12' then sub-cod.ccode = '47'.
            if sysc.chval = 'TXB13' then sub-cod.ccode = '35'.
            if sysc.chval = 'TXB14' then sub-cod.ccode = '63'.
            if sysc.chval = 'TXB15' then sub-cod.ccode = '51'.
            if sysc.chval = 'TXB16' then sub-cod.ccode = '19'.
        end.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'rnnsp' no-lock no-error.
    if not avail sub-cod then do:
        find first codfr where codfr.codfr = 'rnnsp' and codfr.code = substring(cif.jss,1,4) no-lock no-error.
        if avail codfr then do:
            create sub-cod.
            sub-cod.acc = cif.cif.
            sub-cod.sub = 'cln'.
            sub-cod.d-cod = 'rnnsp'.
            sub-cod.rdt = g-today.
            sub-cod.ccode = codfr.code.
        end.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'secek' no-lock no-error.
        if not avail sub-cod then do:
            create sub-cod.
            sub-cod.acc = cif.cif.
            sub-cod.sub = 'cln'.
            sub-cod.d-cod = 'secek'.
            sub-cod.ccode = '9'.
            sub-cod.rdt = g-today.
        end.
        else do:
            sub-cod.ccode = '9'.
        end.
end procedure.

