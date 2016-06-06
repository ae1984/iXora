/* agaz-in.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       Астана ГАЗ - ввод платежа
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
        31/12/99 pragma
 * CHANGES
        31/10/03 sasco изменил commonpl.uid на userid (bank)
        09/06/04 dpuchkov - добавил возможность контроля платежей от юр лиц в пользу юр лиц для Астаны.
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        14/12/2005 Evgeniy (u00568) по тз 175 от 16/11/2005 "Автоматизация снятия комиссий по платежам без открытия банковского счета по филиалам"
                    добавил возможность выбора комиссии из 2-х вариантов, убрал возможность ввода в ручную, добавил отображение названия комиссии
        31/01/2006 Evgeniy (u00568) по тз 230 от 27/01/2006 "Внесение изменений в тарифы" автоматизация тарифов!!!
         6/03/2006 Evgeniy (u00568) теперь сохраняет код комиссии
         4/04/2006 Evgeniy (u00568) если введено в ручную, то код комиссии '##'
                                    по ТЗ 246 от 15/02/2006 - предлагает ввод РНН для Атырау
                                    по ТЗ 175 от 16/11/2005 - сохраняет номер удостоверения ВОВ в таблице РНН
*/
{comm-txb.i}
{comm-rnn.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{comm-com.i}
{yes-no.i}
{comm-num.i}
{rekv_pl.i}

def input parameter g-today as date.
def input parameter newdoc as logical.
def input parameter rid as rowid.
def input parameter selgrp as integer.

def var rids as char initial "".
def var docnum as integer .
def var cret as char init "".
def var temp as char init "" no-undo.
/*define frame sf with side-labels centered view-as dialog-box.*/
/*14/12/2005 Evgeniy (u00568)*/
def var lcom  as logical init false. /*ввод комиссии для формы */
def var comchar  as char. /*название комиссии*/
def var doccomcode  like commonpl.comcode init '__' . /*номер комиссии*/
/*def var can_com_sum  as logical init false.*/ /*да - можно вводить сумму комиссии вручну. - нет, надо выбрать из списка*/
def var v-vov-name as char init "".

def var cdate as date init today.

define variable candel as log.
def var v-whole-sum as decimal.
def var docrnn   as char format "x(12)".
def var rnnValid   as logical initial false  no-undo.
def var rid_rnn as rowid no-undo.
def var result_rnn as logical init false no-undo.
def var vov_str as char init 'ВОВ, ветеран, номер уд. ' no-undo.
def var commonpl_accnt like commonpl.accnt.
candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then
  if lookup (userid("bank"), sysc.chval) = 0 then
    candel = no.

find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
           commonls.visible = yes no-lock no-error.

/* dpuchkov проверка реквизитов см тз 907 */

run rekvin(commonls.rnnbn, commonls.knp, commonls.kbe, commonls.kod).
if not l-ind then return.

def frame sfx
     "Номер и дата выдачи удостоверения участника ВОВ" skip
     "----------------------------------------------------"  skip
     v-vov-name  label "Участник ВОВ"  format "x(45)"
     with side-labels centered view-as dialog-box.


def frame sf
     skip
     commonpl.date    view-as text label "Дата"
     commonpl_accnt                label "Счет"     format ">>>9999999"    skip
     commonpl.service              label "ГРУ/КСК"  format "x(15)"         skip
     docrnn                  label "РНН"      format "999999999999"  help "F2 - ПОИСК,  F3 - РЕДАКТИРОВАНИЕ" skip
     commonpl.fio                  label "ФИО"      format "x(25)"         skip
     commonpl.adr                  label "Адрес"    format "x(25)"         skip
     commonpl.sum                  label "Сумма"    format ">>>,>>>,>>9.99"  skip
     "Комиссия" lcom        format ":/:"       no-label
     comchar         view-as text format 'x(30)'     no-label skip
     commonpl.comsum               label "Сумма комиссии"    format ">>>,>>>,>>9.99"  skip
     v-whole-sum                   label "Общая сумма с комиссией"    format ">>>,>>>,>>9.99"  skip
     with title " " + trim(substr(commonls.bn,1,15)) side-labels centered.


    on value-changed of docrnn in frame sf do:
        docrnn =  docrnn:screen-value.
        if newdoc and doccomcode='24' then do:
          doccomcode = "__". /* оно сразу пересчитается*/
          v-vov-name = ''.
          run choose_doccomcode_calc_and_displ_sums.
        end.
        find first rnnu where rnnu.trn = docrnn no-lock no-error.
        if avail rnnu then do:
                rnnValid  = true.
                commonpl.fio = caps(trim( rnnu.busname )) .
                commonpl.adr = rnnu.street1 + ", " + rnnu.housen1 + "/" + rnnu.apartn1.
        end. else do:
          find first rnn where rnn.trn = docrnn no-lock no-error.
          if avail rnn then do:
            if newdoc and entry(1,comm.rnn.info[1],',') = 'ВОВ' then do:
              v-vov-name = comm.rnn.info[1].
              v-vov-name = substr(v-vov-name, length(vov_str + ' '), length(v-vov-name)) no-error.
              doccomcode = "24".
              run choose_doccomcode_calc_and_displ_sums.
            end.
            rid_rnn = rowid(rnn).
            rnnValid  = true.
            commonpl.fio  = caps(trim( rnn.lname ) + " " + trim( rnn.fname ) + " " + trim( rnn.mname )).
            commonpl.adr  = caps(trim(rnn.street1) + ", " + rnn.housen1 + "/" + rnn.apartn1).
          end. else do:
                rnnValid = false.
          end.
        end.
        displ
          commonpl.fio
          commonpl.adr
        with frame sf.
    end.

    on "enter-menubar" of docrnn in frame sf do:
      if not comm-rnn (docrnn:screen-value) and length(docrnn:screen-value) = 12 then do:
        if yes-no ("", "Редактировать РНН " + docrnn:screen-value + " ?") then do:
          run taxrnnin (docrnn:screen-value).
          apply "value-changed" to docrnn in frame sf.
        end.
      end.
      else message "Не верный РНН!~nНельзя редактировать!" view-as alert-box title "".
    end.



    on return of docrnn in frame sf do:
        IF  (  can-find( first rnn where rnn.trn = docrnn no-lock) or
               can-find( first rnnu where rnnu.trn = docrnn no-lock)
            )  or
            (  length(docrnn) = 12 and yes-no("", "РНН не найден в справочнике.~nПродолжить с введенным РНН?")
               and
               not comm-rnn (docrnn)
            )
            then result_rnn = true.
            else result_rnn = false.

        IF result_rnn
          and LENGTH(docrnn:screen-value) = 12
          and not can-find(first rnn where rnn.trn = docrnn:screen-value no-lock)
          and not can-find(first rnnu where rnnu.trn = docrnn:screen-value no-lock)
        then do:
             if yes-no ("", "Редактировать РНН " + docrnn:screen-value + " ?") then
               run taxrnnin(docrnn:screen-value).
             apply "value-changed" to docrnn in frame sf.

             IF (can-find( first rnn where rnn.trn = docrnn:screen-value no-lock) or
                 can-find( first rnnu where rnnu.trn = docrnn:screen-value no-lock) or
                 length(docrnn:screen-value) = 12)
                 and  (not comm-rnn (docrnn:screen-value))then
                   result_rnn = true.
                 else assign result_rnn = false.
        end.
    end.



    on help of docrnn in frame sf do:
        run taxfind.
        if return-value <> "" then do:
            update docrnn:screen-value = return-value with frame sf.
            update docrnn = return-value with frame sf.
        end.
        apply "value-changed" to self.
    end.



   on help of commonpl.service in frame sf do:
       run agaz-sp.
       commonpl.service:screen-value = return-value.
       commonpl.service = return-value.
       apply "value-changed" to commonpl.service in frame sf.
 /*       disp commonpl_accnt commonpl.counter with frame sf.*/
   end.



 on help of lcom in frame sf do:
     case seltxb:
        WHEN 1 then do: /*Астана*/
          run comtar("7","24,10"). /*run comm-coms.*/
        end.
        WHEN 3 then do: /*Астана*/
          run comtar("7","24,10"). /*run comm-coms.*/   /*!!!*/
        end.
        OTHERWISE do:
          run comm-coms.
        end.
     end case.
     if return-value <> "" then
       doccomcode = return-value.
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
     run choose_doccomcode_calc_and_displ_sums.
 end.



    on value-changed of commonpl.sum in frame sf do:
      commonpl.sum = decimal(commonpl.sum:screen-value).
      run choose_doccomcode_calc_and_displ_sums.
    end.



    on value-changed of commonpl.comsum in frame sf do:
      doccomcode = '##'.
      commonpl.comsum = decimal(commonpl.comsum:screen-value).
      v-whole-sum = commonpl.sum + commonpl.comsum.
      comchar = "Введено вручную".
      displ v-whole-sum
          commonpl.comsum
          comchar
      with frame sf.
    end.



/* REPEAT: */

/*Main logic ------------------------------------------------------------------*/


do transaction:
    if newdoc then CREATE commonpl.
              else find commonpl where rowid(commonpl)=rid.

       if newdoc then do:
         run choose_doccomcode_calc_and_displ_sums.
       end.

       /*commonpl.comsum = commonls.comsum.*/
       commonpl.date = g-today.

       DISPLAY
               commonpl.date
               commonpl.comsum
               commonpl.sum
               v-whole-sum
               comchar
               WITH side-labels FRAME sf.

    if (newdoc or (commonpl.joudoc = ? and commonpl.comdoc = ? and
                   commonpl.prcdoc = ? and commonpl.rmzdoc = ?))
       then do:

               displ commonpl_accnt
                     commonpl.service
                     commonpl.fio
                     commonpl.adr
                     commonpl.comsum
                     commonpl.sum
                     v-whole-sum
                     with frame sf.

               if newdoc or candel then
               UPDATE
                     commonpl_accnt
                     commonpl.service
                     docrnn validate( docrnn = '' or
                       (can-find( first rnn where
                       rnn.trn = docrnn no-lock) or
                       can-find( first rnnu where
                       rnnu.trn = docrnn no-lock) or
                       length(docrnn) = 12 /* and
                       yes-no("", "РНН не найден в справочнике.~nПродолжить с введенным РНН?")*/
                       and result_rnn)
                          and
                       (not comm-rnn (docrnn))
                       ,"Не верный контрольный ключ РНН!")
                     commonpl.fio
                     commonpl.adr
/*                     validate(
                        can-find( first as-gazsp where as-gazsp.disc = commonpl.service no-lock)
                        and yes-no("", "ГРУ/КСК не найден в справочнике.~nПродолжить ?"), "Не верный счет")
*/
                     commonpl.sum
                     lcom
                     commonpl.comsum
                     WITH FRAME sf editing:
                       readkey.
                       apply lastkey.
                       if frame-field = "service" then
                          apply "value-changed" to commonpl.service in frame sf.
                     end.
               else
               UPDATE
                     commonpl.service
                     WITH FRAME sf editing:
                       readkey.
                       apply lastkey.
                       if frame-field = "service" then
                          apply "value-changed" to commonpl.service in frame sf.
                     end.

        temp =  trim(commonls.npl) + " " + trim(commonpl.fio) + " " + trim(commonpl.adr) + ",счет " +
                string(commonpl_accnt,">>9999999").

        v-whole-sum = commonpl.comsum + commonpl.sum.

        displ commonpl.comsum
              commonpl.sum
              v-whole-sum
              with frame sf.

        MESSAGE "Сохранить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel
                 TITLE "Внимание" UPDATE choice as logical.

        case choice:
            when true then do :
                docnum = comm-num (selgrp, g-today) .

              UPDATE
                commonpl.accnt = commonpl_accnt
                commonpl.txb = seltxb
                commonpl.grp = selgrp
                commonpl.arp = commonls.arp
                commonpl.date    = g-today
                commonpl.type    = commonls.type
                commonpl.rnn     = docrnn
                commonpl.rnnbn   = commonls.rnnbn
                commonpl.valid   = false /* РНН плательщика неизвестно */

                commonpl.npl     = temp
                commonpl.fioadr  = trim(fio) + " " + trim(adr)
                commonpl.dnum    = docnum
                commonpl.comcode = doccomcode
                commonpl.info[3] = v-vov-name.

                if doccomcode = "24" and trim(v-vov-name) <> "" then do:
                  run update_rnn_for_veteran.
                end.

              if newdoc then assign commonpl.rko = get-dep( /*commonpl.uid*/ userid ("bank"), g-today)
                                    commonpl.uid = userid("bank")
                                    commonpl.credate = today
                                    commonpl.cretime = time
                                    no-error.
                        else assign commonpl.rko = get-dep(userid("bank"), g-today)
                                    commonpl.euid = userid("bank")
                                    commonpl.edate = today
                                    commonpl.etim = time
                                    no-error.

                cret = string(rowid(commonpl)).
                rids = rids + cret.

            end.
            when false then
                undo.
            otherwise
                undo, leave.
        end case.

        end.

        else
         display
            commonpl.date
            commonpl_accnt
            commonpl.service
            commonpl.fio
            commonpl.adr
            commonpl.comsum format ">>>,>>9.99"
            commonpl.sum format ">>>,>>>,>>9.99"
            v-whole-sum
            WITH FRAME sf.
END.
hide frame sf.
/*
if rids <> "" then do:
    MESSAGE "Распечатать ордер?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Внимание" UPDATE choice4 as logical.
    case choice4:
        when true then
            run wpprn(rids).
    end case.
end.
*/
/*
return cret.

AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Внимание" UPDATE choice4 as logical.
    case choice4:
        when true then
            run wpprn(rids).
    end case.
end.
*/

return cret.


procedure update_rnn_for_veteran:
  if v-vov-name<> '' then do:
    do transaction:
      find comm.rnn where rowid(rnn) = rid_rnn.
      if comm.rnn.trn = docrnn then do:
        assign
          comm.rnn.info[1] = vov_str + v-vov-name
        no-error.
      end.
    end. /* transaction */
  end.
end.


procedure choose_doccomcode_calc_and_displ_sums:
      if doccomcode <> '##' then do:
        if doccomcode <> "24" then do:
          case seltxb:
            WHEN 1 then do: /*Астана*/
              doccomcode = "10".
            end.
            WHEN 3 then do: /*Атырау*/
              doccomcode = "10". /*!!!*/
            end.
          end case.
        end.
        /* calc_and_displ_sums считаем и выводим суммы */
        commonpl.comsum = comm-com-1(commonpl.sum, doccomcode, "7", comchar).
      end. else
        enable commonpl.comsum with frame sf.
      v-whole-sum = commonpl.sum + commonpl.comsum.
      displ
        commonpl.comsum
        v-whole-sum
        comchar
      with frame sf.
end.
