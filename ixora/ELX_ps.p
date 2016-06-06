/* ELX_ps.p
 * BASES
        -bank -comm
 * MODULE
        Elecsnet
 * DESCRIPTION
        Оплата услуг Казахтелеком через Элекснет
 * MENU
        Процесс
 * AUTHOR
        17/10/2006 dpuchkov
 * CHANGES
        17.11.2006 u00124 изменил ORACLE на NTORACLE
        12.02.2007 id00004 добавил alias
        28.07.2010 marinav - автоматическая проводка
        24/11/2010 galina - зачисление на корр-счет для платежей по аккредитивам в ин. валюте
        20.07.2011 id00810 - для аккредитивов (payment, вид оплаты 4, статус 14, adjust/maintain charges, статус 15)
        26.07.2011 Luiza  - создается проводка на счет дохода от комиссии согласно коду комиссии c транзитного арп (ТЗ 901)
        28.10.2011 id00810 - для аккредитивов (Post Finance Details, статус 16)
        30.12.2011 id00810 - для док.инкассо (Advise, статус 17)
        08.02.2012 id00810 - для ODC (Create, статус 17)
        06.03.2012 Lyubov  - "dc" изменила на "idc"
        03.05.2012 aigul - добавила списание комиссии за ЭЦП
        10.08.2012 id00810 - корректировка прерывания по ошибке в блоках Комиссия ЭЦП и ОС
        13.10.2012 id00810 - для док.инкассо (ODC: payment, статус 18, IDC: изменения в статусе 12), ТЗ 1273
        08.11.2012 id00810 - ТЗ 1557, статус 19, создание проводок на счета из списка МТ102
        28/10/2013 Luiza  - ТЗ 1932 изменила параметры шаблона cda0003 и uni0048
*/


{global.i}
def new shared var s-rmzir as char.
def var ourbank as char.
def var v_sec   as char.
def var r-cover as integer.
def var d_1%    as decimal decimals 2. /* Сумма удерживаемая с 1 уровня  */
def var d_2%    as decimal decimals 2. /* Сумма удерживаемая со 2 уровня */
def var d_3%    as decimal decimals 2. /* Сумма для выплаты на 1 уровень */
def var vparam as char.
def var rcode  as inte.
def var vdel    as char initial "^".
def var rdes   as char.
def var v-jh like jh.jh.
def var s-amt2  as decimal decimals 2.
def var s-amt11 as decimal decimals 2.
def var s-amt1  as decimal decimals 2.
def var v-nlg as char.
define buffer bnlg-sysc for sysc.
define buffer b-sysc for sysc.

def var vjh as int.
def var v-arp as char.
def var v_comm as decimal.

/*find first cmp no-lock no-error.
if avail cmp then do:
    if cmp.code = 016 then v-arp = "KZ02470142870A033516".
    if cmp.code = 000 then v-arp = "KZ93470142870A034400".
    if cmp.code = 001 then v-arp = "KZ75470142870A019301".
    if cmp.code = 002 then v-arp = "KZ82470142870A018302".
    if cmp.code = 004 then v-arp = "KZ46470142870A017204".
    if cmp.code = 003 then v-arp = "KZ39470142870A018203".
    if cmp.code = 005 then v-arp = "KZ65470142870A018705".
    if cmp.code = 006 then v-arp = "KZ39470142870A018106".
    if cmp.code = 007 then v-arp = "KZ74470142870A019707".
    if cmp.code = 008 then v-arp = "KZ15470142870A019508".
    if cmp.code = 009 then v-arp = "KZ54470142870A018709".
    if cmp.code = 010 then v-arp = "KZ27470142870A018710 ".
    if cmp.code = 011 then v-arp = "KZ17470142870A018211".
    if cmp.code = 012 then v-arp = "KZ19470142870A020212".
    if cmp.code = 013 then v-arp = "KZ12470142870A017913".
    if cmp.code = 014 then v-arp = "KZ45470142870A020714".
    if cmp.code = 015 then v-arp = "KZ66470142870A021015".
end.*/

find last sysc where sysc.sysc = "ourbnk" no-lock no-error.
ourbank = sysc.chval.

find last wpay where wpay.pay =  "0" and  wpay.txb = ourbank exclusive-lock no-error.
if avail wpay then  do:
    find last cif where cif.cif = wpay.cif no-lock no-error.
    if not avail cif then do:
       wpay.pay =  "2" .
       release  wpay.
    end.
    else do:
        /*find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = "secek" no-lock no-error.
        if avail sub-cod and sub-cod.ccode <> "msc" then v_sec = string(sub-cod.ccode).
        */
        /*aigul - зачисление комиссии*/
        find first tarif2 where tarif2.kont = 460828 no-lock no-error.
        if avail tarif2 then  v_comm = tarif2.ost.
        find first arp where arp.gl = 287082 no-lock no-error.
        if avail arp then v-arp = arp.arp.
        vparam = string(v_comm) + vdel +
                  "1" + vdel +
                  wpay.aaa + vdel +
                  v-arp + vdel +
                  "Комиссия за выпуск электронной цифровой подписи (ЭЦП)." + vdel +
                  "840".
        run trxgen ("jou0068", vdel, vparam, "cif", wpay.aaa, output rcode, output rdes, input-output vjh).
        if rcode ne 0 then do:
            run savelog( "ELX", "Ошибка: Зачисление комиссии, trxgen, " + string(rcode) + ","  + rdes).
            wpay.pay =  "2" .
        end.
        else do:
           run trxsts(vjh, 6, output rcode, output rdes).
           if rcode ne 0 then do:
              run savelog( "ELX", "Ошибка: Зачисление комиссии, trxsts , " + string(rcode) + ","  + rdes).
              wpay.pay =  "2" .
           end.
           else do:
                for each jh where jh.jh = vjh exclusive-lock:
                    jh.party = "057".
                end.
                wpay.pay =  "1" .  /* Платеж создан */
                wpay.sts = return-value .
           end.
        end.
        /*****/
        /**********************************/
        /*if time < 51300 then r-cover = 1. *//* SCLEAR00 */
        /*else r-cover = 2.*/ /* SGROSS00 */

        /*run wpay
        ("1",      *//* Номер документа */
        /*1440,           *//* Сумма платежа   */
        /*wpay.aaa,   *//* Счет отправителя*/
        /*"NBRKKZKX",    *//* Банк получателя */
        /*"KZ54125KZT1002300104",   */ /* Счет получателя */
        /*"",             *//* КБК */
        /*false,         */ /* Тип бюджета - проверяется если есть КБК */
        /*"РГП Казахстанский центр межбанковских расчетов Нац.Банка",      *//* Бенефициар      */
        /*"600400060664",*/ /* РНН Бенефициара */
        /*"851",      *//* KNP */
        /*integer(substr(cif.geo,3,1) + v_sec),      *//* Kod */
        /*integer(comm.taxnk.kod) */
        /*15,    */          /*integer(comm.taxnk.kbe)*/ /* Kbe */
        /*"За регистрацию сертификата KISC Certificate RK-02  " +  wpay.rem,*/ /* Назначение платежа */
        /*"2T",          *//* Код очереди */
        /*"0",           */ /* Кол-во экз. */
        /*r-cover,        *//* remtrz.cover (для проверки даты валютированият.е. 1-CLEAR00 или 2-SGROSS00) */
        /*cif.jss,        *//* РНН отправителя */
        /*cif.name).     */ /* s-fiozer        */
        /**************************************/
        /* if return-value <> "" then do:
            for each jh where jh.jh = vjh exclusive-lock:
                jh.party = "057".
            end.
            wpay.pay =  "1" .  /* Платеж создан и отправлен */
            wpay.sts = return-value .
         end.
         else do:
            wpay.pay =  "2" .  /* Платеж не создан */
         end.*/
    end.
end.

release  wpay.


/******Депозиты - статусы 1,2,3*********************/
vparam = "".
do transaction:
find last clsdp where clsdp.sts = '1' and clsdp.txb = ourbank exclusive-lock no-error.
if avail clsdp then do:
   d_1%  = clsdp.level1.
   d_3%  = clsdp.level2.
   find last aaa where aaa.aaa = clsdp.aaa no-lock no-error.
   find last lgr where lgr.lgr = aaa.lgr no-lock no-error.
   def var v-rate as deci no-undo.
   find last crc where crc.crc = aaa.crc no-lock no-error.
   v-rate  = crc.rate[1].
   if avail aaa then do:
         run tdaremholda(clsdp.aaa).
         /* Проводка с 2 на 1 уровень */
         if d_3% > 0 and d_3% <= (aaa.cr[2] - aaa.dr[2]) then do:
            run trxgen("TDA0001", vdel, string(d_3%) + vdel + aaa.aaa + vdel + string(lgr.autoext,"999"), "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
               /*message "TDA0001" rdes. pause. */
                 clsdp.sts = '3'. undo,retry.
            end.
            else do:
               run trxsts(v-jh, 6, output rcode, output rdes).
               if rcode ne 0 then do:
                   /*message rdes . */
                  clsdp.sts = '3'. undo,retry.

               end.
            end.
         end.

         v-jh = 0.
         /* Проводка с 1 на 2 уровень */
         if d_1% > 0 and d_1% <= (aaa.cr[1] - aaa.dr[1]) then do:
            run trxgen("UNI0074", vdel, string(d_1%) + vdel + aaa.aaa + vdel + "Удержание процентов с 1 уровня" + vdel + string(lgr.autoext,"999"), "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
               /*message "UNI0074 " rdes.  */
               clsdp.sts = '3'. undo,retry.
            end.
         end.
         /*проводка со 2 на 11 или расходы*/
         s-amt2 = aaa.cr[2] - aaa.dr[2]  . s-amt11 = 0.
         find first trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and trxbal.level = 11 no-lock no-error.
         s-amt11 = truncate((trxbal.dam - trxbal.cam) / crc.rate[1], 2).
         if s-amt2 > s-amt11 then s-amt1 = s-amt2 - s-amt11.
         else do : s-amt1 = 0. s-amt11 = s-amt2. end.
         /* Проводка со 2 на 11 уровень */
         if s-amt11 > 0 then do:
            v-jh = 0.
            /*vparam = string(0) + vdel + aaa.aaa + vdel + string(s-amt11).*/
            if aaa.crc = 1 then vparam = string(0) + vdel + aaa.aaa + vdel + string(0) + vdel + aaa.aaa + vdel + "0" + vdel + string(s-amt11) + vdel + aaa.aaa.
            else vparam = string(0) + vdel + aaa.aaa + vdel + string(s-amt11) + vdel + aaa.aaa + vdel + string(round(s-amt11 * v-rate,2)) + vdel + string(0) + vdel + aaa.aaa.
            run trxgen ("cda0003", vdel, vparam, "CIF" , aaa.aaa ,  output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
                /*message "cda0003" ' ' rdes. */
               clsdp.sts = '3'. undo,retry.

            end. else
            do: /* штамповка транзакции */
                 run trxsts(v-jh, 6, output rcode, output rdes).
                 if rcode ne 0 then do:
                    clsdp.sts = '3'. undo,retry.
                    /*message rdes view-as alert-box title "". return. */
                 end.
            end.
         end.
         /* Урегулируем разность если на 2 ур > чем на 11 */
         if s-amt1 > 0 then do:
            v-jh = 0.
            /*vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов за частичное изъятие".*/
            if aaa.crc = 1 then vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов за частичное изъятие" + vdel +
                                    string(0) + vdel + aaa.aaa + vdel + "" + vdel + "0".
            else vparam = string(0) + vdel + aaa.aaa + vdel + "" + vdel +
                                    string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов за частичное изъятие" + vdel + string(round(s-amt1 * v-rate,2)).
            run trxgen ("uni0048", vdel, vparam, "CIF" , aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
               /*message "uni0048" ' ' rdes.  */
               clsdp.sts = '3'. undo,retry.

            end.
         end.

         if decimal(clsdp.cst) > 0 then do:
              find last bnlg-sysc where bnlg-sysc.sysc = "nlg"  no-lock no-error.
              if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
              vparam = string(decimal(clsdp.cst)) + vdel + string(aaa.crc) + vdel +  aaa.aaa + vdel +  string(v-nlg) + vdel + string("15% подоходный налог, " + cif.name + " " + cif.jss) + vdel + "390".
              v-jh = 0.
              run trxgen("uni0113", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
              if rcode ne 0 then do:
                 /*message "Произошла ошибка при удержании налога. Не настроен ARP счет." rdes.*/
                 clsdp.sts = '3'. undo,retry.
              end.

         end.


         aaa.sta = "E".
         clsdp.sts = '2' .
       end.
       else do:
            clsdp.sts = '3' .
       end.
end.
release clsdp.
end.
/****** ОС - статусы 10,11*********************/

find last clsdp where clsdp.sts = '10' and clsdp.txb = ourbank exclusive-lock no-error.
if avail clsdp then do:
    v-jh = 0.
    run trxgen(clsdp.rem, vdel, clsdp.prm, "arp", clsdp.aaa, output rcode, output rdes, input-output v-jh).
    if rcode ne 0 then do:
       clsdp.cst = string(rcode) + " " + rdes. /*undo,retry.*/
    end.
    else do:
        clsdp.sts = '11'.
        clsdp.cst = string(v-jh).

        find first ast where ast.ast = clsdp.aaa no-lock no-error.

        create astjln.
        astjln.ajh = v-jh.
        astjln.aln = 1.
        astjln.awho = g-ofc.
        astjln.ajdt = g-today.
        astjln.arem[1]= entry(4, clsdp.prm, "^").
        astjln.arem[2]=''.
        astjln.arem[3]=''.
        astjln.arem[4]=''.
        astjln.d[1]=ast.dam[1].
        astjln.c[1]=ast.cam[1].
        astjln.d[3]=ast.dam[3].
        astjln.c[3]=ast.cam[3].
        astjln.d[4]=ast.dam[4].
        astjln.c[4]=ast.cam[4].
        astjln.dam= ast.dam[1].
        astjln.adc = "D".
        astjln.agl = ast.gl.
        astjln.aqty= ast.qty.
        astjln.aast = ast.ast.
        astjln.afag = ast.fag.
        astjln.atrx= "o1".
        astjln.ak=ast.cont.
        astjln.crline=ast.crline.
        astjln.icost=ast.dam[1] - ast.cam[1].
        astjln.korgl=ast.gl.
        astjln.koracc=entry(2, clsdp.prm, "^").

        create astatl.
        astatl.ast = ast.ast.
        astatl.agl = ast.gl.
        astatl.fag = ast.fag.
        astatl.dt = g-today.
        astatl.icost = ast.dam[1] - ast.cam[1] .
        astatl.nol =  ast.cam[3] - ast.dam[3].
        astatl.fatl[4] = ast.cam[4] - ast.dam[4].
        astatl.atl = astatl.icost - astatl.nol.
        astatl.qty = ast.qty.

    end.
end.
release clsdp.

/****** galina - Оплата аккредитива (перевод на коррсчет) - статусы 12,13*********************/
def new shared var s-lc          like LC.LC.
def new shared var s-event       like lcevent.event.
def new shared var s-number      like lcevent.number.
def new shared var s-sts         like lcevent.sts.
def new shared var s-paysts      like lcpay.sts.
def new shared var s-lcpay       like lcpay.lcpay.
def new shared var s-lcprod      as char.
def new shared var v-lcsumorg    as deci.
def new shared var v-lcsumcur    as deci.
def new shared var v-lcdtexp  as date.
def buffer b-lcpayres for lcpayres.

find last clsdp where clsdp.sts = '12' and clsdp.txb = ourbank exclusive-lock no-error.
if avail clsdp then do:
    find first lcpayres where lcpayres.info[1] = clsdp.rem no-lock no-error.
    if avail lcpayres and lcpayres.info[2] <> ''
    then find first remtrz where remtrz.remtrz = lcpayres.info[2] no-lock no-error.
    else do:
        find first lceventres where lceventres.info[1] = clsdp.rem no-lock no-error.
        if avail lceventres and lceventres.info[2] <> ''
        then find first remtrz where remtrz.remtrz = lceventres.info[2] no-lock no-error.
    end.
    if avail remtrz and remtrz.jh2 > 0 then do:
        find first lcpay where lcpay.lc = lcpayres.lc and lcpay.lcpay = lcpayres.lcpay no-lock no-error.
        if avail lcpay and ((lcpay.lc begins 'idc' and lcpay.sts = 'bo2') or  (not lcpay.lc begins 'idc')) then do:
            v-jh = 0.
            if clsdp.cst ne '' then do:
                v-jh = int(entry(1,clsdp.cst,';')) no-error.
                if error-status:error then v-jh = 0.
            end.
            if v-jh = 0 then do:
                run trxgen('cif0022', vdel, entry(1,clsdp.prm,';'), "dfb", clsdp.aaa, output rcode, output rdes, input-output v-jh).
                if rcode ne 0 then clsdp.cst = string(rcode) + " " + rdes.
                else do:
                    clsdp.cst = string(v-jh).
                    if not lcpayres.lc begins 'idc' then clsdp.sts = '13'.
                    find current lcpayres exclusive-lock no-error.
                    if avail lcpayres then do:
                        lcpayres.info[3] = string(v-jh).
                        lcpayres.rem = lcpayres.rem + '; Списание с коррсчета № ' + string(v-jh).
                        find current lcpayres no-lock no-error.
                    end.
                    else do:
                        find current lceventres exclusive-lock no-error.
                        if avail lceventres then do:
                            lceventres.info[3] = string(v-jh).
                            lceventres.rem = lceventres.rem + '; Списание с коррсчета № ' + string(v-jh).
                            find current lceventres no-lock no-error.
                            assign s-lc     = lceventres.lc
                                   s-event  = lceventres.event
                                   s-number = lceventres.number
                                   s-sts    = 'BO2'.
                            run lcstse('BO2','FIN').
                        end.
                    end.
                end.
            end.
            if v-jh <> 0 and lcpayres.lc begins 'idc' then do:
                if num-entries(clsdp.prm,';') = 3 then do:
                    v-jh = 0.
                    run trxgen(entry(2,clsdp.prm,';'),vdel, entry(3,clsdp.prm,';'), "arp", clsdp.aaa, output rcode, output rdes, input-output v-jh).
                    if rcode ne 0 then clsdp.cst = clsdp.cst + ';' + string(rcode) + " " + rdes.
                    else do:
                        clsdp.cst = clsdp.cst + ';' + string(v-jh).
                        clsdp.sts = '13'.
                        find first b-lcpayres where b-lcpayres.lc = lcpayres.lc and b-lcpayres.lcpay = lcpayres.lcpay and b-lcpayres.dacc = entry(3,entry(3,clsdp.prm,';'),vdel) exclusive-lock no-error.
                        if avail b-lcpayres then do:
                            assign b-lcpayres.jh = v-jh
                                   b-lcpayres.jdt = g-today.
                            find current b-lcpayres no-lock no-error.
                        end.
                    end.
                end.
                if v-jh <> 0 then do:
                    assign s-lc     = lcpayres.lc
                           s-lcpay  = lcpayres.lcpay
                           s-paysts = 'BO2'.
                    run LCstspay('BO2','FIN') no-error.
                    if error-status:error then do:
                        run savelog( "ELX", s-lc + " ошибка смены статуса").
                    end.
                end.
            end.
        end.
    end.
    else clsdp.cst = 'Нет записи в RMZ ЦО или не создана вторая проводка!'.
end.
release clsdp.

/* аккредитивы - payment, вид оплаты 4, статус 14 */
def new shared var v-lcsts as char.
def var v-param as char no-undo.
def var v-trx   as char no-undo.
def var v-err   as log  no-undo.
/*def buffer b-lcpayres for lcpayres.*/

find last clsdp where clsdp.sts = '14' and clsdp.txb = ourbank no-lock no-error.
if avail clsdp  then do:
    find first lcpay where lcpay.lc = clsdp.rem  and lcpay.lcpay = int(clsdp.prm) no-lock no-error.
    if not avail lcpay then do:
        find current clsdp exclusive-lock no-error.
        clsdp.cst = 'Нет записи в таблице lcpay для ' + clsdp.rem + ' с номером платежа ' + clsdp.prm + '!'.
        find current clsdp no-lock no-error.
    end.
    else do:
        assign s-lc     = lcpay.lc
               s-paysts = lcpay.sts
               s-lcpay  = lcpay.lcpay.
        M:
        for each lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.jh = 0 no-lock:
            if lcpayres.cacc = clsdp.aaa then assign v-trx   = 'uni0207'
                                                     v-param = string(lcpayres.amt) + vdel + lcpayres.dacc  + vdel + lcpayres.cacc + vdel + 'Оплата по аккредитиву ' + lcpayres.lc .
            else if lcpayres.dacc = clsdp.aaa then assign v-trx   = 'uni0003'
                                                          v-param = string(lcpayres.amt) + vdel + string(lcpayres.crc) + vdel + lcpayres.dacc  + vdel + lcpayres.cacc + vdel + 'Оплата по аккредитиву ' + lcpayres.lc + vdel + '2' + vdel + '4' + vdel + '710' .
            else assign v-trx   = 'uni0012'
                        v-param = string(lcpayres.amt) + vdel + string(lcpayres.crc) + vdel + lcpayres.dacc  + vdel + lcpayres.cacc + vdel + 'Оплата по аккредитиву ' + lcpayres.lc + vdel + '2' + vdel + '4' + vdel + '710' .
            v-jh = 0.
            run trxgen(v-trx, vdel, v-param, "", clsdp.aaa, output rcode, output rdes, input-output v-jh).

            if rcode ne 0 then do:
               find current clsdp exclusive-lock no-error.
               clsdp.cst = string(rcode) + " " + rdes.
               find current clsdp no-lock no-error.
               v-err = yes.
               leave M.
            end.
            else do:
                find b-lcpayres where recid(b-lcpayres) = recid(lcpayres) exclusive-lock no-error.
                assign b-lcpayres.trx = v-trx
                       b-lcpayres.jh  = v-jh
                       b-lcpayres.jdt =  g-today.
                find current b-lcpayres no-lock no-error.
            end.
        end.
        if not v-err then do:
            find current clsdp exclusive-lock no-error.
            assign clsdp.sts = '13' clsdp.cst = ''.
            find current clsdp no-lock no-error.
            run LCstspay('BO2','FIN').
        end.
    end.
end.

/* аккредитивы - adjust/maintain charges, статус 15 */
def var v-knp as char.

find last clsdp where clsdp.sts = '15' and clsdp.txb = ourbank no-lock no-error.
if avail clsdp  then do:
    find first lcevent where lcevent.lc = clsdp.rem and lcevent.event = 'adjust' and lcevent.number = int(clsdp.prm) no-lock no-error.
    if not avail lcevent then do:
        find current clsdp exclusive-lock no-error.
        clsdp.cst = 'Нет записи в таблице lcevent для ' + clsdp.rem + ' событие Adjust с номером ' + clsdp.prm + '!'.
        find current clsdp no-lock no-error.
    end.
    else do:
        assign s-lc     = lcevent.lc
               s-event  = lcevent.event
               s-number = lcevent.number
               s-sts    = 'BO2'
               v-knp    = if lcevent.lc begins 'pg' then '182' else '181'
               v-err    = no.

        find first lceventres where lceventres.lc = lcevent.lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh = 0 no-lock no-error.
        if avail lceventres then do:
            assign v-trx   = 'uni0003'
                   v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc  + vdel + lceventres.cacc + vdel + 'Расчеты по ' + lceventres.lc + vdel + '2' + vdel + '4' + vdel + v-knp
                   v-jh    = 0.
            run trxgen(v-trx, vdel, v-param, "", clsdp.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
                v-err = yes.
                find current clsdp exclusive-lock no-error.
                clsdp.cst = string(rcode) + " " + rdes.
                find current clsdp no-lock no-error.
            end.
            else do:
                find current lceventres exclusive-lock no-error.
                assign lceventres.trx = v-trx
                       lceventres.jh  = v-jh
                       lceventres.jdt = g-today.
                find current lceventres no-lock no-error.
            end.
        end.

        if v-err = no then do:
            find current clsdp exclusive-lock no-error.
            assign clsdp.sts = '13' clsdp.cst = ''.
            find current clsdp no-lock no-error.
            run lcstse('BO2','FIN').
        end.
    end.

end.

/* аккредитивы - Post Finance Details, статус 16 */
find last clsdp where clsdp.sts = '16' and clsdp.txb = ourbank no-lock no-error.
if avail clsdp  then do:
    find first lcevent where lcevent.lc = clsdp.rem and lcevent.event = 'pfind' and lcevent.number = int(clsdp.prm) no-lock no-error.
    if not avail lcevent then do:
        find current clsdp exclusive-lock no-error.
        clsdp.cst = 'Нет записи в таблице lcevent для ' + clsdp.rem + ' событие Post Finance Details с номером ' + clsdp.prm + '!'.
        find current clsdp no-lock no-error.
    end.
    else do:
        assign s-lc     = lcevent.lc
               s-event  = lcevent.event
               s-number = lcevent.number
               s-sts    = 'BO2'
               v-err    = no.

        find first lceventres where lceventres.lc = lcevent.lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh = 0 no-lock no-error.
        if avail lceventres then do:
            assign v-trx   = 'cif0018'
                   v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + string(lceventres.levC) + vdel + lceventres.cacc + vdel + lceventres.lc
                   v-jh    = 0.
            run trxgen(v-trx, vdel, v-param, "", clsdp.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
                v-err = yes.
                find current clsdp exclusive-lock no-error.
                clsdp.cst = string(rcode) + " " + rdes.
                find current clsdp no-lock no-error.
            end.
            else do:
                find current lceventres exclusive-lock no-error.
                assign lceventres.trx = v-trx
                       lceventres.jh  = v-jh
                       lceventres.jdt = g-today.
                find current lceventres no-lock no-error.
            end.
        end.

        if v-err = no then do:
            find current clsdp exclusive-lock no-error.
            assign clsdp.sts = '13' clsdp.cst = ''.
            find current clsdp no-lock no-error.
            run lcstse('BO2','FIN').
        end.
    end.
end.
/* документарные инкассо IDC и ODC, статус 17 */
find last clsdp where clsdp.sts = '17' and clsdp.txb = ourbank no-lock no-error.
if avail clsdp  then do:
    find first lc where lc.lc = clsdp.rem  no-lock no-error.
    if not avail lc then do:
        find current clsdp exclusive-lock no-error.
        clsdp.cst = 'Нет записи в таблице lc для ' + clsdp.rem + '!'.
        find current clsdp no-lock no-error.
    end.
    else do:
        assign s-lc     = lc.lc
               v-lcsts  = 'BO2'
               v-err    = no.

        find first lcres where lcres.lc = lc.lc and not lcres.com and lcres.jh = 0 no-lock no-error.
        if avail lcres then do:
            assign v-trx   = if s-lc begins 'idc' then 'vnb0001' else 'uni0144'
                   v-param = clsdp.prm
                   v-jh    = 0.
            run trxgen(v-trx, vdel, v-param, "", clsdp.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
                v-err = yes.
                find current clsdp exclusive-lock no-error.
                clsdp.cst = string(rcode) + " " + rdes.
                find current clsdp no-lock no-error.
            end.
            else do:
                find current lcres exclusive-lock no-error.
                assign lcres.trx = v-trx
                       lcres.jh  = v-jh
                       lcres.jdt = g-today.
                find current lcres no-lock no-error.
            end.
        end.

        if v-err = no then do:
            find current clsdp exclusive-lock no-error.
            assign clsdp.sts = '13' clsdp.cst = ''.
            find current clsdp no-lock no-error.
            run LCsts('BO2','FIN').
        end.
    end.
end.
/* Payment, документарные инкассо ODC, статус 18 */
def var v-rmz1    like remtrz.remtrz no-undo.
def var v-bnkrnn  as char.
def var v-bnkname as char.
def var v-par     as char.
find last clsdp where clsdp.sts = '18' and clsdp.txb = ourbank no-lock no-error.
if avail clsdp  then do:
    find first lc where lc.lc = clsdp.rem  no-lock no-error.
    if not avail lc then do:
        find current clsdp exclusive-lock no-error.
        clsdp.cst = 'Нет записи в таблице lc для ' + clsdp.rem + '!'.
        find current clsdp no-lock no-error.
    end.
    else do:
        assign s-lc     = lc.lc
               v-lcsts  = 'BO2'
               v-err    = no
               v-par    = entry(1,clsdp.prm,';').

        find first lcpayres where lcpayres.lc = lc.lc and lcpayres.lcpay = int(entry(1,v-par,vdel)) and not lcpayres.com and lcpayres.dacc =  clsdp.aaa /*and lcpayres.jh = 0*/ no-lock no-error.
        if avail lcpayres then do:
            if lcpayres.jh = 0 then do:
                assign v-trx   = 'uni0017'
                       v-param = string(lcpayres.amt) + vdel + lcpayres.dacc + vdel + lcpayres.cacc + vdel + lcpayres.rem + vdel + '1' + vdel + '4' + vdel + '710'.
                       v-jh    = 0.
                run trxgen(v-trx, vdel, v-param, "", clsdp.aaa, output rcode, output rdes, input-output v-jh).
                if rcode ne 0 then do:
                    v-err = yes.
                    find current clsdp exclusive-lock no-error.
                    clsdp.cst = string(rcode) + " " + rdes.
                    find current clsdp no-lock no-error.
                end.
                else do:
                    find current lcpayres exclusive-lock no-error.
                    assign lcpayres.trx = v-trx
                           lcpayres.jh  = v-jh
                           lcpayres.jdt = g-today.
                    find current lcpayres no-lock no-error.
                end.
            end.
            /* перевод в филиал */
            find current lcpayres no-lock no-error.
            if lcpayres.jh <> 0 and lcpayres.info[1] = '' then do:
                find first cmp no-lock no-error.
                if avail cmp then assign v-bnkrnn = cmp.addr[2] v-bnkname = cmp.name.

                run rmzcre (int(entry(1,v-par,vdel)),
                    lcpayres.amt,
                    lcpayres.cacc,
                    v-bnkrnn,
                    v-bnkname,
                    lc.bank,
                    entry(2,v-par,vdel),
                    entry(3,v-par,vdel),
                    entry(4,v-par,vdel),
                    '0',
                     no,
                    '710',
                    '14',
                    '14',
                    lcpayres.rem ,
                    '1P',
                    0,
                    5,
                    g-today) .
                v-rmz1 = return-value.
                if v-rmz1 <> '' then do:
                    find first remtrz where remtrz.remtrz = v-rmz1 exclusive-lock no-error.
                    if avail remtrz then do:
                        remtrz.rsub = 'arp'.
                        find current remtrz no-lock no-error.
                    end.
                    find current lcpayres exclusive-lock no-error.
                    assign lcpayres.rem     = lcpayres.rem  + ' (перевод в филиал ' +  v-rmz1 + ')'
                           lcpayres.info[1] = v-rmz1.
                    find current lcpayres no-lock no-error.
                    for each jl where jl.jh = v-jh exclusive-lock:
                        jl.rem[1] = jl.rem[1] + ' (перевод в филиал '  + v-rmz1 + ')'.
                    end.
                end.
                else do:
                    v-err = yes.
                    find current clsdp exclusive-lock no-error.
                    clsdp.cst = 'не сформировался перевод в филиал'.
                    find current clsdp no-lock no-error.
                end.
            end.
            find current lcpayres no-lock no-error.
            if lcpayres.jh <> 0 and lcpayres.info[1] <> '' and num-entries(clsdp.prm,';') = 3 then do:
                find first b-lcpayres where b-lcpayres.lc = lcpayres.lc and b-lcpayres.lcpay = lcpayres.lcpay and b-lcpayres.dacc = entry(3,entry(3,clsdp.prm,';'),vdel) no-lock no-error.
                if avail b-lcpayres and b-lcpayres.jh = 0 then do:
                    v-jh = 0.
                    run trxgen(entry(2,clsdp.prm,';'),vdel, entry(3,clsdp.prm,';'), "arp", clsdp.aaa, output rcode, output rdes, input-output v-jh).
                    if rcode ne 0 then clsdp.cst = "ошибка проводки списания документов " + string(rcode) + " " + rdes.
                    else do:
                        find current b-lcpayres exclusive-lock.
                        assign b-lcpayres.jh  = v-jh
                               b-lcpayres.jdt = g-today.
                        find current b-lcpayres no-lock no-error.
                    end.
                end.
            end.
        end.

        if v-err = no then do:
            find current clsdp exclusive-lock no-error.
            assign clsdp.sts = '13' clsdp.cst = ''.
            find current clsdp no-lock no-error.
            /*run LCsts('BO2','FIN').*/
        end.
    end.
end.

/*  статус 19, создание проводок на счета из списка МТ102 */
def var v-res  as deci no-undo.
def var v-str  as char no-undo.
def var v-21   as char no-undo.
def var v-amt  as char no-undo.
def var v-la   as char no-undo.
def var v-irs  as char no-undo.
def var v-seco as char no-undo.
def var v-nazn as char no-undo.
def var v-ok   as logi no-undo.
def stream r-in.
find last clsdp where clsdp.sts = '19' and clsdp.txb = ourbank no-lock no-error.
if avail clsdp  then do:
    v-err = no.
    find first remtrz where remtrz.racc = clsdp.aaa and remtrz.amt = clsdp.level1 and remtrz.fcrc = int(clsdp.level2) and remtrz.rdt = today  and remtrz.rcvinfo[3] = clsdp.rem no-lock no-error.
    if not avail remtrz then v-err = yes.
    else if remtrz.jh2 = ? then v-err = yes.
    if v-err then do:
        find current clsdp exclusive-lock no-error.
        clsdp.cst = 'Нет RMZ или 2-ой проводки'.
        find current clsdp no-lock no-error.

    end.
    else do:
        find first arp where arp.arp = clsdp.aaa no-lock no-error.
        if not avail arp then v-err = yes.
        else do:
            find first sub-cod where sub-cod.acc   = arp.arp
                                 and sub-cod.sub   = "arp"
                                 and sub-cod.d-cod = "clsa"
                                 no-lock no-error.
            if avail sub-cod then if sub-cod.ccode ne "msc" then v-err = yes.
            else do:
                run lonbalcrc.p ('arp',arp.arp,g-today,'1',yes,arp.crc,output v-res).
                if abs(v-res) < remtrz.amt then v-err = yes.
            end.
        end.
        if v-err then do:
            find current clsdp exclusive-lock no-error.
            clsdp.cst = 'Нет ARP или закрыт или не хватает средств'.
            find current clsdp no-lock no-error.
        end.
        else do:
            if clsdp.cst ne '' then do:
                find current clsdp exclusive-lock no-error.
                clsdp.cst = ''.
                find current clsdp no-lock no-error.
            end.
            input stream r-in from value(clsdp.prm). /*читаем содержимое файла*/
            repeat:
                import stream r-in unformatted v-str.
                v-str = trim(v-str).
                if v-str begins '/IRS/' and v-irs = '' then do:
                    v-irs = substr(v-str,6,1).
                    next.
                end.
                if v-str begins '/SECO/' and v-seco = '' then do:
                    v-seco = substr(v-str,7,1).
                    next.
                end.
                if v-str begins '/KNP/' then do:
                    v-knp = trim(substr(v-str,6)).
                    next.
                end.
                if v-str begins '/ASSIGN/' then do:
                    v-nazn = trim(substr(v-str,9)).
                    next.
                end.
                if v-str begins ':21:' then do:
                    assign v-21  = trim(substr(v-str,5))
                           v-amt = ''
                           v-la  = ''.
                    next.
                end.
                else if v-str begins ':32B:' then do: v-amt  = replace(trim(substr(v-str,9)),',','.'). next. end.
                else if v-str begins '/LA/'  then do:
                        assign v-la    = trim(substr(v-str,5))
                               v-trx   = 'uni0211'
                               v-param = v-amt + vdel + string(remtrz.tcrc) + vdel + remtrz.ba + vdel + v-la + vdel + v-nazn + vdel + v-irs + vdel + v-seco + vdel + v-knp
                               v-jh    = 0.
                        run trxgen(v-trx, vdel, v-param, "", clsdp.aaa, output rcode, output rdes, input-output v-jh).
                        if rcode ne 0 then do:
                            find current clsdp exclusive-lock no-error.
                            clsdp.cst = clsdp.cst + v-amt + " " + v-la + " " + rdes + ";".
                            find current clsdp no-lock no-error.
                        end.
                        else v-ok = yes.
                end.
            end.
            input stream r-in close.
        end.
    end.
    if not v-err and v-ok then do:
        find current clsdp exclusive-lock no-error.
        clsdp.sts = '13'.
        find current clsdp no-lock no-error.
    end.
end.

/* Luiza--------------------------------------------------------------*/
def var v-tmpl as char no-undo.
def var v-param1 as char no-undo.
def var v-chk as char no-undo.
def var v_doc as char.
/*def var vdel    as char initial "^".
def var rcode  as inte.
def var rdes   as char.*/
def new shared var s-jh like jh.jh.
def var v-rmz  like remtrz.remtrz no-undo.
def new shared var vrat as deci decimals 2 .
def buffer b-filpayment for filpayment.

/*-----------генерация проводки на счет дохода согласно кодификатору на сумму комиссии с арп счета 287031--для тенговых счетов-------------------*/
for each  b-filpayment where  b-filpayment.stscom = 'sen1' and b-filpayment.whn = g-today and b-filpayment.bankfrom = ourbank no-lock.
    if b-filpayment.amountcom > 0 and b-filpayment.jhcom < 1 and trim(b-filpayment.rem[5]) <> "" and trim(b-filpayment.rem[2]) = '2' then do:

        find first remtrz where remtrz.ref = b-filpayment.rem[5] no-lock no-error.
        if available remtrz then find first que where que.remtrz = remtrz.remtrz no-lock no-error.
        else next.
        if available que and que.pid  = "F" and que.con = "W" then  do: /* если у платежа очередь не F, значит перевод на комиссию еще не поступил, проводку комиссии не проводим, ждем.*/
            /* создать проводку на счет дохода от комиссии согласно коду комиссии */
            find first tarif2 where tarif2.str5 = b-filpayment.info[2] and tarif2.stat = 'r' no-lock no-error.
            if avail tarif2 then do:
                    v-tmpl = "jou0021".
                    v-param1 = "" + vdel + string(b-filpayment.amountcom) + vdel + "1" + vdel + b-filpayment.info[10] + vdel + string(tarif2.kont) + vdel + "Комиссия за " + tarif2.pakalp.

                    s-jh = 0.
                    run trxgen (v-tmpl, vdel, v-param1, "", "" , output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                            message rdes. undo,next.
                    end.
                    run jou.
                    v_doc = return-value.
                    find first jh where jh.jh = s-jh exclusive-lock.
                    jh.party = v_doc.

                    if jh.sts < 6 then jh.sts = 6.
                    for each jl of jh:
                            if jl.sts < 6 then jl.sts = 6.
                    end.
                    find current jh no-lock.
                    find first joudoc where joudoc.docnum = v_doc no-error.
                    if avail joudoc then do:
                           joudoc.info = b-filpayment.name. joudoc.perkod = b-filpayment.rnnto. joudoc.kfmcif = b-filpayment.cif.
                    end.

                    find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
                    if not avail acheck then do:
                        v-chk = "".
                        v-chk = string(NEXT-VALUE(krnum)).
                        create acheck.
                        assign acheck.jh  = string(s-jh)
                               acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk
                               acheck.dt = g-today
                               acheck.n1 = v-chk.
                        release acheck.
                    end.

                    /*run vou_bank2(2,1, joudoc.info).*/
                    v_doc = b-filpayment.id.
                    find first filpayment where filpayment.id = v_doc exclusive-lock no-error.
                    if available filpayment then do:
                        filpayment.jhcom = s-jh.
                        filpayment.stscom = 'trx'.
                    end.
                    else do:
                        find current filpayment no-lock.
                        undo, next.
                    end.
                    find current filpayment no-lock.
                    release filpayment.

            end.  /*  avail tarif2   */
        end.  /* if available que  */
    end. /*  if filpayment.amountcom > 0 ...     */
end.

/*----------обработка платежей в ин валюте--снятие суммы комиссии со счета клиента с конвертацией в тенге  на арп счет 287031
------------и создание межфилиального платежа с апр 287031 где открыт счет на арп 287031 где пополняется счет клиента.-----------*/
def var vv-sum as decim init 0.
for each  b-filpayment where  b-filpayment.stscom = 'new2' and b-filpayment.whn = g-today and b-filpayment.bankto = ourbank no-lock.
    if b-filpayment.amountcom > 0 and b-filpayment.jhcom < 1 and trim(b-filpayment.rem[2]) = '2' then do:
        find first remtrz where remtrz.ref = b-filpayment.rem[4] no-lock no-error.
        if available remtrz then find first que where que.remtrz = remtrz.remtrz no-lock no-error.
        else next.
        if available que then if not (que.pid  = "F" and que.con = "W") then  next. /* если у платежа очередь не F, значит перевод еще не поступил, проводку комиссии не проводим, ждем.*/

        v-tmpl = "uni0105".

        if b-filpayment.info[9] = 'B' then  do: /* тип клиента если 'B' юр лицо иначе физ лицо */
            find sysc where sysc.sysc = "transu" no-lock no-error.
            if not avail sysc or sysc.chval = "" then do:
               display " В настройках нет записи transu  !!". next.
            end.
        end.
        else  do:
            find sysc where sysc.sysc = "transf" no-lock no-error.
            if not avail sysc or sysc.chval = "" then do:
               display " В настройках нет записи transf  !!". next.
            end.
        end.

        v-param1 = string(b-filpayment.amountcom) + vdel + entry(2,b-filpayment.info[8]) + vdel + entry(1,b-filpayment.info[8]) +
        vdel + "Комиссия за " + b-filpayment.info[7] + vdel + substring(b-filpayment.kbe,1,1) +
        vdel + substring(b-filpayment.kbe,2,1) + vdel + b-filpayment.knp  + vdel + trim(entry(1,trim(sysc.chval))).
        s-jh = 0.
        run trxgen (v-tmpl, vdel, v-param1, "cif", "", output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
                message rdes. undo, next.
        end.
        run jou.
        v_doc = return-value.
        find first jh where jh.jh = s-jh exclusive-lock.
        jh.party = v_doc.

        if jh.sts < 6 then jh.sts = 6.
        for each jl where jl.jh = jh.jh exclusive-lock.
            if jl.dc = "D" and jl.ln > 2 then vv-sum = jl.dam.
            if jl.sts < 6 then jl.sts = 6.
        end.
        find current jh no-lock.

        find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
        if avail joudoc then do:
           joudoc.info = b-filpayment.name.
           joudoc.perkod = b-filpayment.rnnto.
           joudoc.kfmcif = b-filpayment.cif.
           joudoc.cracctype = "1".
        end.
        find current joudoc no-lock.

             run rmzcre (
             1  /*filpayment.jh*/    ,
             vv-sum ,
             trim(entry(1,trim(sysc.chval))),
             b-filpayment.rnnto     ,
             b-filpayment.name     ,
             b-filpayment.bankfrom   ,
             b-filpayment.info[10]    ,
             b-filpayment.namefrom   ,
             b-filpayment.rnnfrom  ,
             ''      ,
             no ,
             b-filpayment.knp     ,
             b-filpayment.kod     ,
             b-filpayment.kbe     ,
             'Комиссия за ' + b-filpayment.info[7]   ,
             '1P'     ,
             1     ,
             5     ,
             g-today ).

         v-rmz = return-value.

         find first remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
         if avail remtrz then do:
             remtrz.source = 'P'.
             remtrz.ordins[1] = "ЦО ".
             remtrz.ordins[2] = " ".
             remtrz.valdt1 = g-today.
             remtrz.valdt2 = g-today.
             remtrz.rsub = "arp".
             v_doc = b-filpayment.id.
             find first filpayment where filpayment.id = v_doc exclusive-lock no-error.
             if available filpayment then do:

                 filpayment.rem[3] = v-rmz.
                 filpayment.stscom = "sen2".
                 filpayment.rem[5] = remtrz.ref.
             end.
             else do:
                find current filpayment no-lock.
                undo, next.
             end.
             find current filpayment no-lock.
             release filpayment.
             find first filpayment where filpayment.id = v_doc no-lock no-error.

             /*message "Платеж " v-rmz " на списание комиссии со счета " filpayment.info[8] " отправлен. Транзитный счет будет пополнен через 5 минут!" view-as alert-box.*/
             run mail   (filpayment.info[3],
                      "METROCOMBANK <mkb@metrocombank.kz>",
                      "Межфилиальный Перевод ",
                      "Добрый день!\n\n ФИО: " + filpayment.name + "\n ИИК: " + entry(1,filpayment.info[8]) + "\n списание комиссии со счета \n " +
                       string(remtrz.amt) + " KZT " + "\n " + string(filpayment.whn) + "\n " + filpayment.who,
                       "1", "","" ).
        end.
        else message "Ошибка при отправке платежа на списание комиссии со счета " + entry(1,filpayment.info[8])  + " ! filpayment.id = "  + filpayment.id.
    end. /*  if filpayment.amountcom > 0 ...     */
end.

/*-----------генерация проводки на счет дохода согласно кодификатору на сумму комиссии с арп счета 287031-----------------------------------------*/
for each  b-filpayment where  b-filpayment.stscom = 'sen2' and b-filpayment.whn = g-today and b-filpayment.bankfrom = ourbank no-lock.
    if b-filpayment.amountcom > 0 and b-filpayment.jhcom < 1 and trim(b-filpayment.rem[5]) <> "" and trim(b-filpayment.rem[2]) = '2' then do:

        find first remtrz where remtrz.ref = b-filpayment.rem[5] no-lock no-error.
        if available remtrz then find first que where que.remtrz = remtrz.remtrz no-lock no-error.
        else next.
        if available que and que.pid  = "F" and que.con = "W" then  do: /* если у платежа очередь не F, значит перевод на комиссию еще не поступил, проводку комиссии не проводим, ждем.*/
            /* создать проводку на счет дохода от комиссии согласно коду комиссии */
            find first tarif2 where tarif2.str5 = b-filpayment.info[2] and tarif2.stat = 'r' no-lock no-error.
            if avail tarif2 then do:
                    v-tmpl = "jou0021".

                    if b-filpayment.info[9] = 'B' then  do: /* тип клиента если 'B' юр лицо иначе физ лицо */
                        find sysc where sysc.sysc = "transu" no-lock no-error.
                        if not avail sysc or sysc.chval = "" then do:
                           display " В настройках нет записи transu  !!". next.
                        end.
                    end.
                    else  do:
                        find sysc where sysc.sysc = "transf" no-lock no-error.
                        if not avail sysc or sysc.chval = "" then do:
                           display " В настройках нет записи transf  !!". next.
                        end.
                    end.

                    v-param1 = "" + vdel + string(remtrz.amt) + vdel + string(remtrz.fcrc) + vdel + trim(entry(1,trim(sysc.chval))) + vdel + string(tarif2.kont) + vdel + "Комиссия " + tarif2.pakalp.

                    s-jh = 0.
                    run trxgen (v-tmpl, vdel, v-param1, "", "" , output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                            message rdes. undo, next.
                    end.
                    run jou.
                    v_doc = return-value.
                    find first jh where jh.jh = s-jh exclusive-lock.
                    jh.party = v_doc.

                    if jh.sts < 6 then jh.sts = 6.
                    for each jl of jh:
                            if jl.sts < 6 then jl.sts = 6.
                    end.
                    find current jh no-lock.
                    find first joudoc where joudoc.docnum = v_doc no-error.
                    if avail joudoc then do:
                           joudoc.info = b-filpayment.name. joudoc.perkod = b-filpayment.rnnto. joudoc.kfmcif = b-filpayment.cif.
                    end.

                    find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
                    if not avail acheck then do:
                        v-chk = "".
                        v-chk = string(NEXT-VALUE(krnum)).
                        create acheck.
                        assign acheck.jh  = string(s-jh)
                               acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk
                               acheck.dt = g-today
                               acheck.n1 = v-chk.
                        release acheck.
                    end.

                    /*run vou_bank2(2,1, joudoc.info).*/
                    v_doc = b-filpayment.id.
                    find first filpayment where filpayment.id = v_doc exclusive-lock no-error.
                    if available filpayment then do:
                        filpayment.jhcom = s-jh.
                        filpayment.stscom = 'trx'.
                    end.
                    else do:
                        find current filpayment no-lock.
                        undo, next.
                    end.
                    find current filpayment no-lock.
                    release filpayment.

            end.  /*  avail tarif2   */
        end.  /* if available que  */
    end. /*  if filpayment.amountcom > 0 ...     */
end.

/*--------------------------------------------------------------------*/

/*
define buffer b-sysclg for sysc.
define buffer b-syscpw for sysc.
define buffer b-sysonl for sysc.
define buffer b-elxnet for sysc.

find b-sysclg where b-sysclg.sysc = "KZTLG" no-lock no-error.
find b-syscpw where b-syscpw.sysc = "KZTPW" no-lock no-error.
find b-sysonl where b-sysonl.sysc = "ONL" no-lock no-error.
find b-elxnet where b-elxnet.sysc = "ELXNET" no-lock no-error.


if (not avail b-sysonl) or b-sysonl.chval = ""  then return.
if (not avail b-elxnet) or b-elxnet.chval = ""  then return.
if (not avail b-sysclg) or (not avail b-syscpw) then return.


 for each commonpl where commonpl.grp = 17  exclusive-lock:
     if commonpl.billdoc = "doc1" then next.
     v-sts = "".
     accnt = "".
     v-id  = "".
     v-bal = "0".

     run ConnectWebServices("2","TXB_KIOSK","TXB_ATM", string(commonpl.counter), "0","0","0","0", b-sysclg.chval, b-syscpw.chval,"0","v-mon","v-day").
     if v-sts = "OK" then do:
        v-ind = 0.
        v-bal1 = "0".

        run ConnectWebServices("3","TXB_KIOSK","TXB_ATM",string(commonpl.counter), "1", string(commonpl.dnum),string(commonpl.sum),v-id, b-sysclg.chval,b-syscpw.chval,string(commonpl.dnum),string(month(commonpl.date)),string(day(commonpl.date))).
        if v-s = "OK" then do:
           run savelog ("KTERROR", "ELEKSNET" + "_" + "Payment OK " + string(commonpl.counter)).
           commonpl.billdoc = "doc1".
           commonpl.accnt  = integer(v-id).
        end.
        else do:
             run savelog ("KTERROR", "ELEKSNET" + "_" + v-s).
        end.
     end.
     else do:
             run savelog ("KTERROR", "ELEKSNET" + "_" + v-sts).
     end.
 end.
*/




/*
Procedure ConnectWebServices.
   def input parameter e1  as char.
   def input parameter e2  as char.
   def input parameter e3  as char.
   def input parameter e4  as char.
   def input parameter e5  as char.
   def input parameter e6  as char.
   def input parameter e7  as char.
   def input parameter e8  as char.
   def input parameter e9  as char.
   def input parameter e10 as char.
   def input parameter e11 as char.
   def input parameter e12 as char.
   def input parameter e13 as char.


  input through value ("rsh NTORACLE java -classpath
'C://Java//jdk1.5.0_02//bin;C://Kaztelecom//lib//axis.jar;C://Kaztelecom//lib//.jar;C:
//Kaztelecom//lib//.jar;C://Kaztelecom//lib//log4j-1.2.8.jar;C://Kaztelecom/
/lib//realsoft.jar;C://Kaztelecom//lib//axis-schema.jar;C://Kaztelecom//lib//axi
s-ant.jar;C://Kaztelecom//lib//jaxrpc.jar;C://Kaztelecom//lib//commons-logging-1
.0.4.jar;C://Kaztelecom//lib//commons-discovery-0.2.jar;C://Kaztelecom//lib//saa
j.jar;C://Kaztelecom//lib//activation.jar;C://Kaztelecom//lib//wsdl4j-1.5.1.jar;
C://Kaztelecom//lib//activation.jar;C://Kaztelecom//lib//mail.jar;C://Kaztelecom
//lib;C://Kaztelecom//lib//commons-codec-1.3.jar;C://Kaztelecom//lib//saxon.jar;
C://Kaztelecom//lib' TelecomClient "
      + " " + e1
      + " " + e2
      + " " + e3
      + " " + e4
      + " " + e5
      + " " + e6
      + " " + e7
      + " " + e8
      + " " + e9
      + " " + e10
      + " " + e11
      + " " + e12
      + " " + e13).
  repeat:
      v-ind = v-ind + 1.
      import unformatted v-s.


      if v-ind = 1 then v-sts  = v-s.
if e1 = "2" then do:
      if v-ind = 2 then v-id   = v-s.
      if v-ind = 3 then v-bal  = v-s.
end.
if e1 = "1" then do:
      if v-ind = 1 then v-sts  = v-s.
      if v-ind = 2 then v-bal1  = v-s.
end.
    end.
end.
*/

