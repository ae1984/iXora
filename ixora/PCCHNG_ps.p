/* PCCHNG_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Обмен данными с карточной системой
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
        BANK COMM
 * AUTHOR
        28.12.12 id00810
* CHANGES
        17.01.2013 Lyubov  - обработка случаев локировки записей
        04.02.2013 Lyubov  - ТЗ №1692, изменен формат входящего файла, программа приведена в соответствие
        07.02.2013 Lyubov  - ТЗ №1692, заменяем амперсанд(&) в названии компании на слово and
        04.04.2013 Lyubov  - ТЗ №1772, ФИО в pccards тянется из pcstaff0
        22/07/2013 galina - ТЗ1903, при загрузке ответника обновляется номер карты в pcstaff0 и pccards
        29.08.2013 Lyubov - ТЗ №2048, на тестовом работаем с С:\, обработка нового поля prodotv, не смотрим на статус счета
        25.09.2013 Lyubov - ТЗ №2069, обработка нового поля prodtarif
        04/10/2013 galina - ТЗ1470 для перевыпуска по причине 4 (смена эмбосинг найм) указываем наименование на латинском
        18.10.2013 Lyubov - ТЗ 2155, статус счета тянется из 6 поля ответного файла
*/

def shared var g-today as date.
def shared var g-ofc   as char.
{massxml.i}
def var v-bank    as char no-undo.
def var i         as inte no-undo.
def var v-sel     as char no-undo.
def var v-fname   as char no-undo.
def var v-cifname as char no-undo.
def var v-expdt   as date no-undo.
def var v-sts     as char no-undo.
def new shared temp-table tmp
	field fil        as char
    field shortname  as char
    field iin        as char
    field acc        as char
    field accsts     as char
    field cardnumber as char
    field cardsts    as char
    field dtexp      as char
    field namelat    as char
    field prod       as char.

def buffer b-pcstaff0 for pcstaff0.
def buffer b-pccards  for pccards.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    run savelog( "PCCHNG", " Нет параметра ourbnk sysc!").
    return.
end.
v-bank = sysc.chval.

find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.sts = "ready" and pcstaff0.pcard = '' no-lock no-error.
if avail pcstaff0 then run outabn.    /* отправка заказа на выпуск карт */

find first pccards where pccards.bank = v-bank and pccards.sts = "reready" and pccards.info[4] = "" no-lock no-error.
if avail pccards then run reoutabn . /* отправка заказа на перевыпуск карт */

if v-bank = 'TXB00' then run inabn.     /* получение файла ответа с номерами выпускаемых карт */

/* Отправка заказа на выпуск карт */
procedure outabn.
    empty temp-table tmp2.
    for each pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.sts = "ready" and pcstaff0.pcard = '' no-lock:
        find first pcprod where pcprod.pcode = pcstaff0.pcprod
                            and pcprod.ccode = pcstaff0.ccode
                            and pcprod.acode = pcstaff0.acode
                            no-lock no-error.
        if not avail pcprod then do:
            run savelog( "PCCHNG", 'err1 ' +  pcstaff0.iin  + " Не найдена запись в таблице pcprod!").
            next.
        end.
        if pcprod.sup then do:
            find first pccards where pccards.aaa = pcstaff0.aaa and pccards.sts = 'ok' no-lock no-error.
            if not avail pccards then do:
                run savelog( "PCCHNG", 'err2 ' + pcstaff0.iin  + " Не найдена запись в таблице pccards!").
                next.
            end.
        end.
        create tmp2.
        assign
        tmp2.namef   = pcstaff0.namef
        tmp2.nomdoc  = pcstaff0.nomdoc
        tmp2.rez     = pcstaff0.rez
        tmp2.aaa     = pcstaff0.aaa
        tmp2.issdoc  = pcstaff0.issdoc
        tmp2.issdt   = pcstaff0.issdt
        tmp2.sname   = pcstaff0.sname
        tmp2.fname   = pcstaff0.fname
        tmp2.mname   = pcstaff0.mname
        tmp2.namelat = upper(pcstaff0.namelat)
        tmp2.cword   = pcstaff0.cword
        tmp2.country = pcstaff0.country
        tmp2.birth   = pcstaff0.birth
        tmp2.tel1    = pcstaff0.tel[1]
        tmp2.tel2    = pcstaff0.tel[2]
        tmp2.city    = ''
        tmp2.addr1   = pcstaff0.addr[1]
        tmp2.acode   = pcstaff0.acode
        tmp2.orddep2 = substring(pcstaff0.bank,4,2)
        tmp2.rnn     = pcstaff0.rnn
        tmp2.iin     = pcstaff0.iin
        tmp2.ccode   = pcstaff0.ccode
        tmp2.sup     = pcprod.sup.

        find first crc where crc.crc = pcstaff0.crc no-lock no-error.
        if avail crc then tmp2.crc = crc.code.

        if pcstaff0.pcprod = 'salary' then do:
            find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
            if avail cif then tmp2.company = trim(replace(cif.prefix + ' ' + cif.name,'&','and')).
        end.
        else tmp2.company = 'АО FORTEBANK'.
        tmp2.cltype = if tmp2.rez then "APR_" else "APN_".
    end.

    find first tmp2 where not tmp2.sup no-lock no-error.
    if avail tmp2 then do:
        run Put_header.
        for each tmp2 where not tmp2.sup no-lock:
            run Put_application.
            find first b-pcstaff0 where b-pcstaff0.namef = tmp2.namef and b-pcstaff0.aaa = tmp2.aaa and b-pcstaff0.namefout eq "" exclusive-lock no-error no-wait.
            if locked b-pcstaff0 then message 'Locked b-pcstaff0 :' b-pcstaff0.bank b-pcstaff0.cif b-pcstaff0.iin file-name string(time,'hh:mm:ss').
            if avail b-pcstaff0 then do:
                assign b-pcstaff0.namefout = file-name
                       b-pcstaff0.sts      = "open"
                       b-pcstaff0.who      = g-ofc
                       b-pcstaff0.whn      = g-today.
            end.
        end.
        run Put_footer.
        run Copyfile.
    end.
    find first tmp2 where tmp2.sup no-lock no-error.
    if avail tmp2 then do:
        run Put_header.
        for each tmp2 where tmp2.sup no-lock:
            run Put_applicationS.
            find first b-pcstaff0 where b-pcstaff0.namef = tmp2.namef and b-pcstaff0.aaa = tmp2.aaa and b-pcstaff0.namefout eq "" exclusive-lock no-error no-wait.
            if locked b-pcstaff0 then message 'Locked b-pcstaff0 sup:' b-pcstaff0.bank b-pcstaff0.cif b-pcstaff0.iin file-name string(time,'hh:mm:ss').
            if avail b-pcstaff0 then do:
                assign b-pcstaff0.namefout = file-name
                       b-pcstaff0.sts      = "open"
                       b-pcstaff0.who      = g-ofc
                       b-pcstaff0.whn      = g-today.
            end.
        end.
        run Put_footer.
        run Copyfile.
    end.
end procedure.

/* Отправка заказа на перевыпуск карт */
procedure reoutabn.
    empty temp-table tmp2.
    for each pccards where pccards.bank = v-bank and pccards.sts = "reready" and pccards.info[4] = "" no-lock:
        create tmp2.
        assign tmp2.pcard   = pccards.pcard
               tmp2.expdt   = substr(string(pccards.expdt),4,2) + substr(string(pccards.expdt),7,2)
               tmp2.nomdoc  = pccards.info[3]
               tmp2.sname   = entry(1,pccards.sname,' ')
               tmp2.fname   = entry(2,pccards.sname,' ')
               tmp2.mname   = entry(3,pccards.sname,' ')
               tmp2.orddep2 = substring(pccards.bank,4,2)
               tmp2.reason  = pccards.info[2].
         if tmp2.reason = '4' then do:
            find first pcstaff0 where pcstaff0.cif = pccards.cif no-lock no-error.
            if avail pcstaff0 then tmp2.namelat = pcstaff0.namelat.
         end.

        find first codfr where codfr.codfr = 'pcreason'
                           and codfr.code  = pccards.info[2]
                           no-lock no-error.
        if avail codfr then assign tmp2.prtype  = codfr.name[2]
                                   tmp2.prevent = if index(codfr.name[2],'PIN') > 0 then 'RALLRE' else 'RPLRE'.
        else do:
            run savelog( "PCCHNG", "err3 " + pccards.iin  + " Не найдена запись в таблице codfr!").
            next.
        end.
    end.
    find first tmp2 no-lock no-error.
    if avail tmp2 then do:
        run Put_header.
        for each tmp2 no-lock:
            run Put_reissue.
        end.

        run Put_footer.

        for each tmp2 no-lock:
            find first b-pccards where b-pccards.pcard = tmp2.pcard and b-pccards.info[4] = "" exclusive-lock no-error no-wait.
            if locked b-pccards then message 'Locked b-pcstaff0 re:' b-pccards.bank b-pccards.cif b-pccards.iin string(time,'hh:mm:ss').
            if avail b-pccards then do:
                assign b-pccards.info[4] = file-name
                       b-pccards.sts     = "reopen"
                       b-pccards.who     = g-ofc
                       b-pccards.whn     = g-today.
            end.
        end.
        run Copyfile.
    end.
end procedure.

procedure inabn.

    def var j       as int  no-undo.
    def var v-dt    as char no-undo.
    def var v-str   as char no-undo.
    def var v-arc   as char no-undo.
    v-dt = string(year(g-today)) + string(month(g-today),'99') + string(day(g-today),'99').

    v-fname = 'metro' + v-dt + '.txt'.

    if isProductionServer() then do:
        input through value("ssh Administrator@fs01.metrobank.kz -q dir /b ' " + "D:\\\\euraz\\\\Cards\\\\in\\\\" + v-fname + "'") no-echo.
        repeat:
            import unformatted v-str.
            if v-str begins 'the system' or v-str = 'file not found' then return.
        end.
        input through value("scp Administrator@fs01.metrobank.kz:D:/euraz/Cards/In/" + v-fname + " ./;echo $?").
        repeat:
            import unformatted v-str.
        end.
    end.
    else do:
        input through value("ssh Administrator@`askhost` -q dir /b ' " + "C:\\\\PC\\\\in\\\\" + v-fname + "'") no-echo.
        repeat:
            import unformatted v-str.
            if v-str begins 'the system' or v-str = 'file not found' then return.
        end.
        input through value("scp Administrator@`askhost`:C:/PC/in/" + v-fname + " ./;echo $?").
        repeat:
            import unformatted v-str.
        end.
    end.

    if v-str <> "0" then do:
        run savelog( "PCCHNG", "err4 " + "Ошибка копирования файла " + v-fname).
        return.
    end.

    i = 0.
    input from value(v-fname).
    repeat on error undo, leave:
        import unformatted v-str.

        if not v-str begins 'MC_FILIAL' then next.
        if index(entry(2,v-str,";"),'com') > 0 then next.
        i = i + 1.
        create tmp.
        assign
        tmp.fil        = trim(entry(1,v-str,";"))
        tmp.shortname  = trim(entry(3,v-str,";"))
        tmp.iin        = trim(entry(4,v-str,";"))
        tmp.acc        = trim(entry(5,v-str,";"))
        tmp.accsts     = trim(entry(6,v-str,";"))
        tmp.cardnumber = trim(entry(7,v-str,";"))
        tmp.cardsts    = trim(entry(8,v-str,";"))
        tmp.dtexp      = trim(entry(11,v-str,";"))
        tmp.namelat    = trim(entry(12,v-str,";"))
        tmp.prod       = trim(entry(17,v-str,";")).
    end.
    input close.
    j = 0.
    for each tmp no-lock:
        find first pcstaff0 where pcstaff0.aaa = tmp.acc and pcstaff0.iin = tmp.iin no-lock no-error.
        if avail pcstaff0 then do:
            j = j + 1.

            find current pcstaff0 exclusive-lock no-error no-wait.
            if locked pcstaff0 then do:
                message 'Locked b-pcstaff0 :' pcstaff0.bank pcstaff0.cif pcstaff0.iin string(time,'hh:mm:ss').
                return.
            end.
            assign pcstaff0.pcard   = tmp.cardnumber
                   pcstaff0.info[2] = tmp.dtexp
                   pcstaff0.sts     = entry(2,tmp.accsts,' ')
                   pcstaff0.who     = g-ofc
                   pcstaff0.whn     = g-today.

            if int(substr(pcstaff0.info[2],3)) = 12 then v-expdt = date(12,31,int(substr(pcstaff0.info[2],1,2)) + 2000).
            else v-expdt = date(int(substr(pcstaff0.info[2],3)) + 1,1,int(substr(pcstaff0.info[2],1,2)) + 2000) - 1.

            find current pcstaff0 no-lock no-error.
            find first pccards where pccards.pcard = tmp.cardnumber no-lock no-error.
            if not avail pccards then do:
                create pccards.
                assign pccards.pcard  = pcstaff0.pcard
                       pccards.bank   = pcstaff0.bank
                       pccards.cif    = pcstaff0.cif
                       pccards.aaa    = pcstaff0.aaa
                       pccards.pctype = pcstaff0.pctype
                       pccards.sts    = pcstaff0.sts
                       pccards.who    = g-ofc
                       pccards.whn    = g-today
                       pccards.issdt  = g-today
                       pccards.expdt  = v-expdt
                       pccards.sname  = pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname
                       pccards.iin    = tmp.iin
                       pccards.namelat = tmp.namelat
                       pccards.prodotv = tmp.prod
                       pccards.prodtarif = caps(tmp.prod)
                       pccards.info[1] = if pcstaff0.rez then '1' else '2'.
                       if tmp.prod matches '*sup*' then pccards.sup = yes.
                       pccards.prodtarif = replace(pccards.prodtarif,'staff','TEAM').
                       pccards.prodtarif = replace(pccards.prodtarif,'salary','PARTNER').
            end.
            else do:
                find current pccards exclusive-lock no-wait.
                if locked pccards then do:
                    message 'Locked pccards sup:' pccards.bank pccards.cif pccards.iin string(time,'hh:mm:ss').
                    return.
                end.
                assign pccards.sts    = entry(2,tmp.cardsts,' ')
                       pccards.who    = g-ofc
                       pccards.whn    = g-today
                       pccards.prodotv = tmp.prod
                       pccards.prodtarif = caps(tmp.prod)
                       pccards.sname   = pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname.
                       if tmp.prod matches '*sup*' then pccards.sup = yes.
                       pccards.prodtarif = replace(pccards.prodtarif,'staff','TEAM').
                       pccards.prodtarif = replace(pccards.prodtarif,'salary','PARTNER').
                find current pccards no-lock no-error.
            end.
        end.
    end.
    /* копирование в архив */
    v-arc = "/data/import/pc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
    input through value( "find " + v-arc + ";echo $?").
    repeat:
        import unformatted v-str.
    end.
    if v-str <> "0" then do:
        unix silent value ("mkdir " + v-arc).
        unix silent value ("chmod 777 " + v-arc).
    end.
    unix silent value('cp ' + v-fname + ' ' + v-arc).
    if isProductionServer() then input through value ("ssh Administrator@fs01.metrobank.kz -q move " + "D:\\\\euraz\\\\Cards\\\\In\\\\" + v-fname + " D:\\\\euraz\\\\Cards\\\\In\\\\arc\\\\" + v-fname + " ;echo $?").
    else input through value ("ssh Administrator@`askhost` -q move " + "C:\\\\PC\\\\in\\\\" + v-fname + " C:\\\\PC\\\\arc\\\\" + " ;echo $?").

    repeat:
        import unformatted v-str.
    end.
    if v-str <> "0" then run savelog( "PCCHNG", "err6 " + "Ошибка копирования файла " + v-fname  + " в архив!Код ошибки " + v-str).
    unix silent value ("rm -f " + v-fname).
end.