/* filadd.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Пополнение счета в другом филиале
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        24.06.2010 marinav galina denis
 * CHANGES
        добавить паспорт
        10/02/2011 madiyar  - в jou-документ прописываем код клиента
        15/02/2011 madiyar  - в jou-документ комиссии также прописываем код клиента
        10.06.2011 aigul    - проверка срока действия УЛ
        28.06.2011 Luiza    - (ТЗ 901) добавила вид оплаты комиссии v-oplcom  (с кассы или со счета).
        если с кассы - прежний алгоритм, если со счета - автоматически создается несколько проводок.
        25/01/2012 evseev   - ТЗ-1245
        01.02.2012 lyubov   - изменила символ кассплана (200 на 100)
        07.03.2012 damir    - добавил входной параметр в printord.p, пока осталась печать на матричный, если вдруг нужно в word, просто
        убрать комментарии.
        18.04.2012 damir    - убрал комментарии по печати кассовых ордеров printord.p.
        21/05/2012 Luiza    - подключение comm
        23.07.2012 damir    - поправил сохранение данных по удост.личности.
*/

{mainhead.i}
{keyord.i} /*Переход на новые и старые форматы форм*/

def var v-bank as char.
def var v-cifname as char.
def var s_account_a as char no-undo.
def var s_account_b1 as char no-undo.
def var c-gl like gl.gl no-undo.
def var c-gl1002 like gl.gl no-undo.

find last sysc where sysc.sysc = "cashgl" no-lock no-error.
if avail sysc then c-gl = sysc.inval.
              else c-gl = 100100.
find last sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then c-gl1002 = sysc.inval.
              else c-gl1002 = 100200.

def var v-yn 	as log init false 	no-undo. /*получаем признак работы касса/касса в пути*/
def var v-err	as log init false 	no-undo. /*получаем признак возникновения ошибки*/

def var v-tmpl as char no-undo.

def new shared var v-cif-f as char.
def new shared var v-bankname as char.
def new shared var v-iik like bank.aaa.aaa.
def new shared var v-crc like bank.crc.crc.
def new shared var v-crc_val as char no-undo format "xxx".

def new shared var v-fio as char no-undo format "x(60)".
def new shared var v-rnn like bank.cif.jss.
def new shared var v-pss as char no-undo format "x(30)".


def new shared var v-fio1 as char no-undo format "x(60)".
def new shared var v-rnn1 like bank.cif.jss.
def new shared var v-pss1 as char no-undo format "x(30)".


/*def new shared var v-pssdt as char.*/
def new shared var v-sum as deci no-undo.
def new shared var v-kod as char no-undo. /* init "19".*/
def new shared var v-kbe as char no-undo. /* init "19".*/
def new shared var v-knp as char no-undo.
def new shared var v-codename as char no-undo .
def new shared var v-com as char no-undo.
def new shared var v-sum_com as deci no-undo.
def new shared var v-npl as char.
def new shared var v-npl1 as char.
def new shared var v-ja as logi no-undo format "Да/Нет" init no.
def new shared var v-tit as char.
def new shared var v-comkod as char.
def new shared var v-type as char.
def new shared var v-mail as char.
def new shared var v-gtoday as date no-undo.
def new shared var v-fu as char.

def new shared var v_doc as char.
def var v-rmz  like remtrz.remtrz no-undo.

def new shared var s-jh like jh.jh.
def var v-glrem as char no-undo.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.
define var v-chk as char no-undo.


/* Luiza*/
def new shared var v-oplcom as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/
def var v_arp as char format "x(20)".
def new shared var  s-remtrz like remtrz.remtrz.
def new shared var v-iik1 like bank.aaa.aaa.
def new shared var vv-crc as int.
/*-------------------------------------------------------------------------------*/

/* galina - мои переменные*/ {kfm.i "new"}

def frame f-client skip(1)
  v-bank label "ФИЛИАЛ "  format "x(6)" help " Введите код банка (F2 - поиск)"
  v-bankname no-label format "x(45)"  skip
  v-cif-f label "КЛИЕНТ " format "x(6)" help " Введите код клиента (F2 - поиск)"   validate (v-cif-f ne "", " Введите код клиента ! ")
  v-cifname no-label format "x(45)"
  with  centered side-label row 7 title 'Выберите филиал и клиента'.

on help of v-bank in frame f-client do:
{itemlist.i
       &file = "txb"
       &where = "txb.bank begins 'txb'"
       &form = "txb.bank txb.info form ""x(30)""  "
       &frame = "row 5 centered scroll 1 18 down overlay "
       &flddisp = "txb.bank txb.info"
       &chkey = "bank"
       &chtype = "string"
       &index  = "bank"
       &funadd = "if frame-value = '' then do:
		    message 'Банк не выбран'.
		    pause 1.
		    next.
		  end." }
  v-bank = frame-value.
  displ v-bank with frame f-client.
end.

 v-gtoday  = g-today.
 v-comkod = '302'.
 v-tit = 'Пополнение счета на филиале '.
 v-type = ''.

  update v-bank with frame f-client.
  if v-bank = s-ourbank then do:
     message "Клиент вашего филиала! " view-as alert-box.
     return.
  end.

  find first txb where txb.bank = v-bank no-lock no-error.
  if not avail txb then return.
  v-bankname = txb.info.
  displ v-bankname with frame f-client.

  if connected ("txb") then disconnect "txb".
  connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
     update v-cif-f  with frame f-client.
     run check_ul_txb(v-cif-f).
     run filadd1.
     run filadd_kfm(v-iik).
    /* run selaaa(v-cif-f, output v-iik1, output vv-crc).*/
  if connected ("txb") then disconnect "txb".
    /*if v-iik1 = "" or vv-crc = 0 then do:
        message "Ошибка, не выбран счет для снятия комиссии"  view-as alert-box error.
        return.
    end.*/


/*********************************************************************/

  if v-ja then do transaction:

        /*Luiza подключение comm */
        find sysc where sysc.sysc = 'CMHOST' no-lock no-error.
        if avail sysc then connect value (sysc.chval) no-error.

        if v-fu = 'B' then  do:
            find sysc where sysc.sysc = "transu" no-lock no-error.
            if not avail sysc or sysc.chval = "" then do:
               display " В настройках нет записи transu  !!".   pause.   return.
            end.
        end.
        else  do:
            find sysc where sysc.sysc = "transf" no-lock no-error.
            if not avail sysc or sysc.chval = "" then do:
               display " В настройках нет записи transf  !!".   pause.   return.
            end.
        end.

        run get100200arp(input g-ofc, input v-crc, output v-yn, output s_account_b1, output v-err).
        if v-err then /*если ошибка имела место, то еще раз скажем об этом пользователю*/
        do:
            v-err = not v-err.
        message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip "произошла ошибка!" view-as alert-box error.
            return.
        end.

        if v-yn then s_account_a = "".
        else do:
        s_account_a = string(c-gl).
        s_account_b1 = "".
        end.
        create filpayment.
        filpayment.id = 'fil' + string(next-value(filp)).
        filpayment.type = 'add'.
        filpayment.bankfrom = s-ourbank.
        filpayment.bankto = v-bank.
        filpayment.iik = v-iik.
        filpayment.cif = v-cif-f.
        filpayment.sts = 'A'.
        filpayment.name = v-fio.
        filpayment.rnnto = v-rnn.
        filpayment.crc = v-crc.
        filpayment.amount = v-sum.
        filpayment.arp = trim(entry(v-crc,trim(sysc.chval))). /* транзитный арп счет для соответствующей валюты  */
        filpayment.info[10] = trim(entry(1,trim(sysc.chval))). /* транзитный арп счет для тенге */
        filpayment.info[9] = v-fu. /* тип клиента, если 'B' юр. лицо, иначе физ лицо */
        filpayment.kod = v-kod.
        filpayment.kbe = v-kbe.
        filpayment.knp = v-knp.
        filpayment.info[1] = v-npl + " " + v-npl1.
        filpayment.info[2] = v-com.
        filpayment.info[3] = v-mail.
        filpayment.info[4] = v-pss1.
        filpayment.rdt = today.
        filpayment.whn = g-today.
        filpayment.who = g-ofc.
        filpayment.tim = time.

        /********galina - КФМ************/ {filpay_kfm.i}

        v-glrem = v-npl + " " + v-npl1.

        if v-oplcom = "1" then do: /*вид оплаты с кассы*/
            filpayment.rem[2] = "1".  /* сохраняем признак оплаты 1- с кассы  */
            if s_account_a = string(c-gl) and s_account_b1 = '' then do:
               v-tmpl = "jou0007".
               v-param = "" + vdel + string(v-sum) + vdel + string(v-crc) + vdel + filpayment.arp + vdel + v-glrem + vdel +
                                     substr(v-kod,1,1) + vdel + substr(v-kbe,1,1) + vdel + substr(v-kod,2,1) + vdel + v-knp .
            end.
            else do:
               v-tmpl = "jou0036".
               v-param = "" + vdel + string(v-sum) + vdel + string(v-crc) + vdel + s_account_b1 + vdel + filpayment.arp + vdel + v-glrem + vdel +
                                     substr(v-kod,1,1) + vdel + substr(v-kbe,1,1) + vdel + v-knp .
            end.

            s-jh = 0.
            run trxgen (v-tmpl, vdel, v-param, "arp", "" , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                    message rdes.  pause 1000.  next.
            end.
            run jou.
            v_doc = return-value.
            find first jh where jh.jh = s-jh exclusive-lock.
            jh.party = v_doc.

            if jh.sts < 5 then jh.sts = 5.
            for each jl of jh:
                    if jl.sts < 5 then jl.sts = 5.
            end.
            find current jh no-lock.
            /*run setcsymb (s-jh, 110).*/

            find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
            if avail joudoc then do:
                   joudoc.info = v-fio1. joudoc.perkod = v-rnn1. /*joudoc.passp = v-pss1.*/ joudoc.kfmcif = filpayment.cif.

                   if num-entries(trim(v-pss1),",") > 1 or num-entries(trim(v-pss1)," ") <= 1 then
                   joudoc.passp = trim(v-pss1).
                   else joudoc.passp = entry(1,trim(v-pss1)," ") + "," +
                   substring(trim(v-pss1),index(trim(v-pss1)," "), length(v-pss1)).
            end.
            find current joudoc no-lock.
            filpayment.rnnfrom = joudoc.perkod.
            filpayment.namefrom = joudoc.info.
            filpayment.jou = v_doc.
            filpayment.jh = s-jh.

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

            /*galina - запись в таблицы*/
            if v-kfm then run kfmcopy(v-operid,filpayment.id,'fm', s-jh).
            if v-noord = no then run vou_bank2(2,1, joudoc.info).
            else run printord(s-jh,"").
            pause 0.
            hide all no-pause.
            run x0-cont1.
            hide all no-pause.

            /*Комиссия*/
            if v-sum_com > 0 then do:
                display "" skip(2) "  Создается проводка для комиссии     " skip(1) "" with frame f1 centered overlay row 10 title 'ВНИМАНИЕ'.
                find first tarif2 where tarif2.str5 = v-com and tarif2.stat = 'r' no-lock no-error.
                if avail tarif2 then do:

                    if s_account_a = string(c-gl) and s_account_b1 = '' then do:
                       v-tmpl = "jou0025".
                       v-param = "" + vdel + string(v-sum_com) + vdel + "1" + vdel + string(tarif2.kont) + vdel + "Комиссия " + tarif2.pakalp + vdel +
                                             substr(v-kod,1,1) + vdel + substr(v-kod,2,1) .
                    end.
                    else do:
                       v-tmpl = "jou0021".
                       v-param = "" + vdel + string(v-sum_com) + vdel + "1" + vdel + s_account_b1 + vdel + string(tarif2.kont) + vdel + "Комиссия " + tarif2.pakalp .
                    end.

                    s-jh = 0.
                    run trxgen (v-tmpl, vdel, v-param, "", "" , output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                            message rdes.  pause 1000.  next.
                    end.
                    run jou.
                    v_doc = return-value.
                    find first jh where jh.jh = s-jh exclusive-lock.
                    jh.party = v_doc.

                    if jh.sts < 5 then jh.sts = 5.
                    for each jl of jh:
                            if jl.sts < 5 then jl.sts = 5.
                    end.
                    find current jh no-lock.
                    run setcsymb (s-jh, 100).
                    find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
                    if avail joudoc then do:
                           joudoc.info = v-fio1. joudoc.perkod = v-rnn1. joudoc.kfmcif = filpayment.cif.
                    end.
                    find current joudoc no-lock no-error.

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

                    if v-noord = no then run vou_bank2(2,1, joudoc.info).
                    else run printord(s-jh,"").

                    filpayment.amountcom = v-sum_com.
                    filpayment.jhcom = s-jh.
                    hide frame f1 no-pause.
                    pause 0.
                    hide all no-pause.
                    run x0-cont1.   /* для комиссии  */
               end.  /*  avail tarif2   */
           end.  /*  v-sum_com  */
        end. /* вид оплаты с кассы  */

        if v-oplcom = "2" then do: /*вид оплаты со счета*/
            if v-iik1 = "" or vv-crc = 0 then do:
                message "Ошибка, не выбран счет для снятия комиссии"  view-as alert-box error.
                return.
            end.

            filpayment.rem[2] = "2".  /* сохраняем признак оплаты 2 - со счета  */
            v-tmpl = "jou0007".
            v-param = "" + vdel + string(v-sum) + vdel + string(v-crc) + vdel + trim(filpayment.arp) + vdel + v-glrem + vdel +
                                 substr(v-kod,1,1) + vdel + substr(v-kbe,1,1) + vdel + substr(v-kod,2,1) + vdel + v-knp .
            s-jh = 0.
            run trxgen (v-tmpl, vdel, v-param, "arp", "" , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                    message rdes.  pause 1000.  next.
            end.
            run jou.
            v_doc = return-value.
            find first jh where jh.jh = s-jh exclusive-lock.
            jh.party = v_doc.

            if jh.sts < 5 then jh.sts = 5.
            for each jl of jh:
                    if jl.sts < 5 then jl.sts = 5.
            end.
            find current jh no-lock.
            /*run setcsymb (s-jh, 110).*/

            find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
            if avail joudoc then do:
                   joudoc.info = v-fio1. joudoc.perkod = v-rnn1. /*joudoc.passp = v-pss1.*/ joudoc.kfmcif = filpayment.cif.

                   if num-entries(trim(v-pss1),",") > 1 or num-entries(trim(v-pss1)," ") <= 1 then
                   joudoc.passp = trim(v-pss1).
                   else joudoc.passp = entry(1,trim(v-pss1)," ") + "," +
                   substring(trim(v-pss1),index(trim(v-pss1)," "), length(v-pss1)).
            end.
            find current joudoc no-lock no-error.
            filpayment.rnnfrom = joudoc.perkod.
            filpayment.namefrom = joudoc.info.
            filpayment.jou = v_doc.
            filpayment.jh = s-jh.
            filpayment.amountcom = v-sum_com.


            /*Комиссия*/
            if v-sum_com > 0 then do:
                find first tarif2 where tarif2.str5 = v-com and tarif2.stat = 'r' no-lock no-error.
                if not avail tarif2 then do:
                    message "Ошибка, не найден тариф комиссии в таблице tarif2"  view-as alert-box error.
                    return.
                end.
                filpayment.info[8] = v-iik1 + "," + string(vv-crc). /* запоминаем счет с которого снять комиссию и код валюты */
                filpayment.info[7] = tarif2.pakal. /* запоминаем описание тарифа */
                if not (vv-crc >= 1 and vv-crc <= 6) then do:
                    message "Ошибка кода валюты счета клиента"  view-as alert-box error.
                    return.
                end.

                if vv-crc = 1 then filpayment.stscom = "new1". /* внеш платеж для комиссии сформир-тся в x1-cash.p  */
                else filpayment.stscom = "new2".  /* внеш платеж для комиссии сформир-тся в ELX_ps.p. после пополнения счета клиента  */
            end.
            /*-------------------------------------------------------*/
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

            /*galina - запись в таблицы*/
            if v-kfm then run kfmcopy(v-operid,filpayment.id,'fm', s-jh).
            if v-noord = no then run vou_bank2(2,1, joudoc.info).
            else run printord(s-jh,"").

            pause 0.
            hide all no-pause.
            run x0-cont1.

            /*проводка комиссии с АРП счета на счет дохода согласно кодификатору создастся в ELX_ps.p
            после снятия комиссии со счета клиента и поступления суммы в текущий филиал */

       end. /* вид оплаты со счета  */
  end.  /* transaction  */