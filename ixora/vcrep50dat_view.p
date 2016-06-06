/* vcrep50dat_view.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по физ. лицам для НБ РК
        Сборка данных во временную таблицу по всем филиалам
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        13.12.2010 aigul - на основе vcrep50dat
 * BASES
        BANK COMM TXB
 * CHANGES
        09,02,11 Дамир- если нет страны , то кнп пустой

*/

define shared var g-ofc    like txb.ofc.ofc.
def  shared var v-god as integer format "9999".
def  shared var v-month as integer format "99".
def shared var v-dtb as date format "99/99/9999".
def shared var v-dte as date format "99/99/9999".
def shared var v-pay as integer.
def var v-rnn as char no-undo.
def var v-rnnd as deci no-undo.
def var v-knp as char no-undo.
def var v-knpK as char no-undo.
def var v-bn as char no-undo.

def shared temp-table rmztmp
    field rmz       as char
    field rmztmp_aaa       as char
    field rmztmp_cif       as char
    field rmztmp_fio       as char
    field rmztmp_rez1      as char
    field rmztmp_rnn       as char
    field rmztmp_tranz     as char
    field rmztmp_tranzK    as char
    field rmztmp_knp       as char
    field rmztmp_knpK       as char /*КНП*/
    field rmztmp_dt        as date
    field rmztmp_bc        as char /*ї банковского счета*/
    field rmztmp_st        as char /*страна получения/отправления*/
    field rmztmp_stch      as char /*буквенный код страны*/
    field rmztmp_stK       as char /*код страны получения/отправления*/
    field rmztmp_rez2      as char
    field rmztmp_sec       as char /*сектор экономики*/
    field rmztmp_secK      as char /*код сектор экономики*/
    field rmztmp_bn        as char /*наименование отправителя/получателя 28.02.2006*/
    field rmztmp_crc       like txb.ncrc.code  /*валюта*/
    field rmztmp_crcK      like txb.ncrc.stn   /*код валюты*/
    field rmztmp_camt      as deci
    field rmztmp_uamt      as deci
    field rmztmp_bin       as char
    field rmztmp_bank       as char.

def var v-amtusd as deci no-undo.
def var v-sum as deci no-undo.
def var v-sum1 as deci no-undo.
def var v-fio    as char no-undo.
def var v-bank   as char no-undo.
def var v-rez1 as char no-undo. def var v-rez2 as char no-undo.
def var v-tranz as char no-undo. def var v-tranzK as char no-undo.
def var v-dt as date format "99/99/9999" no-undo.
def var v-ncrc as char  no-undo.  def var v-ncrcK as integer no-undo.   /*char*/
def var v-sec as char no-undo. def var v-secK as char no-undo.
def var v-amt as deci no-undo. def var v-stK as char no-undo.
def var rep_f as logi initial false no-undo.
def var v-bin as char no-undo.
def var s-ourbank as char no-undo.


find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

if s-ourbank = "TXB00" then do:
    /*по всем платежам*/
    for each txb.remtrz where txb.remtrz.valdt2 >= v-dtb and txb.remtrz.valdt2 <= v-dte and
    ((v-pay = 2 and string(txb.remtrz.drgl) begins '1052') or (v-pay = 1 and string(txb.remtrz.crgl) begins '1052') or
    (v-pay = 2 and string(txb.remtrz.drgl) begins '1351') or (v-pay = 1 and string(txb.remtrz.crgl) begins '1351')) no-lock.
        run rep50-remtrz(txb.remtrz.remtrz).
    end.
    /*по разблокированным в текущем месяце*/
    for each vcblock where vcblock.sts = 'C' and vcblock.deldt >= v-dtb and vcblock.deldt <= v-dte no-lock.
        find first rmztmp where rmztmp.rmz = vcblock.remtrz no-lock no-error.
        if avail rmztmp then next.
        find first txb.remtrz where txb.remtrz.remtrz = vcblock.remtrz  and
        ((v-pay = 2 and string(txb.remtrz.drgl) begins '1052') or (v-pay = 1 and string(txb.remtrz.crgl) begins '1052') or
        (v-pay = 2 and string(txb.remtrz.drgl) begins '1351') or (v-pay = 1 and string(txb.remtrz.crgl) begins '1351')) no-lock no-error.
        if avail txb.remtrz then do:
            rep_f = true.
            run rep50-remtrz(txb.remtrz.remtrz).
        end.
    end.
end.
else do:
/*по всем платежам*/
    for each txb.remtrz where txb.remtrz.valdt2 >= v-dtb and txb.remtrz.valdt2 <= v-dte and
    ((v-pay = 2 and string(txb.remtrz.drgl) begins '1052') or (v-pay = 1 and string(txb.remtrz.crgl) begins '1052') or
    (v-pay = 2 and string(txb.remtrz.drgl) begins '1351') or (v-pay = 1 and string(txb.remtrz.crgl) begins '1351')) no-lock.
        run rep50-remtrz(txb.remtrz.remtrz).
    end.
    /*по разблокированным в текущем месяце*/
    for each vcblock where vcblock.sts = 'C' and vcblock.deldt >= v-dtb and vcblock.deldt <= v-dte no-lock.
        find first rmztmp where rmztmp.rmz = vcblock.remtrz no-lock no-error.
        if avail rmztmp then next.
        find first txb.remtrz where txb.remtrz.remtrz = vcblock.remtrz  and
        ((v-pay = 2 and string(txb.remtrz.drgl) begins '1052') or (v-pay = 1 and string(txb.remtrz.crgl) begins '1052') or
        (v-pay = 2 and string(txb.remtrz.drgl) begins '1351') or (v-pay = 1 and string(txb.remtrz.crgl) begins '1351')) no-lock no-error.
        if avail txb.remtrz then do:
            rep_f = true.
            run rep50-remtrz(txb.remtrz.remtrz).
        end.
    end.
end.

procedure rep50-remtrz.
    def input parameter v-remtrz like txb.remtrz.remtrz.
    v-rnn = ''. v-rnn = ''. v-bn = ''. v-tranz = ''. v-tranzK = ''. v-rez1 = ''. v-rez2 = ''. v-ncrc = ''. v-ncrcK = 0.
    v-sec = ''. v-secK = ''. v-stK = ''.
    find first txb.remtrz where txb.remtrz.remtrz =  v-remtrz no-lock no-error.
    if avail txb.remtrz then do:
        /*валютному контролю подлежат не только операции в валюте, но и в тенге*/
        /*if remtrz.fcrc = 1 then next. */
        find first txb.sub-cod where txb.sub-cod.sub   = 'rmz'
        and txb.sub-cod.acc   = txb.remtrz.remtrz
        and txb.sub-cod.d-cod = 'zsgavail' no-lock  no-error.
        if avail txb.sub-cod then do:
            if txb.sub-cod.ccode <> "1" then next.
        end.
        else next.
        /*если страна бенефициара и отправителя казахстан то next*/
        find first txb.sub-cod where txb.sub-cod.sub = 'rmz'
        and txb.sub-cod.acc        = txb.remtrz.remtrz
        and txb.sub-cod.d-cod      = 'iso3166'  no-lock no-error.
        if (txb.sub-cod.ccode = 'KZ' or txb.sub-cod.ccode = 'msc') then next.
        /* Если не физ лицо то next */
        find first txb.sub-cod where txb.sub-cod.sub   = 'rmz'
        and txb.sub-cod.acc   = txb.remtrz.remtrz
        and txb.sub-cod.d-cod = 'eknp' no-lock  no-error.
        if avail txb.sub-cod and
        (((txb.remtrz.ptype = '6' or txb.remtrz.ptype = '2' or (txb.remtrz.ptype = '4' and txb.remtrz.rbank = "VALOUT"))
        and substr(txb.sub-cod.rcode,2,1) = "9" and v-pay = 1) or
        ((txb.remtrz.ptype = '7'or (txb.remtrz.ptype = '3' /*and not remtrz.sbank begins "TXB"*/)) and substr(txb.sub-cod.rcode,5,1) = "9" and v-pay = 2 ))
        then do:
            v-knpK = substr(txb.sub-cod.rcode,7,3).
            /*исключить преводы между собственными счетами*/
            if trim(v-knpK) = '321' then next.
            find txb.codfr where txb.codfr.codfr = 'spnpl' and txb.codfr.code = substr(txb.sub-cod.rcode,7,3) no-lock no-error.
            if avail txb.codfr then
            v-knp = trim(txb.codfr.name[1]). /*кнп*/
            if not avail txb.codfr then v-knp = " ".
            if (txb.remtrz.ptype = '6' or txb.remtrz.ptype = '2' or (txb.remtrz.ptype = '4' and txb.remtrz.rbank = "VALOUT")) and v-pay = 1 then do:    /*30.03.2006 u00600*/
                v-tranz = "отправленный". v-dt = txb.remtrz.valdt2.    /*"исходящий"*/
                v-tranzK = '1'.
                v-rez1 = substr(txb.sub-cod.rcode,1,1).   /*резидентство клиента банка*/
                v-rez2 = substr(txb.sub-cod.rcode,4,1).   /*резидентсво инопартнера*/
                v-secK = substr(txb.sub-cod.rcode,5,1).  /*сектор экономики в кодовом значении*/
                find first txb.codfr where txb.codfr.codfr = 'secek'      /*исходящий - получатель 2-я пара, 5.1*/
                and   txb.codfr.code  = substr(txb.sub-cod.rcode,5,1) no-lock no-error.
                if avail txb.codfr then v-sec = txb.codfr.name[1].   /*сектор экономики*/
                else v-sec = ''.
            end.
            if (txb.remtrz.ptype = '7'or (txb.remtrz.ptype = '3' /*and not remtrz.sbank begins "TXB"*/)) and v-pay = 2 then do: /*входящий*/
                /*если платеж блокирован, то пропускаем*/
                if rep_f = false then do:
                    if txb.remtrz.rsub = 'arp' then do:
                        find first vcblock where vcblock.remtrz = txb.remtrz.remtrz no-lock no-error.
                        if avail vcblock then do:
                            if vcblock.sts <> 'C' then next.
                            if vcblock.sts = 'C' and (vcblock.deldt >= v-dtb and vcblock.deldt <= v-dte) then v-dt = vcblock.deldt.
                            /*else next.*/
                        end.
                    end.
                    else v-dt = txb.remtrz.valdt2.
                end.
                else do:
                    find first vcblock where vcblock.remtrz = txb.remtrz.remtrz no-lock no-error.
                    if avail vcblock then do:
                        if vcblock.sts = 'C' and (vcblock.deldt >= v-dtb and vcblock.deldt <= v-dte) then v-dt = vcblock.deldt.
                        else next.
                    end.
                end.
                v-tranz = "полученный". v-tranzK = '2'.
                v-rez1 = substr(txb.sub-cod.rcode,4,1).    /*резидентство клиента банка*/
                v-rez2 = substr(txb.sub-cod.rcode,1,1).    /*резидентсво инопартнера*/
                v-secK = substr(txb.sub-cod.rcode,2,1).  /*сектор экономики в кодовом значении*/
                find first txb.codfr where txb.codfr.codfr = 'secek'     /*входящий - отправитель 1-я пара, 2.1*/
                and   txb.codfr.code  = substr(txb.sub-cod.rcode,2,1) no-lock no-error.
                if avail txb.codfr then v-sec = txb.codfr.name[1].   /*сектор экономики*/
                else v-sec = ''.
             end.
             if txb.remtrz.fcrc = 2 then v-amtusd = txb.remtrz.amt.
             else do:  /*перевод суммы платежа по курсу в доллары*/
                find last txb.ncrchis where txb.ncrchis.crc = txb.remtrz.fcrc and txb.ncrchis.rdt <= txb.remtrz.rdt - 1 no-lock no-error.
                if avail txb.ncrchis then v-amtusd = txb.remtrz.amt * txb.ncrchis.rate[1].
                find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= txb.remtrz.rdt - 1 no-lock no-error.
                if avail txb.ncrchis then v-amtusd = v-amtusd / txb.ncrchis.rate[1].
             end.
             v-amt =  txb.remtrz.amt. /*сумма в валюте платежа*/
             find first txb.sub-cod where txb.sub-cod.sub = 'rmz'
             and txb.sub-cod.acc        = txb.remtrz.remtrz
             and txb.sub-cod.d-cod      = 'iso3166'  no-lock no-error.
             /*if not avail txb.sub-cod then next.*/
             find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod
             and  txb.codfr.code        = txb.sub-cod.ccode no-lock no-error.
             /*if not avail txb.codfr then next.*/
             find first code-st where code-st.code = txb.codfr.code no-lock no-error.
             if avail code-st then v-stK = code-st.cod-ch.
             else v-stK = ''.
             if (txb.remtrz.ptype = '6' or txb.remtrz.ptype = '2' or (txb.remtrz.ptype = '4' and txb.remtrz.rbank = "VALOUT")) and v-pay = 1 then do:
                if index(txb.remtrz.ord,"/RNN/") > 0 then do:
                    v-rnn = substr(txb.remtrz.ord, index(txb.remtrz.ord,"/RNN/") + 5, 12).
                    v-fio = substr(txb.remtrz.ord, 1 , index(txb.remtrz.ord,"/RNN/") - 1).
                    if index(v-fio,"ALMATY") > 0 then substr(v-fio, index(v-fio,'ALMATY'), 6) = " ".
                    if index(v-fio,"URALSK") > 0 then substr(v-fio, index(v-fio,"URALSK"), 6) = " " .
                    if index(v-fio,"ASTANA") > 0 then substr(v-fio, index(v-fio,"ASTANA"), 6) = " " .
                    if index(v-fio,"ATYRAU") > 0 then substr(v-fio, index(v-fio,"ATYRAU"), 6) = " " .
                    if index(v-fio,"KAZAKHSTAN") > 0 then substr(v-fio, index(v-fio,"KAZAKHSTAN"), 10) = " " .
                    v-rnnd = deci(v-rnn) no-error.
                    IF ERROR-STATUS:ERROR then assign v-rnn = txb.remtrz.ord v-fio = txb.remtrz.ord.
                end.
                IF trim(v-rnn) = '' then assign v-rnn = txb.remtrz.ord v-fio = txb.remtrz.ord.
                v-bn = txb.remtrz.bn[1] + " " + txb.remtrz.bn[2] + " " + txb.remtrz.bn[3].  /*получатель 28.02.2006*/
             end.
             if (txb.remtrz.ptype = '7'or (txb.remtrz.ptype = '3' /*and not remtrz.sbank begins "TXB"*/)) and v-pay = 2 then do:
                find first txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
                if avail txb.aaa then do:
                    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if avail txb.cif then  assign v-rnn = txb.cif.jss v-fio = txb.cif.name v-bin = txb.cif.bin.
                end.
                if v-rnn = '' then assign v-rnn = txb.remtrz.bn[1] v-fio = txb.remtrz.bn[1] .
                v-bn = txb.remtrz.ord. /*отправитель 28.02.2006*/
             end.
             /* Валюта платежа */
             find first txb.ncrc where txb.ncrc.crc = txb.remtrz.fcrc no-lock no-error.
             if avail txb.ncrc then do:
                v-ncrc = txb.ncrc.code.
                v-ncrcK = txb.ncrc.stn.
             end.
             create rmztmp.
             assign rmztmp.rmztmp_fio   =  v-fio
                    rmztmp.rmz = txb.remtrz.remtrz
                    rmztmp.rmztmp_rez1  =  v-rez1
                    rmztmp.rmztmp_rez2  =  v-rez2
                    rmztmp.rmztmp_rnn   =  v-rnn
                    rmztmp.rmztmp_tranz =  v-tranz
                    rmztmp.rmztmp_tranzK =  v-tranzK
                    rmztmp.rmztmp_knp = v-knp
                    rmztmp.rmztmp_knpK = v-knpK
                    rmztmp.rmztmp_dt    =  v-dt
                    rmztmp.rmztmp_sec   =  v-secK        /*v-sec*/
                    rmztmp.rmztmp_bn    =  v-bn
                    rmztmp.rmztmp_crc   =  v-ncrc            /*валюта платежа*/
                    rmztmp.rmztmp_crcK  =  v-ncrcK           /*код валюты платежа*/
                    rmztmp.rmztmp_camt  =  v-amt / 1000      /*сумма в валюте платежа*/
                    rmztmp.rmztmp_uamt  =  v-amtusd / 1000          /*сумма в долларах*/
                    rmztmp.rmztmp_st    =  txb.codfr.name[1] /*наименование страны*/
                    rmztmp.rmztmp_stch  =  txb.codfr.code /*буквенный код страны*/
                    rmztmp.rmztmp_stK   =  v-stK.            /*код страны для статистики*/
                    /*разобраться с входящими*/
                    if v-pay = 1 then rmztmp.rmztmp_bank = txb.remtrz.sbank.
                    if v-pay = 2 then rmztmp.rmztmp_bank = txb.remtrz.rbank.
                    rmztmp.rmztmp_bin = v-bin.
             if (txb.remtrz.ptype = '6' or txb.remtrz.ptype = '2' or (txb.remtrz.ptype = '4' and txb.remtrz.rbank = "VALOUT"))
             and v-pay = 1 then rmztmp.rmztmp_bc  = txb.remtrz.sacc.   /* исходящий */
             if (txb.remtrz.ptype = '7' or (txb.remtrz.ptype = '3' /*and not remtrz.sbank begins "TXB"*/)) and v-pay = 2 then rmztmp.rmztmp_bc  = txb.remtrz.racc.   /* входящий */
       end.
    end.
end.