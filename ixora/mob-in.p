/* mob-in.p
 * MODULE
     Коммунальные платежи
 * DESCRIPTION
     Процедура принятия платежей Kcell, K-Mobile
 * AUTHOR
        31/12/99 pragma
 * CHANGES
     30.06.03 kanat добавил изменения в процедуру, чтобы в г.Уральск платежи KCell обрабатывались как в г. Алматы
     07.07.03 kanat добавил новый параметр при вызове процедуры commpl - РНН плательщика для таможенных платежей, по - умолчанию ставятся пустые кавычки
     13.07.03 kanat убрал проверку на филиалы при вызове mob-u300.i
     24.07.03 kanat добавил зачисление на АРП на кассы в пути по департаментам из sysc.sysc = "csptdp"
     31.07.03 kanat добавил новый параметр при вызове процедуры commpl для совместимости с обработкой таможенных платежей
     29.09.03 sasco ИСПОЛЬЗОВАНИЕ comdelpay.i при удалении
     09.10.03 sasco Автоматическая печать квитанции
     10.10.03 sasco Запрос на ордер через "canprn"
     01.01.2004 nadejda - изменила ставку НДС - брать из sysc
     12.04.04 kanat добавил транзакцию по комиссии
     14.04.04 kanat добавил create cashofc после штамповки
     21.04.04 kanat добавил выбор комиссии при приеме платежа
     19.05.2004 valery - перенес зачисление на АРП на кассы в пути в - comm-arp1.i
     25/05/04 dpuchkov - добавил возможность контроля платежей от юр лиц в пользу юр лиц.
     03/06/04 kanat - убрал пережиток select max... поставил на его место find last из буфера таблицы, так как
              программа медленно работала.
     07/06/04 kanat - добавил вывод общей суммы с комиссией при вводе платежа
     14/06/04 kanat - убрал печать чеков при проведении транзакции в Алматы - где комиссия (если она есть) и основная сумма
                      проходят в одной проводке разными линиями. Чеки печатаются из mob-list.
     29/06/04 kanat - Теперь чеки БКС печатаются только после сохранения платежа
     04.08.04 saltanat добавила передаваемые параметры для процедуры mob-prn(rids, KOd_, KBe_, KNp_).
     08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
     09/02/2005 kanat - добавил выбор комисиий и убрал ручной ввод комиссий
                       добавил обработку плательщиков ВОВ и приравненных им
     31/01/2006 Evgeniy (u00568) по тз 230 от 27/01/2006 "Внесение изменений в тарифы"
                добавил возможность выбора комиссии из 2-х вариантов, авто пересчет
     24/05/06   marinav  - добавлен параметр даты факт приема платежа
     04/05/2006 u00568 Evgeniy - по тз 328 от 03/05/2006 изменение тарифа в филиалах всегда 717 код во всех филиалах
     03/07/2006 sasco    - вместо temp в назначение платежа попадает просто номер телефона
     24.07.2006 tsoy     - зачисление на АРП в Алмате, в связи с закрытием счета
     28.07.2006 tsoy     - реквизиты kcell для филиалов
     31.07.2006 tsoy     - исправил глюк с rsub для картела
     05.09.2006 tsoy     - поменял код с 300 на 701 добавил код 705
     06/09/2006 u00568 Evgeniy + Талдыкорган
     07/09/2006 u00568 Evgeniy + Караганда
     28.11.2006 u00568 evgeniy - все тарифы перенес в function get_tarifs_common  (comm-com.i)
     24.04.2007 id00004 переделал зачисление на ARP счет.

*/

{comm-com.i}
{comm-txb.i}

def var KOd_ as char.
def var KBe_ as char.
def var KNp_ as char.

def var seltxb as int.
def var ourbank as char.
def var v-nds as decimal.
define buffer bcommpl for commonpl.

find sysc where sysc = "nds" no-lock no-error.
if avail sysc then v-nds = sysc.deval.
ourbank = comm-txb().
seltxb  = comm-cod().

define shared variable g-ofc as character.

define variable candel as log.

/* может запрашивать ордер или нет */
define variable canprn as log initial no.
find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
if available sysc then if lookup (g-ofc, sysc.chval) > 0 then canprn = yes.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (g-ofc, sysc.chval) = 0 then candel = no.

{get-dep.i}
{yes-no.i}
{padc.i}
{u-2-d.i}
{sysc.i}
{rekv_pl.i}

def input parameter g-today as date.
def input parameter newdoc as logical.
def input parameter rid as rowid.
def var rids as char initial "".
def new shared var s-jh like jh.jh.

def var cret as char init "".
def var temp as char init "" no-undo.

/*define frame sf with side-labels centered view-as dialog-box.*/

def var comchar  as char.
def var lcom as logical init false.
def var doccomsum  as decimal.
def var doccomcode  as char.
def var v-vov-name as char init "".

def frame sfx
     "Номер и дата выдачи удостоверения участника ВОВ" skip
     "----------------------------------------------------"  skip
     v-vov-name  label "Участник ВОВ"  format "x(45)"
     with side-labels centered view-as dialog-box.

def var cdate as date init today.
def var selgrp  as integer init 4.  /* Определяем номер группы в таблице commonls */
def var seltype as integer init 1.  /* type в таблице commonls */
def var docnum as integer.
define buffer bc for commonpl.

def var v-phone as char init "".
def var v-cell  as char init "".
def var v-fio   as char init "".
def var v-rnn   as char init "".
def var v-accnt as inte init 0.
def var v-amt   as deci init 0.
def var v-s     as char no-undo.
def var v-v     as char init "TK" no-undo.
def var v-n     as char  no-undo.
def var v-t     as char  no-undo.
def var dlm     as char.
def var l333    as logical init false.

def var cTitle as char init '' no-undo.
def var crlf as char.

def var s_sbank as char.
def var i_clrgrss as integer.

def var i_temp_dep as integer.
def var s_dep_cash as char.
def var s_account_a as char.
def var s_account_b as char.

def var v-tmpjh as integer.
define var v-cash as logical.
define var cashgl like jl.gl.

def var rdes  as char.
def var rcode as integer.

def var v-whole-sum as decimal.

crlf = chr(13) + chr(10).

doccomcode = get_tarifs_common(seltxb, selgrp, '', false).

update "Телефон:" "8 - " v-cell format "999" " - " v-phone format "9999999" skip(1)
       "K'Cell 701 / K-Mobile 777 / Beeline 705"
       with no-labels centered frame sfu.
hide frame sfu.

if trim(v-phone) = "" then return.



case v-cell:
     when "701" then seltype = 1. /* KCELL */
     when "777" then seltype = 2. /* KMOBILE */
     when "705" then seltype = 2. /* BEELINE */
     when ""    then return.
     OTHERWISE do:
        MESSAGE "Неизвестный оператор сотовой связи."
        VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Платежи K'Cell/K-Mobile" .
        return.
     end.
end.

  if seltype = 1 then do:
     MESSAGE "Запрещено принимать платежи K-cell"
     VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Платежи K'Cell/K-Mobile" .
     return.
  end.


find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
           commonls.type = seltype and commonls.visible = yes no-lock no-error.

if not avail commonls then do:
 MESSAGE "Не настроена таблица commonls"
 VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Платежи K'Cell/K-Mobile" .
 return.
end.
if newdoc then do:
  /* dpuchkov проверка реквизитов см тз 907 */
  run rekvin(commonls.rnnbn, commonls.knp, commonls.kbe, commonls.kod).
  if not l-ind then return.
end.

/* Запоминаем значения КОДА, КБЕ, КНП */
assign
      KOd_ = commonls.kod
      KBe_ = commonls.kbe
      KNp_ = commonls.knp
no-error.

if newdoc and seltype = 2 then do:
   run mob-f333 (v-phone).
   if return-value = "" then l333 = false.
                        else do:
                          find first k-mobile where rowid(k-mobile) = to-rowid(return-value).
                          if not avail k-mobile then do:
                               MESSAGE "Ошибка: отсутствует данная запись - " + return-value
                               VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Платежи K'Cell/K-Mobile".
                               return.
                          end.
                          assign
                              v-phone = k-mobile.phone
                              v-amt   = k-mobile.amt
                              v-rnn   = k-mobile.rnn
                              v-fio   = k-mobile.name[1].
                        end.
end.

def frame sf
     commonpl.date    view-as text label "Дата" skip
     commonpl.service view-as text label "8 - "  format "9999999" skip
     commonpl.counter              label "Телефон"  format "9999999" skip
     commonpl.fio                  label "ФИО"      format "x(40)" skip
     commonpl.accnt   view-as text label "Счет"     format "999999999"  skip
     commonpl.sum                  label "Сумма"    format ">>>,>>9.99" skip
     lcom                          label "Код комиссии"      format ":/:"  skip
     doccomsum       view-as text  format ">>>,>>9.99"       label "Сумма комиссии"  skip
     v-whole-sum                   label "Общая сумма" format ">>>,>>>,>>9.99" skip
     with side-labels centered.


    on value-changed of commonpl.sum in frame sf do:
      commonpl.sum = decimal(commonpl.sum:screen-value).
      if doccomcode <> "24" then do:
        doccomcode = get_tarifs_common(seltxb, selgrp, '', false).
      end.
      doccomsum = comm-com-1(commonpl.sum, doccomcode, "7", comchar).
      v-whole-sum = commonpl.sum + doccomsum.
      displ v-whole-sum
            doccomsum
            comchar
          with frame sf.
    end.



    on help of lcom in frame sf do:
      case seltxb:
        when 0 then  run comtar("7","24,##").
        when 1 then  run comtar("7","24,##").
        when 2 then  run comtar("7","24,##").
        when 3 then  run comtar("7","24,##").
        when 4 then  run comtar("7","24,##").
        when 5 then  run comtar("7","24,##").
        when 6 then  run comtar("7","24,##").
        OTHERWISE run comm-coms.
      END CASE.
      if return-value <> "" then
        doccomcode = return-value.
      apply "value-changed" to commonpl.sum in frame sf.
      if doccomcode = "24" then do:
        update
          v-vov-name
        with frame sfx.
        hide frame sfx.
        if trim(v-vov-name) = "" then do:
          message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
          undo,retry.
        end.
      end.
    end.

do /*transaction*/:
    if newdoc then do:
          CREATE commonpl.
          assign
               commonpl.txb   = seltxb
               commonpl.fio    = v-fio
               commonpl.fioadr = v-fio
               commonpl.rnn   = v-rnn
               commonpl.sum   = v-amt
               commonpl.accnt = v-accnt
               commonpl.counter = integer(v-phone)
               commonpl.service = v-cell
               commonpl.date = g-today.
               /*commonpl.comsum = commonls.comsum.*/
    end. else
      find commonpl where rowid(commonpl) = rid no-error.
    doccomsum = comm-com-1(commonpl.sum, doccomcode, "7", comchar).
    /*commonpl.comsum = doccomsum.*/
    v-whole-sum = commonpl.sum + doccomsum.
    DISPLAY
      commonpl.date
      commonpl.service
      commonpl.accnt
      doccomsum
      v-whole-sum
    WITH side-labels FRAME sf.

    if newdoc then do:


      UPDATE commonpl.counter
             commonpl.fio
             commonpl.sum
             lcom
             with frame sf.

      commonpl.comsum = doccomsum.
      commonpl.comcode = doccomcode.

      v-whole-sum = commonpl.sum + doccomsum.
      displ v-whole-sum with frame sf.

      assign v-amt = commonpl.sum.

      temp =  trim(commonls.npl) + " " + string(commonpl.counter,"9999999") +
              ' от ' +  trim( commonpl.fio ) + '. Cумма ' + trim( string( v-amt, '>>>,>>>,>>9.99' )) +
              ', в т.ч. НДС ' + trim( string( truncate( v-amt / (1 + v-nds) * v-nds, 2 ), '>>>,>>>,>>9.99' )) + '.'.


      if doccomcode = "24" and trim(v-vov-name) = "" then do:
        message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
        undo,retry.
      end. else
        commonpl.info[3] = v-vov-name.

      MESSAGE "Сохранить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel
        TITLE "Внимание" UPDATE choice as logical.


      find last bcommpl where bcommpl.txb = seltxb and
                        bcommpl.grp = selgrp use-index datenum no-lock no-error.
      if avail  bcommpl then
        docnum = bcommpl.dnum + 1.

      case choice:
        when true then do :
            UPDATE
            commonpl.txb     = seltxb
            commonpl.grp     = selgrp
            commonpl.arp     = commonls.arp
            commonpl.uid     = g-ofc
            commonpl.date    = g-today
            commonpl.credate = today
            commonpl.cretime = time
            commonpl.type    = commonls.type
            commonpl.rnnbn   = commonls.rnnbn
            commonpl.npl     = temp
            commonpl.dnum    = docnum.
            assign
                commonpl.rko = get-dep(g-ofc, g-today)
                cret = string(rowid(commonpl))
                rids = rids + cret.

            i_temp_dep = int (get-dep (g-ofc, g-today)).
            {comm-arp1.i}
            if not yes-no("Платежи K'Cell/K-Mobile","Сформировать ордер на сумму " + string(v-amt) + " тенге ?") then
            do:
              undo.
              return.
            end.


















/*-------------------------------------------------------------*/
/*-------------------------------------------------------------*/
/*-------------------------------------------------------------*/

/*
    if seltxb = 0 then do:

message s_account_a " -- "  s_account_b  " -- " commonls.arp.
pause 555.

              run trx (       /* Зачисление на АРП */
              6,
              v-amt,
              1,
              s_account_a, /*if return-value = '1' then '100100' else '',*/
              s_account_b, /*if return-value = '1' then '' else '000061302',*/
              '',
              commonls.arp,
              'Зачисление на транзитный счет ' + temp,
              commonls.kod,commonls.kbe,'856').

              if return-value = '' then undo, return.

              s-jh = int(return-value).

              run setcsymb (s-jh, commonls.symb).


              run jou.
              if return-value = "" then undo, return.
              assign commonpl.joudoc = return-value.


              run vou_bank(2).


              /* Комиссия */

              if commonpl.comsum <> 0 then do:
                run trx (6,
                   commonpl.comsum,
                   1,
                   s_account_a, /*if return-value = '1' then '100100' else '',*/
                   s_account_b, /*if return-value = '1' then '' else '000061302',*/
                   commonls.comgl, /* сет комис. */
                   '',
                   "Комиссия за платежи сотовой связи",
                   commonls.kbe, '14', '840').

                if return-value = '' then do:
                  undo.
                  return.
                end.
                s-jh = int(return-value).
                run setcsymb (s-jh, commonls.symb).
                assign commonpl.comdoc = string(s-jh).
                run jou.
                run vou_bank(2).
              end.

    end.

*/
/*-------------------------------------------------------------*/
/*-------------------------------------------------------------*/
/*-------------------------------------------------------------*/
























/*

            if seltxb = 0 then do:
              if commonpl.comsum <> 0 then do:

                run mobtrx(0,
                            v-amt,
                            1,
                            s_account_a,
                            s_account_b,
                            '',
                            string(commonls.iik, "999999999"),
                            temp,
                            commonls.kod,commonls.kbe,"856", v-tmpjh).

                if return-value = '' then do:
                  undo.
                  return.
                end.

                v-tmpjh = integer(return-value).



                run mobtrx(0,
                           commonpl.comsum,
                           1,
                           s_account_a,
                           s_account_b,
                           commonls.comgl,
                           '',
                           "Комиссия за платежи сотовой связи",
                           commonls.kbe, '14', '840', v-tmpjh).
 
                if return-value = '' then do:
                  undo.
                  return.
                end.
                s-jh = int(return-value).
                run trmbts (input s-jh, input 6, output rcode, output rdes).
                if rcode ne 0 then do:
                  message rdes.
                end.
                


                find sysc where sysc.sysc = 'CASHGL' no-lock no-error.
                if avail sysc then do:
                  cashgl = sysc.inval.

                  for each jl where jl.jh = s-jh no-lock:
                    if jl.sts = 6 and jl.gl = cashgl then do:
                      find first cashofc where cashofc.whn eq g-today and
                                       cashofc.sts eq 2 and
                                       cashofc.ofc eq g-ofc and
                                       cashofc.crc eq jl.crc
                                       exclusive-lock no-error.
                      if avail cashofc then do:
                        cashofc.amt = cashofc.amt + jl.dam - jl.cam.
                      end. else do:
                        create cashofc.
                        cashofc.whn = g-today.
                        cashofc.ofc = g-ofc.
                        cashofc.crc = jl.crc.
                        cashofc.sts = 2.
                        cashofc.amt = jl.dam - jl.cam.
                        cashofc.who = g-ofc.
                      end.

                      release cashofc.
                    end.
                  end.

                end.


                run setcsymb (s-jh, commonls.symb).
                run jou.

                assign commonpl.joudoc = return-value
                       commonpl.comdoc = string(s-jh).
                run vcell(2). 
              end. else do:
                run trx (6,
                         v-amt,
                         1,
                         s_account_a,
                         s_account_b,
                         '',
                         string( commonls.iik, "999999999"),
                         temp,
                         commonls.kod,commonls.kbe,"856").

                if return-value = '' then do: undo. return. end.
                s-jh = int(return-value).
                run setcsymb (s-jh, commonls.symb).
                run jou.
                assign commonpl.joudoc = return-value.
                run vou_bank(2).
              end.

            end. /* Алматы */
*/
/*
            else do:   /* Если филиал */
              run trx (       /* Зачисление на АРП */
              6,
              v-amt,
              1,
              s_account_a, /*if return-value = '1' then '100100' else '',*/
              s_account_b, /*if return-value = '1' then '' else '000061302',*/
              '',
              commonls.arp,
              'Зачисление на транзитный счет ' + temp,
              commonls.kod,commonls.kbe,'856').
              if return-value = '' then undo, return.
              s-jh = int(return-value).
              run setcsymb (s-jh, commonls.symb).
              run jou.
              if return-value = "" then undo, return.
              assign commonpl.joudoc = return-value.
              run vou_bank(2).
              /* Комиссия */
              if commonpl.comsum <> 0 then do:
                run trx (6,
                   commonpl.comsum,
                   1,
                   s_account_a, /*if return-value = '1' then '100100' else '',*/
                   s_account_b, /*if return-value = '1' then '' else '000061302',*/
                   commonls.comgl, /* сет комис. */
                   '',
                   "Комиссия за платежи сотовой связи",
                   commonls.kbe, '14', '840').

                if return-value = '' then do:
                  undo.
                  return.
                end.
                s-jh = int(return-value).
                run setcsymb (s-jh, commonls.symb).
                assign commonpl.comdoc = string(s-jh).
                run jou.
                run vou_bank(2).
              end.
              if seltxb <> 0 then do:
                     s_sbank = "TXB00".
                     i_clrgrss = 5.
              end.

              if seltype = 2 then  temp = v-cell + v-phone.
              if seltype = 1 then  temp = string(commonpl.counter).

              if seltype = 2 then do:
                    /* Отправка платежа */
                   run commpl (
                        commonpl.dnum,
                        v-amt,
                        commonls.arp,
                        s_sbank,
                        commonls.iik,
                        0,                      /* KBK string(tcommpl.kb,"999999") */
                        no,                     /* MB or RB   */
                        "AO 'TEXAKABANK'",      /* name */
                        "600900050984",         /* rnn_nk     */
                        commonls.knp,
                        commonls.kod,
                        commonls.kbe,
                        temp,
                        trim(commonls.que),
                        0,
                        i_clrgrss,
                        "",
                        "",
                        g-today   /*19 параметр даты факт приема платежа marinav*/
                        ).
              assign commonpl.rmzdoc = return-value no-error.
              find remtrz where  remtrz.remtrz =  commonpl.rmzdoc exclusive-lock no-error.
              if avail  remtrz then do:
                    remtrz.rsub = "arp".
              end.
              find remtrz where  remtrz.remtrz =  commonpl.rmzdoc no-lock no-error.
              end.

              if seltype = 1 then do:
                    /* Отправка платежа */
                   run commpl (
                        commonpl.dnum,
                        v-amt,
                        commonls.arp,
                        s_sbank,
                        commonls.iik,
                        0,                      /* KBK string(tcommpl.kb,"999999") */
                        no,                     /* MB or RB   */
                        trim(commonls.bn),      /* name */
                        commonls.rnnbn,         /* rnn_nk     */
                        commonls.knp,
                        commonls.kod,
                        commonls.kbe,
                        temp,
                        trim(commonls.que),
                        0,
                        i_clrgrss,
                        "",
                        "",
                        g-today   /*19 параметр даты факт приема платежа marinav*/
                        ).
              end.


              assign commonpl.rmzdoc = return-value no-error.
              
            end.
    */

        end.

        when false then
          undo.
        otherwise
          undo, leave.
      end case.
    end. /*newdoc*/
    else
      display
             commonpl.date
             commonpl.counter
             commonpl.accnt
             commonpl.sum    format ">>>,>>9.99"
             doccomsum
             v-whole-sum     format ">>>,>>>,>>9.99"
      WITH FRAME sf.
END. /*transaction*/

hide frame sf.


if newdoc and seltxb = 0 then
do:
   if seltype = 1 then do:
      message "Отправка платежа в KCELL".
      {mob-u300.i}
   end.
   
   if seltype = 2 then do:
      
      message "Отправка платежа в K-Mobile".
      
      {mob-u333.i}
       
       mobtemp.phone = v-cell + mobtemp.phone.
       mobtemp.npl   = mobtemp.phone.

   end.

   if rids <> "" then do:
      if canprn then do:
         MESSAGE "Распечатать ордер ?"
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
         TITLE "Внимание" UPDATE choice4 as logical.
         case choice4:
              when true then run mob-prn (rids, KOd_, KBe_, KNp_).
         end case.
      end.

      else run mob-prn (rids, KOd_, KBe_, KNp_).
   end.
end.
    pause 555.
return cret.
