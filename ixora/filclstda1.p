/* filgettda1.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Снятие с деп счета в другом филиале
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        24.06.2010 marinav
 * CHANGES
        07.06.2011 id00004  добавил условие для Метросуперлюкс если > 18 мес то выплачиваем %
        13/06/2011 evseev - для lgr.feensf = 6
        17/06/2011 id00004 - внес запрет выплаты % по МетроСуперЛюкс после пролонгации согласно ТЗ-1070
        28/06/2011 evseev - при досрочном закрытии 478-483 % не выплачивать. ТЗ-1070
        25/01/2012 evseev - ТЗ-1245
        23.05.2012 evseev - ТЗ-1366 запрет на операцию если не акцептован клиент
        31.08.2012 evseev - иин/бин
        13.05.2013 evseev - tz-1828
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
        28.06.2013 evseev - tz-1909

*/



def shared    var v-cif-f       as char.
def shared    var v-bankname    as char.
def shared    var v-iik         like txb.aaa.aaa.
def shared    var v-crc         like txb.crc.crc.
def shared    var v-crc_val     as char    no-undo format "xxx".
def shared    var v-fio         as char    no-undo format "x(60)".
def shared    var v-rnn         like txb.cif.jss.
def shared    var v-pss         as char    no-undo format "x(30)".

def shared    var v-fio1        as char    no-undo format "x(60)".
def shared    var v-rnn1        like bank.cif.jss.
def shared    var v-pss1        as char    no-undo format "x(30)".

def shared    var v-sum         as deci    no-undo.
def shared    var v-kod         as char    no-undo init "19".
def shared    var v-kbe         as char    no-undo init "19".
def shared    var v-knp         as char    no-undo.
def shared    var v-codename    as char    no-undo .
def shared    var v-com         as char    no-undo.
def shared    var v-sum_com     as deci    no-undo.
def shared    var v-npl         as char.
def shared    var v-npl1        as char.

def shared    var v-ja          as logi    no-undo format "Да/Нет" init no.
def shared    var v-tit         as char.
def shared    var v-comkod      as char.
def shared    var v-type        as char.
def shared    var v-mail        as char.
def shared    var v-gtoday      as date no-undo.
def shared    var v-gofc        as char.

def var v-whplat as logic.
def var v-chr as char.


def           var vavl          as deci.
def           var v_sumfirst    as decimal.
def           var t-aaa         as char.
def           var d_sumrt       as decimal.
def           var v-opnamt      as decimal.
def           var t_date        as date.
def           var t_date2       as date.
def           var d_daycount    as integer.
def           var ss            as decimal.
def           var dd            as decimal.

def           var d_trdaydate   as date.
def           var v-rt1         as decimal.
def           var d_ost         as decimal.
def           var d_tssum       as decimal.

def           var ev-date       as date.
define shared var d_tssum_nalog as decimal.
def           var d_sumfreez    as decimal decimals 2.
def           var v-val         as char.
def           var i-mon         as decimal.
def temp-table tmp-conv like txb.aaa_conv.
def var t-ind       as date.
def var v-sumchkamt as decimal.
def var d-brate     as decimal decimals 2.
def buffer bf-t      for txb.acvolt.
def buffer bf-aaa    for txb.aaa.
def buffer b-bufaaa  for txb.aaa.
def buffer bf-acvolt for txb.acvolt.
def buffer bf-acc    for txb.aaa.

def shared var d_1% as decimal decimals 2. /* Сумма удерживаемая с 1 уровня  */
def shared var d_2% as decimal decimals 2. /* Сумма удерживаемая со 2 уровня */
def shared var d_3% as decimal decimals 2. /* Сумма для выплаты на 1 уровень */
def buffer baaa  for txb.aaa.
def buffer b-crc for txb.crc.
def temp-table t-ln no-undo
    field code as char
    field name as char format "x(70)"
    index main is primary code.

{chk12_innbin.i}

Function EventInRange returns date (input event as char, input vdat1 as date, input vdat2 as date).
    def var curdate as date.
    def var e-fire  as logi.
    curdate = vdat1.
    repeat:
        run EventHandler(event, curdate, date(bf-acvolt.x1), date(bf-acvolt.x3) - 1, output e-fire).
        if e-fire then
        do:
            return curdate.
        end.
        curdate = curdate + 1.
        if curdate > vdat2 then return ?.
    end.
End Function.

d_tssum_nalog = 0.
for each t-ln.
    delete t-ln.
end.

/*БИН   */
def var v-bin as logi init no.
def var v-label as char format "x(18)".
def var v-label1 as char format "x(18)".
find first txb.sysc where txb.sysc.sysc = 'bin' no-lock no-error.
if avail txb.sysc then v-bin = txb.sysc.loval.
if v-bin  then v-label = "ИИН/БИН          :". else v-label =   "РНН/БИН клиента  :".
if v-bin  then v-label1 = "ИИН/БИН получ.   :". else v-label1 = "РНН получателя   :".

for each txb.codfr where txb.codfr.codfr = 'spnpl' no-lock .
    create t-ln.
    t-ln.code =  txb.codfr.code.
    t-ln.name = txb.codfr.name[1] + txb.codfr.name[2].
end.
form  skip(1)
    v-iik label "Счет клиента    " format "x(20)" skip
    v-crc label "Валюта           "   v-crc_val no-label skip
    v-fio label "Клиент           " format "x(50)" skip
    v-label no-label v-rnn no-label validate((chk12_innbin(v-rnn)),'Неправильно введён БИН/ИИН') colon 18 skip
    v-pss label "Уд. личн.        "  skip
    v-sum label "Сумма            " format ">>>,>>>,>>>,>>>,>>9.99"  skip
    v-fio1 label "ФИО получателя   " format "x(50)" skip
    v-pss1 label "Документ         "  skip
    v-label1 no-label v-rnn1 no-label validate((chk12_innbin(v-rnn1)),'Неправильно введён БИН/ИИН') colon 18  skip
    v-kod label "Код              " format "x(2)" validate(v-kod ne "" , "Введите Код!") skip
    v-kbe label "Кбе              " format "x(2)" validate(v-kod ne "" , "Введите Кбе!") skip
    v-knp label "КНП              " format "x(3)" validate( can-find (t-ln where t-ln.code = v-knp) , "Введите КНП! См. справочник (F2)") help "F2 - справочник" v-codename no-label format "x(40)" skip
    v-com label     "Комиссия         " format "x(3)" validate(lookup(v-com, v-comkod) > 0, "Допустимы кода " + v-comkod + " !") skip
    v-sum_com label "Сумма комиссии   " format ">>>,>>9.99"  skip(1)
    '----------------------------Назначение платежа---------------------------' at 5 skip(1)
    v-npl  no-label format "x(78)"  skip
    v-npl1 no-label format "x(78)"  skip(2)

    v-ja label "Формировать транзакцию?   " skip(1)
    with centered side-label row 7 width 80 overlay  title v-tit +  v-bankname frame fr1.


form
    v-chr no-label format "x(1)" skip(1)
    'u - Уполномоченные лица, n - наследнк ' at 5 skip(1)
    with centered side-label row 7 width 80 overlay  title "Задайте параметр" frame fr3.


on help of v-knp in frame fr1
    do:
        {itemlist.i
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 20 down overlay "
       &where = " true "
       &flddisp = " t-ln.code label 'КОД' format 'x(3)'  t-ln.name label 'НАЗВАНИЕ' format 'x(70)' "
       &chkey = "code"
       &chtype = "string"
       &index  = "main"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
    }
        v-knp = t-ln.code.
        displ v-knp with frame fr1.
    end.

displ v-label v-label1 no-label with frame fr1.
update v-iik with frame fr1.
find first txb.aaa where txb.aaa.aaa = v-iik exclusive-lock no-error.
if not avail txb.aaa then
do:
    message "Счет не найден ! " view-as alert-box.
    return.
end.
else
do:
    v-crc = txb.aaa.crc.
    find txb.crc where txb.crc.crc = v-crc no-lock no-error.
    v-crc_val = txb.crc.code.
    find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if not avail txb.cif then do:
       message "Клиент не найден ! " view-as alert-box.
       return.
    end.

    if cif.crg = "" or cif.crg = ? then do:
       message "Счет " + txb.aaa.aaa + " заблокирован! Необходим акцепт для CIF " + txb.aaa.cif view-as alert-box.
       return.
    end.

    v-fio = txb.cif.name.
    if v-bin then v-rnn = txb.cif.bin. else v-rnn = txb.cif.jss.
    v-pss = txb.cif.pss.
    displ v-crc_val v-fio v-rnn v-pss with frame fr1.
    if txb.aaa.cif ne v-cif-f then
    do:
        message "Счет принадлежит другому клиенту ! " view-as alert-box.
        return.
    end.
    if txb.aaa.sta = 'C' then
    do:
        message "Счет закрыт ! " view-as alert-box.
        return.
    end.
    if v-type ne '' then
    do:
        find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
        if lookup(txb.lgr.led, v-type) = 0 then
        do:
            message "Тип счета не " + v-type + " ! " view-as alert-box.
            return.
        end.
    end.
    if txb.cif.type = 'B' then
    do:
        message "Счет юридического лица ! Изъятие невозможно!" view-as alert-box.
        return.
    end.


    v-sum =  (aaa.cr[1] - aaa.dr[1])  + (aaa.cr[2] - aaa.dr[2]).
    /*v-com = '302'.*/
    v-sum_com = 0.

    v-fio1 = "".
    v-rnn1 = "".
    v-pss1 = "".

    def var fio as char.
    def var doc as char.
    def var rnn as char.

    if (txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699) or (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799) then
    do:
        MESSAGE "Получатель является владелец счета?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE v-whplat.
        if v-whplat then
        do:
            v-fio1 = v-fio.
            v-rnn1 = v-rnn.
            v-pss1 = v-pss.
            /*displ v-fio1 v-pss1 v-rnn1  with frame fr1.*/
        end. else
        do:
            update v-chr with frame fr3.
            if v-chr = 'u' or v-chr = 'U' or v-chr = 'Г' or v-chr = 'г' then
            do:
                find first txb.uplcif where txb.uplcif.cif = v-cif-f and txb.uplcif.coregdt <= v-gtoday and txb.uplcif.finday >= v-gtoday no-lock no-error.
                if avail txb.uplcif then
                do:
                    run seluplcif(output fio,output doc,output rnn).
                    v-fio1 = fio.
                    v-rnn1 = rnn.
                    v-pss1 = doc.
                    /*displ v-fio1 v-pss1 v-rnn1  with frame fr1.*/
                end. else
                do:
                    message "У клиента нет уполномоченных лиц !" VIEW-AS ALERT-BOX TITLE "".
                end.
            end.
            if v-chr = 'n' or v-chr = 'N' or v-chr = 'Т' or v-chr = 'т' then
            do:
                find first txb.cif-heir where txb.cif-heir.cif = v-cif-f no-lock no-error.
                if avail txb.cif-heir then
                do:
                    run selcifref(output fio,output doc,output rnn).
                    v-fio1 = fio.
                    v-rnn1 = rnn.
                    v-pss1 = doc.
                    /*displ v-fio1 v-pss1 v-rnn1  with frame fr1.*/
                end. else
                do:
                    message "У клиента нет наследников !" VIEW-AS ALERT-BOX TITLE "".
                end.
            end.
        end.
    end.

    update  v-fio1 v-pss1 v-rnn1  with frame fr1.

    displ v-sum v-com with frame fr1.
    /*     update v-sum v-kod v-kbe v-knp v-com with frame fr1. */
    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = v-cif-f no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-kbe = substring(txb.cif.geo, 3,1) + txb.sub-cod.ccode.

    update v-kod v-kbe v-knp with frame fr1.

    displ v-sum_com v-ja with frame fr1.
    if v-type ne '' then
    do:
        vavl = txb.aaa.cbal - txb.aaa.hbal.


        find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.

        d_sumfreez = 0.
        d_ost = 0.


        /*Депозиты физических лиц*/
        find last txb.acvolt where txb.acvolt.aaa =  txb.aaa.aaa no-lock no-error.
        if txb.lgr.led = 'TDA' then
        do:
            if v-gtoday <> aaa.regdt then
            do:

                /*Метрошка*/
                if txb.lgr.feensf = 7 then
                do:
                    i-mon = 0.
                    run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
                    t-aaa = txb.aaa.aaa.
                    v-sumchkamt = 0.
                    if i-mon < 1 then
                    do:
                        for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
                            v-sumchkamt = v-sumchkamt + txb.aad.sumg .
                        end.
                        v-sumchkamt  =  v-sumchkamt + aaa.opnamt.
                        d_1% = (txb.aaa.cr[1] - txb.aaa.dr[1]) - v-sumchkamt - txb.aaa.stmgbal.
                        d_3% = 0.
                        if d_1% < 0 then d_1% = 0.
                    end.
                    else
                    do:
                        v-sumchkamt = 0.
                        t_date = date(txb.acvolt.x1).
                        t_date2 = v-gtoday - 1.
                        d_sumrt = 0.
                        v-rt1 = 0.
                        repeat: /*выбор конвертаций*/
                            find last txb.aaa_conv where txb.aaa_conv.aaa = t-aaa  no-lock no-error.
                            if not avail txb.aaa_conv then leave.
                            if avail txb.aaa_conv then
                            do:
                                create tmp-conv.
                                tmp-conv.aaa = txb.aaa_conv.aaa.
                                tmp-conv.conv = txb.aaa_conv.conv.
                                tmp-conv.dt = txb.aaa_conv.dt.
                                tmp-conv.aaaold = txb.aaa_conv.aaaold.
                                tmp-conv.aaac = txb.aaa_conv.aaac.
                                t-aaa = txb.aaa_conv.aaaold.
                            end.
                        end.
                        find last bf-acvolt where bf-acvolt.aaa =  t-aaa no-lock no-error.
                        if avail bf-acvolt then
                        do:
                            run Get_Rate_Real(t-aaa, date(bf-acvolt.x1), output v-rt1).
                            if i-mon < 18 then
                            do:
                                /*            run Get_Rate_18(t-aaa, date(bf-acvolt.x1), output v-rt1).  */
                                v-rt1 = txb.aaa.rate / 2.

                            end.
                        end.
                        else
                            v-rt1 = 0.

                        v-opnamt = txb.aaa.opnamt.
                        do t-ind = t_date to t_date2:
                            find last tmp-conv where tmp-conv.dt = t-ind   no-error.
                            if avail tmp-conv then
                            do:
                                t-aaa = tmp-conv.aaa.

                                run Get_Rate_Real(tmp-conv.aaa, t-ind, output v-rt1).
                                if i-mon < 18 then
                                do:
                                    v-rt1 = txb.aaa.rate / 2.
                                /*               run Get_Rate_18(tmp-conv.aaa, t-ind, output v-rt1).  */
                                end.

                            end.

                            find last txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.regdt = t-ind and txb.aad.who <> "bankadm" no-lock no-error.
                            if avail txb.aad then
                            do:
                                v-opnamt = v-opnamt + sumg.
                            end.


                            d_sumrt = d_sumrt + ((v-opnamt * (v-rt1) ) / (txb.aaa.base * 100)).


                            find last bf-aaa where bf-aaa.aaa = t-aaa no-lock no-error.
                            find last bf-acvolt where bf-acvolt.aaa = t-aaa no-lock no-error.
                            if avail bf-aaa and avail bf-acvolt then
                            do:

                                ev-date = EventInRange("18", t-ind, t-ind).
                                if ev-date <> ? then
                                do:
                                    run tdagetrate(bf-aaa.aaa, bf-aaa.pri, bf-aaa.cla, ev-date, bf-aaa.opnamt, output v-rt1).
                                    if i-mon < 18 then
                                    do:
                                        run Get_Rate_18(bf-aaa.aaa, t-ind, output v-rt1).
                                        v-rt1 = bf-aaa.rate / 2.

                                    end.
                                end.
                            end.
                        end.


                        for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
                            v-sumchkamt = v-sumchkamt + txb.aad.sumg .
                        end.
                        v-sumchkamt  =  v-sumchkamt + txb.aaa.opnamt.


                        if (txb.aaa.cr[1] - txb.aaa.dr[1]) >= (txb.acvolt.bonusopnamt + v-sumchkamt + d_sumrt - (txb.aaa.accrued - (txb.aaa.cr[2] - txb.aaa.dr[2]) - txb.aaa.stmgbal)) then
                        do:
                            d_1% = (txb.aaa.cr[1] - txb.aaa.dr[1]) - (txb.acvolt.bonusopnamt + v-sumchkamt + d_sumrt - (txb.aaa.accrued - (txb.aaa.cr[2] - txb.aaa.dr[2]) - txb.aaa.stmgbal) ).
                            d_3% = 0.
                        end.
                        else
                        do:
                            d_1% = 0.
                            d_3% =  (txb.acvolt.bonusopnamt + v-sumchkamt + d_sumrt - (txb.aaa.accrued - (txb.aaa.cr[2] - txb.aaa.dr[2]) - txb.aaa.stmgbal)) - (txb.aaa.cr[1] - txb.aaa.dr[1]).
                        end.

                    end.
                end.
                /*Метро-VIP*/
                if txb.lgr.feensf = 4 then
                do:
                    i-mon = 0.
                    run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
                    t-aaa = txb.aaa.aaa.
                    v-sumchkamt = 0.
                    if i-mon < 3 then
                    do:
                        if i-mon < 1 then
                        do:
                            for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
                                v-sumchkamt = v-sumchkamt + txb.aad.sumg .
                            end.
                            v-sumchkamt  =  v-sumchkamt + txb.aaa.opnamt.

                            d_1% = (txb.aaa.cr[1] - txb.aaa.dr[1]) - v-sumchkamt.
                            d_3% = 0.
                            if d_1% < 0 then d_1% = 0.
                        end.
                        else
                        do:
                            for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
                                v-sumchkamt = v-sumchkamt + txb.aad.sumg .
                            end.
                            v-sumchkamt  =  v-sumchkamt + txb.aaa.opnamt.
                            d_1% = (txb.aaa.cr[1] - txb.aaa.dr[1]) - (v-sumchkamt - (txb.aaa.accrued - (txb.aaa.cr[2] - txb.aaa.dr[2]) - txb.aaa.stmgbal)).
                            d_3% = 0.
                            if d_1% < 0 then d_1% = 0.
                        end.

                    end.
                    else
                    do:
                        d_1% = 0.
                        d_3% = (txb.aaa.cr[2] - txb.aaa.dr[2]).
                    end.
                end.
                /* Метро-люкс */
                if (txb.lgr.feensf = 3)  then
                do:
                    i-mon = 0.
                    run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
                    if i-mon < 1 then
                    do:
                        v-sumchkamt = 0.
                        for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
                            v-sumchkamt = v-sumchkamt + txb.aad.sumg.
                        end.
                        v-sumchkamt  =  v-sumchkamt + txb.aaa.opnamt.

                        d_1% = 0.
                        d_3% = 0.
                        if d_1% < 0 then d_1% = 0.
                    end.
                    else
                    do:
                        d_1% = 0.
                        d_3% = (txb.aaa.cr[2] - txb.aaa.dr[2]).
                    end.
                end.
                /* Метро-люкс c 1/06/2011*/
                if (txb.lgr.feensf = 6)  then do:
                    i-mon = 0.
                    run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
                    if i-mon < 1 then do:
                        v-sumchkamt = 0.
                        for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
                            v-sumchkamt = v-sumchkamt + txb.aad.sumg.
                        end.
                        v-sumchkamt  =  v-sumchkamt + txb.aaa.opnamt.

                        d_1% = 0.
                        d_3% = 0.
                        if d_1% < 0 then d_1% = 0.
                    end. else do:
                        d_1% = 0.
                        d_3% = 0 /*(txb.aaa.cr[2] - txb.aaa.dr[2])*/.
                    end.
                end.
                if lookup(txb.lgr.lgr, "A38,A39,A40") > 0  then
                do:
                        v-sumchkamt = 0.
                        for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who = "bankadm" no-lock:
                            v-sumchkamt = v-sumchkamt + txb.aad.cam - txb.aad.dam.
                        end.
                        d_1% = v-sumchkamt.
                        d_3% = 0.
                        if date(txb.acvolt.x3) <= v-gtoday then d_1% = 0.

                end.
                /* Метро-суперлюкс  */
                if  (txb.lgr.feensf = 5) then
                do:
                    i-mon = 0.
                    run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
                    if i-mon < 1 then
                    do:
                        v-sumchkamt = 0.
                        for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
                            v-sumchkamt = v-sumchkamt + txb.aad.sumg.
                        end.
                        v-sumchkamt  =  v-sumchkamt + txb.aaa.opnamt.

                        /*d_1% = (txb.aaa.cr[1] - txb.aaa.dr[1]) - v-sumchkamt - txb.aaa.stmgbal. */
                        d_1% = 0.
                        d_3% = 0.
                        if d_1% < 0 then d_1% = 0.
                    end.
                    else
                    do:
                        d_1% = 0.
                        d_3% = 0.
                        if i-mon >= 18 then
                        do:
                            d_1% = 0.
                            d_3% = (txb.aaa.cr[2] - txb.aaa.dr[2]).
                        end.


                        def var vendsum as decimal.
                        vendsum = 0.
                        for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1 and txb.jl.jdt >= txb.aaa.expdt and txb.jl.rem[1] begins "Выплата процентов" no-lock use-index acc :
                            if txb.jl.dc <> "D" then
                            do:
                                vendsum = vendsum + abs(txb.jl.cam - txb.jl.dam).
                            end.
                        end.

                        if v-gtoday >= txb.aaa.expdt then
                        do:
                            d_1% = vendsum.
                            d_3% = 0.
                        end.





                    end.
                end.


                /*Метро-Стандарт*/
                if txb.lgr.feensf = 1 then
                do:
                    run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
                    if i-mon < 1 then
                    do:
                        t_date = date(txb.acvolt.x1).
                        t_date2 = v-gtoday - 1.
                        d_sumrt = 0.
                        v-rt1 = 0.
                        repeat: /*выбор конвертаций*/
                            find last txb.aaa_conv where txb.aaa_conv.aaa = t-aaa  no-lock no-error.
                            if not avail txb.aaa_conv then leave.
                            if avail txb.aaa_conv then
                            do:
                                create tmp-conv.
                                tmp-conv.aaa = txb.aaa_conv.aaa.
                                tmp-conv.conv = txb.aaa_conv.conv.
                                tmp-conv.dt = txb.aaa_conv.dt.
                                tmp-conv.aaaold = txb.aaa_conv.aaaold.
                                tmp-conv.aaac = txb.aaa_conv.aaac.
                                t-aaa = txb.aaa_conv.aaaold.
                            end.
                        end.

                        find last bf-aaa where bf-aaa.aaa = t-aaa no-lock no-error.
                        if avail bf-aaa then
                        do:
                            run Get_Rate(t-aaa, output v-rt1).
                        end.
                        else
                            v-rt1 = 0.

                        do t-ind = t_date to t_date2:
                            find last tmp-conv where tmp-conv.dt = t-ind   no-error.
                            if avail tmp-conv then
                            do:
                                run Get_Rate(tmp-conv.aaa, output v-rt1).
                            end.
                            d_sumrt = d_sumrt + ((txb.aaa.opnamt * v-rt1) / (txb.aaa.base * 100)).
                        end.
                        d_3% = d_sumrt.
                        d_1% = 0.
                    end. /*меньше месяца*/
                    else
                    do: /*больше месяца*/
                        t_date = date(txb.acvolt.x1).
                        t_date2 = v-gtoday - 1.
                        d_sumrt = 0.
                        v-rt1 = 0.
                        repeat: /*выбор конвертаций*/
                            find last txb.aaa_conv where txb.aaa_conv.aaa = t-aaa  no-lock no-error.
                            if not avail txb.aaa_conv then leave.
                            if avail txb.aaa_conv then
                            do:
                                create tmp-conv.
                                tmp-conv.aaa = aaa_conv.aaa.
                                tmp-conv.conv = aaa_conv.conv.
                                tmp-conv.dt = aaa_conv.dt.
                                tmp-conv.aaaold = aaa_conv.aaaold.
                                tmp-conv.aaac = aaa_conv.aaac.
                                t-aaa = aaa_conv.aaaold.
                            end.
                        end.
                        find last bf-acvolt where bf-acvolt.aaa =  t-aaa no-lock no-error.
                        if avail bf-acvolt then
                        do:
                            run Get_Rate_Real(t-aaa, date(bf-acvolt.x1), output v-rt1).
                        end.
                        else
                            v-rt1 = 0.

                        do t-ind = t_date to t_date2:
                            find last tmp-conv where tmp-conv.dt = t-ind   no-error.
                            if avail tmp-conv then
                            do:
                                t-aaa = tmp-conv.aaa.
                                run Get_Rate_Real(tmp-conv.aaa, t-ind, output v-rt1).
                            end.
                            d_sumrt = d_sumrt + ((txb.aaa.opnamt * (v-rt1 / 2) ) / (txb.aaa.base * 100)).
                            find last bf-aaa where bf-aaa.aaa = t-aaa no-lock no-error.
                            find last bf-acvolt where bf-acvolt.aaa = t-aaa no-lock no-error.
                            if avail bf-aaa and avail bf-acvolt then
                            do:

                                ev-date = EventInRange("Y", t-ind, t-ind).
                                if ev-date <> ? then
                                do:
                                    run tdagetrt(bf-aaa.aaa, bf-aaa.pri, bf-aaa.cla, ev-date, bf-aaa.opnamt, output v-rt1).
                                end.
                            end.
                        end.
                        d_3% = d_sumrt.
                        d_1% = 0.
                    end.
                end.  /*txb.lgr.feensf = 1*/

            end.
            else
            do:
                txb.aaa.sta = "E".
                d_1% = 0.
                d_3% = 0.
            end.







        end.
        else

            /*Депозиты юридических лиц*/
            if txb.lgr.led = 'CDA' then
            do:
                if txb.aaa.crc = 1   then
                do:
                    find txb.sysc "ratekz" no-lock no-error.
                    if available txb.sysc then d-brate = txb.sysc.deval.
                end.
                if txb.aaa.crc = 2   then
                do:
                    find txb.sysc "rateus" no-lock no-error.
                    if available txb.sysc then d-brate = txb.sysc.deval.
                end.
                if txb.aaa.crc = 3  then
                do:
                    find txb.sysc "rateeu" no-lock no-error.
                    if available txb.sysc then d-brate = txb.sysc.deval.
                end.


                /* Срочный вклад */
                if (txb.aaa.regdt < 08/01/2011) and (lookup(txb.lgr.lgr,"478,479,480,481,482,483") <> 0) then
                do:
                    i-mon = 0.
                    /*Закрытие после окончания сроков после всех пролонгаций*/
                    if (v-gtoday > date(txb.acvolt.x3) and txb.acvolt.x7 = 4) then
                    do:
                        d_1% = 0.
                        d_3% = 0.
                    end.
                    else
                    do: /*досрочное расторжение*/
                        run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
                        if i-mon < 1 then
                        do:
                            d_tssum = 0.
                            d_1% = 0.
                            d_3% = 0.
                        end.
                        else
                        do:
                            run Get_Month_Data(date(txb.acvolt.x1), v-gtoday, output d_daycount, output d_trdaydate).
                            if i-mon < 12  then
                            do:

                                d_tssum = 0.
                                d_tssum =  (d_trdaydate - date(txb.acvolt.x1)) * txb.aaa.opnamt *  d-brate / (365 * 100).
                            end.
                            else
                            do:
                                if txb.aaa.crc = 1 then v-val = "KZT" .
                                if txb.aaa.crc = 2 then v-val = "USD" .
                                if txb.aaa.crc = 3 then v-val = "EUR" .

                                find last txb.rtur where txb.rtur.cod = v-val and txb.rtur.trm = integer(txb.acvolt.x4) and txb.rtur.rem = "SR"  no-lock no-error.
                                d_tssum = 0.
                                d_tssum =  (d_trdaydate - date(txb.acvolt.x1)) * txb.aaa.opnamt *  (txb.rtur.rate / 2) / (365 * 100).

                            end.
                            ss = 0.
                            dd = 0.
                            find last b-bufaaa where b-bufaaa.aaa20 = txb.aaa.aaa no-lock no-error.
                            if avail b-bufaaa then
                            do:
                                for each txb.jl where txb.jl.acc = b-bufaaa.aaa and txb.jl.lev = 1 and txb.jl.dc = "D" and  txb.jl.rem[1] begins "15%"  no-lock use-index acc :
                                    ss = ss + (if txb.jl.dc = "D" then txb.jl.dam else txb.jl.cam).
                                end.

                                for each txb.jl where txb.jl.acc = b-bufaaa.aaa and txb.jl.lev = 1 and txb.jl.dc = "D"  and  not txb.jl.rem[1] begins "Перенос в связи с переходом на" no-lock use-index acc :
                                    dd = dd + (if txb.jl.dc = "D" then txb.jl.dam else txb.jl.cam).
                                end.
                            end.

                            for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1 and txb.jl.dc = "D" and  txb.jl.rem[1] begins "15%"  no-lock use-index acc :
                                ss = ss + (if txb.jl.dc = "D" then txb.jl.dam else txb.jl.cam).
                            end.

                            for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1 and txb.jl.dc = "D" and    not txb.jl.rem[1] begins "Перенос в связи с переходом на"  no-lock use-index acc :
                                dd = dd + (if txb.jl.dc = "D" then txb.jl.dam else txb.jl.cam).
                            end.


                            d_tssum = (d_tssum + txb.aaa.opnamt + txb.acvolt.bonusopnamt) - (dd - ss).  /* должны выплатить ели клиент не забирал */

                            d_tssum = round(d_tssum, 2).
                            d_1% = 0.
                            d_3% = 0.
                            if (txb.aaa.cr[1] - txb.aaa.dr[1])  >  d_tssum then  d_1% = (txb.aaa.cr[1] - txb.aaa.dr[1]) - d_tssum.
                            if (txb.aaa.cr[1] - txb.aaa.dr[1])  <  d_tssum then  d_3% = d_tssum - (txb.aaa.cr[1] - txb.aaa.dr[1]).
                        end.
                    end.
                end.
                /* Срочный вклад c 01/08/2011*/
                if (txb.aaa.regdt >= 08/01/2011) and (lookup(txb.lgr.lgr,"478,479,480,481,482,483") <> 0) then
                do:
                    d_tssum = 0.
                    d_1% = 0.
                    d_3% = 0.
                end.

                /*Накопительный вклад*/
                if lookup(lgr.lgr,"484,485,486,487,488,489") <> 0 then
                do:
                    i-mon = 0.
                    /*Закрытие после окончания сроков после всех пролонгаций*/
                    if (v-gtoday > date(txb.acvolt.x3) and txb.acvolt.x7 = 4) then
                    do:
                        d_1% = 0.
                        d_3% = 0.
                    end.
                    else
                    do: /*досрочное расторжение*/
                        run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
                        if i-mon < 1 then
                        do:
                            d_tssum = 0.
                            d_1% = 0.
                            d_3% = 0.
                        end.
                        else
                        do:
                            message "ОШИБКА ПРИ ВЕДЕНИИ СЧЕТА: необходим пересчет вручную"  view-as alert-box .
                            return.
                            run Get_Month_Data(date(txb.acvolt.x1), v-gtoday, output d_daycount, output d_trdaydate).
                            find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa exclusive-lock no-error.
                            if not avail txb.acvolt then
                            do:
                                message "ОШИБКА ПРИ ВЕДЕНИИ СЧЕТА: продолжение невозможно"  view-as alert-box .
                                return.
                            end.
                            ss = 0.
                            find last b-bufaaa where b-bufaaa.aaa20 = aaa.aaa no-lock no-error.
                            if avail b-bufaaa then
                            do:
                                for each txb.jl where txb.jl.acc = b-bufaaa.aaa and txb.jl.lev = 1 and txb.jl.dc = "D" and  txb.jl.rem[1] begins "15%"  no-lock use-index acc :
                                    ss = ss + (if txb.jl.dc = "D" then txb.jl.dam else txb.jl.cam).
                                end.
                            end.
                            for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1 and txb.jl.dc = "D" and  txb.jl.rem[1] begins "15%"  no-lock use-index acc :
                                ss = ss + (if txb.jl.dc = "D" then txb.jl.dam else txb.jl.cam).
                            end.
                            d_tssum_nalog = 0.
                            d_tssum =  (decimal(txb.acvolt.prim1) - ss - txb.acvolt.bonusopnamt) / 2.
                            d_tssum_nalog = d_tssum * 15 / 100.
                            /*   d_tssum = d_tssum - d_tssum_nalog. */
                            d_tssum = d_tssum + txb.acvolt.bonusopnamt.
                            ss = 0.
                            for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
                                d_tssum = d_tssum + txb.aad.sumg.
                                ss = ss + txb.aad.sumg.
                            end.

                            d_tssum = d_tssum + txb.aaa.opnamt.
                            ss = ss + txb.aaa.opnamt.
                            /*message (acvolt.bonusopnamt + ss) (aaa.cr[1] - aaa.dr[1]).
                            pause 333. */
                            if (txb.acvolt.bonusopnamt + ss) >= (txb.aaa.cr[1] - txb.aaa.dr[1]) then
                            do:
                                d_tssum = d_tssum - ((txb.acvolt.bonusopnamt + ss) - (txb.aaa.cr[1] - txb.aaa.dr[1])).
                            end.

                            d_tssum = round(d_tssum, 2).

                            d_1% = 0.
                            d_3% = 0.

                            if (txb.aaa.cr[1] - txb.aaa.dr[1])  >  d_tssum then  d_1% = (txb.aaa.cr[1] - txb.aaa.dr[1]) - d_tssum.
                            if (txb.aaa.cr[1] - txb.aaa.dr[1])  <  d_tssum then  d_3% = d_tssum - (txb.aaa.cr[1] - txb.aaa.dr[1]).

                        end.
                    end.

                end.
            end.


        if lookup(lgr.lgr,"B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20,151,152,153,154,171,172,157,158,176,177,173,175,174") <> 0 then do:
           message "Досрочное закрытие невозможно!"  view-as alert-box .
           return.
        end.

        if (txb.aaa.cr[1] - txb.aaa.dr[1]) < d_1% then do:
           message "Не достаточно средст на 1м уровне для удержания %%. Досрочное закрытие невозможно!"  view-as alert-box .
           return.
        end.


        message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА!" skip
            "Сумма в размере" trim(string((txb.aaa.cr[1] - txb.aaa.dr[1]) - d_1% + d_3%  ,'z,zzz,zzz,zz9.99-')) txb.crc.code "будет перечислена на счет!"  skip
            "Налог в размере" trim(string(d_tssum_nalog,'z,zzz,zzz,zzz,zz9.99-')) crc.code "будет удержан" skip
            "Подтвердите закрытие депозита."
            view-as alert-box question buttons yes-no title "" update v-ans as logical.
        if not  v-ans then return.

         DEFINE QUERY q-tar FOR txb.tarif2.

         DEFINE BROWSE b-tar QUERY q-tar
                DISPLAY txb.tarif2.str5 label "Код тарифа " format "x(3)" txb.tarif2.pakalp label "Наименование   " format "x(40)"
                WITH  15 DOWN.
         DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 85 NO-BOX.

         /*обработка F4*/

         on end-error of b-tar in frame f-tar do:
             hide frame f-tar.
            undo, return.
         end.

         on help of v-com in frame fr1 do:
             OPEN QUERY  q-tar FOR EACH txb.tarif2 where lookup (tarif2.str5, v-comkod)  > 0 no-lock.
             ENABLE ALL WITH FRAME f-tar.
             wait-for return of frame f-tar
             FOCUS b-tar IN FRAME f-tar.
             v-com = txb.tarif2.str5.
             hide frame f-tar.
             displ v-com with frame fr1.
         end.


         update v-com with frame fr1.

         def var v-sel as int.

        v-sum = (txb.aaa.cr[1] - txb.aaa.dr[1]) - d_1% + d_3% - d_tssum_nalog .
        find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' exclusive-lock no-error.
        if avail txb.sub-cod then
        do:
            txb.sub-cod.rdt = v-gtoday.
        end.



    end.
    update v-npl v-npl1 with frame fr1.
    find txb.sysc where txb.sysc.sysc = "bnkadr" no-lock no-error.
    if avail txb.sysc then
    do:
        v-mail = entry(5, txb.sysc.chval, "|") no-error.
    end.

    v-ja = no.
    update v-ja with frame fr1.
end.











Procedure Get_Month_Begin.
    def input parameter a_start as date.
    def input parameter e_date as date.
    def output parameter out_month as integer.

    def var vterm       as inte.
    def var e_refdate   as date.
    def var e_displdate as date.
    def var t_date      as date.
    def var years       as inte    initial 0.
    def var months      as inte    initial 0.
    def var days        as inte    initial 0.

    def var t-years     as inte    initial 0.
    def var t-months    as inte    initial 0.
    def var t-days      as inte    initial 0.

    def var i           as integer initial 0.


    vterm = 1.
    t_date = a_start.
    i = 0.



    repeat:
        days = day(a_start).
        years = integer(vterm / 12 - 0.5).
        months = vterm - years * 12.
        months = months + month(t_date).
        if months > 12 then
        do:
            years = years + 1.
            months = months - 12.
        end.
        /*Если счет открыт в последний день месяца но не в феврале*/
        if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then
        do:
            t-years = years.
            t-months = months + 1.
            if t-months = 13 then
            do:
                t-months = 1.
                t-years = years + 1.
            end.
            t-days = 1.

            if months <> 2 then
            do:
                e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
            end.
            else
            do:
                e_displdate = date(t-months, t-days, year(t_date) + t-years).
            end.
        end.

        else
            /*Если счет открыт 1-го числа*/
            if day(a_start) = 1 then
            do: /*Если Дата открытия 1 числа*/
                if months <> 3 then
                    e_displdate = date(months, days, year(t_date) + years) - 1.
                else
                    e_displdate = date(months, days, year(t_date) + years).
            end.
            else
            /*Если счет открыт не первого и не последнего */
            do: /*обычная дата*/

                if months = 2 and (days = 29 or days = 30 or days = 31) then
                do:
                    months = 3.
                    days = 2.
                end.

                days = days - 1.
                e_displdate = date(months, days, year(t_date) + years).
            end.



        if e_displdate + 1 >= e_date then
        do:
            if e_displdate + 1 = e_date then i = i + 1.
            out_month = i.
            return.
        end.

        i = i + 1.

        t_date = date(months, 15, year(t_date) + years).
    end.  /*repeat*/
End procedure.

Procedure tdagetrt.

    def input parameter vaaa as char.
    def input parameter vpri as char format "x(3)".
    def input parameter vterm as inte.
    def input parameter vuntil as date.
    def input parameter vamt like txb.jl.dam.
    def output parameter vrate like txb.aaa.rate.

    def var highamount    like txb.jl.dam initial 999999999.99.
    def var lowlowvalue   as inte initial 0.
    def var lowvalue      as inte initial 1.
    def var highhighvalue as inte initial 100.
    def var highvalue     as inte initial 99.
    def var highterm      as inte.
    def var lowterm       as inte.
    def var cpri          as char.
    def var v-inc         as inte.
    def var v-min         like txb.jl.dam.
    def var v-max         like txb.jl.dam.
    def buffer b-acc for txb.aaa.
    find first b-acc where b-acc.aaa = vaaa no-lock no-error.
    if avail b-acc and b-acc.payfre = 1 then
    do:
        /* счет с исключением по % ставке */
        vrate = b-acc.rate.
        return.
    end.

    if vamt > highamount then vamt = highamount.
    if vterm < lowvalue then vterm = lowvalue.
    if vterm > highvalue then vterm = highvalue.

    highterm = highhighvalue.

    for each txb.pri where txb.pri.pri begins "^" + vpri no-lock group by txb.pri.pri desc:
    lowterm = integer(substring(txb.pri.pri,5,2)).
    if vterm > lowterm and vterm <= highterm then leave.
    highterm = lowterm.
end.
if lowterm  = lowlowvalue and highterm = highhighvalue then
do:
    find last txb.prih where txb.prih.pri = txb.pri.pri and txb.prih.until = vuntil
        no-lock no-error.
    if available txb.prih then vrate = txb.prih.rat.
    else vrate = txb.pri.rate.
    return.
end.
else if highterm = highhighvalue
        then cpri = "^" + string(vpri,"x(3)") + string(highvalue,"99").
    else cpri = "^" + string(vpri,"x(3)") + string(highterm,"99").

find txb.pri where txb.pri.pri = cpri no-lock no-error.
if not available txb.pri then  return.
find last txb.prih where txb.prih.pri = txb.pri.pri and txb.prih.until <= vuntil
    no-lock no-error.
if available txb.prih then
do:
    repeat v-inc = 6 to 1 by -1:
        v-max = txb.prih.tlimit[v-inc].
        if v-inc gt 1 then v-min = txb.prih.tlimit[v-inc - 1].
        else v-min = 0.
        if vamt > v-min and vamt <= v-max then
        do:
            vrate = txb.prih.trate[v-inc].
            leave.
        end.
    end.
end.
else
do:
    repeat v-inc = 6 to 1 by -1:
        v-max = txb.pri.tlimit[v-inc].
        if v-inc gt 1 then v-min = txb.pri.tlimit[v-inc - 1].
        else v-min = 0.
        if vamt > v-min and vamt <= v-max then
        do:
            vrate = txb.pri.trate[v-inc].
            leave.
        end.
    end.
end.
End procedure.


Procedure EventHandler.
    def input parameter e_period as char.
    def input parameter e_date as date.
    def input parameter a_start as date.
    def input parameter a_expire as date.
    def output parameter e_fire as logi.

    def var vterm       as inte.
    def var e_refdate   as date.
    def var e_displdate as date.
    def var t_date      as date.
    def var years       as inte    initial 0.
    def var months      as inte    initial 0.
    def var days        as inte    initial 0.

    def var t-years     as inte    initial 0.
    def var t-months    as inte    initial 0.
    def var t-days      as inte    initial 0.


    def var i           as integer initial 0.

    e_fire = false.
    if e_period  = "N" then return.
    else if e_period = "S" and e_date = a_start then
        do:
            e_fire = true.
            return.
        end.
        else if e_period = "F" and e_date = a_expire then
            do:
                e_fire = true.
                return.
            end.
            else if e_period = "M" or e_period = "Q" or e_period = "Y"
                    or e_period = "1" or e_period = "2" or e_period = "3"
                    or e_period = "4" or e_period = "5" or e_period = "6"
                    or e_period = "7" or e_period = "8" or e_period = "9" then
                do:
                    if e_period = "M" then vterm = 1.
                    else if e_period = "Q" then vterm = 3.
                        else if e_period = "Y" then vterm = 12.
                            else vterm = integer(e_period).
                    t_date = a_start.
                    i = 1.



                    repeat:
                        days = day(a_start).
                        years = integer(vterm / 12 - 0.5).
                        months = vterm - years * 12.
                        months = months + month(t_date).
                        if months > 12 then
                        do:
                            years = years + 1.
                            months = months - 12.
                        end.


                        /*Если счет открыт в последний день месяца но не в феврале*/
                        if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then
                        do:
                            t-years = years.
                            t-months = months + 1.
                            if t-months = 13 then
                            do:
                                t-months = 1.
                                t-years = years + 1.
                            end.
                            t-days = 1.

                            if months <> 2 then
                            do:
                                e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
                            end.
                            else
                            do:
                                e_displdate = date(t-months, t-days, year(t_date) + t-years).
                            end.
                        end.

                        else
                            /*Если счет открыт 1-го числа*/
                            if day(a_start) = 1 then
                            do: /*Если Дата открытия 1 числа*/
                                if months <> 3 then
                                    e_displdate = date(months, days, year(t_date) + years) - 1.
                                else
                                    e_displdate = date(months, days, year(t_date) + years).
                            end.
                            else
                            /*Если счет открыт не первого и не последнего */
                            do: /*обычная дата*/

                                if months = 2 and (days = 29 or days = 30 or days = 31) then
                                do:
                                    months = 3.
                                    days = 2.
                                end.

                                days = days - 1.
                                e_displdate = date(months, days, year(t_date) + years).
                            end.

                        if e_displdate > e_date then return.
                        else if e_displdate > a_expire then return.
                        if e_date = e_displdate then
                        do:
                            e_fire = true.
                            return.
                        end.


                        t_date = date(months, 15, year(t_date) + years).
                        i = i + 1.
                    end.  /*repeat*/

                end.
                else if e_period = "D" then e_fire = true.
End procedure.


Procedure Get_Rate_18. /*Возврещает ставку счета*/
    def input parameter a_aaa as char.
    def input parameter a_date as date.
    def output parameter r_rate as decimal.
    find last bf-t where bf-t.aaa = a_aaa no-lock no-error.
    if avail bf-t then
    do:
        r_rate = decimal(bf-t.x4).
    end.
    else
        r_rate = 0.
end.





Procedure Get_Month_Data.
    def input parameter a_start as date.
    def input parameter e_date as date.
    def output parameter out_month as integer.
    def output parameter o_date as date.

    def var vterm       as inte.
    def var e_refdate   as date.
    def var e_displdate as date.
    def var t_date      as date.
    def var years       as inte    initial 0.
    def var months      as inte    initial 0.
    def var days        as inte    initial 0.

    def var t-years     as inte    initial 0.
    def var t-months    as inte    initial 0.
    def var t-days      as inte    initial 0.

    def var i           as integer initial 0.


    vterm = 1.
    t_date = a_start.
    i = 0.



    repeat:
        days = day(a_start).
        years = integer(vterm / 12 - 0.5).
        months = vterm - years * 12.
        months = months + month(t_date).
        if months > 12 then
        do:
            years = years + 1.
            months = months - 12.
        end.
        /*Если счет открыт в последний день месяца но не в феврале*/
        if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then
        do:
            t-years = years.
            t-months = months + 1.
            if t-months = 13 then
            do:
                t-months = 1.
                t-years = years + 1.
            end.
            t-days = 1.

            if months <> 2 then
            do:
                e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
            end.
            else
            do:
                e_displdate = date(t-months, t-days, year(t_date) + t-years).
            end.
        end.

        else
            /*Если счет открыт 1-го числа*/
            if day(a_start) = 1 then
            do: /*Если Дата открытия 1 числа*/
                if months <> 3 then
                    e_displdate = date(months, days, year(t_date) + years) - 1.
                else
                    e_displdate = date(months, days, year(t_date) + years).
            end.
            else
            /*Если счет открыт не первого и не последнего */
            do: /*обычная дата*/

                if months = 2 and (days = 29 or days = 30 or days = 31) then
                do:
                    months = 3.
                    days = 2.
                end.

                days = days - 1.
                e_displdate = date(months, days, year(t_date) + years).
            end.


        if e_displdate + 1 > e_date then
        do:
            if e_displdate + 1 = e_date then
            do:
                i = i + 1.
            end.
            out_month = i.
            /*          o_date =  e_displdate + 1.*/
            return.
        end.
        o_date =  e_displdate + 1.


        i = i + 1.

        t_date = date(months, 15, year(t_date) + years).
    end.  /*repeat*/
End procedure.
