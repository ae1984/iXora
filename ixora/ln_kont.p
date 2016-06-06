/* ln_kont.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Контроль, повторная печать транзакций по кредитам
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        4-1-11
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        09.09.2003 nadejda - ужесточила контроль штамповки - теперь только по списку контролеров (4-3-7)
                             после штампа снимается специнструкция на эту сумму
        10.09.2003 nadejda - добавила поиск анкеты по Потребкредитам, если найдена - статус поменять на "проводка проведена"
        15.09.2003 nadejda - запретила удаление проводок в этом пункте
        17.12.2003 nadejda - добавила pk0.i для перекомпиляции
        27.01.2004 sasco   - убрал today для cashofc
        19.07.2004 tsoy    - Проверка на документ документ департамента авторизации
        20.07.2004 tsoy    - Проводки по дебету ссудного счета только 1-го уровня
        14/04/2010 madiyar - контроль транзакций по выдаче гарантий
        21/12/2011 id00810 - добавила новые шаблоны транзакций по выдаче гарантий в v-templs
*/

def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.
def new shared var s-aah as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.
def var i as int.
def var v-templs as char init "uni0057,uni0058,lon0051,lon0052,dcl0010,dcl0016,dcl0017".

{mainhead.i}  /* GENERAL ENTRY - SINGLE */
{pk0.i}

def var vbal like jl.bal.
def var vdam like jl.dam.
def var vcam like jl.cam.
def var vop  as int format "z".
def var oldround as log.
def var vrem like jl.rem.
def var vans as log.
def var v-dep as char.

{jhjl1.f new}

def var v-ourbank as char.
{comm-txb.i}
v-ourbank = comm-txb().

main:
repeat: /* 1 */

    clear frame jh.
    clear frame jl all.
    clear frame rem1.
    clear frame tot.
    clear frame bal.
    clear frame party.
    view frame heading.
    view frame jh.
    view frame bal.
    view frame tot.
    view frame party.
    view frame jl.
    view frame rem1.

    getjh:
    repeat on endkey undo, return:
        prompt jh.jh with frame jh.

        find jh using jh.jh no-error.
        if not available jh then do:
            bell.
            {mesg.i 9204}.
            next getjh.
        end.
        else do:
            s-jh = jh.jh.
            {mesg.i 0946}.
            display jh.jh jh.jdt jh.who with frame jh.
            display jh.cif jh.party jh.crc with frame party.
            if jh.cif ne "" then do:
                find cif where cif.cif eq jh.cif.
                display cif.name @ jh.party with frame party.
            end.
        end.

        s-jh = jh.jh.

        /* tsoy Проверка департамента авторизации*/
        if comm-txb () = "TXB00" then do:
            find first ofc where ofc.ofc = g-ofc no-lock no-error.
            for each jl where jl.jh = s-jh no-lock:
                if jh.sub = "lon" and jl.dc = "D" then do:
                    find first lon where lon.lon = jl.acc no-lock no-error.
                    if avail lon and ofc.titcd <> "523" and  jl.lev = 1 then do:
                        message "Документ департамента авторизации !!!".
                        pause 5.
                        next getjh.
                    end.
                end.
            end.
        end.

        find first jl where jl.jh = s-jh no-lock no-error.
        if jl.sub <> "lon" and lookup (jl.trx, v-templs) = 0 then do:
            message "Документ не Кредитного Департамента !!!".
            pause 5.
            next getjh.
        end.

        clear frame jl all.
        vdam = 0.
        vcam = 0.
        vbal = 0.
        i = 0.
        for each jl of jh no-lock:
            i = i + 1.
            if i = 1 then do:
                vrem[1] = jl.rem[1].
                vrem[2] = jl.rem[2].
                vrem[3] = jl.rem[3].
                vrem[4] = jl.rem[4].
                vrem[5] = jl.rem[5].
            end.
            vdam = vdam + jl.dam.
            vcam = vcam + jl.cam.
            vbal = vdam - vcam.
            find gl of jl no-lock.

            display jl.ln jl.crc jl.gl gl.sname jl.acc jl.dam jl.cam with frame jl.

            if i = 4 then do:
                pause.
                i = 0.
            end.

            if g-tty ne 0 then do:
                find ttl where ttl.tty eq g-tty and ttl.ln eq jl.ln no-error.
                if available ttl then do:
                    color display message jl.dam when ttl.dc eq "D" with frame jl.
                    color display message jl.cam when ttl.dc eq "C" with frame jl.
                end.
            end.
            down with frame jl.
        end. /* for each jl of jh */

        display vrem[1] vrem[2] vrem[3] vrem[4] vrem[5] with frame rem1.
        display vbal with frame bal.
        display vdam vcam with frame tot.

        find jh where jh.jh eq s-jh.

        repeat:
            pause 0.

            vop = 0.
            message " 1) Выбор проводки  2) Печать  3) Штамп"  update vop.
            if vop = 1 then next getjh.

            /* Print */
            if vop eq 2 then do:
                hide all.
                run x-jlvou.
                if jh.sts ne 6 then do:
                    for each jl of jh:
                        jl.sts = 5.
                        find sysc where sysc.sysc eq "CASHGL" no-lock.
                        if avail sysc then do:
                            if jl.gl eq sysc.inval then do:
                                find prev cashofc where cashofc.ofc eq g-ofc and
                                                        cashofc.sts eq 2 /* curr.value */ and
                                                        cashofc.crc eq jl.crc and
                                                        cashofc.whn eq g-today exclusive-lock
                                                        no-error.
                                if avail cashofc then cashofc.amt = cashofc.amt + jl.dam - jl.cam.
                                release cashofc.
                            end.
                        end.
                    end.
                    jh.sts = 5.
                end.
                {x-jlvf.i}
            end. /* 3. Print */
            else
            /* Stamp */
            if vop eq 3 then do:
                /* 09.09.2003 nadejda - в случае проводки на выдачу проверить, может ли текущий офицер штамповать */
                if jh.party begins "GRANT OF LOAN" then run ln_kontofc (jh.who, yes, output vans).
                                                   else vans = true.

                if vans then do:
                    {mesg.i 6811} update vans.
                    if vans then do:
                        run chgsts(input "lon", s-jh, "lon").
                        run jl-stmp.

                        find jh where jh.jh = s-jh.
                        /* если это проводка на выдачу и отштампована - снимаем заморозку */
                        if jh.party begins "GRANT OF LOAN" and jh.sts = 6 then do:
                            /* 09.09.2003 nadejda - снять заморозку с суммы транзакции, если найдутся замороженные средства для этой проводки */
                            find first jl where jl.jh = s-jh and jl.sub = "cif" and jl.dc = "c" and jl.lev = 1 no-lock no-error.
                            if avail jl then run jou-aasdel (jl.acc, jl.cam, s-jh).

                            /* попытаться найти анкету и поменять статус */
                            find first jl where jl.jh = s-jh and jl.sub = "lon" and jl.dc = "d" and jl.lev = 1 no-lock no-error.
                            if avail jl then do:
                                find first pkanketa where pkanketa.bank = v-ourbank and pkanketa.lon = jl.acc and pkanketa.trx1 = s-jh no-lock no-error.
                                if avail pkanketa and pkanketa.sts = "35" then do:
                                    find current pkanketa exclusive-lock.
                                    pkanketa.sts = "40".
                                    find current pkanketa no-lock.
                                end.
                            end.
                        end.
                    end.
                end.
                view frame jh.
                view frame bal.
                view frame party.
                view frame jl.
                view frame rem1.
                view frame heading.
            end.
        end. /* repeat: */
    end. /* getjh: repeat on endkey undo, return: */
end. /* main: repeat: */

