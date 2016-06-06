/*  spreg.p
 * MODULE
     Платежная система
 * DESCRIPTION
     Регистрация зарплатных платежей юридических лиц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        19.09.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}

def shared var g-today as date.
def shared var g-ofc as character.
def var alldoc as logical.
alldoc = false.
def var rid as rowid.
def stream m-out.
def var ofc_name like ofc.name.
def var dat as date.
def var s_rid as char.
def var s_payment as char.
def var d_whole_sum as decimal init 0.
define variable docdnum as int.
define variable docuid as char.
define variable docdate as date.


dat = g-today.
update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

def var totalt as dec.

DEFINE QUERY q1 FOR salary_p.
def browse b1
    query q1 no-lock
    display whn label "Дата" format "99/99/99"
        salary_p.nom label "No" format ">>>>>>>>9"
        salary_p.rnn  label "РНН(ИИН/БИН)" format "999999999999"
        salary_p.name label "Ф.И.О" format "x(52)"
        salary_p.sum format ">>>>>>>>>>>>>9.99" label "Сумма"
        with 25 down title "Зарплатные платежи" no-labels.

DEFINE BUTTON bedt LABEL "См./Изм.".
DEFINE BUTTON bnew LABEL "Создать".
DEFINE BUTTON bdel LABEL "Удал.".
DEFINE BUTTON bacc LABEL "Итог".


def frame f1
    b1
    skip
    bedt
    bnew
    bdel
    bacc with width 110.

ON CHOOSE OF bedt IN FRAME f1
    do:
        run regzpinp (false, rowid(salary_p), dat).
        b1:refresh().
    end.

ON CHOOSE OF bnew IN FRAME f1
    do:
        run regzpinp (true, rowid(salary_p),dat).

        if return-value <> "" then do:
            open query q1 for each salary_p where salary_p.txb = seltxb and salary_p.whn = dat and
                (alldoc or salary_p.who = userid("bank")) and salary_p.del = ? no-lock by salary_p.nom descending.
            get last q1.
            reposition q1 to rowid to-rowid(return-value) no-error.
            b1:refresh().
        end.
    end.

ON CHOOSE OF bdel IN FRAME f1 do:

    MESSAGE "Удалить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "" UPDATE choice as logical.
          if choice = true then do:

            rid = rowid(salary_p).
            FIND salary_p WHERE ROWID(salary_p) = rid EXCLUSIVE-LOCK.
            if not avail salary_p then leave.

            message skip " Не забудьте вернуть комиссию! "
                 skip(1) view-as alert-box button ok title " ВНИМАНИЕ ".

            find first aas where aas.aaa = salary_p.acc and aas.ln = salary_p.ln exclusive-lock no-error.
            if avail aas then do:
                  CREATE aas_hist.

                    find first aaa where aaa.aaa = aas.aaa no-lock no-error.
                    IF AVAILABLE aaa THEN DO:
                       FIND FIRST cif WHERE cif.cif= aaa.cif USE-INDEX cif NO-LOCK NO-ERROR.
                       IF AVAILABLE cif THEN DO:
                          aas_hist.cif= cif.cif.
                          aas_hist.name= trim(trim(cif.prefix) + " " + trim(cif.name)).
                        END.
                     END.

                     aas_hist.aaa    = aas.aaa.
                     aas_hist.ln     = aas.ln.
                     aas_hist.sic    = aas.sic.
                     aas_hist.chkdt  = aas.chkdt.
                     aas_hist.chkno  = aas.chkno.
                     aas_hist.chkamt = aas.chkamt.
                     aas_hist.payee  = aas.payee + ' Удалили неверный платеж.'.
                     aas_hist.expdt  = aas.expdt.
                     aas_hist.regdt  = aas.regdt.
                     aas_hist.who    = g-ofc.
                     aas_hist.whn    = g-today.
                     aas_hist.tim    = time.
                     aas_hist.del    = aas.del.
                     aas_hist.chgdat = g-today.
                     aas_hist.chgtime= time.
                     aas_hist.chgoper= 'D'.

                     if aas.sic = 'HB' then do:
                     find first aaa where aaa.aaa = aas.aaa exclusive-lock.
                          if avail aaa then aaa.hbal = aaa.hbal - aas.chkamt.
                     end.

                     delete aas.
            end.

            find first aas where aas.aaa = salary_p.acc and aas.ln = integer(salary_p.info[10]) exclusive-lock no-error.
            if avail aas then do:
                  CREATE aas_hist.

                    find first aaa where aaa.aaa = aas.aaa no-lock no-error.
                    IF AVAILABLE aaa THEN DO:
                       FIND FIRST cif WHERE cif.cif= aaa.cif USE-INDEX cif NO-LOCK NO-ERROR.
                       IF AVAILABLE cif THEN DO:
                          aas_hist.cif= cif.cif.
                          aas_hist.name= trim(trim(cif.prefix) + " " + trim(cif.name)).
                        END.
                     END.

                     aas_hist.aaa    = aas.aaa.
                     aas_hist.ln     = aas.ln.
                     aas_hist.sic    = aas.sic.
                     aas_hist.chkdt  = aas.chkdt.
                     aas_hist.chkno  = aas.chkno.
                     aas_hist.chkamt = aas.chkamt.
                     aas_hist.payee  = aas.payee + ' Удалили неверный платеж.'.
                     aas_hist.expdt  = aas.expdt.
                     aas_hist.regdt  = aas.regdt.
                     aas_hist.who    = g-ofc.
                     aas_hist.whn    = g-today.
                     aas_hist.tim    = time.
                     aas_hist.del    = aas.del.
                     aas_hist.chgdat = g-today.
                     aas_hist.chgtime= time.
                     aas_hist.chgoper= 'D'.

                     if aas.sic = 'HB' then do:
                     find first aaa where aaa.aaa = aas.aaa exclusive-lock.
                          if avail aaa then aaa.hbal = aaa.hbal - aas.chkamt.
                     end.

                     delete aas.
            end.
            delete salary_p.
            RELEASE salary_p.

            open query q1 for each salary_p where salary_p.txb = seltxb /*and salary_p.pf_soc = v-sel*/ and salary_p.whn = dat and
              (alldoc or salary_p.who = userid("bank"))  and salary_p.del = ? no-lock by salary_p.nom descending.
            b1:refresh().

          end.
end.

ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(salary_p).
    FOR each salary_p where salary_p.txb = seltxb and salary_p.whn = dat and
        (alldoc or salary_p.who = userid("bank")) no-lock:
        ACCUMULATE salary_p.sum (TOTAL COUNT).
    END.
    totalt=(accum total salary_p.sum).
    MESSAGE "Количество платежей:" (accum count salary_p.sum) skip
        "Hа сумму:" totalt skip
        VIEW-AS ALERT-BOX MESSAGE BUTTONS OK
        TITLE "Зарплатные платежи" .
    find salary_p where rowid(salary_p) = rid.
end.
open query q1 for each salary_p where salary_p.txb = seltxb and salary_p.whn = dat and
    (alldoc or salary_p.who = userid("bank"))  and salary_p.del = ? no-lock by salary_p.nom.
ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
