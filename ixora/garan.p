/* garan.p

 * MODULE
      Кредитный модуль
 * DESCRIPTION
      Открытие новых гарантий  в соответсвии с тербованиями НБ РК
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
      2-15
 * AUTHOR
      15/08/03 nataly
 * BASES
      BANK COMM
 * CHANGES
      18/08/03 nataly была доработана форма просмотра  и удаления проводки
      03.11.03 nataly была поставлена проверка , чтобы сумма покрытия =
                      сумме требования по гарантии
      01.03.04 nataly была добавлена проверка на наличие проводки по гарантии
      13/05/2004 madiyar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
      26/09/2005 nataly - добавила проверку на валюту счета депозита гарантии с валютой гарантии
      12.08.2008 galina - к полю Обеспечение подвязан новый справочник
      14/04/2010 madiyar - переделал форму; комиссия через кассу
      15/04/2010 madiyar - ордер печатался два раза, исправил
      16/04/2010 madiyar - исправил проблему (не находился счет при оплате комиссии с тек. счета)
      24/05/2010 galina - перенесла выдачу гантий в пункт меню 2-1-9
      01.02.2012 lyubov - изменила символ кассплана (200 на 100)
      13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{mainhead.i}

def var s_account_a as char no-undo.
def var s_account_b as char no-undo.
def var c-gl like gl.gl no-undo.
def var c-gl1002 like gl.gl no-undo.
def var v_doc as char no-undo.

find last sysc where sysc.sysc = "cashgl" no-lock no-error.
if avail sysc then c-gl = sysc.inval.
else c-gl = 100100.
find last sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then c-gl1002 = sysc.inval.
else c-gl1002 = 100200.

def var v-yn  as log init false no-undo. /*получаем признак работы касса/касса в пути*/
def var v-err as log init false no-undo. /*получаем признак возникновения ошибки*/

def new shared var s-jh like jh.jh.

def var v-cif as char no-undo.
def var v-name as char no-undo.
def var v-rnn as char no-undo.
def var vaaa like aaa.aaa.
def var vaaa2 like aaa.aaa.
def var vcif like cif.name.
def var vcif2 like cif.name.
def var vsum as deci no-undo.

def var dfrom as date no-undo.
def var dto as date no-undo.
def var v-garan as char no-undo.
def var v-bankben as char no-undo.
def var v-naim as char no-undo.
def var v-address as char no-undo.
def var v-codfr as char no-undo.
def var vobes as char no-undo.
def var v-eknp as char no-undo.
v-eknp = '182'.

def var rem1 as char.
def var rem2 as char.
def var rem3 as char.
def var rem4 as char.
def var rem5 as char.

def var sumtreb as decimal .
def var vcrc like crc.crc.

def var vaaa3 like aaa.aaa.
def var vcrc3 like crc.crc.
def var sumkom as decimal no-undo.
def var sumzalog as decimal no-undo.

def var v-ans as logi.
def var vdel as char initial "^".
def var vparam as char.
def var vparam2 as char.
def var v-jh like jh.jh init 0.
def var v-jh2 like jh.jh init 0.
def var rcode as inte.
def var rdes as char.

def var v-templ as char.

def var ja as log format "да/нет".
def var vou-count as int initial 1.
def var i as int.

def buffer baaa for aaa.
def buffer bcrc for crc.

def var v-jdt as date no-undo.
def var v-our as log no-undo.
def var v-lon as log no-undo.
def var v-finish as log no-undo.
def var v-cash as log no-undo.
def var v-cashgl as integer no-undo.
def var v-sts as int no-undo.

/*define button b1 label "НОВЫЙ".*/
define button b2 label "ПОИСК".
/*define button b3 label "УДАЛИТЬ(КОМИССИЯ)".
define button b4 label "УДАЛИТЬ".*/

find first sysc where sysc.sysc = "cashgl" no-lock no-error.
if avail sysc then v-cashgl = sysc.inval.
else v-cashgl = 100100.

define frame a2
    /*b1*/ b2 /*b3 b4*/
    with side-labels row 3 no-box.

{garan.f}

/* new */
/*on choose of b1 in frame a2 do:

    assign v-cif = ''
           v-name = ''
           v-rnn = ''
           v-jh = 0
           vaaa2 = ''
           vsum = 0
           v-garan = ''
           vaaa = ''
           dfrom = ?
           dto = ?
           v-codfr = ''
           vobes = ''
           sumzalog = 0
           sumtreb = 0
           vcrc = 0
           vaaa3 = ''
           v-jh2 = 0
           vcrc3  = 0
           sumkom = 0
           /* v-eknp = '' */
           v-bankben = ''
           v-naim = ''
           v-address = ''.

    run showinfo.

    upper:
    repeat on error undo, return:
        /* клиент */
        update v-cif with frame garan0.

        find cif where cif.cif = v-cif no-lock no-error.
        if avail cif then do:
            v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
            v-rnn = cif.jss.
            display v-name with frame garan0.
        end.

        /*счет депозит-гарантия*/
        update vaaa2 with frame garan0.

        find baaa where baaa.aaa = vaaa2 no-lock no-error.
        if not available baaa then do:
            message "Счет " + vaaa2 + " не существует" view-as alert-box title "".
            pause.
            next upper.
        end.

        if baaa.sta = "C" or baaa.sta = "E" then do:
            message "Закрытый счет" view-as alert-box title "".
            pause.
            next upper.
        end.

        update vsum with frame garan0.
        update v-garan with frame garan0.

        if vsum > 0 then do:
            update vaaa with frame garan0.

            find first aaa where aaa.aaa = vaaa no-lock no-error.
            if not available aaa then do:
                message "Счет " + vaaa + " не существует!" view-as alert-box title "".
                pause.
                next upper.
            end.

            if aaa.sta = "C" or aaa.sta = "E" then do:
                message "Закрытый счет!" view-as alert-box title "".
                pause.
                next upper.
            end.
        end.
        else vaaa = ''.

        update dfrom with frame garan0.
        update dto with frame garan0.

        update v-codfr with frame garan0.
        find first lonsec where lonsec.lonsec = integer(trim(v-codfr)) no-lock no-error.
        if avail lonsec then vobes = lonsec.des. else vobes = "".
        displ vobes with frame garan0.

        if trim(v-codfr) <> '1' then update sumzalog with frame garan0.

        /*03.11.03 nataly*/
        update sumtreb with frame garan0.
        update vcrc with frame garan0.
        find bcrc where bcrc.crc = baaa.crc no-lock no-error.
        /* 26/09/05 nataly */
        if bcrc.crc <> vcrc then do:
            message 'Валюта депозита-гарантии ' + string(bcrc.crc) + ' не соответствует валюте гарантии ' + string(vcrc) + '!'.
            pause 5.
            next upper.
        end.
        /* 26/09/05 nataly */

        update vcrc3 with frame garan0.
        update sumkom with frame garan0.
        /* update v-eknp with frame garan0. */

        update vaaa3 with frame garan0.
        if vaaa3 = '' then message "Комиссия должна быть оплачена через кассу!" view-as alert-box warning.

        if vaaa3 = '' then do:
            /* счет кассы в пути в валюте vcrc3 */
            run get100200arp(input g-ofc, input vcrc3, output v-yn, output s_account_b, output v-err).
            if v-err then do:
                /*если ошибка имела место, то еще раз скажем об этом пользователю*/
                v-err = not v-err.
                message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip
                    "произошла ошибка!" view-as alert-box error.
                return.
            end.

            if v-yn then s_account_a = "". /*касса в пути*/
            else do:
                /*касса*/
                s_account_a = string(c-gl).
                s_account_b = "".
            end.
        end.

        update v-bankben with frame garan0.
        update v-naim with frame garan0.
        update v-address with frame garan0.

        hotkeys:
        repeat:
            message "T-сделать проводку, F4-выход".
            readkey.
            if keyfunction(lastkey) = 'T' then do:
                message "Вы действительно хотите сделать транзакцию? " view-as alert-box question buttons yes-no title "" update v-ans.
                if not v-ans then next hotkeys.
                /*01/03/04 nataly*/
                if v-jh <> 0 then do:
                    message 'Проводка уже создана! N транзакции ' string(v-jh) view-as alert-box.
                    next hotkeys.
                end.
                else
                do transaction:  /*if v-ans*/
                    v-templ = "dcl0010".
                    rem1 = 'Гарантия N ' + trim(v-garan)  + ' от ' + string(dfrom) + ' до ' + string(dto).
                    rem2 = 'Вид залога: ' + v-codfr + ' Сумма ' + string(sumzalog).
                    rem3 = 'Банк бенеф: '   +  v-bankben.
                    rem4 = 'Наимен бенеф: ' +  v-naim.
                    rem5 = 'Адрес бенеф: '  +  v-address.

                    if vsum > 0 then vparam = string(vsum) + vdel + vaaa.
                    else vparam = string(0) + vdel + vaaa2. /* сумма нулевая, проводка не будет сделана, поэтому неважно, какой передается номер счета */

                    vparam = vparam + vdel + vaaa2 + vdel + v-eknp + vdel +
                        string(sumtreb) + vdel + string(vcrc) +  vdel + rem1 + vdel + rem2 + vdel + rem3 + vdel + rem4 + vdel + rem5.

                    if vaaa3 <> '' then vparam = vparam + vdel + string(sumkom) + vdel + string(vcrc3) + vdel + vaaa3.
                    else do:
                        /* сумма нулевая, проводка не будет сделана, поэтому неважно, какой передается номер счета */
                        find first aaa where aaa.aaa = vaaa2 no-lock no-error.
                        vparam = vparam + vdel + string(0) + vdel + string(aaa.crc) + vdel + vaaa2.
                    end.

                    run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output v-jh).

                    if rcode ne 0 then do:
                        message v-templ ' ' rdes.
                        pause.
                        pause.
                        undo,retry.
                    end.

                    if v-jh > 0 then do:
                        displ v-jh with frame garan0.
                        find first jh where jh.jh = v-jh exclusive-lock.
                        if jh.sts < 5 then jh.sts = 5.
                        for each jl of jh:
                            if jl.sts < 5 then jl.sts = 5.
                        end.
                        find current jh no-lock.
                    end.
                end.
                s-jh = v-jh.
                run vou_bank(2).
                /*voucher printing nataly--------------------*/
                /*
                if v-jh ne 0 then do:
                    do on endkey undo:
                        find first jl where jl.jh = v-jh no-error.
                        if available jl then do:
                            ja = no.
                            message "Печатать ваучер ?" update ja.
                            if ja then do:
                                message "Сколько ?" update vou-count.
                                if vou-count > 0 and vou-count < 10 then do:
                                    s-jh = v-jh.
                                    {mesg.i 0933} s-jh.
                                    do i = 1 to vou-count:
                                        run /*x-jlvou.*/ uvou_bank("prit").
                                    end.
                                end.  /* if vou-count > 0 */
                                /*
                                run trxsts(v-jh, 6, output rcode, output rdes).
                                if rcode ne 0 then do:
                                    message rdes view-as alert-box title "".
                                    next hotkeys.
                                end.
                                */
                            end. /* if ja */
                            if not ja then do:
                                {mesg.i 0933} v-jh.
                                pause 5.
                            end. /*  if not ja*/
                            pause 0.
                        end.  /* if available jl */
                        else do:
                            message "Can't find transaction " v-jh view-as alert-box.
                            return.
                        end.
                        pause 0.
                    end. /* do on endkey undo: */
                end.  /*  if v-jh ne 0 then do : */
                */
                /*voucher printing nataly--------------------*/

                if v-jh <> 0 then do:
                    if vaaa3 = '' then do:
                        do transaction:
                            v-jh2 = 0.
                            if s_account_a = string(c-gl) and s_account_b = '' then do:
                                /* 100100 */
                                v-templ = "vnb0003".
                                vparam = string(sumkom) + vdel + string(vcrc3) + vdel + "460610" + vdel + "Комиссия за выдачу гарантии" + vdel.
                            end.
                            else do:
                                /* 100200 */
                                v-templ = "vnb0001".
                                vparam = string(sumkom) + vdel + string(vcrc3) + vdel + s_account_b + vdel + "460610" + vdel + "Комиссия за выдачу гарантии" + vdel.
                            end.

                            run trxgen (v-templ, vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh2).
                            if rcode ne 0 then do:
                                message 'Комиссия: ' + rdes.
                                pause.
                                undo,retry.
                            end.

                            if v-jh2 > 0 then do:
                                displ v-jh2 with frame garan0.

                                s-jh = v-jh2.
                                run jou. /* создадим jou-документ */
                                v_doc = return-value.

                                find first jh where jh.jh = v-jh2 exclusive-lock.
                                if jh.sts < 5 then jh.sts = 5.
                                for each jl of jh:
                                    if jl.sts < 5 then jl.sts = 5.
                                end.
                                jh.party = v_doc.
                                find current jh no-lock.

                                run setcsymb (v-jh2, 100). /* проставим символ кассплана */

                                find first jh where jh.jh = v-jh exclusive-lock.
                                jh.tty = v-jh2.
                                find current jh no-lock.

                                find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
                                if avail joudoc then do:
                                    joudoc.info = v-name. joudoc.passp = ''. joudoc.perkod = v-rnn.
                                end.
                            end.
                        end. /* transaction */
                        run vou_bank(2).
                    end.
                end.
                if v-jh2 > 0 then enable b3 with frame a2.
                if v-jh > 0 then do:
                    enable b4 with frame a2.
                    message "Транзакция по выдаче гарантии N " + string(v-jh) + " передана на акцепт контролеру!" view-as alert-box.
                end.
                leave upper. /*leave hotkeys.*/
            end.  /*T*/
            else
            if keyfunction(lastkey) = 'end-error' then do:
                /*clear frame garan0.*/
                leave upper. /*leave hotkeys.*/
            end.
        end. /*repeat*/
    end.  /*repeat*/
end.*/ /* b2 new */

/* search */
on choose of b2 in frame a2 do:
    do transaction:
        update v-jh label 'Введите номер транзакции ' with row 3 frame a3.
        find first jl where jl.jh = v-jh no-lock no-error.
        if not avail jl then do:
            message 'Транзакция с N ' + string(v-jh) + ' не найдена !' view-as alert-box.
            hide frame a3. v-jh = 0.
            undo,retry.
        end.
        if jl.trx <> 'dcl0010' then do:
            message 'Транзакция с N ' + string(v-jh) + ' не относится к гарантиям!' view-as alert-box.
            hide frame a3. v-jh = 0.
            undo,retry.
        end.
        hide frame a3.

        run fill_form(v-jh).
        view frame garan0.
        find first cif where cif.cif = v-cif no-lock no-error.
        run showinfo.
        /*enable b3 b4 with frame a2.*/
    end.
end. /* on choose of b2 */

/* delete */
/*on choose of b3 in frame a2 do:
    if v-jh2 > 0 then do:
        find first jl where jl.jh = v-jh2 no-lock no-error.
        if avail jl then do transaction:
            ja = no.
            message "Удалить проводку-комиссию?" update ja.
            if ja then run del_trx(v-jh2).
        end.
        else do:
            message "Проводка не была создана или уже удалена!" view-as alert-box.
            return.
        end.
    end.
    else do:
        message "Проводка не была создана или уже удалена!" view-as alert-box.
        return.
    end.
end.*/ /* on choose of b3 */

/*on choose of b4 in frame a2 do:
    def var v-comdel as logi no-undo.
    if v-jh > 0 then do:
        find first jl where jl.jh = v-jh no-lock no-error.
        if avail jl then do:
            v-comdel = no.
            if v-jh2 = 0 then v-comdel = yes.
            else do:
                find first jl where jl.jh = v-jh2 no-lock no-error.
                if not avail jl then v-comdel = yes.
            end.
            if v-comdel then do transaction:
                ja = no.
                message "Удалить проводку по выдаче гарантии?" update ja.
                if ja then run del_trx(v-jh).
            end.
            else do:
                message "Сначала удалите проводку-комиссию!" view-as alert-box.
                return.
            end.
        end.
        else do:
            message "Проводка не была создана или уже удалена!" view-as alert-box.
            return.
        end.
    end.
    else do:
        message "Проводка не была создана или уже удалена!" view-as alert-box.
        return.
    end.
end.*/ /* on choose of b4 */

enable /*b1*/ b2 /*all*/ with frame a2.
wait-for window-close of current-window.

procedure showinfo.
    displ v-cif v-name v-jh
          vaaa2 vaaa
          vsum v-garan dfrom dto v-codfr vobes sumzalog sumtreb vcrc vaaa3 v-jh2 vcrc3 sumkom /* v-eknp */
          v-bankben v-naim v-address
          with frame garan0.
end procedure.

procedure fill_form.
    define input parameter v-jh as integer.
    def buffer baaa2 for aaa.
    def buffer bjl for jl.

    def var i1 as integer.
    def var i2 as integer.
    def var i3 as integer.
    def var i4 as integer.
    def var i5 as integer.
    def var i6 as integer.
    def var i7 as integer.
    def var i8 as integer.

    vsum = 0. vaaa = ''.
    vaaa3 = ''. sumkom = 0.
    v-jh2 = 0.
    for each jl where jh = v-jh no-lock:
        if string(jl.gl) begins '2203' then do:
            find  first bjl where bjl.jh = jl.jh and bjl.ln = jl.ln + 1.
            if bjl.subled = "cif" then do: /*1-я линия */
                vaaa = jl.acc. vsum = jl.dam.
                find aaa where aaa.aaa = vaaa no-lock no-error.
                find cif where cif.cif = aaa.cif no-lock no-error.
                if avail cif then assign v-cif = cif.cif v-name = cif.cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)).
            end.
            else do:    /*3-я линия*/
                vaaa3 = jl.acc. vcrc3 = jl.crc. sumkom = jl.dam.
            end.
        end.
        if string(jl.gl) begins '6055' then do: /*2-я линия*/
            vaaa2 = jl.acc. sumtreb = jl.dam. vcrc = jl.crc.
            find baaa where baaa.aaa = vaaa2 no-lock no-error.
            find cif where cif.cif = baaa.cif no-lock no-error.
            if avail cif then assign v-cif = cif.cif v-name = trim(trim(cif.prefix) + " " + trim(cif.name)) v-rnn = cif.jss.
            i1 = index(jl.rem[1], "N").
            i2 = index(jl.rem[1], "от").
            i3 = index(jl.rem[1], "до").
            i4 = index(jl.rem[2], ":").
            i5 = index(jl.rem[2], "Сумма").
            i6 = index(jl.rem[3], ":").
            i7 = index(jl.rem[4], ":").
            i8 = index(jl.rem[5], ":").
            v-garan = trim(substr(jl.rem[1],i1 + 1,i2 - i1 - 1 )).
            dfrom  =  date(substr(jl.rem[1],i2 + 3,i3 - i2 - 3)).
            dto = date(substr(jl.rem[1],i3 + 3)).
            v-codfr = trim(substr(jl.rem[2],i4 + 2,i5 - i4 - 2)).
            find first lonsec where lonsec.lonsec = integer(trim(v-codfr)) no-lock no-error.
            if avail lonsec then vobes = lonsec.des. else vobes = "".
            sumzalog = decimal(trim(substr(jl.rem[2],i5 + 6))).
            v-bankben = trim(substr(jl.rem[3],i6 + 1)).
            v-naim = trim(substr(jl.rem[4],i7 + 1)).
            v-address = trim(substr(jl.rem[5],i8 + 1)).
        end.
    end.
    if vaaa3 = '' then do:
        find first jh where jh.jh = v-jh no-lock no-error.
        v-jh2 = jh.tty.
    end.
    find first jl where jl.jh = v-jh2 and jl.dc = 'd' no-lock no-error.
    if avail jl then assign vcrc3 = jl.crc sumkom = jl.dam.
end procedure.

procedure del_trx.
    def input parameter p-jh as integer no-undo.
    v-jdt = g-today.
    v-our = yes.
    v-finish = no.
    v-cash = no.
    for each jl where jl.jh eq p-jh no-lock:
        if jl.sts eq 6 then v-finish = yes.
        if jl.gl eq v-cashgl then v-cash = yes.
        if jl.jdt ne g-today then v-jdt = jl.jdt.
        if jl.who ne g-ofc then v-our = no.
    end.
    find jh where jh.jh eq p-jh no-lock no-error.
    if not v-our then do:
        message "Вы не можете удалить чужую транзакцию." view-as alert-box information buttons ok.
        return.
    end.
    if v-finish and v-cash then do:
        message "Вы не можете удалить выполненную кассовую транзакцию (" + string(p-jh) + ")." view-as alert-box information buttons ok.
        return.
    end.

    ja = no.
    if v-jdt ne g-today then do:
        message "Транзакция " + string(p-jh) + " не текущего дня. Выполнить сторно?" view-as alert-box question buttons yes-no update ja.
        if not ja then return.
    end.
    if v-jdt eq g-today then do:
        v-sts = 0.
        run trxsts(input p-jh, input v-sts, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes view-as alert-box.
            return.
        end.
        run trxdel(input p-jh, input true, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes view-as alert-box.
            return.
        end.
        else do:
            message 'Транзакция ' + string(p-jh) + ' была успешно удалена'.
            pause 20.
        end.
    end.  /* nataly v-jdt eq g-today - транзакция сегодня */
    else do:
        v-sts = 0. s-jh = 0.
        run trxstor(input p-jh, input v-sts, output s-jh, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes view-as alert-box.
            return.
        end.

        /* pechat vauchera */
        ja = no.
        vou-count = 1. /* kolichestvo vaucherov */
        find jh where jh.jh eq s-jh no-lock no-error.
        do on endkey undo:
            message "Печатать ваучер ? " + string(s-jh) view-as alert-box
            buttons yes-no update ja.
            if ja then do:
                message "Сколько ?" update vou-count.
                if vou-count > 0 and vou-count < 10 then do:
                    find first jl where jl.jh = s-jh no-error.
                    if available jl then do:
                        {mesg.i 0933} s-jh.
                        do i = 1 to vou-count: run x-jlvou. end.
                        if jh.sts < 5 then jh.sts = 5.
                        for each jl of jh:
                            if jl.sts < 5 then jl.sts = 5.
                        end.
                    end. /* if available jl */
                    else do:
                        message "Can't find transaction " s-jh view-as alert-box.
                        return.
                    end.
                end.  /* if vou-count > 0 */
            end. /* if ja */
            pause 0.
        end.
        pause 0.
        /*
        view frame lon.
        view frame ln1.
        ja = no.
        message "Штамповать ?" update ja.
        if ja then run jl-stmp.
        */
    end.
end procedure.


