/* filadd1.p
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
        BANK COMM  TXB
 * AUTHOR
        24.06.2010 marinav galina denis
 * CHANGES
        17/02/2011 evseev - добавил Уведомление о задолженности {checkdebt.i} run checkdebt(g-today, v-iik, v-com)
                            в v-comkod добавил 401, 436.
        01/03/2011 evseev - Коды комиссий 401 и 436 применимы только для ЮЛ и ИП соответственно
        15/03/2011 evseev - добавил условия ((txb.cif.cgr = 403) or (txb.cif.cgr = 405)) ((txb.cif.cgr <> 403) or (txb.cif.cgr <> 405))
        16/03/2011 evseev - изменил условие от 15/03/2011 на (lookup(string(txb.cif.cgr), '403,405') > 0) и (lookup(string(txb.cif.cgr), '403,405') <= 0)
        13/06/2011 evseev - для lgr.feensf = 6
        28.06.2011 Luiza - (ТЗ 901) добавила поле вид оплаты комиссии v-oplcom (с кассы или со счета) и v-iik1.
        25/01/2012 evseev - ТЗ-1245
        23.02.2012 aigul -  Добавила букву И в Вид опл.комиссии
        12/07/2012 Luiza - если сумма комиссии нулевая Вид опл.комиссии не предлагаем
        31.08.2012 evseev - иин/бин
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        13.05.2013 evseev - tz-1828
        22/05/2013 Luiza  - ТЗ 1309 льготные тарифы при межфилиальных платежах
*/




def  shared var v-cif-f as char.
def  shared var v-bankname as char.
def  shared var v-iik like bank.aaa.aaa.
def  shared var v-crc like bank.crc.crc.
def  shared var v-crc_val as char no-undo format "xxx".
def  shared var v-fio as char no-undo format "x(60)".
def  shared var v-rnn like bank.cif.jss.
def  shared var v-pss as char no-undo format "x(30)".

def  shared var v-fio1 as char no-undo format "x(60)".
def  shared var v-rnn1 like bank.cif.jss.
def  shared var v-pss1 as char no-undo format "x(30)".


def  shared var v-sum as deci no-undo.
def  shared var v-kod as char no-undo. /* init "19".*/
def  shared var v-kbe as char no-undo. /* init "19".*/
def  shared var v-knp as char no-undo.
def  shared var v-codename as char no-undo .
def  shared var v-com as char no-undo.
def  shared var v-sum_com as deci no-undo.
def  shared var v-npl as char.
def  shared var v-npl1 as char.

def  shared var v-ja as logi no-undo format "Да/Нет" init no.
def  shared var v-tit as char.
def  shared var v-comkod as char.
def  shared var v-type as char.
def  shared var v-mail as char.
def  shared var v-gtoday as date no-undo.
def  shared var v-fu as char.
def  shared var v-oplcom as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/
def  var v-oplcom1 as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/
def  shared var v-iik1 like bank.aaa.aaa.
def  shared var vv-crc as int.
def var v-ok as logic init no.
def var v-whplat as logic.
def var v-chr as char.


def var i_mk as integer.
def var vavl as deci.
def buffer baaa for txb.aaa.

/* для комиссии*/
def var v-amt as decim.
def var tproc as decim.
def var pakal as char.

def temp-table t-ln no-undo
    field code as char
    field name as char format "x(70)"
    index main is primary code.

{checkdebt.i &file = "txb"}

{chk12_innbin.i}

for each t-ln. delete t-ln. end.

for each txb.codfr where txb.codfr.codfr = 'spnpl' no-lock .
    create t-ln.
    t-ln.code =  txb.codfr.code.
    t-ln.name = txb.codfr.name[1] + txb.codfr.name[2].
end.
/*БИН   */
def var v-bin as logi init no.
def var v-label as char format "x(18)".
def var v-label1 as char format "x(18)".
find first txb.sysc where txb.sysc.sysc = 'bin' no-lock no-error.
if avail txb.sysc then v-bin = txb.sysc.loval.
if v-bin  then v-label = "ИИН/БИН          :". else v-label =   "РНН/БИН клиента  :".
if v-bin  then v-label1 = "ИИН/БИН плател.  :". else v-label1 = "РНН плательщика  :".


form  skip(1)
    v-iik label "Счет клиента     " format "x(20)" skip
    v-crc label "Валюта           "   v-crc_val no-label skip
    v-fio label "Клиент           " format "x(50)" skip
    v-label no-label v-rnn no-label validate((chk12_innbin(v-rnn)),'Неправильно введён БИН/ИИН') colon 18 skip
    v-pss label "Уд. личн.        "  skip
    v-sum label "Сумма            " format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-fio1 label "ФИО плательщика  " format "x(50)" skip
    v-pss1 label "Документ         "  skip
    v-label1 no-label v-rnn1 no-label validate((chk12_innbin(v-rnn1)),'Неправильно введён БИН/ИИН') colon 18  skip
    v-kod label "Код              " format "x(2)" validate(v-kod ne "" , "Введите Код!") skip
    v-kbe label "Кбе              " format "x(2)" validate(v-kbe ne "" , "Введите Кбе!") skip
    v-knp label "КНП              " format "x(3)" validate( can-find (t-ln where t-ln.code = v-knp) , "Введите КНП! См. справочник (F2)") help "F2 - справочник" v-codename no-label format "x(40)" skip
    v-com label     "Комиссия         " format "x(3)" validate(lookup(v-com, v-comkod) > 0, "Допустимы кода " + v-comkod + " !") skip
    v-sum_com label "Сумма комиссии   " format ">>>,>>9.99"  skip
    v-oplcom1 label "Вид опл.комиссии  " format "x(15)" skip
    v-iik1    label "Счет комиссии    " format "x(20)" skip(1)
  '----------------------------Назначение платежа---------------------------' at 5 skip(1)
    v-npl  no-label format "x(78)"  skip
    v-npl1 no-label format "x(78)"  skip(2)

    v-ja label "Формировать транзакцию?   " skip(1)
with centered side-label row 7 width 80 overlay  title v-tit +  v-bankname frame fr1.




form
    v-chr no-label format "x(1)" skip(1)
   'u - Уполномоченный лица, t - третье лицо ' at 5 skip(1)
with centered side-label row 7 width 80 overlay  title "Задайте параметр" frame fr3.

form
    v-chr no-label format "x(1)" skip(1)
   'u - Уполномоченные лица, r - первый руководитель, b - главный бухгалтер' at 5 skip(1)
with centered side-label row 7 width 80 overlay  title "Задайте параметр" frame fr4.

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
    if txb.cif.type = "P" then OPEN QUERY  q-tar FOR EACH txb.tarif2 where tarif2.str5 = "450" or txb.tarif2.str5 = "459" or txb.tarif2.str5 = "125" or txb.tarif2.str5 = "302" no-lock.
    else OPEN QUERY  q-tar FOR EACH txb.tarif2 where txb.tarif2.str5 = "403" or txb.tarif2.str5 = "436" or txb.tarif2.str5 = "302" or txb.tarif2.str5 = "401" or txb.tarif2.str5 = "456" no-lock.
    ENABLE ALL WITH FRAME f-tar.
    wait-for return of frame f-tar
    FOCUS b-tar IN FRAME f-tar.
    v-com = txb.tarif2.str5.
    hide frame f-tar.
    displ v-com with frame fr1.
end.


on help of v-knp in frame fr1 do:
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
find first txb.aaa where txb.aaa.aaa = v-iik no-lock no-error.
  if not avail txb.aaa then do:
     message "Счет не найден ! " view-as alert-box.
     return.
  end.
  else do:
     v-crc = txb.aaa.crc.
     find txb.crc where txb.crc.crc = v-crc no-lock no-error.
     v-crc_val = txb.crc.code.
     find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
     v-fio = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
     if txb.cif.bin = '' then do: message v-bin view-as alert-box.
         if not v-bin then message ' ИИН/БИН отсутсвует в карточке клиента, запросите у клиента документ с ИИН/БИН и внесите данные в АБС. ' view-as alert-box title " ВНИМАНИЕ ! ".
         else do:
             message ' Операции без ИИН/БИН невозможны. ' view-as alert-box title " ВНИМАНИЕ ! ".
             return.
         end.
     end.
     if v-bin then v-rnn = txb.cif.bin. else v-rnn = txb.cif.jss.
     v-pss = txb.cif.pss.
     displ v-crc_val v-fio v-rnn v-pss with frame fr1.

     v-fu = txb.cif.type.
     if v-type = '' and txb.cif.type = 'B' then v-comkod = '302,401,403,436,456'. /* пополнение счета юр лица*/

     if txb.aaa.cif ne v-cif-f then do:
        message "Счет принадлежит другому клиенту ! " view-as alert-box.
        return.
     end.
     if txb.aaa.sta = 'C' then do:
        message "Счет закрыт ! " view-as alert-box.
        return.
     end.
     if v-type ne '' then do:
        find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
        if lookup(txb.lgr.led, v-type) = 0 then do:
           message "Тип счета не " + v-type + " ! " view-as alert-box.
           return.
        end.
     end.
     update v-sum with frame fr1.

     def var fio as char.
     def var doc as char.
     def var rnn as char.
     v-fio1 = "".
     v-rnn1 = "".
     v-pss1 = "".

     if (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499) or
        (txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599) or
        (txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699) or
        (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799)
     then do:
         MESSAGE "Плательщеком является владелец счета?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE v-whplat.
         if v-whplat then do:
           v-fio1 = v-fio.
           v-rnn1 = v-rnn.
           v-pss1 = v-pss.
           /*displ v-fio1 v-pss1 v-rnn1  with frame fr1.*/
         end. else do:
            update v-chr with frame fr3.
            if v-chr = 't' or v-chr = 'T' or v-chr = 'Е' or v-chr = 'е' then do:
               v-fio1 = "".
               v-rnn1 = "".
               v-pss1 = "".
               /*update  v-fio1 v-pss1 v-rnn1  with frame fr1.*/
            end.
            if v-chr = 'u' or v-chr = 'U' or v-chr = 'Г' or v-chr = 'г' then do:
                /*
                def new shared var v-gtoday as date no-undo.
                def new shared var v-cif-f as char.
                v-gtoday = today.
                v-cif-f = "Q10132".
                compile seluplcif.p save.*/

                find first txb.uplcif where txb.uplcif.cif = v-cif-f and txb.uplcif.coregdt <= v-gtoday and txb.uplcif.finday >= v-gtoday no-lock no-error.
                if avail txb.uplcif then do:
                    run seluplcif(output fio,output doc,output rnn).
                    v-fio1 = fio.
                    v-rnn1 = rnn.
                    v-pss1 = doc.
                    /*displ v-fio1 v-pss1 v-rnn1  with frame fr1.*/
                end. else do:
                    message "У клиента нет уполномоченных лиц !" VIEW-AS ALERT-BOX TITLE "".
                end.
            end.

         end.

     end.

     if (txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399) or
        (txb.aaa.gl >= 221500 and txb.aaa.gl <= 221599) or
        (txb.aaa.gl >= 221700 and txb.aaa.gl <= 221799) or
        (txb.aaa.gl >= 221900 and txb.aaa.gl <= 221999)
     then do:
        def var v-yn as logical.
        v-yn = true.
        MESSAGE "Плательщеком является уполномоченное лицо?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE v-whplat.
        if v-whplat then do:
            update v-chr with frame fr4.
            if v-chr = 'u' or v-chr = 'U' or v-chr = 'Г' or v-chr = 'г' then do:
                find first txb.uplcif where txb.uplcif.cif = v-cif-f and txb.uplcif.coregdt <= v-gtoday and txb.uplcif.finday >= v-gtoday no-lock no-error.
                if avail txb.uplcif then do:
                    run seluplcif(output fio,output doc,output rnn).
                    v-fio1 = fio.
                    v-rnn1 = rnn.
                    v-pss1 = doc.
                    /*displ v-fio1 v-pss1 v-rnn1  with frame fr1.*/
                end. else do:
                    message "У клиента нет уполномоченных лиц !" VIEW-AS ALERT-BOX TITLE "".
                end.
            end.
            if v-chr = 'r' or v-chr = 'R' or v-chr = 'К' or v-chr = 'к' then do:
               v-fio1 = "".
               v-rnn1 = "".
               v-pss1 = "".
               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchf" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-fio1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfrnn" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-rnn1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfdnum" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfddt" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = v-pss1 + " " + txb.sub-cod.rcode.

               /*displ  v-fio1 v-pss1 v-rnn1  with frame fr1.*/
            end.
            if v-chr = 'b' or v-chr = 'B' or v-chr = 'И' or v-chr = 'и' then do:
               v-fio1 = "".
               v-rnn1 = "".
               v-pss1 = "".
               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbk" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-fio1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkrnn" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-rnn1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbknum" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkdt" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = v-pss1 + " " + txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkpl" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = v-pss1 + " " + txb.sub-cod.rcode.

            end.

        end. else do:
           v-fio1 = "".
           v-rnn1 = "".
           v-pss1 = "".
        end.
     end.

     update  v-fio1 v-pss1 v-rnn1  with frame fr1.

     find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = v-cif-f no-lock no-error.
     if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-kbe = substring(txb.cif.geo, 3,1) + txb.sub-cod.ccode.


     update v-kod v-kbe v-knp with frame fr1.
     repeat:
     update v-com with frame fr1.

     if txb.cif.type = 'b' and (lookup(string(txb.cif.cgr), '403,405') > 0) and v-com = '401' then do:
        message "К этому виду клиента (ИП) данный вид комиссии не применим!" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
     end.
     else do:
     if txb.cif.type = 'b' and (lookup(string(txb.cif.cgr), '403,405') <= 0) and v-com = '436' then do:
        message "К этому виду клиента (ЮЛ) данный вид комиссии не применим!" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
     end.
     else leave.
     end.
     end.

     run checkdebt(g-today, v-iik, v-com, "txb").

     /* вычисление суммы комиссии-----------------------------------*/
     run perev_txb (v-iik,input v-com, input v-sum, input v-crc, v-crc,v-cif-f, output v-amt, output tproc, output pakal).
     v-sum_com = v-amt.
     displ v-sum_com v-ja with frame fr1.

     if v-type ne '' then do:
        vavl = txb.aaa.cbal - txb.aaa.hbal.
        if txb.lgr.led = 'DDA' then do:
           find baaa where baaa.aaa = txb.aaa.craccnt no-lock no-error.
           if available baaa then vavl = vavl + baaa.cbal.
        end.

        if vavl < v-sum + v-sum_com then do:
           message "Нехватка средств на счете ! " view-as alert-box.
           return.
        end.
     end.
     else do:
        /*Проверка депозита Юридического лица*/
        find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
        if txb.lgr.led = 'CDA' then do:
           if lookup(txb.lgr.lgr, "478,479,480,481,482,483") <> 0 then do:
               message "Дополнительные взносы на счета срочных депозитов группы " + txb.lgr.lgr + " не предусмотрены." view-as alert-box.
               return.
           end.
           find last  txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
           if avail txb.acvolt then do:
              if date(acvolt.x3) - v-gtoday < 31 then do:
                 message "Взносы запрещены, до окончания срока депозита осталось менее 30 дней! " view-as alert-box.
                 return.

              end.
           end.
           else do:
              message "Депозит открыт с ошибками: Взносы запрещены" view-as alert-box.
              return.
           end.
        end.
        /*Проверка депозита Физического лица*/
        if txb.lgr.led = 'TDA' then do:
           if (txb.lgr.feensf = 2 or txb.lgr.feensf = 3 or txb.lgr.feensf = 6 or txb.lgr.feensf = 4 or txb.lgr.feensf = 5 or txb.lgr.feensf = 7 or lookup(txb.lgr.lgr, "A38,A39,A40") > 0) and v-gtoday <> txb.aaa.regdt then do:
              find last txb.t-cnv where txb.t-cnv.aaa = txb.aaa.aaa no-lock no-error.
              /*Депозит Люкс, Суперлюкс, Пенсионный  */
              if (txb.lgr.feensf = 3 or txb.lgr.feensf = 6 or txb.lgr.feensf = 5 or lookup(txb.lgr.lgr, "A38,A39,A40") > 0) and not avail txb.t-cnv then do:
                  find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa exclusive-lock no-error.
                  if not avail txb.acvolt then do:
                     message "Депозит открыт с ошибками: Взносы запрещены" view-as alert-box.
                     return.
                  end.
                  else
                  do:
                      run Get_Month_End(date(txb.acvolt.x1), v-gtoday, date(txb.acvolt.x3),  output i_mk).
                      if i_mk = 0 then do:
                         message "До окончания срока депозита осталось меньше 1 месяца" view-as alert-box.
                         return.
                      end.
                  end.
              end.
              /*Депозит Классик  */
              if (txb.lgr.feensf = 2) and not avail t-cnv then do:
                  find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa exclusive-lock no-error.
                  if not avail txb.acvolt then do:
                     message "Депозит открыт с ошибками: Взносы запрещены" view-as alert-box.
                     return.
                end.
                else
                do:
                    run Get_Month_End(date(txb.acvolt.x1), v-gtoday, date(txb.acvolt.x3),  output i_mk).
                    if i_mk = 2 then do:
                       message "До окончания срока депозита осталось меньше 3 месяцев!" view-as alert-box.
                       return.
                    end.
                end.
              end.
            end.
        end.
     end.
     /* Luiza---------------------------------------------------------*/
     v-oplcom = "1".
     if v-type = '' and v-sum_com <> 0 then do:  /* если есть комиссия     */
        repeat:
            v-ok = no.
            v-iik1 = "".
            displ v-iik1 with frame fr1.
             run sel1("Выберите вид оплаты комиссии", "1 - с кассы|2 - со счета").
             if keyfunction(lastkey) = "end-error" then return.
             v-oplcom1 = return-value.
             if v-oplcom1 = '' then return.
             displ v-oplcom1 with frame fr1.
             v-oplcom = entry(1,v-oplcom1," ").
             if v-oplcom = "1" then do:
                 /* вычисление суммы комиссии-----------------------------------*/
                 run perev_txb (v-iik,input v-com, input v-sum, input v-crc, v-crc,v-cif-f, output v-amt, output tproc, output pakal).
                 v-sum_com = v-amt.
                 displ v-sum_com v-ja with frame fr1.
                 leave.
             end.
             if v-oplcom = "2" then do:

                def var I as int init 0.
                def var aaalist as char init "".

                v-iik1 = "".
                vv-crc = 0.
                FOR EACH txb.aaa where txb.aaa.cif = v-cif-f no-lock, txb.crc where txb.aaa.crc  = txb.crc.crc no-lock.
                   find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
                   if not available txb.lgr or txb.lgr.led = 'ODA' then next.
                   if aaa.sta <> "C" and aaa.sta <> "E" then do:
                        I = I + 1.
                        if aaalist <> "" then aaalist = aaalist + "|".
                        aaalist = aaalist + txb.aaa.aaa + " " + string(txb.crc.crc) + " " + txb.crc.code + " " + string(txb.aaa.cbal - txb.aaa.hbal,"-zzzzzzzzzzzz9.99").
                    end.
                end.

                if I > 0 then do:
                   run sel1("Выберите счет для снятия комиссии", aaalist).
                   if keyfunction(lastkey) = "end-error" then return.
                   v-iik1 = entry(1,return-value," ").
                   vv-crc = integer(entry(2,return-value," ")).
                end.
                displ v-iik1 with frame fr1.
                aaalist = "".

                find first txb.aaa where txb.aaa.aaa = v-iik1 no-lock no-error.
                 if txb.aaa.hbal <> 0 then do:
                    message "Ошибка, на выбранном счете имеются спец инструкции, ~nоплата комиссии возможна только с кассы"  view-as alert-box error.
                 end.
                 else do:
                     /* вычисление суммы комиссии-----------------------------------*/
                     run perev_txb (v-iik,input v-com, input v-sum, input v-crc, vv-crc,v-cif-f, output v-amt, output tproc, output pakal).
                     v-sum_com = v-amt.

                     displ v-sum_com v-ja with frame fr1.

                     find first txb.aaa where txb.aaa.aaa = v-iik1 no-lock no-error.
                     if v-sum_com > txb.aaa.cbal - txb.aaa.hbal then do:
                        message "Ошибка, на выбранном счете недостаточно средств для снятия комиссии"  view-as alert-box error.
                       /* return.*/
                     end.
                     else leave.
                end.
            end. /* if v-oplcom  = 2*/
        end.  /* repeat */
    end.

     /*----------------------------------------------------------------*/
     update v-npl v-npl1 with frame fr1.
     find txb.sysc where txb.sysc.sysc = "bnkadr" no-lock no-error.
     if avail txb.sysc then do:
        v-mail = trim(entry(5, txb.sysc.chval, "|")) no-error.

     end.
     v-ja = no.
     update v-ja with frame fr1.
  end.



Procedure Get_Month_End.

   def input parameter a_start as date.
   def input parameter a_now as date.
   def input parameter e_date as date.
   def output parameter out_month as integer.


   def var vterm as inte.
   def var e_refdate as date.
   def var e_displdate as date.
   def var t_date as date.
   def var years as inte initial 0.
   def var months as inte initial 0.
   def var days as inte initial 0.

   def var t-years as inte initial 0.
   def var t-months as inte initial 0.
   def var t-days as inte initial 0.

   def var i as integer init -1.


     vterm = 1.
     t_date = a_start.


if a_start = a_now then i = 0.

     repeat:

       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.
       /*Если счет открыт в последний день месяца но не в феврале*/
       if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then do:
          t-years = years.
          t-months = months + 1.
          if t-months = 13 then do:
             t-months = 1.
             t-years = years + 1.
          end.
          t-days = 1.

          if months <> 2 then do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
          end.
          else do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years).
          end.
       end.

       else
       /*Если счет открыт 1-го числа*/
       if day(a_start) = 1 then do: /*Если Дата открытия 1 числа*/
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
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
       end.


       if e_displdate > e_date then do:
          if i < 0 then  i = 0.
          out_month = i.
          return.
       end.

      if e_displdate + 1 >= a_now then do: /*начало отсчета*/
         i = i + 1.
      end.





       t_date = date(months, 15, year(t_date) + years).
     end.  /*repeat*/


End procedure.
