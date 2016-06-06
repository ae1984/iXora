/* 2P_ps.p
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
* AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
* CHANGES
        28.05.2012 aigul - блокировка платежей дебет 1052 кредит 2237 в 9-7
        29.05.2012 aigul - добавила BASES
*/

{global.i}
{lgps.i }
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha .
def var v-chk as logical initial no.
def var v-sub as char.
def var lbnstr like sysc.chval .
find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if avail sysc then lbnstr = trim(sysc.chval) .

find first sysc where sysc.sysc = "PR-DIR" no-lock no-error .
if not avail sysc then do:
    v-text = " Нет записи PR-DIR в sysc файле " .  run lgps.
    return .
end.

do transaction :
    find first que where que.pid = m_pid and que.con = "W"
    use-index fprc  exclusive-lock no-error.
    if avail que then do:
        que.dw = today.
        que.tw = time.
        que.con = "P".
        find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
        /*  Beginning of main program body */
        find first jl where jl.jh = remtrz.jh2 no-lock no-error.
        if not available jl then do :
            que.dp = today.
            que.tp = time.
            que.con = "F".
            que.rcod = "10".
            v-text = "Ошибка ! Нет 2 проводки  " + remtrz.remtrz.
            run lgps.
            return.
        end.
        if search ( sysc.chval + "/2TRXprot.log" ) <> ( sysc.chval + "/2TRXprot.log" ) then do :
            output to value( sysc.chval + "/2TRXprot.log" ).
            put unformatted
            "Дата   " g-today  " Время " string(time,"HH:MM:SS") skip
            "Исполнитель " jl.who skip
            "Протокол 1 проводки " skip
            /*
            "Протокол автоматически обработанных переводов" skip
            */
            fill("-",130) skip
            "Номер документа  "
            "Сумма" to 37
            "Вал" to 41
            "Банк " to 50
            "Счет кредита  " to 65
            "Платеж   " to 78
            "2Дата валют" to 90
            "Nr.пр" to 98 skip
            fill("-",130) skip.
            output close.
        end.
        output to value( sysc.chval + "/2TRXprot.log" ) append.
        find sysc where sysc.sysc = "OURBNK" no-lock no-error.
        if not avail sysc then do:
            v-text = " Нет записи OURBNK в sysc файле     " .  run lgps.
            return .
        end.
        find crc where crc.crc = remtrz.tcrc no-lock no-error.
        put substr(remtrz.sqn,19,10) space(8)
        remtrz.payment space(2)
        crc.code space(3)
        trim(sysc.chval) space(1)
        remtrz.cracc space(6)
        remtrz.remtrz space(2)
        remtrz.valdt2 space(3)
        remtrz.jh2 skip.
        output close.
        /*  End of program body */
        que.dp = today.
        que.tp = time.
        que.con = "F".
        if (remtrz.source = "SW" and remtrz.dracc = lbnstr and remtrz.ptype = "7" )
        then  que.rcod = "1".
        else  que.rcod = "0".
        v-text = " Протокол 2 проводки сформирован для " + remtrz.remtrz.
        find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
        if string(remtrz.drgl) begins "1052" then do:
            find txb where txb.consolid = true and txb.bank = remtrz.rbank no-lock no-error.
            if avail txb then do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(txb.path,"/data/","/data/b") + " -ld txb -U " + txb.login + " -P " + txb.password).
                run vc_blk(remtrz.racc, output v-chk, output v-sub).
                if connected ("txb") then disconnect "txb".
            end.
            if v-chk then do:
                find first vcblock where vcblock.bank = remtrz.rbank and vcblock.remtrz = remtrz.remtrz no-lock no-error.
                if not avail vcblock then do:
                    run savelog("vcjoublk", "id: " + g-ofc + ", date: " + string(g-today) + ",bank: " + remtrz.rbank + ",rmz: " + remtrz.remtrz).
                    create vcblock.
                    assign vcblock.bank = remtrz.rbank
                    vcblock.remtrz = remtrz.remtrz
                    vcblock.remracc = remtrz.sacc
                    vcblock.remname = remtrz.bn[1]
                    vcblock.remdetails = trim(remtrz.detpay[1] + remtrz.detpay[2] + remtrz.detpay[3] + remtrz.detpay[4])
                    vcblock.amt = remtrz.amt
                    vcblock.crc = remtrz.tcrc
                    vcblock.arp = remtrz.racc
                    vcblock.depart = v-sub
                    vcblock.jh1 = remtrz.jh2
                    vcblock.rdt = g-today
                    vcblock.rwho = g-ofc
                    vcblock.retremtrz = "".
                    vcblock.sts = "B".
                end.
            end.
        end.
        run lgps.
    end.
end.

