/* filgettda1.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Снятие с деп счета в другом филиале????
        закрытие в др филиале
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        19.07.2010 denis
 * CHANGES
        18/01/2011 evseev - запретил закрытие по группам 518,519,520
        07.06.2011 id00004 - добавил проверку для МетроСуперлюкс если срок < 1 мес запретить снятие сумм
        13/06/2011 evseev - для lgr.feensf = 6
        22/06/2011 evseev - исправил ошибку. добавил процедуру Get_Month_Begin.
        25/01/2012 evseev - ТЗ-1245
        13/02/2012 evseev - СЗ от 13/02/2012. Мин остаток для KZ81470162215A141115 = 30 000 000
        14/02/2012 evseev - СЗ от 13/02/2012.
        20/02/2012 evseev - СЗ от 13/02/2012.
        22/02/2012 evseev - СЗ от 13/02/2012. отправка почты на Чимкент
        28/04/2012 evseev - логирование значения aaa.hbal
        02/05/2012 evseev - добавил процедуру логирования proc_savelog
        23.05.2012 evseev - ТЗ-1366 запрет на операцию если не акцептован клиент
        31.08.2012 evseev - иин/бин
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        13.05.2013 evseev - tz-1828
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
        28.06.2013 evseev - tz-1909

*/



def  shared var v-cif-f as char.
def  shared var v-bankname as char.
def  shared var v-iik like txb.aaa.aaa.
def  shared var v-crc like txb.crc.crc.
def  shared var v-crc_val as char no-undo format "xxx".
def  shared var v-fio as char no-undo format "x(60)".
def  shared var v-rnn like txb.cif.jss.
def  shared var v-pss as char no-undo format "x(30)".

def  shared var v-fio1 as char no-undo format "x(60)".
def  shared var v-rnn1 like txb.cif.jss.
def  shared var v-pss1 as char no-undo format "x(30)".

def  shared var v-sum as deci no-undo.
def  shared var v-kod as char no-undo init "19".
def  shared var v-kbe as char no-undo init "19".
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
def  shared var v-gofc as char.

def var v-whplat as logic.
def var v-chr as char.

def var vavl as deci.
def var v_sumfirst as decimal.
def var d_ost    as decimal.
def var d_sumfreez as decimal decimals 2.
def var i-mon as decimal.
def buffer baaa for txb.aaa.
def buffer b-crc for txb.crc.
def temp-table t-ln no-undo
    field code as char
    field name as char format "x(70)"
    index main is primary code.

{chk12_innbin.i}

procedure proc_savelog:

define input parameter v-logfile as char.
define input parameter v-mess as char.

def var v-dbpath as char.
find txb.sysc where txb.sysc.sysc = "stglog" no-lock no-error.
v-dbpath = txb.sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".

output to value(v-dbpath + v-logfile + "." + string(today, "99.99.9999" ) + ".log") append.
    put unformatted
    today " "
    string(time, "hh:mm:ss") " "
    userid("txb") format "x(8)" " "
    v-mess
    skip.
output close.

end procedure.

/*БИН   */
def var v-bin as logi init no.
def var v-label as char format "x(18)".
def var v-label1 as char format "x(18)".
find first txb.sysc where txb.sysc.sysc = 'bin' no-lock no-error.
if avail txb.sysc then v-bin = txb.sysc.loval.
if v-bin  then v-label = "ИИН/БИН          :". else v-label =   "РНН/БИН клиента  :".
if v-bin  then v-label1 = "ИИН/БИН получ.   :". else v-label1 = "РНН получателя   :".

for each t-ln. delete t-ln. end.

for each txb.codfr where txb.codfr.codfr = 'spnpl' no-lock .
    create t-ln.
    t-ln.code =  txb.codfr.code.
    t-ln.name = txb.codfr.name[1] + txb.codfr.name[2].
end.
form  skip(1)
    v-iik label "Счет клиента     " format "x(20)" skip
    v-crc label "Валюта           "   v-crc_val no-label skip
    v-fio label "Клиент           " format "x(50)" skip
    v-label no-label v-rnn no-label validate((chk12_innbin(v-rnn)),'Неправильно введён БИН/ИИН') colon 18 skip
    v-pss label "Уд. личн.        "  skip
    v-sum label "Сумма            " format ">>>,>>>,>>>,>>>,>>9.99" validate(v-sum > 0 , "Введите сумму!") skip
    v-fio1 label "ФИО получателя   " format "x(50)" skip
    v-pss1 label "Документ         "  skip
    v-label1 no-label v-rnn1 no-label validate((chk12_innbin(v-rnn1)),'Неправильно введён БИН/ИИН') colon 18  skip
    v-kod label "Код              " format "x(2)" validate(v-kod ne "" , "Введите Код!") skip
    v-kbe label "Кбе              " format "x(2)" validate(v-kod ne "" , "Введите Кбе!") skip
    v-knp label "КНП              " format "x(3)" validate( can-find (t-ln where t-ln.code = v-knp) , "Введите КНП! См. справочник (F2)") help "F2 - справочник" v-codename no-label format "x(40)" skip
    v-com label     "Комиссия         " format "x(3)" help " Введите код комиссии (F2 - поиск)" validate(lookup(v-com, v-comkod) > 0, "Допустимы кода " + v-comkod + " !") skip
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


    def var v-propath as char no-undo.
    v-propath = propath. /* так как нам будут мешаться тригеры , перенаправим путь к библиотеке в каталог в котором лежат эти тригеры откомпиленые под логическое имя txb*/

do trans:
displ v-label v-label1 no-label with frame fr1.
update v-iik with frame fr1.

  find first txb.aaa where txb.aaa.aaa = v-iik exclusive-lock no-error.
  if not avail txb.aaa then do:
     message "Счет не найден ! " view-as alert-box.
     return.
  end.


     v-crc = txb.aaa.crc.
     find txb.crc where txb.crc.crc = v-crc no-lock no-error.
     v-crc_val = txb.crc.code.
     find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
     if not avail txb.cif then do:
        message "Клиент не найден ! " view-as alert-box.
        return.
     end.
     if txb.cif.bin = '' then do: message v-bin view-as alert-box.
         if not v-bin then message ' ИИН/БИН отсутсвует в карточке клиента, запросите у клиента документ с ИИН/БИН и внесите данные в АБС. ' view-as alert-box title " ВНИМАНИЕ ! ".
         else do:
             message ' Операции без ИИН/БИН невозможны. ' view-as alert-box title " ВНИМАНИЕ ! ".
             return.
         end.
     end.
     if cif.crg = "" or cif.crg = ? then do:
        message "Счет " + txb.aaa.aaa + " заблокирован! Необходим акцепт для CIF " + txb.aaa.cif view-as alert-box.
        return.
     end.

     v-fio = txb.cif.name.
     if v-bin then v-rnn = txb.cif.bin. else v-rnn = txb.cif.jss.
     v-pss = txb.cif.pss.
     displ v-crc_val v-fio v-rnn v-pss with frame fr1.
     if txb.aaa.cif ne v-cif-f then do:
        message "Счет принадлежит другому клиенту ! " view-as alert-box.
        return.
     end.
     if txb.aaa.sta = 'C' then do:
        message "Счет закрыт ! " view-as alert-box.
        return.
     end.
     if txb.cif.type = 'B' then do:
        message "Счет юридического лица ! Изъятие невозможно!" view-as alert-box.
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
     v-fio1 = "".
     v-rnn1 = "".
     v-pss1 = "".

     def var fio as char.
     def var doc as char.
     def var rnn as char.

     if (txb.aaa.gl >= 220600 and txb.aaa.gl <= 220699) or (txb.aaa.gl >= 220700 and txb.aaa.gl <= 220799) then do:
         MESSAGE "Получатель является владелец счета?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE v-whplat.
         if v-whplat then do:
           v-fio1 = v-fio.
           v-rnn1 = v-rnn.
           v-pss1 = v-pss.
           /*displ  v-fio1 v-pss1 v-rnn1  with frame fr1.*/
         end. else do:
           update v-chr with frame fr3.
           if v-chr = 'u' or v-chr = 'U' or v-chr = 'Г' or v-chr = 'г' then do:
               find first txb.uplcif where txb.uplcif.cif = v-cif-f and txb.uplcif.coregdt <= v-gtoday and txb.uplcif.finday >= v-gtoday no-lock no-error.
               if avail txb.uplcif then do:
                   run seluplcif(output fio,output doc,output rnn).
                   v-fio1 = fio.
                   v-rnn1 = rnn.
                   v-pss1 = doc.
                   /*displ  v-fio1 v-pss1 v-rnn1  with frame fr1.*/
               end. else do:
                   message "У клиента нет уполномоченных лиц !" VIEW-AS ALERT-BOX TITLE "".
               end.
           end.
           if v-chr = 'n' or v-chr = 'N' or v-chr = 'Т' or v-chr = 'т' then do:
               find first txb.cif-heir where txb.cif-heir.cif = v-cif-f no-lock no-error.
               if avail txb.cif-heir then do:
                   run selcifref(output fio,output doc,output rnn).
                   v-fio1 = fio.
                   v-rnn1 = rnn.
                   v-pss1 = doc.
                   /*displ  v-fio1 v-pss1 v-rnn1  with frame fr1.*/
               end. else do:
                   message "У клиента нет наследников !" VIEW-AS ALERT-BOX TITLE "".
               end.
           end.
         end.
     end.

     update  v-fio1 v-pss1 v-rnn1  with frame fr1.

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


     find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = v-cif-f no-lock no-error.
     if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-kbe = substring(txb.cif.geo, 3,1) + txb.sub-cod.ccode.


     update v-kod v-kbe v-knp v-com with frame fr1.

     find first txb.tarif2 where txb.tarif2.str5 = v-com and txb.tarif2.stat = 'r' no-lock no-error.
     if avail txb.tarif2 then do:
        v-sum_com = txb.tarif2.ost.
        if txb.tarif2.proc > 0 then do:
           v-sum_com = (v-sum / 100) * txb.tarif2.proc * txb.crc.rate[1].
           if txb.tarif2.min > 0 then do:
              if v-sum_com < txb.tarif2.min then v-sum_com = txb.tarif2.min.
           end.
        end.
        v-sum_com = v-sum_com / txb.crc.rate[1].
     end.
     displ v-sum_com v-ja with frame fr1.

     vavl = txb.aaa.cbal - txb.aaa.hbal.


        find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
        /*Депозиты физических лиц*/
        d_sumfreez = 0.
        d_ost = 0.
        if txb.lgr.led = 'TDA' then do:
           if (txb.lgr.feensf = 3) or (lgr.feensf = 4) or (lgr.feensf = 5) or (lgr.feensf = 7) or (lgr.feensf = 6) or lookup(txb.lgr.lgr, "A38,A39,A40") > 0   then do: /**/

           if  (txb.lgr.feensf = 3) or (lgr.feensf = 4) or (lgr.feensf = 5) or (lgr.feensf = 6) or lookup(txb.lgr.lgr, "A38,A39,A40") > 0 then do:
              if txb.lgr.usdval = False then d_sumfreez = lgr.tlimit[1].
              else
              do:
                   find last b-crc where b-crc.crc = lgr.crc no-lock no-error.
                   if avail b-crc then d_sumfreez = lgr.tlimit[1] / b-crc.rate[1].
              end.

              if d_sumfreez > ((txb.aaa.cr[1] - txb.aaa.dr[1]) - v-sum - v-sum_com) then do:
                 message "СУММА ИЗЪЯТИЯ НЕ ДОЛЖНА ПРЕВЫШАТЬ" trim(string((txb.aaa.cr[1] - txb.aaa.dr[1]) - d_sumfreez, 'z,zzz,zzz,zz9.99-'))  view-as alert-box.
                 return.
              end.
           end.
           if  txb.lgr.feensf = 5 then do:
               find last txb.acvolt where txb.acvolt.aaa =  txb.aaa.aaa exclusive-lock no-error.
              i-mon = 0.
              run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
              if i-mon < 1 then do:
                 message "По депозиту нет начисленных процентов(изъятие сумм невозможно) " skip "" view-as alert-box.
                 return.
              end.

           end.
           if  txb.lgr.feensf = 7 then do:
               find last txb.acvolt where txb.acvolt.aaa =  txb.aaa.aaa exclusive-lock no-error.
              i-mon = 0.
              run Get_Month_Begin(date(txb.acvolt.x1), v-gtoday, output i-mon).
              if i-mon < 1 then do:
                 message "По депозиту нет начисленных процентов(изъятие сумм невозможно) " skip "" view-as alert-box.
                 return.
              end.
              if i-mon < 18 and v-sum + v-sum_com > txb.aaa.stmgbal then do:
                 message "Сумма изъятия превышает сумму выплаченных процентов " skip "" view-as alert-box.
                 return.
              end.
            end.
           end.
           else do:
              message "По данному депозиту запрещено частичное изъятие ! " view-as alert-box.
              return.
           end.
        end.
        /*Депозиты юридических лиц*/
        if txb.lgr.led = 'CDA' then do:
           if lookup(txb.lgr.lgr,"484,485,486,487,488,489,518,519,520,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20,151,152,153,154,171,172,157,158,176,177,173,175,174") = 0 then do:
              message "По данному депозиту изъятия запрещены." view-as alert-box.
              return.
           end.
           if txb.aaa.sta = "C" or txb.aaa.sta = "E" then do:
              message "Закрытый счет" view-as alert-box.
              return.
           end.
           for each txb.aad where txb.aad.aaa = txb.aaa.aaa and txb.aad.who <> "bankadm" no-lock:
               d_ost = d_ost + txb.aad.sumg.
           end.
           d_ost = d_ost + txb.aaa.opnamt.

           if txb.aaa.crc = 1  then d_sumfreez = 150000.
           if txb.aaa.crc <> 1 then d_sumfreez = 1000.

           if  txb.aaa.aaa = 'KZ81470162215A141115' then d_sumfreez = 30000000.
           if d_sumfreez > ((txb.aaa.cr[1] - txb.aaa.dr[1]) - v-sum - v-sum_com) then do:
              if  txb.aaa.aaa <> 'KZ81470162215A141115' then message "СУММА ИЗЪЯТИЯ НЕ ДОЛЖНА ПРЕВЫШАТЬ" trim(string((aaa.cr[1] - aaa.dr[1]) - d_sumfreez, 'z,zzz,zzz,zz9.99-')) view-as alert-box.
              else message "СУММА ИЗЪЯТИЯ НЕ ДОЛЖНА ПРЕВЫШАТЬ" trim(string((aaa.cr[1] - aaa.dr[1]) - d_sumfreez, 'z,zzz,zzz,zz9.99-')) skip
                           " иначе договор считается расторгнутым!" view-as alert-box.
              if  txb.aaa.aaa <> 'KZ81470162215A141115' then return.
            end.

             if  txb.aaa.aaa <> 'KZ81470162215A141115' then do:
                if txb.aaa.regdt < 04.01.2010 then do: /*Согласно ТЗ-643 необходимо внести изменения в расчет изъятий с 01.04.2010*/
                   find last txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1 and txb.jl.dc = "D" and txb.jl.jdt = v-gtoday  no-lock no-error.
                   if avail txb.jl then do:
                      message "Разрешено только одно частичное изъятие не более 50% от остатка за день! "  view-as alert-box.
                      return.
                   end.

                   if v-sum + v-sum_com > (d_ost / 2 ) then do:
                      message "Разрешено только одно частичное изъятие не более 50% от остатка за день "  view-as alert-box.
                      return.
                   end.
                end.
                if txb.aaa.regdt >= 04.01.2010 then do:
                   find first jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1  and txb.jl.dc = "C" no-lock use-index acc .
                   v_sumfirst = txb.jl.cam. /*Сумма первоначального вклада*/


                  find last txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1 and txb.jl.dc = "D" and month(txb.jl.jdt) = month(v-gtoday)  no-lock use-index acc .
                  if avail txb.jl then do:
                     message "Разрешено только одно изъятие в месяц. Последнее было "  txb.jl.jdt view-as alert-box.
                     return.
                  end.
                  else do:
                     if v-sum + v-sum_com > v_sumfirst * 30 / 100 then do:
                        message "Разрешено изъятие не более 30% от первоначальной суммы" view-as alert-box.
                        return.
                     end.
                  end.
                end.
            end.
        end.


        propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.

         find last txb.aas where txb.aas.aaa = txb.aaa.aaa and txb.aas.ln = 7777777 exclusive-lock no-error.
         if available txb.aas then do:
            txb.aas.chkdt = v-gtoday.
            txb.aas.whn = today.
            txb.aas.who = v-gofc.
            txb.aas.tim = time.
            txb.aas.chkamt = txb.aas.chkamt - v-sum - v-sum_com.
            run proc_savelog("aaahbal", "filgettda1 ; " + txb.aaa.aaa + " ; " + string(txb.aaa.hbal) + " ; " + string(txb.aaa.hbal - v-sum - v-sum_com) + " ; " + string( v-sum + v-sum_com)).
            txb.aaa.hbal = txb.aaa.hbal - v-sum - v-sum_com.
            if txb.aas.chkamt <= 0 then delete txb.aas.
            if txb.aaa.hbal < 0 then do:
               run proc_savelog("aaahbal", "filgettda1 ; " + txb.aaa.aaa + " ; " + string(txb.aaa.hbal) + " ; " + string(0) + " ; " + string('full')).
               txb.aaa.hbal = 0.
            end.
         end.

        if  txb.aaa.aaa = 'KZ81470162215A141115' then do:
           if d_sumfreez > ((txb.aaa.cr[1] - txb.aaa.dr[1]) - v-sum - v-sum_com) then do:
             find last txb.aas where txb.aas.aaa = txb.aaa.aaa and txb.aas.ln = 7777777 exclusive-lock no-error.
             if available txb.aas then do:
                run proc_savelog("aaahbal", "filgettda1 ; " + txb.aaa.aaa + " ; " + string(txb.aaa.hbal) + " ; " + string(txb.aaa.hbal - txb.aas.chkamt) + " ; " + string(txb.aas.chkamt)).
                txb.aaa.hbal = txb.aaa.hbal - txb.aas.chkamt.
                if txb.aaa.hbal < 0 then do:
                   run proc_savelog("aaahbal", "filgettda1 ; " + txb.aaa.aaa + " ; " + string(txb.aaa.hbal) + " ; " + string(0) + " ; " + string('full')).
                   txb.aaa.hbal = 0.
                end.
                delete txb.aas.
             end.
             message "Договор расторгнут ! " view-as alert-box.
           end.
        end.

        if txb.aaa.cbal - txb.aaa.hbal < v-sum + v-sum_com then do:
           message "Нехватка средств на счете ! " view-as alert-box.
           return.
        end.


     update v-npl v-npl1 with frame fr1.
     find txb.sysc where txb.sysc.sysc = "bnkadr" no-lock no-error.
     if avail txb.sysc then do:
        v-mail = entry(5, txb.sysc.chval, "|") no-error.
     end.

     v-ja = no.
     update v-ja with frame fr1.

     if v-ja then do:
      if  txb.aaa.aaa = 'KZ81470162215A141115' then do:
          for each txb.ofc where txb.ofc.exp[1] matches "*P00032*" or txb.ofc.exp[1] matches "*P00121*" or
                                 txb.ofc.exp[1] matches "*P00136*" or txb.ofc.exp[1] matches "*P00046*" or
                                 txb.ofc.exp[1] matches "*P00033*" no-lock:
             run mail(txb.ofc.ofc + "@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Будет произведено частичное изъятие KZ81470162215A141115 с другого филиала", "Необходим перерасчет 2ого уровня счета KZ81470162215A141115", "0", "", "").
          end.
      end.

     end.
end.

propath = v-propath no-error. /*вернем старый путь к библотеки на "родину"*/


Procedure Get_Month_Begin.
   def input parameter a_start as date.
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

   def var i as integer initial 0.


     vterm = 1.
     t_date = a_start.
     i = 0.



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



       if e_displdate + 1 >= e_date then do:
          if e_displdate + 1 = e_date then i = i + 1.
          out_month = i.
          return.
       end.

       i = i + 1.

       t_date = date(months, 15, year(t_date) + years).
     end.  /*repeat*/
End procedure.
