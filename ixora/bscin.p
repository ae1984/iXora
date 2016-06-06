/* kztcin.p
 * MODULE
     Коммунальные платежи
 * DESCRIPTION
     Прием платежей Базис-телеком
 * AUTHOR
        11/04/2007 id00004
 * CHANGES
*/


{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{yes-no.i}
{rekv_pl.i}
{comm-com.i}

def input parameter g-today as date.
def input parameter newdoc as logical.
def input parameter rid as rowid.
def var rids as char initial "".
define frame sf with side-labels centered view-as dialog-box.

def var KOd_ as char no-undo.
def var KBe_ as char no-undo.
def var KNp_ as char no-undo.

/* def var commtel like commonpl.comsum.*/
def var cret as char init "" no-undo.
def var temp as char init "" no-undo.

/* def var cdate as date init today no-undo.*/
def var selgrp  as integer init 9.  /* Определяем номер группы в таблице commonls */


define variable candel as log no-undo.

define buffer oldb for commonpl.
define buffer cmpb for commonpl.

def var v-whole-sum as decimal.

def var comchar  as char.
def var lcom as logical init false no-undo.
def var doccomsum  as decimal.
def var doccomcode  as char.
def var v-vov-name as char init "" no-undo.



def frame sfx
     "Номер и дата выдачи удостоверения участника ВОВ" skip
     "----------------------------------------------------"  skip
     v-vov-name  label "Участник ВОВ"  format "x(45)"
     with side-labels centered view-as dialog-box.


candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.

if seltxb = 0 then do:
   find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
              commonls.visible = yes and commonls.type = 18 no-lock no-error.
end.
else do:
   find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
              commonls.visible = yes no-lock no-error.
end.

/* dpuchkov проверка реквизитов см тз 907 */
run rekvin(commonls.rnnbn, commonls.knp, commonls.kbe, commonls.kod).
if not l-ind then return.

/* saltanat запоминаем КОД, КБЕ, КНП для передачи на печать */
assign
        KOd_ = commonls.kod
        KBe_ = commonls.kbe
        KNp_ = commonls.knp
no-error.

def frame sf
     commonpl.date    view-as text label "Дата"              skip
     commonpl.fioadr               label "Сч. извещение"     format "x(15)"  validate(commonpl.fioadr <> "",'Введите счет-извещение ')   skip
/*   commonpl.counter view-as text label "Телефон"           format "999999" skip      */
     commonpl.fio                  label "Ф.И.О"     format "x(23)" validate(commonpl.fio <> "",'Введите Ф.И.О абонента') skip
     commonpl.adr                  label "Адрес"     format "x(23)"      validate(commonpl.adr <> "",'Введите адрес абонента') skip  skip
     commonpl.rnn                  label "РНН  "     format "999999999999"  validate(commonpl.rnn <> "",'Введите РНН')   skip
/*   commonpl.accnt                label "Номер договора"    format "99999999999" skip */
     commonpl.sum                  label "Сумма"             format ">>>,>>9.99" skip
     lcom                          label                           "Код комиссии  "      format ":/:"  skip
     doccomsum       view-as text  format ">>>,>>9.99"       label "Сумма комиссии"  skip
     v-whole-sum                   label                           "Общая сумма   "  format ">>>,>>>,>>9.99" skip
     with side-labels centered.


    on value-changed of commonpl.fioadr in frame sf do:
/*
        commonpl.fioadr = commonpl.fioadr:screen-value.

        find first kaztelsp where kaztelsp.statenmb = commonpl.fioadr
                   USE-INDEX statenmb no-lock no-error. 

        if avail kaztelsp then do:
        commonpl.counter = kaztelsp.phone.
        commonpl.accnt = kaztelsp.accnt.
        end.
        else do:
        commonpl.counter = 0.
        commonpl.accnt = 0.
        end.               

        displ commonpl.counter with frame sf.
        displ commonpl.accnt with frame sf.
        apply "value-changed" to self.
*/
    end.

    /*
    on value-changed of commonpl.counter in frame sf do:
        commonpl.counter = integer(commonpl.counter:screen-value).
        apply "value-changed" to self.
    end.
    
    on value-changed of commonpl.accnt in frame sf do:
        commonpl.accnt = integer(commonpl.accnt:screen-value).
        apply "value-changed" to self.
    end.
    */
    
    on help of commonpl.fioadr in frame sf do:
       run kztcfind.
       commonpl.fioadr:screen-value = return-value.
       commonpl.fioadr = return-value.
       apply "value-changed" to commonpl.fioadr in frame sf.
    end.


    on help of lcom in frame sf do:
        run comtar("7","24,##").
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
    commonpl.sum = decimal(commonpl.sum:screen-value) no-error.
    run choose_doccomcode_calc_and_displ_sums.
    apply "value-changed" to self.
  end.

/*main-------------------------------------------------------------------------*/

/*REPEAT:*/
do transaction:


    if newdoc then CREATE commonpl.
               else find commonpl where rowid(commonpl)=rid.


       commonpl.date = g-today.

       commonpl.comsum = commonls.comsum.
       v-whole-sum = commonpl.sum + commonpl.comsum.
       doccomsum = commonpl.comsum.


       DISPLAY
               commonpl.date
/*               commonpl.counter 
               commonpl.accnt     */

               lcom

               doccomsum
               v-whole-sum
               WITH side-labels FRAME sf.

        if not newdoc then do:
           create oldb.
           buffer-copy commonpl to oldb.
           commonpl.chval[5] = "0".
           assign oldb.deldate = today
                  oldb.deltime = time
                  oldb.deluid = userid ("bank")
                  oldb.delwhy = "Изменение реквизитов"
                  oldb.deldnum = next-value(kztd).
        end.

        displ commonpl.sum
              doccomsum
              v-whole-sum
              with frame sf.

        if newdoc then
        UPDATE commonpl.fioadr
               commonpl.fio
               commonpl.adr
               commonpl.rnn
               commonpl.sum
/*             commonpl.accnt
               commonpl.sum     */
               lcom

               WITH FRAME sf editing:
                   readkey.
                   apply lastkey.
                   if frame-field = "fioadr" then
                            apply "value-changed" to commonpl.fioadr in frame sf.
/*                   if frame-field = "accnt" then
                            apply "value-changed" to commonpl.accnt in frame sf. */
               end.
        else
        UPDATE commonpl.fioadr
               commonpl.fio
               commonpl.adr
               commonpl.rnn
               commonpl.sum

               lcom

/*               commonpl.accnt */
               WITH FRAME sf editing:
                   readkey.
                   apply lastkey.
                   if frame-field = "fioadr" then
                            apply "value-changed" to commonpl.fioadr in frame sf.
/*                   if frame-field = "accnt" then
                            apply "value-changed" to commonpl.accnt in frame sf. */
               end.

        doccomsum = commonpl.comsum.
        v-whole-sum = commonpl.sum + doccomsum.
        displ v-whole-sum with frame sf.

/*      temp =  trim(commonls.npl) + " по счету - извещ. " + trim(commonpl.fioadr).   */
        temp =  trim(commonls.npl) + " по сч-извещ. " + trim(commonpl.fioadr).


    if doccomcode = "24" and trim(v-vov-name) = "" then do:
    message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
    undo,retry.
    end.
    else
    commonpl.info[3] = v-vov-name.


        MESSAGE "Сохранить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel TITLE "Внимание" UPDATE choice as logical.

        if not choice then delete oldb.

        case choice:

            when true then do :

            find first cmpb where cmpb.txb = seltxb and cmpb.grp = selgrp and cmpb.date = g-today and
                            cmpb.rnnbn = commonls.rnnbn and cmpb.fioadr = commonpl.fioadr and
                            cmpb.counter = commonpl.counter /*and cmpb.accnt = commonpl.accnt */  and
                            cmpb.sum = commonpl.sum and cmpb.dnum <> commonpl.dnum and cmpb.deluid = ? no-lock no-error.
            if available cmpb then do:
               message "Повторный платеж за дату валютирования!" view-as alert-box title ''.
               delete oldb.
               undo, return.
            end.

            if trim(commonpl.fioadr) = "" then do:
               MESSAGE "Не введен счет - извещение!" VIEW-AS ALERT-BOX TITLE "Внимание".
               return.
            end.

/*          if commonpl.accnt = 0 then do:
               MESSAGE "Не введен лицевой счет!" VIEW-AS ALERT-BOX TITLE "Внимание".
               return.
            end. */


            if newdoc then do:
                UPDATE
                commonpl.txb = seltxb
                commonpl.grp = selgrp
                commonpl.arp = commonls.arp
                commonpl.uid = userid("bank")
                commonpl.date    = g-today
                commonpl.credate = today
                commonpl.cretime = time
                commonpl.type    = commonls.type
                commonpl.rnnbn   = commonls.rnnbn
                commonpl.npl     = temp
                commonpl.comcode = doccomcode
                commonpl.dnum    = next-value(kztd).
                update commonpl.rko = get-dep(userid("bank"), g-today).
                cret = string(rowid(commonpl)).
                rids = rids + cret.
            end. /* newdoc */
            else do:
                UPDATE
                commonpl.txb = seltxb
                commonpl.grp = selgrp
                commonpl.arp = commonls.arp
                commonpl.euid  = userid("bank")
                commonpl.edate = today
                commonpl.etim  = time
                commonpl.type    = commonls.type
                commonpl.rnnbn   = commonls.rnnbn
                commonpl.npl     = temp
                commonpl.comsum  = doccomsum
                commonpl.comcode = doccomcode
                commonpl.dnum    = oldb.deldnum.
                update commonpl.rko = get-dep(commonpl.uid, g-today).
                cret = string(rowid(commonpl)).
                rids = rids + cret.
            end. /* update */
            end.
            when false then
                undo.
            otherwise
                undo, leave.
        end case.

END.
hide frame sf.

if rids <> "" then do:
    MESSAGE "Распечатать ордер?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Внимание" UPDATE choice4 as logical.
    case choice4:
        when true then
            run kztcprn (rids, KOd_, KBe_, KNp_).
    end case.
end.

return cret.



procedure choose_doccomcode_calc_and_displ_sums:
      if doccomcode <> "24" then do:
        doccomcode = get_tarifs_common(seltxb, selgrp, '', false).
      end.
      doccomsum = comm-com-1(commonpl.sum, doccomcode, '7', comchar).
      commonpl.comsum = doccomsum.
      v-whole-sum = commonpl.sum + doccomsum.
      displ
        doccomsum
        v-whole-sum
      with frame sf.
end.
