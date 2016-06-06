/* filgettda.p
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
        BANK COMM
 * AUTHOR
        19.07.2010 denis
 * CHANGES
        11.12.2010 marinav  - шаблон jou0041 с КНП и Кбе
        15/02/2011 madiyar  - в jou-документы прописываем код клиента
        10.06.2011 aigul    - проверка срока действия УЛ
        28.12.2011 id00004  - добавил код тарифов 056, 197 и заменил 029 на 028 согласно распоряжения Исайкина А.
        25/01/2012 evseev   - ТЗ-1245
        01.02.2012 lyubov   - изменила символ кассплана (410 на 220 и 150 на 090)
        18.04.2012 damir    - печать операционных и кассовых ордеров на лазерный принтер.
        23.07.2012 damir    - поправил сохранение данных по удост.личности.
        31.08.2012 evseev - иин/бин
*/

{mainhead.i}
{keyord.i} /*Переход на новые и старые форматы форм*/
{chbin.i}

def var v-bank as char.
def var v-cifname as char.
def var s_account_a as char no-undo.
def var s_account_b1 as char no-undo.
def var c-gl like gl.gl no-undo.
def var c-gl1002 like gl.gl no-undo.
def var v-sel as char init '0'.

find last sysc where sysc.sysc = "cashgl" no-lock no-error.
if avail sysc then c-gl = sysc.inval.
              else c-gl = 100100.
find last sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then c-gl1002 = sysc.inval.
              else c-gl1002 = 100200.

def var v-yn 	as log init false 	no-undo. /*получаем признак работы касса/касса в пути*/
def var v-err	as log init false 	no-undo. /*получаем признак возникновения ошибки*/

def var v-tmpl as char no-undo.

/*def var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(sysc.chval).*/

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

def new shared var v-pssdt as char.
def new shared var v-sum as deci no-undo.
def new shared var v-kod as char no-undo init "19".
def new shared var v-kbe as char no-undo init "19".
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
def new shared var v-gofc as char.
def new shared var v_doc as char.
def var v-rmz  like remtrz.remtrz no-undo.

def new shared var s-jh like jh.jh.
def var v-glrem as char no-undo.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.


/* galina - мои переменные*/ {kfm.i "new"}


v-gtoday = g-today.
v-gofc = g-ofc.
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


run sel2 ("Выбор :", " 1. Новая заявка на снятие средств | 2. Выплата с транзитного счета", output v-sel).
if v-sel = '0' then return.

if v-sel = '1' then do:

      v-comkod = '302,028,119,056,197'.
      v-tit = 'Снятие со сберегательного счета на филиале '.
      v-type = 'TDA,CDA'.

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
          run filgettda1.
       if connected ("txb") then disconnect "txb".

     /*********************************************************************/

       if v-ja then do:

              do transaction:
              find sysc where sysc.sysc = "transf" no-lock no-error.
              if not avail sysc or sysc.chval = "" then do:
                   display " В настройках нет записи transf  !!".   pause.   return.
              end.

               create filpayment.
                 filpayment.id = 'fil' + string(next-value(filp)).
                 filpayment.type = 'gettda'.
                 filpayment.bankfrom = s-ourbank.
                 filpayment.bankto = v-bank.
                 filpayment.iik = v-iik.
                 filpayment.cif = v-cif-f.
                 filpayment.sts = 'A'.
                 filpayment.name = v-fio.
                 filpayment.rnnto = v-rnn.
                 filpayment.rnnfrom = v-rnn1.
                 filpayment.namefrom = v-fio1.
                 filpayment.crc = v-crc.
                 filpayment.amount = v-sum.
                 filpayment.amountcom = v-sum_com.
                 filpayment.arp = entry(v-crc,trim(sysc.chval)).
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
             end.

               find first txb where txb.bank = v-bank no-lock no-error.
               if not avail txb then return.

               if connected ("txb") then disconnect "txb".
               connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

               run rmzcretxb (
                1    ,
                filpayment.amount + filpayment.amountcom,
                filpayment.iik ,
                filpayment.rnnto    ,
                filpayment.name     ,
                filpayment.bankfrom   ,
                filpayment.arp    ,
                filpayment.namefrom   ,
                filpayment.rnnfrom   ,
                ''      ,
                no ,
                filpayment.knp  ,
                filpayment.kod  ,
                filpayment.kbe  ,
                filpayment.info[1] ,
                '2T'     ,
                1     ,
                5     ,
                g-today,
                'arp'    ).

               v-rmz = return-value.
               if connected ("txb") then disconnect "txb".


          do transaction:
          if v-rmz ne "" then  do:
                                  message "Платеж " v-rmz " на снятие средств со счета " filpayment.iik " сделан. Транзитный счет будет пополнен через 5 минут." view-as alert-box title "".
                                  find crc where crc.crc = filpayment.crc no-lock no-error.
                                  run mail   (filpayment.info[3],
                                              "METROCOMBANK <mkb@metrocombank.kz>",
                                              "Межфилиальный Перевод ",
                                              "Добрый день!\n\n ФИО: " + filpayment.name + "\n ИИК: " + filpayment.iik + "\n Снятие средств со сберегательного счета \n " +
                                               string(filpayment.amount + filpayment.amountcom) + "  " + crc.code + "\n " + string(g-today) + "\n " + g-ofc,
                                               "1", "","" ).
                                  filpayment.rem[1] = v-rmz.
                                  end.

                                  else message "Ошибка при формировании платежа на снятие со счета " filpayment.iik " !" view-as alert-box title "".
          end.

       end.
end.

if v-sel = '2' then do:

       find first filpayment where filpayment.bankfrom = s-ourbank and filpayment.type = 'gettda' and filpayment.jou = '' no-lock no-error.
       if not avail filpayment then do:
           message "Сумм для выплаты нет !" view-as alert-box.
           return.
        end.


       def new shared var v-id as char.

        {itemlist.i
           &file = "filpayment"
           &where = "filpayment.bankfrom = s-ourbank and filpayment.type = 'gettda' and filpayment.jou = '' "
           &form = "filpayment.id filpayment.bankto label 'Банк' filpayment.name format 'x(30)' filpayment.amount filpayment.whn label 'Дата' filpayment.rem[1] label 'Платеж'"
           &frame = "row 7 centered scroll 1 12 down overlay "
           &flddisp = "filpayment.id filpayment.bankto filpayment.name filpayment.amount filpayment.whn filpayment.rem[1] "
           &chkey = "id"
           &chtype = "string"
           &index  = "bankf"
           &funadd = "if frame-value = '' then do:
              message 'Платеж не выбран'.
              pause 1.
            next.
        end." }
        v-id = frame-value.

        find first filpayment where filpayment.id = v-id no-lock no-error.
        if not avail filpayment then do:
           message "Платеж не найден !" view-as alert-box.
           return.
        end.

        find first arp where arp.arp = filpayment.arp no-lock no-error.
        if not avail arp then do:
           message "Счет не найден !" view-as alert-box.
           return.
        end.

        find first jl where jl.acc = filpayment.arp and jl.dc = 'C' and jl.jdt >= filpayment.whn
                       and  jl.cam = filpayment.amount + filpayment.amountcom and (jl.rem[1] + jl.rem[2]) matches "*" + trim(filpayment.name) + "*"  use-index accdcjdt no-lock no-error.
        if not avail jl then do:
           message " Сумма клиента на транзитный счет еще не поступила !" view-as alert-box.
           return.
        end.

        if arp.cam[1] - arp.dam[1] < filpayment.amount + filpayment.amountcom then do:
           message "Нехватка средств на транзитном счете !" view-as alert-box.
           return.
        end.


        find first txb where txb.bank = filpayment.bankto no-lock no-error.
        if not avail txb then return.
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run filadd_kfm(filpayment.iik).
        if connected ("txb") then disconnect "txb".

        def var v-label as char format "x(16)".
        if v-bin  then v-label = "ИИН/БИН получ. :". else v-label =   "РНН получателя :".

        v-ja = no.
        form  skip(1)
            filpayment.iik       label "ИИК            " format "x(20)" skip
            filpayment.crc       label "Валюта         "   v-crc_val no-label skip
            filpayment.namefrom  label "ФИО получателя " format "x(60)" skip
            v-label no-label filpayment.rnnfrom no-label colon 17 skip
            filpayment.amount    label "Сумма          " format ">>>,>>>,>>>,>>>,>>9.99" skip
            filpayment.amountcom label "Сумма комиссии " format ">>>,>>9.99"  skip(1)
          '----------------------------Назначение платежа---------------------------' at 5 skip
            filpayment.info[1]  no-label format "x(78)"  skip(1)

            v-ja label "Формировать кассовую транзакцию ?   " skip(1)
        with centered side-label row 7 width 80 overlay  title 'Выдача средств с транзитного счета' frame fr1.

        displ v-label filpayment.iik  filpayment.crc filpayment.namefrom filpayment.rnnfrom  filpayment.amount  filpayment.amountcom filpayment.info[1] with frame fr1.
        update v-ja  with frame fr1.


        /*****************************************************/
        if v-ja then do:

          do transaction:
          /*galina*/ {filpay_kfm.i}

          v-glrem = v-npl + " " + v-npl1.


            find first filpayment where filpayment.id = v-id exclusive-lock no-error.

            find sysc where sysc.sysc = "transf" no-lock no-error.
            if not avail sysc or sysc.chval = "" then do:
                   display " В настройках нет записи transf  !!".   pause.   return.
            end.

            run get100200arp(input g-ofc, input v-crc, output v-yn, output s_account_b1, output v-err).
            if v-err then
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

            v-glrem = filpayment.info[1].

            if s_account_a = string(c-gl) and s_account_b1 = '' then do:
               v-tmpl = "jou0041".
               v-param = string(filpayment.amount) + vdel + string(filpayment.crc) + vdel + entry(filpayment.crc,trim(sysc.chval)) + vdel + v-glrem + vdel +
                         substr(filpayment.kod,1,1) + vdel + substr(filpayment.kbe,1,1) + vdel + substr(filpayment.kod,2,1) + vdel + substr(filpayment.kbe,2,1) + vdel + filpayment.knp .
            end.
            else do:
               v-tmpl = "jou0036".
               v-param = "" + vdel + string(filpayment.amount) + vdel + string(filpayment.crc) + vdel + entry(filpayment.crc,trim(sysc.chval)) + vdel + s_account_b1 + vdel + v-glrem + vdel +
                                     substr(filpayment.kbe,1,1) + vdel + substr(filpayment.kbe,1,1) + vdel + filpayment.knp .
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
            run setcsymb (s-jh, 220).
            find first joudoc where joudoc.docnum = v_doc no-error.
            if avail joudoc then do:
                   joudoc.info = filpayment.namefrom. joudoc.perkod = filpayment.rnnfrom. /*joudoc.passp = filpayment.info[4].*/
                   joudoc.kfmcif = filpayment.cif.

                   if num-entries(trim(filpayment.info[4]),",") > 1 or num-entries(trim(filpayment.info[4])," ") <= 1 then
                   joudoc.passp = trim(filpayment.info[4]).
                   else joudoc.passp = entry(1,trim(filpayment.info[4])," ") + "," +
                   substring(trim(filpayment.info[4]),index(trim(filpayment.info[4])," "), length(filpayment.info[4])).
            end.
            filpayment.jou = v_doc.
            filpayment.jh = s-jh.
            run chgsts ('jou', v_doc, 'baf').

           /*galina - запись в таблицы*/
            if v-kfm then run kfmcopy(v-operid,filpayment.id,'fm', s-jh).
/****marinav*****/
            find first cursts where cursts.sub = 'jou' and  cursts.acc = v_doc  use-index subacc exclusive-lock no-error .
            if not avail cursts then do:
               create cursts .
               cursts.sub = 'jou' .
               cursts.acc = v_doc .
            end.
            cursts.sts = 'baf' .
            cursts.rdt = g-today .
            cursts.rtim = time .
            cursts.who = g-ofc .
/****marinav*****/

            find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
            if not avail acheck then do:
                define var v-ch as char no-undo.
                v-ch = "".
                v-ch = string(NEXT-VALUE(krnum)).
                create acheck.
                assign acheck.jh  = string(s-jh)
                       acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-ch
                       acheck.dt = g-today
                       acheck.n1 = v-ch.
                release acheck.
            end.

            if v-noord = no then run vou_bank2(2,2, joudoc.info).
            else do:
                run printvouord(2).
                run printord(s-jh,"").
            end.


            if filpayment.amountcom > 0 then do:

                find first tarif2 where tarif2.str5 = trim(filpayment.info[2]) and tarif2.stat = 'r' no-lock no-error.
                if avail tarif2 then do:

                    v-tmpl = "jou0021".
                    v-param = "" + vdel + string(filpayment.amountcom) + vdel + string(filpayment.crc) + vdel + entry(filpayment.crc,trim(sysc.chval)) + vdel + string(tarif2.kont) + vdel + "Комиссия " + tarif2.pakalp .
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
                    run setcsymb (s-jh, 090).
                    find first joudoc where joudoc.docnum = v_doc no-error.
                    if avail joudoc then do:
                           joudoc.info = filpayment.namefrom. joudoc.perkod = filpayment.rnnfrom. joudoc.kfmcif = filpayment.cif.
                    end.
                    if v-noord = no then run vou_bank(2).
                    else do:
                        run printvouord(2).
                        run printord(s-jh,"").
                    end.

                    filpayment.jhcom = s-jh.

                end.
          end.
          end.
       end.
/************************************************************/
  end.


