/* defxarc.p
 * MODULE
        Операционист
 * DESCRIPTION
        выписка по текущим счетам клиентов (открытых и закрытых)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        п.п. 2-4-2, 2-4-7-4
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        12/08/03 nataly для счетов группы 235 брался остаток по депозитному  счету aaa.cracc Эта ошибка была устранена !!!
        19.09.2003 nadejda - исключаем печать Storned/Storno, если у клиента есть такая настройка
        24.06.2006 tsoy    - Если платеж на АРП картела то показывать реквизиты Картела в АТФ банке
        04.08.10 marinav   - история берется из histrxbal
        20/07/2011 lyubov  - перекомпиляция для defxarc.i
        06.03.2012 damir   - перекомпиляция
        17.09.2012 damir   - убрал message "Неверный остаток счета". Т.З. № 1379.
*/

/* ==================================================================
                              defxarc.p                             =
                Statement Generator System by Andrey Popoff         =
                        Default Data Generator                      =
                            with ArcBase                            =
================================================================== */


define input parameter in_cif       like cif.cif. /* Customer's CIF    */
define input parameter in_account   like aaa.aaa. /* Customer's Account*/
define input parameter in_date_from as date.      /* Period Begin      */
define input parameter in_date_to   as date.      /* Period End        */
define input parameter in_stmsts    as character. /* Statement Status  */
def var arc_debit as decimal.
def var arc_credit as decimal.

/* Temporary Tables Structure Defining --------------------------------- */


{header-t.i "shared" }
{deals.i    "shared" }
{stlist.i   "shared" }

/* --------------------------------------------------------------------- */

{stlib.i}

/* --------------------------------------------------------------------- */

define shared variable g-comp AS character.
define shared variable g-today as date.
define shared variable g-batch as logical.
define shared variable g-ofc   like ofc.ofc.

define variable tmp_amt as decimal.
define variable t-amt        as decimal.
define variable ot-amt  as decimal.
define variable obal    as decimal.
define variable cbal    as decimal.
define variable crline  as decimal.
define variable tcbal   as decimal.
define variable abal    as decimal.
define variable tocbal  as decimal.
define variable oabal   as decimal.
define variable avlbal  as decimal.
define variable hlam         as decimal.
define variable hlamc   as character.
define variable t-lox   as integer.
define variable ac      as integer.
/* define variable aa          as decimal.
define variable bb          as decimal. */
define variable cc         as decimal.
define variable dd          as decimal.
define variable ee         as decimal.
define variable v-kurss like crc.rate[1].
define variable v-koef  like crc.rate[9].
define variable rate_date   as date.
define variable rate_crc    like crc.crc.
define variable oseq           as decimal.
define variable ostmsts    as character.
def var v-nostorno as logical.

ostmsts = in_stmsts.

define buffer oaaa for aaa.
define buffer oaab for aab.
define buffer d-prostm for prostm.

/* -------------------- Header's Data Creating ------------------------- */

find first cmp no-lock .

run setv("h-bankname",cmp.name, ?, ?).
run setv("h-bankaddr", (trim(cmp.addr[1]) + " " + trim(cmp.addr[2]) + " " +  trim(cmp.addr[3])), ?, ?).
run setv("h-bankreg","" ,? ,? ).

find first cif where cif.cif = in_cif no-lock no-error.

 if not available cif then do:
    run elog("DEFEX","ERR", "Not found CIF: " + in_cif + ". Terminated.").
    if not g-batch then message
    "Генератор " program-name(1) skip
    "не может найти клиента по коду " in_cif
    view-as alert-box title "Ошибка генератора" .
    return "1".
 end.

/* 19.09.2003 nadejda - найти установку у клиента - сторно печатать/нет */
find first sub-cod where sub-cod.sub = "vip" and sub-cod.d-cod = "clnprn" and sub-cod.acc = cif.cif no-lock no-error.
v-nostorno = (avail sub-cod and sub-cod.ccode = "10").
/***************/

run setv("h-cif", cif.cif, ?, ?).
run setv("h-custaddr", (trim(cif.addr[1]) + " " + trim(cif.addr[2]) + " " +  trim(cif.addr[3])), ?, ?).
run setv("h-custboss", "", ?, ?).
run setv("h-custname", trim(trim(cif.prefix) + ' ' + trim(cif.name)), ?, ?).
run setv("hcustreg",  cif.jss, ?, ?).

run setv("h-phone", "", ?, ?).
run setv("h-repname", "", ?, ?).
run setv("h-repnr", "", ?, ?).
run setv("h-whn", ?, ?, g-today).
run setv("h-time", ?, time, ?).
run setv("h-who", g-ofc, ?, ?).

/*----------- Footer's Data Creating -------------------------- */

run setv("e-sign", "", ?, ?).
run setv("ftitle", "", ?, ?).

/* .......... Active Accounts List Creating .................. */

if in_account <> "" and in_account <> ? then do:
 find first aaa where aaa.aaa = in_account no-lock no-error.
 if not available aaa then do:
     find first lon where lon.lon eq in_account no-lock no-error.
     if not available lon then do:
     run elog("DEFXARC","ERR", "Not found Account: "
     + in_account + ". Terminated.").
     if not g-batch then message
     "Генератор " program-name(1) skip
     "не может найти счет # " in_account
     view-as alert-box title "ОШИБКА ГЕНЕРАТОРА".
     return "1".
     end.   /* not avail lon */
     else do:
     run delnarc(input in_cif, input in_account,
     input in_date_from, input in_date_to, input in_stmsts).
     return return-value.
       /*if return-value eq "1" then do:
       if not g-batch then message
       "Ошибка генератора для ссудных счетов"
       view-as alert-box title "ОШИБКА ГЕНЕРАТОРА ДЛЯ ССУДНЫХ СЧЕТОВ".
       run elog("DEFXARC","ERR", "LOAN Generator Error: "
       + in_account + ". Terminated.").
       return "1".
       end.*/
     end.
 end.  /* not avail aaa */



 /* -- Status & Sequence Checking -- */

 run stschek(in_cif, aaa.aaa, in_date_from, in_date_to,
 input-output ostmsts, output oseq).
 if return-value = "1" then do:
 if not g-batch then message
 "Генератор " program-name(1) "получил ошибку проверки статуса" skip
 in_cif skip
 aaa.aaa skip
 in_date_from skip
 in_date_to skip
 view-as alert-box title "Ошибка в программе проверки статуса".
 run elog("STCHECK","ERR", "Statement status Checking for :"
 + aaa.aaa + " not completed. Terminated.").
 return "1".
 end.

        /* -------------------------------- */

        do transaction:
        create acc_list.
          acc_list.aaa = aaa.aaa.
          acc_list.d_from = in_date_from.
          acc_list.d_to   = in_date_to.
          acc_list.crc = aaa.crc.
          acc_list.lgr = aaa.lgr.
          acc_list.hbal = aaa.hbal.
      /*nataly 12/08/03*/
          if aaa.lgr <> "235" then
            acc_list.craccnt = aaa.craccnt.
          else   acc_list.craccnt = "".
        /*  acc_list.craccnt = aaa.craccnt.*/
          acc_list.stmsts = ostmsts.
          acc_list.seq = oseq.

        end.
     end.
     else do:
       for each stml.
          /* -- Status & Sequence Checking -- */

          find first aaa where aaa.aaa = stml.aaa no-lock no-error.
            if not available aaa then do:
              if not g-batch then message
              "Генератор " program-name(1) skip
              "не может найти счет клиента # " stml.aaa
              view-as alert-box title "ОШИБКА ГЕНЕРАТОРА".
              run elog("DEFEX","ERR", "Not found Account: " + in_account + ". Terminated.").
              return "1".
            end.

         do transaction:

          create acc_list.
           acc_list.aaa = aaa.aaa.
           acc_list.d_from = stml.d_from.
           acc_list.d_to   = stml.d_to.
           acc_list.crc = aaa.crc.
           acc_list.lgr = aaa.lgr.
           acc_list.hbal = aaa.hbal.
           acc_list.craccnt = aaa.craccnt.
           acc_list.stmsts = stml.sts.
           acc_list.seq = stml.seq.

          end.

       end.
     end.

/* ================================================================ */
{defxarc.i}   /* BaseList work-file creating */

for each acc_list break by acc_list.crc:

    find lgr where lgr.lgr = acc_list.lgr no-lock.
    find led where led.led = lgr.led no-lock.

    t-amt = 0.
    t-lox = 0.
    ac = acc_list.crc.
    cc = 0.
    dd = acc_list.credit - acc_list.debit.
    ee = 0.

/* -------- Working Database PROSTM TRX Till Today ----------- */
/* `````` Today Short Transaction ```````` */

    if acc_list.d_to = g-today  then do:  /* Today's Cash Operations */
       for each aal where aal.aaa = acc_list.aaa and
                          aal.regdt = acc_list.d_to and
                          (aal.jh = ? or aal.jh = 0) no-lock:

        if aal.rem[1] begins "O/D PROTECT" or
           aal.rem[1] begins "O/D PAYMENT" then next.

         find aax where aax.lgr = acc_list.lgr and aax.ln = aal.aax no-lock.

         run add_deal(recid(aal), aal.aaa, aal.regdt,
         (aal.amt * aax.drcr ), aal.crc, string(aal.aah), "st",                integer(recid(aax)) ).
         accumulate aal.amt * aax.drcr (total).

               if aax.drcr > 0 then do:
                 cc = cc - aal.amt.
                 acc_list.debit = acc_list.debit + aal.amt.
               end.
               else do:
                 cc = cc + aal.amt.
                 acc_list.credit = acc_list.credit + aal.amt.
               end.
            end.
          end.


 /* >>>>>>>>>>>> Actual Base Long Transaction >>>>>>>>>>>>>>>>>> */
 for each jl where jl.acc eq acc_list.aaa
             and jl.jdt ge max(start_dt,acc_list.d_from)
             and jl.jdt le acc_list.d_to no-lock:

 if jl.rem[1] begins "O/D PROTECT" or
    jl.rem[1] begins "O/D PAYMENT" then next.

  /* 19.09.2003 nadejda - сторно не печатаем совсем, если у клиента есть установка */
  if v-nostorno then do:
    find jh where jh.jh = jl.jh no-lock no-error.
    if jh.party begins "Storn" then next.
  end.
  /****************/

  find first gl where gl.gl = jl.gl no-lock no-error.
  if gl.subled = "CIF" and gl.level eq 1 then do:
      run add_deal(recid(jl),jl.acc,jl.jdt,?,jl.crc,string(jl.jh),"lt", ?).
      accumulate jl.dam (total) jl.cam (total).
      acc_list.debit = acc_list.debit + jl.dam.
      acc_list.credit = acc_list.credit + jl.cam.
  end.

end. /* --- for each jl --- */

/* --- Turnover registration --- */
run add_deal(?,acc_list.aaa,acc_list.d_to,acc_list.debit, acc_list.crc,?,"ldt",?).
run add_deal(?,acc_list.aaa,acc_list.d_to,acc_list.credit,acc_list.crc,?,"lct",?).


/* ^^^^^^^^^^^^^^^^^^^^^^ Currency Rates ^^^^^^^^^^^^^^^^^^^^^^^^^ */
/*
if first-of (acc_list.crc)  then do:
rate_date = acc_list.d_to.
rate_crc =  acc_list.crc.
make_rate.i}         /* Currency Rates History Exploring ... */
run add_deal( ?, ?, acc_list.d_to, v-kurss, acc_list.crc, ?, "crr", v-koef).
end.
*/
/* ===================== Holds Calculation ======================= */

 acc_list.hbal = 0.
 find first aas_hist where aas_hist.aaa = acc_list.aaa and
                           aas_hist.chgdat <= acc_list.d_to
                           /*use-index sq_idx*/ no-lock no-error.
     if available aas_hist then do:

     define buffer tass for aas_hist.
     define buffer dass for aas_hist.

       for each aas_hist where aas_hist.aaa = acc_list.aaa and
                               aas_hist.chgoper = "A"  and
                               aas_hist.sic     = "HB" and
                               aas_hist.chgdat <= acc_list.d_to
                               /*use-index sq_idx*/ no-lock by aas_hist.ln:

       find last tass where tass.aaa = acc_list.aaa and
                            tass.ln  = aas_hist.ln and
                            tass.chgdat <= acc_list.d_to and
                            (tass.chgoper = "A" or tass.chgoper = "E" )
                            /*use-index sq_idx*/ no-lock no-error.

         if available tass then do:

         find last dass where dass.aaa = acc_list.aaa and
                              dass.ln  = aas_hist.ln and
                              dass.chgdat <= acc_list.d_to and
                              dass.chgoper = "D"
                              /*use-index sq_idx*/
                              no-lock no-error.

            if not available dass then do:
            /* run add_deal( recid(tass), acc_list.aaa, acc_list.d_to, tass.
            chkamt, acc_list.crc, ?, "hbi", ? ). */
            acc_list.hbal = acc_list.hbal + tass.chkamt.
            end.

          end.  /* available tass */
       end.    /* for each aas_hist */
  end.        /* if available aas_hist  */


/* ------- Balances / Hold / Credit Line Processing -------------- */

find oaaa where oaaa.aaa = acc_list.craccnt no-lock no-error.

   if acc_list.craccnt <> "" and not available oaaa then do:
   if not g-batch then message
   "Генератор " program-name(1) skip
   "не может найти овердрафтный счет " acc_list.craccnt "для счета "
    acc_list.aaa
   view-as alert-box title "ОШИБКА ГЕНЕРАТОРА".
   run elog("DEFEX","ERR","Can Not find Overdraft Contro Account " + acc_list.craccnt).
   return "1".
   end.

   find last histrxbal where histrxbal.sub = 'cif' and histrxbal.acc = acc_list.aaa and histrxbal.lev = 1 and histrxbal.dt < acc_list.d_from
   no-lock no-error.
   if not available histrxbal then t-amt = 0. else t-amt = histrxbal.cam - histrxbal.dam.

   find last histrxbal where histrxbal.sub = 'cif' and histrxbal.acc = acc_list.craccnt and histrxbal.dt < acc_list.d_from
   no-lock no-error.
   if not available histrxbal then ot-amt = 0. else ot-amt = histrxbal.cam - histrxbal.dam.

   dd = acc_list.credit - acc_list.debit.

   obal = t-amt + ot-amt.    /* ===== Opening Balance ===== */
   cbal = obal + cc + dd.    /* ===== Closing Balance ===== */


  if  acc_list.d_to <> g-today then do:   /* --- g-today --- */

  find last aab where aab.aaa = acc_list.aaa and aab.fdt <= acc_list.d_to
  no-lock no-error.
  if not available aab then do: tcbal = 0. abal  = 0. end.
                       else do: tcbal = aab.bal. abal  = aab.avl. end.

  find last oaab where oaab.aaa = acc_list.craccnt and oaab.fdt <= acc_list.d_to
  no-lock no-error.
  if not available oaab then do: tocbal = 0. oabal  = 0. end.
                        else do: tocbal = oaab.bal. oabal  = oaab.avl. end.

  /*if available aab and available oaab and aab.fdt = acc_list.d_to
  and (tcbal + tocbal) <> cbal then do: */
  if (tcbal + tocbal) <> cbal then do:

  run elog("DEFEX","ERR","-----------------------------------------------").
  run elog("DEFEX","ERR","-----------------------------------------------").
  run elog("DEFEX","ERR", "CLOSING BALANCES MISMATCH FOR " + acc_list.aaa
                       + " and " + string(acc_list.d_to)).
  run elog("DEFEX","ERR","tcbal - tocbal =" + string(tcbal + tocbal)
                       + " cbal = " + string(cbal) + "------").
  run elog("DEFEX","ERR","-----------------------------------------------").
  run elog("DEFEX","ERR","-----------------------------------------------").
  /*if not g-batch then
  message "Остаток на счету по выписке:       " cbal skip
          "Остаток на счету по истории счета: " tcbal + tocbal
          view-as alert-box title "Неверный остаток счета".*/
  /* return "1". */
  end.

   avlbal = abal + oabal - acc_list.hbal.

   end.
   else run aaa-bal777 (acc_list.aaa, output cbal, output avlbal,
                        output hlam, output hlam, output crline,
                        output hlam, output hlamc).
   cbal = cbal - crline.


run add_deal(?,acc_list.aaa,acc_list.d_from,obal,acc_list.crc,?,"ob",?).
run add_deal(?,acc_list.aaa,acc_list.d_to,  cbal,acc_list.crc,?,"cb",?).
run add_deal(?,acc_list.aaa,acc_list.d_to,avlbal,acc_list.crc,?,"ab",?).
end.
