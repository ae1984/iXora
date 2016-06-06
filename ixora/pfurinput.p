/* pfurinput.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       Пенсионные и прочие платежи - ввод платежа
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
        30.06.2005 marinav
 * BASES
        BANK COMM
 * CHANGES
        20.07.2005 marinav - создание jou документа на комиссию
        17.08.2005 saltanat - включила возможность редактирования РНН . А также подключен справочник доступных рнн.
        25.08.2005 dpuchkov - проверка на специнструкции инкассовых распоряжений.
        14.09.2005 dpuchkov - добавил возможность проплаты пенсионных если есть ограничение за исключением платежей в бюджет
                              в связи с изменением в законодательстве.
        26.09.2005 dpuchkov - добавил возможность проплаты социальных если есть ограничение в п 1.6.2.9 (Т.З._131)
        03.11.2006 u00777 - добавлено время ввода дебетовой части платежа
        09.01.2009 marinav - в проводке проставляется статус 6
        02.02.10 marinav - расширение поля счета до 20 знаков
        01.02.2011 marinav - изменения в связи с переходом на БИН/ИИН
        07.03.2012 damir - переход на новые форматы.
        02/05/2012 evseev - логирование значения aaa.hbal
        24.07.2012 evseev - ТЗ-1233
        27.08.2012 evseev - иин/бин
        31/01/2012 zhasulan - ТЗ-1428 help для текущих счетов
        25/11/2013 Luiza    - ТЗ 2181 поиск по таблице comon
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{p_f_com.i}
{p_f_gs.i}
{p_f_com1.i}
{comm-com.i}
{comm-rnn.i}
{trim.i}
{chbin.i}
{keyord.i} /*Переход на новые и старые форматы форм*/


def shared var g-today as date.
define shared variable g-ofc as character.
def var v-resident as integer init 1.

/* может запрашивать ордер или нет */
define variable canprn as log initial no.
find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
if available sysc then if lookup (g-ofc, sysc.chval) > 0 then canprn = yes.

def input parameter newdoc as logical.
def input parameter rid as rowid.
def input parameter dat as date.
def input parameter v-sel as integer .

def new shared var pass_no as char.
def var cret as char init "".
def var v-knp as char.
def var amount as decim.
def var comsum as decimal init 0.
def var pf-name as char init ''.
def var comchar as char init "Без комиcсии".
def var doccomcode as char.
def var resultt as log init true.
def var l-str as char format 'x(1)' .
define variable oldrnn as character.
def var v-whole-sum as decimal.
def var v-acc as logi.
def var vbal like jl.dam.
def var vavl like jl.dam.
def var vhbal like jl.dam.
def var vfbal like jl.dam.
def var vcrline like jl.dam.
def var vcrlused like jl.dam.
def var vooo like aaa.aaa.
define variable vparam  as character.
define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
def new shared var s-jh like jh.jh.
def var v-kont as inte.
def var v-cif as char.
def var s-rnn as char.
def var v-rtim as char no-undo. /*время ввода дебет. части платежа*/
def var op_kod as char.
def var s-aaa as char.
def var v-aaac as char. /* счет для комиссии из табл comon */



/* Zhassulan. Choice of acc */
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)"
               aaa.cr[1] - aaa.dr[1] label "Доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
               aaa.sta label "Статус" format "x(1)"
               aaa.crc label "Вал" format "z9"
               lgr.des label "Описание" format "x(20)"
       WITH  10 DOWN.
DEFINE FRAME f-help b-help  WITH centered overlay row 6 COLUMN 25 WIDTH 89 TITLE "Текущие счета клиента в нац. валюте".
/* end choice */

{aas2his.i &db = "bank"}

define frame sf skip
      pay_ur.nom  label "Пл.пор." format ">>>>>9" skip(1)

      v-cif       label "Код клиента" format "x(6)" validate(can-find(first cif where cif.cif = v-cif no-lock),"Нет такого ID клиента! F2-помощь") skip
      pay_ur.acc  label "Р/счет " format "x(20)"
      pay_ur.rnn  label "ИИН/БИН " format "x(12)" skip
      pay_ur.name label "Наименование" view-as text skip(1)

      pay_ur.rnnf label "БИН Пенс фонда " format "x(12)" skip
      pay_ur.namef no-label format 'x(50)' view-as text skip
      pay_ur.knp  label "КНП [ 010, 019, 013, 012, 017 ]     " v-knp no-label skip(1)

      pay_ur.sum  label "Сумма" format ">>>>>>>>9.99"
      pay_ur.qty  validate (pay_ur.qty >= 0, "Неверное кол-во вкладчиков!") label "Кол-во вкладчиков "
      pay_ur.com  format ">>>>>>>>9.99" label "Комиссия" skip
      v-whole-sum format ">>>>>>>>9.99" label "Общая сумма с комиссией" skip
      v-rtim      label "Время" skip
      l-str       no-label
      with side-labels centered overlay row 6.


/* Zhassulan. Отображение текущих счетов клиента */
on help of pay_ur.acc in frame sf do:

            OPEN QUERY  q-help FOR EACH aaa where aaa.cif = v-cif and aaa.sta <> "C" and aaa.crc = 1 and length(aaa.aaa) >= 20 no-lock,
                                   each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" and lgr.led <> "CDA" and lgr.led <> "TDA" no-lock.
            if avail aaa then do:
                 ENABLE ALL WITH FRAME f-help.
                 wait-for return of frame f-help FOCUS b-help IN FRAME f-help.
                 pay_ur.acc = aaa.aaa.
                 hide frame f-help.
                 displ pay_ur.acc with frame sf.
                 end.
             else do:
                 pay_ur.acc = "".
                 MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
                 undo.
             end.
end.
/* Отображение текущих счетов клиента */

on help of pay_ur.rnnf in frame sf do:
     run p_f_rnn.
     pay_ur.rnnf:screen-value = return-value.
     pay_ur.rnnf = pay_ur.rnnf:screen-value.
end.

on enter of pay_ur.qty in frame sf do:
     find first tarif2 where tarif2.num = '1' and tarif2.kod = "12" and tarif2.stat = 'r' no-lock no-error.
     if avail tarif2 then do:
        find first tarifex where tarifex.str5 = '112' and tarifex.stat = 'r' and tarifex.cif = aaa.cif no-lock no-error.
        if avail tarifex then comsum = tarifex.ost. else comsum = tarif2.ost.
        pay_ur.com = comsum * integer(pay_ur.qty:screen-value).
        v-kont = tarif2.kont.
     end.
     v-whole-sum = decimal(pay_ur.sum:screen-value) + comsum * integer(pay_ur.qty:screen-value).
     displ pay_ur.com v-whole-sum with frame sf.
end.

on return of pay_ur.acc in frame sf do:
     find first aaa where aaa.aaa = pay_ur.acc:screen-value and aaa.sta ne 'C' no-lock no-error.
     if avail aaa then do:
         find first cif where cif.cif = aaa.cif no-lock no-error.
         if avail cif then do:
            assign pay_ur.name = cif.name pay_ur.rnn = (if v-bin = no then cif.jss else cif.bin) v-cif = cif.cif.
         end. else do:
            message " В АО ForteBank нет такого счета !" view-as alert-box button Ok. v-acc = false.
         end.
     end. else do:
         message " В АО ForteBank нет такого счета !" view-as alert-box button Ok. v-acc = false.
     end.
     displ pay_ur.rnn pay_ur.name with frame sf.
end.

on help of pay_ur.rnn in frame sf do:
     run ord_help(v-cif, output s-rnn).
     pay_ur.rnn = s-rnn.
     displ pay_ur.rnn with frame sf.
end.

/* --------------------------------------------------- */

REPEAT:
     if newdoc then do:
        CREATE pay_ur.
        pay_ur.txb = seltxb.
        pay_ur.rnn = "".
        oldrnn = ''.
        pay_ur.qty = 0.
        pay_ur.pf_soc = v-sel.
        pay_ur.rtim = time. /*03.11.06 u00777*/
     end. else do:
        find pay_ur where rowid(pay_ur)=rid.
        if not avail pay_ur then leave.
        oldrnn = pay_ur.rnn.
        comsum = pay_ur.com.
        v-whole-sum = pay_ur.com + pay_ur.sum.
     end.
     v-rtim = string(pay_ur.rtim,"HH:MM:SS").
     displ
       pay_ur.nom
       v-cif
       pay_ur.acc
       pay_ur.rnn
       pay_ur.name
       pay_ur.rnnf
       pay_ur.namef
       pay_ur.knp
       pay_ur.qty
       pay_ur.sum
       pay_ur.com
       v-whole-sum
       v-rtim
       with frame sf.

     v-acc = true.
     UPDATE pay_ur.nom WITH FRAME sf.

     set v-cif WITH FRAME sf.

     /*Редактировать счет нельзя , т к он связан со спец инструкцией*/
     repeat:
       if newdoc then UPDATE pay_ur.acc WITH FRAME sf.
       if v-acc then leave.
     end.

     if keyfunction(lastkey) eq "end-error" then  return.
     if v-bin = no then pay_ur.rnnf = '600400073391'. else pay_ur.rnnf = '970740001013'.
     displ pay_ur.rnnf WITH FRAME sf.

     if v-sel = 1 then UPDATE pay_ur.knp validate (lookup(pay_ur.knp, '010,019') > 0 and pay_ur.knp ne '',"Неверный КНП!") WITH FRAME sf.
     if v-sel = 2 then do:
        v-knp = pay_ur.knp. pay_ur.knp = ''. displ pay_ur.knp  WITH FRAME sf.
        UPDATE v-knp validate (lookup(v-knp, '012,017') > 0 and v-knp ne '',"Неверный КНП!") WITH FRAME sf.
        pay_ur.knp = v-knp.
     end.
     /*Редактировать сумму нельзя , т к она связана со спец инструкцией*/
     repeat:
        if newdoc then UPDATE pay_ur.sum validate (pay_ur.sum > 0, "Сумма должна быть больше нуля!") pay_ur.qty validate (pay_ur.qty >= 0, "Неверное количество плательщиков!") WITH FRAME sf.
         assign pay_ur.whn = dat pay_ur.who = g-ofc.
         v-whole-sum = pay_ur.sum + pay_ur.com.
         displ pay_ur.com v-whole-sum with frame sf.
         if newdoc then do:
            run aaa-bal777(pay_ur.acc, output vbal, output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).
            /*если есть ограничение кроме пенсионных то пропускаем*/
            if v-sel = 1 or v-sel = 2 then do: /*пенсионный или социальный*/
               def buffer b1-aas for aas.
               def var d_sm as decimal. d_sm = 0.
               /*
               find last b1-aas where b1-aas.aaa = pay_ur.acc and b1-aas.sta = 2 no-lock no-error.
               if not avail b1-aas then do:
                  find last b1-aas where b1-aas.aaa = pay_ur.acc and b1-aas.sta = 11 no-lock no-error.
                  if avail b1-aas then do:
                     d_sm = 0.
                     for each b1-aas where b1-aas.aaa = pay_ur.acc and b1-aas.sta = 11 no-lock:
                         d_sm = d_sm + b1-aas.chkamt.
                     end.
                     vavl = vavl + d_sm.
                  end.
                  d_sm = 0.
                  find last b1-aas where b1-aas.aaa = pay_ur.acc and b1-aas.sta = 16 no-lock no-error.
                  if avail b1-aas then do:
                     for each b1-aas where b1-aas.aaa = pay_ur.acc and b1-aas.sta = 16 no-lock:
                         d_sm = d_sm + b1-aas.chkamt.
                     end.
                     vavl = vavl + d_sm.
                  end.
                  d_sm = 0.
                  find last b1-aas where b1-aas.aaa = pay_ur.acc and lookup(string(b1-aas.sta), "11,16") <> 0 no-lock no-error.
                  if avail b1-aas then do:
                     for each b1-aas where b1-aas.aaa = pay_ur.acc and lookup(string(b1-aas.sta), "4,5,6,8") <> 0 no-lock:
                         d_sm = d_sm + b1-aas.chkamt.
                     end.
                  end.
                  vavl = vavl + d_sm.
               end.*/
               for each b1-aas where b1-aas.aaa = pay_ur.acc and lookup(string(b1-aas.sta), "2,4,5,15,6,7,8,9,11,16,17") <> 0 or
                                     b1-aas.aaa = pay_ur.acc and b1-aas.mn = "30037" no-lock:
                   d_sm = d_sm + b1-aas.chkamt.
               end.
               vavl = vavl + d_sm.
            end.
            if vavl  < v-whole-sum /*сумма с комиссией*/ then do:
               message " На текущем счете недостаточно средств для оплаты!" view-as alert-box button Ok.
               undo, retry.
            end. else leave.
         end. else leave.
     end.
     update l-str with frame sf.
     MESSAGE "Сохранить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel TITLE "Пенсионные и др. платежи " UPDATE choice as logical.

     case choice:
          when true then do:
              if newdoc then do:
                 /*если платеж новый, то заблокируем нужную сумму*/
                 create aas.
                 find last aas_hist where aas_hist.aaa = pay_ur.acc no-lock no-error.
                 if available aas_hist then aas.ln = aas_hist.ln + 1. else aas.ln = 1.
                 pay_ur.ln = aas.ln.
                 aas.sic = 'HB'.
                 aas.chkdt = g-today.
                 aas.chkno = 0.
                 aas.chkamt  = pay_ur.sum.
                 if v-sel = 1 then do:
                    aas.mn = "a1000".
                    aas.payee = ' Пенсионный платеж'.
                 end.
                 if v-sel = 2 then do:
                    aas.mn = "a2000".
                    aas.payee = ' Социальный платеж' .
                 end.
                 aas.aaa = pay_ur.acc .
                 s-aaa = pay_ur.acc.
                 aas.who = g-ofc.
                 aas.whn = g-today.
                 aas.regdt = g-today.
                 aas.tim = time.

                 if aas.sic = 'HB' then do:
                     find first aaa where aaa.aaa = pay_ur.acc exclusive-lock.
                     if avail aaa then do:
                        run savelog("aaahbal", "pfurinput ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
                        aaa.hbal = aaa.hbal + aas.chkamt.
                     end.
                 end.

                 FIND FIRST ofc WHERE ofc.ofc = g-ofc NO-LOCK no-error.
                 if avail ofc then do:
                   aas.point = ofc.regno / 1000 - 0.5.
                   aas.depart = ofc.regno MODULO 1000.
                 end.
                 op_kod = "A".
                 run aas2his.
                 /*снимем комиссию*/
                 if pay_ur.com > 0 then do:
                    v-aaac = trim(pay_ur.acc).
                    find first comon where comon.aaa = pay_ur.acc no-lock no-error.
                    if available comon then v-aaac = trim(comon.aaac).
                    vparam = " " + vdel + string (pay_ur.com) + vdel + '1' + vdel + v-aaac /*string (pay_ur.acc)*/ + vdel + string(v-kont) + vdel + "Комиссия за " + aas.payee.
                    s-jh = 0.
                    find last b1-aas where b1-aas.aaa = v-aaac /*pay_ur.acc*/ and lookup(string(b1-aas.sta), "2,11,16") <> 0 no-lock no-error.
                    if avail b1-aas then do:
                       create aas.
                       find last aas_hist where aas_hist.aaa = v-aaac /*pay_ur.acc*/ no-lock no-error.
                       if available aas_hist then aas.ln = aas_hist.ln + 1. else aas.ln = 1.
                       pay_ur.info[10] = string(aas.ln).
                       aas.sic = 'HB'.
                       aas.chkdt = g-today.
                       aas.chkno = 0.
                       aas.chkamt  = pay_ur.com.
                       if v-sel = 1 then do:
                          aas.mn = "a3000".
                          aas.payee = ' Комиссия за Пенсионный платеж'.
                       end.
                       if v-sel = 2 then do:
                          aas.mn = "a4000".
                          aas.payee = ' Комиссия за Социальный платеж'.
                       end.
                       aas.aaa = v-aaac /*pay_ur.acc*/ .
                       aas.who = g-ofc.
                       aas.whn = g-today.
                       aas.regdt = g-today.
                       aas.tim = time.
                       if aas.sic = 'HB' then do:
                          find first aaa where aaa.aaa = v-aaac /*pay_ur.acc*/ exclusive-lock.
                          if avail aaa then do:
                             run savelog("aaahbal", "pfurinput ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
                             aaa.hbal = aaa.hbal + aas.chkamt.
                          end.
                       end.
                       FIND FIRST ofc WHERE ofc.ofc = g-ofc NO-LOCK no-error.
                       if avail ofc then do:
                          aas.point = ofc.regno / 1000 - 0.5.
                          aas.depart = ofc.regno MODULO 1000.
                       end.
                       op_kod = "A".
                       run aas2his.
                    end. else do:
                       run trxgen ("JOU0026", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
                       if rcode <> 0 then do: message rcode rdes. pause 100.  return.  end.
                       run jou.
                       if v-noord = no then run vou_bank(1). else run printvouord(1).
                       run trxsts(s-jh, 6, output rcode, output rdes).
                    end.
                 end.
              end.
              cret = string(rowid(pay_ur)).
              leave.
          end.
          when false then undo.
          otherwise  undo, leave.
     end case.
END.

hide frame sf.
return cret.
