/* wpchg.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       ИВЦ/Алсеко/Водоканал/АПК - смена получателей
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
        24/07/04 kanat
 * CHANGES
        26/07/04 kanat - добавил автоматическое формирование причины удаления из временной таблицы для упрощения операции 
                         перевода сумм  
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{comm-com.i}
{yes-no.i}

define variable candel as log.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.

def input parameter g-today as date.
def input parameter newdoc as logical.
def input parameter rid as rowid.
def input parameter selgrp as integer.
def output parameter selbn as char.

define buffer oldb for commonpl.
define buffer cmpb for commonpl.

def var rids as char initial "".

def var commtel like commonpl.comsum.
def var cret as char init "".
def var temp as char init "" no-undo.
define frame sf with side-labels centered view-as dialog-box.

def var lcom  as logical init false.
def var cdate as date init today.

def var doccomcode as char.
def var v-comsum as decimal.


/* def var selcom  as decimal init 10.  сумма комиссии */

find first commonls where commonls.txb = seltxb and commonls.grp = selgrp
           and commonls.visible = yes no-lock no-error.


def var grpname as char format "x(10)".
grpname =  selname(selgrp).

def frame sf
     "Платеж " grpname view-as text no-label skip
     "----------------------------------------"  skip
     commonpl.date    view-as text label "Дата"     skip
     commonpl.accnt                label "Счет лицевой"     format "9999999" skip
     commonpl.fioadr               label "Счет - извещение" format "x(40)" skip
     commonpl.rnn 	           label "РНН"      format "x(12)" skip
     commonpl.rnnbn                label "РНН получателя" format "x(12)"
     commonpl.comsum               label "Комиссия" help "F2 - ВЫБОР КОМИССИИ ПО ПОЛУЧАТЕЛЮ" skip
     commonpl.sum                  label "Сумма"    format ">>>,>>9.99" skip
     with side-labels centered.

    on help of commonpl.comsum in frame sf do:
        run comm-coms.
        if return-value <> "" then do:
            find first tarif2 where num = '7' and kod = return-value and tarif2.stat = "r" no-lock no-error.
            commonpl.comsum = comm-com(commonpl.sum, tarif2.kod).
        end.
            displ commonpl.comsum with frame sf.
    end.


/*REPEAT:*/
do transaction:


    find commonpl where rowid(commonpl) = rid.

    if commonpl.grp <> 1 and commonpl.grp <> 4 and commonpl.grp <> 3 then do:
        do while true:
           run comm-grp(output selgrp).
           if selgrp > 0 then leave.
           else if selgrp = -1 then return.
        end.
    end.

    find first commonls where commonls.txb = seltxb and commonls.grp = selgrp
           and commonls.visible = yes no-lock no-error.

       commonpl.comsum = commonls.comsum.
       commonpl.date = g-today.

       selbn = commonls.bn.

       DISPLAY 
               grpname
               commonpl.date 
               WITH side-labels FRAME sf.

        if not newdoc then do:
           create oldb.
           buffer-copy commonpl to oldb.
           commonpl.chval[5] = "0".
           assign oldb.deldate = today
                  oldb.deltime = time
                  oldb.deluid = userid ("bank")
                  oldb.delwhy = "Изменение реквизитов"
                  oldb.deldnum = next-value(w_p_seq).
        end.

              UPDATE 
     	      commonpl.accnt 
              commonpl.fioadr 
              commonpl.rnn 
              commonpl.rnnbn 
              commonpl.comsum 
              commonpl.sum  
              WITH FRAME sf.

        temp =  trim(commonls.npl) + ", лицевой счет " +
                string(commonpl.accnt,"9999999").

        MESSAGE "Сохранить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel
                 TITLE "Внимание" UPDATE choice as logical.

        if not choice then delete oldb.

        case choice:
            when true then do :

            find first cmpb where cmpb.txb = seltxb and cmpb.grp = selgrp and cmpb.date = g-today and
                                  cmpb.type = commonpl.type and cmpb.rnnbn = commonls.rnnbn and cmpb.fioadr = commonpl.fioadr and
                                  cmpb.counter = commonpl.counter and cmpb.accnt = commonpl.accnt and
                                  cmpb.sum = commonpl.sum and cmpb.dnum <> commonpl.dnum and cmpb.deluid = ? no-lock no-error.

            if available cmpb then do:
               message "Повторный платеж за дату валютирования!" view-as alert-box title ''.
               delete oldb.
               undo, return.
            end.
                
                UPDATE 
                commonpl.txb = seltxb
                commonpl.grp = selgrp
                commonpl.arp = commonls.arp
                commonpl.type    = commonls.type
                commonpl.rnnbn   = commonls.rnnbn
                commonpl.valid   = false /* РНН плательщика неизвестно */
                commonpl.npl     = temp.

                assign
                   commonpl.edate = today
                   commonpl.dnum = oldb.deldnum
                   commonpl.euid = userid("bank")
                   commonpl.etim = time.

                assign commonpl.rko = get-dep(commonpl.uid, g-today).

                cret = string(rowid(commonpl)).
                rids = rids + cret.
            end.
            when false then                                  
                undo.
            otherwise
                undo, leave.
        end case.

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

return cret.
