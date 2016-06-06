﻿/* dewidell.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        14.12.09 marinav - добавлена информация для клиентов
        11.06.10 marinav - изменена информация для клиентов
        14.09.10 marinav - изменена информация для клиентов
        28.09.10 marinav - изменена информация для клиентов
        06.03.2012 id00477 - изменил дату введения в действие ИН с 01 января 2012 года на 1 января 2013 года.
*/

 /* ==============================================================
=                        DEWIDE.P                                =
=              Default Statement Formatter                        =
=             Statement Generator System                         =
=                LAST MODIFIED: 29/12/1998                         =
============================================================== */
define input parameter destination as character.
define shared var g-lang as char.

/* Temporary Tables Structure Defining --------------------------------- */

{header-t.i "shared" }
{deals.i    "shared" }

define variable crccode as character.

define variable v-kurs as decimal.                  /* --- Currency Kurs     */
define variable v-koef as integer.                  /* --- Currency Quantity */
define variable lines as integer initial 0.         /* --- Lines in deal          */

define variable d_t as decimal initial 0.
define variable c_t as decimal initial 0.

define variable ordins         as character extent 4.
define variable ordcust  as character extent 4.
define variable ordacc         as character.
define variable benfsr   as character extent 4.
define variable benbank  as character extent 4.
define variable benacc   as character .
define variable dealsdet as character extent 4.
define variable bankinfo as character extent 4.

/* --------------------------------------------------------------------- */

{stlibll.i}
{r-htrx2.f}

/* --------------------------------------------------------------------- */

define shared variable g-comp AS character.
define shared variable g-today as date.
define shared variable g-batch as logical.
define shared variable g-ofc   like ofc.ofc.

define variable strbal as character initial "Промежуточный остаток".
define variable sakbal as character initial
"Входящий остаток по осн. долгу".
define variable dpre   as logical.


new_page = yes.
frmt = "x(" + string(cols) + ")".

/**** 02.2000
for each acc_list :
   find first deals where deals.account = acc_list.aaa and
                         ( deals.servcode = "lt" or deals.servcode = "st" ) and
                           deals.d_date >= acc_list.d_from and
                           deals.d_date <= acc_list.d_to
                           no-error .
   if not avail deals then do:
    /* message "nav" acc_list.aaa. pause 5. */
    delete acc_list.
    next.
   end.
end.

find first acc_list no-error.
if not avail acc_list then do: message " Оборотов нет ". pause 10. end.

****/


/* ----- Destination Processing --------------------------------------- */

if destination = ? or destination = "" then destination = "rpt.img".

output to value (destination) page-size 0.

for each acc_list break by acc_list.crc by acc_list.aaa .

{stmeuro.i}

    new_acc = yes.
    t1 = fa3.

    if first-of (acc_list.crc) then do:
     find first crc where crc.crc = acc_list.crc no-lock no-error.
      if crc.code = "Ls" then crccode = "LVL".
                         else crccode = crc.code.
      tcrc = crccode.
    end.

    /* -- Account Header Position Checking -- */

    lines = 30.  /* Minimum row for account output */
    if row_in_page + lines >= rows then do:
          new_page = no.
          do while new_page = no : run pwskip(0). end.
    end.

    page_num = 1.

    /* --- Statement Header Generation --- */

    {defhwidel.i}
/**** 02.2000
    def var v-preddat as date.
    v-preddat=?.
    for each jl where jl.acc=acc_list.aaa no-lock :
     if v-preddat eq ? then do :
        if jl.jdt lt acc_list.d_from then  v-preddat = jl.jdt.
     end.
     else if jl.jdt lt acc_list.d_from and v-preddat lt jl.jdt then
                                           v-preddat = jl.jdt.
    end.
    if v-preddat ne ? then
    put skip space(21) "ДАТА ПОСЛЕДНЕЙ РАБОТЫ СЧЕТА ДО НАЧАЛА ПЕРИОДА: "
                   v-preddat format "99/99/9999" skip.
****/

    /* --- Account Header --- */

        put "Кредитная линия " + acc_list.aaa + " " + crccode at 1 +
        margin format "x(40)" .

        new_acc = no.
        run pwskip(0).

            /* .. Opening Balance .. */

        find first deals where deals.account = acc_list.aaa and
                               deals.servcode = "ob"        and
                               deals.d_date = acc_list.d_from no-error.

         if available deals then intermbal = deals.amount.
                            else intermbal = 0.

    /* ---- Transaction Processing --- */

      for each deals where deals.account = acc_list.aaa and
                         ( deals.servcode = "lt" or deals.servcode = "st" ) and
                           deals.d_date >= acc_list.d_from and
                           deals.d_date <= acc_list.d_to
                            break by deals.account by deals.d_date
                            by integer(deals.trxtrn) .

        dpre = yes.

      if new_page = yes or first-of(deals.account)  then do:

               /* ---- Deals List Header */

        {acchwidel.i}

        if first-of(deals.account) then do:
           put sakbal format "x(30)" at 11 + margin.

            if intermbal < 0 then do:
                put absolute(intermbal)
                format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            end.
            else do:
                put intermbal format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
            end.

            run pwskip(0).

            put fill ("-",cols) at 1 + margin format frmt. run pwskip(0).
        end.
        else do:
            /*
            put strbal format "x(25)" at 11 + margin.

            if intermbal < 0 then do:
                put absolute(intermbal)
                format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            end.
            else do:
                put intermbal format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
            end.

            run pwskip(0).
            */
        end.
            new_page = no.
        if deals.d_date ne acc_list.d_from then do:
            {dewcrc.i acc_list.d_from}
        end.
      end. /* ... new page ... new account ... */
      if first-of(deals.d_date) then do:
            {dewcrc.i deals.d_date}
      end.

     /* ............................................................. */


     /* String Quantity Calculation */

       lines = 2. /* --- TRN & Amount --- */

       /* --- Deals Details */
        {declear.i}

       if deals.dc = "c" then do:

        ordins[1] = substring(deals.ordins,1,70).
        if ordins[1] <> "" then lines = lines + 1.
         ordins[2] = substring(deals.ordins,71,70).
         if ordins[2] <> "" then lines = lines + 1.

         ordcust[1] = substring(deals.ordcust,1,70).
         if ordcust[1] <> "" then lines = lines + 1.
         ordcust[2] = substring(deals.ordcust,71,70).
         if ordcust[2] <> "" then lines = lines + 1.

         ordacc = substring(deals.ordacc, 1, 35).
         if ordacc <> ? then lines = lines + 1.

       end.

       else do: /* --- deals.dc = "d" --- */

        benbank[1] = substring(deals.benbank,1,70).
        if benbank[1] <> "" then lines = lines + 1.
         benbank[2] = substring(deals.benbank,71,70).
         if benbank[2] <> "" then lines = lines + 1.

        benacc  = substring(deals.benacc,1,35).
        if benacc <> "" then lines = lines + 1.

        benfsr[1] = substring(deals.benfsr,1,70).
         if benfsr[1] <> "" then lines = lines + 1.
         benfsr[2] = substring(deals.benfsr,71,70).
         if benfsr[2] <> "" then lines = lines + 1.

       end.

       if deals.trxcode begins "COM" then do:
         find first codfr where codfr.codfr = v-codfr and codfr.code = deals.trxcode no-lock no-error.
         if not available codfr then do:
            dealsdet[1] = "Комиссия.".
            dealsdet[2] = "".
            dealsdet[3] = "".
            dealsdet[4] = "".
         end.
         else do:
            dealsdet[1] = codfr.name[1].
            dealsdet[2] = "".
            dealsdet[3] = "".
            dealsdet[4] = "".
         end.
         if dealsdet[1] <> "" then lines = lines + 1.
       end.
       else do:
         dealsdet[1] = substring(deals.dealsdet,1,70).
         if dealsdet[1] <> "" then lines = lines + 1.
         dealsdet[2] =  substring(deals.dealsdet,71,70).
         if dealsdet[2] <> "" then lines = lines + 1.


         bankinfo[1] = substring(deals.bankinfo,1,70).
         if bankinfo[1] <> "" then lines = lines + 1.
         bankinfo[2] =  substring(deals.bankinfo,71,70).
         if bankinfo[2] <> "" then lines = lines + 1.

       end.


 if row_in_page + lines >= rows then do:    /* =========== New Page Processing ============= */

    do while new_page = no :
       run pwskip(0).
    end.

    /* ---- Deals List Header ---- */

    {acchwidel.i}
    /*
    put strbal format "x(25)" at 11 + margin.

        if intermbal < 0 then
             put absolute(intermbal) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
        else
             put intermbal format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.

    run pwskip(1).
    */
    /* put fill ("-",cols) format frmt. run pwskip(0). */

    new_page = no.

 end. /* ... row_in_page + lines >= rows ... */

     /* ........................... */


        put deals.d_date at 1 + margin.

        put deals.trxtrn format "x(10)" at 11 + margin.
        put deals.custtrn format "x(18)" at 22 + margin.


        if deals.dc = "d"  then do:
              put deals.amount format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
              intermbal = intermbal - deals.amount.
           end.
        else do:
              put deals.amount format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
              intermbal = intermbal + deals.amount.
           end.

        run pwskip(0).

        put upper(deals.trxcode) to 10  + margin format "x(5)".

        if deals.dealtrn <> "" then
        put unformatted deals.dealtrn  at 11 + margin.

        run pwskip(0).

        /* --- Ordering Customer --- */

       if deals.dc = "c" then do:

        if ordins[1] <> "" then do: put ">" at 9 + margin ordins[1] format "x(70)" at 11 + margin. run pwskip(0). end.
        if ordins[2] <> "" then do: put ordins[2] format "x(70)" at 11 + margin. run pwskip(0). end.

         if ordcust[1] <> "" then do: put ">" at 9 + margin ordcust[1] format "x(70)" at 11 + margin. run pwskip(0). end.
        if ordcust[2] <> "" then do: put ordcust[2] format "x(70)" at 11 + margin. run pwskip(0). end.

        if ordacc <> "" then do: put ">" at 9 + margin ordacc format "x(70)" at 11 + margin. run pwskip(0). end.

       end.

        /* --- Beneficiar --- */

       else do: /* --- if deals.dc = "d" --- */

        if benbank[1] <> "" then do: put ">" at 9 + margin benbank[1] format "x(70)" at 11 + margin. run pwskip(0). end.
        if benbank[2] <> "" then do: put benbank[2] format "x(70)" at 11 + margin. run pwskip(0). end.

         if benfsr[1] <> "" then do: put ">" at 9 + margin benfsr[1] format "x(70)" at 11 + margin. run pwskip(0). end.
         if benfsr[2] <> "" then do: put benfsr[2] format "x(70)" at 11 + margin. run pwskip(0). end.

        if benacc <> "" then do: put ">" at 9 + margin benacc format "x(70)" at 11 + margin. run pwskip(0). end.

       end.

        /* --- Deals Details --- */

        if dealsdet[1] <> "" then do: put ">" at 9 + margin dealsdet[1] format "x(70)" at 11 + margin. run pwskip(0). end.
        if dealsdet[2] <> "" then do: put dealsdet[2] format "x(70)" at 11 + margin. run pwskip(0). end.

        /* --- Bank Information --- */

        if bankinfo[1] <> "" then do: put ">" at 9 + margin bankinfo[1] format "x(70)" at 11 + margin. run pwskip(0). end.
        if bankinfo[2] <> "" then do: put bankinfo[2] format "x(70)" at 11 + margin. run pwskip(0). end.

     /* ......................................................................... */

       /* ---- TRX_CODE Table Update ---- */

          find first trx_codes where trx_codes.code = deals.trxcode no-error.
          if not available trx_codes then do:
             find first codfr where codfr.codfr = v-codfr and
                                    codfr.code = deals.trxcode no-lock no-error.
               if available codfr then do:
                  create trx_codes.
                  trx_codes.code = deals.trxcode.
                  trx_codes.name = codfr.name[1].
               end.
          end.
       /* --------------------------------- */

            if last-of(deals.account) then do:
                {dewcrc.i acc_list.d_to}
            end.

      end.  /* for each deals ... */

     /* ---- Turnover Processing ---------------------------------------------------- */

      d_t = 0.
      c_t = 0.

      find first deals where deals.account = acc_list.aaa and
                             deals.servcode = "ldt" and
                             deals.d_date = acc_list.d_to no-error.
      if available deals then d_t = deals.amount.

      find first deals where deals.account = acc_list.aaa and
                             deals.servcode = "lct"       and
                             deals.d_date = acc_list.d_to no-error.
      if available deals then c_t = deals.amount.

      if c_t <> 0 and d_t <> 0 then lines =  9.
        else lines = 13.

      if row_in_page + lines >= rows then do:
          do while new_page = no :
             run pwskip(0).
          end.
      end.

  if c_t <> 0 or d_t <> 0  then do:

    run pwskip(0).

    put fill ("-",cols) at 1 + margin format frmt . run pwskip(0).

    put "Итого" at 1 + margin.

   /* .. Debit Turnover .. */

      if d_t <> 0 then
          put d_t format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
      else
          put 0   format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.

   /* .. Credit Turnover .. */

      if c_t <> 0 then do:
         put c_t format "z,zzz,zzz,zzz,zz9.99" at 100 + margin. run pwskip(1).
      end.
      else do:
         put 0 format "z,zzz,zzz,zzz,zz9.99" at 100 + margin. run pwskip(1).
      end.

   end. /* Turnover ... */

   /* ======================== Balances Output ======================================= */

   balance_mode = yes.

   if dpre = no then do:

      put fill("-",120) at 1 + margin format "x(120)". run pwskip(0).
      put "ДЕБЕТ" to 99 + margin.
      put "КРЕДИТ" to 119 + margin.
      run pwskip(0).
      put fill("-",120) at 1 + margin format "x(120)". run pwskip(0).

      find first deals where deals.account = acc_list.aaa and
                             deals.servcode = "ob"        and
                             deals.d_date = acc_list.d_from no-error.
      if available deals then do:
         {dewcrc.i acc_list.d_from}
         if deals.amount < 0 then
             put "Входящий остаток" at 1 + margin absolute(deals.amount) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
         else
             put "Входящий остаток" at 1 + margin deals.amount format "z,zzz,zzz,zzz,zz9.99" at 100 + margin .
         run pwskip(0).
      end.

   end.

   /* .. Closing Balance .. */

   find first deals where deals.account = acc_list.aaa and
                          deals.servcode = "cb"        and
                          deals.d_date = acc_list.d_to no-error.
      if available deals then do:
         if dpre = no then do:
            {dewcrc.i acc_list.d_to}
         end.
         if deals.amount < 0 then do:
             put "Исходящий остаток по осн. долгу" at 1 + margin
             absolute(deals.amount)
             format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
             {stmeuro1.i "absolute(deals.amount)" "76"}
         end.
         else do:
             put "Исходящий остаток по осн. долгу" at 1 + margin
             deals.amount
             format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
             {stmeuro1.i "deals.amount" "96"}
         end.
         run pwskip(0).
      end.

   /* .. Available Balance */

   find first deals where deals.account = acc_list.aaa and
                          deals.servcode = "ab"        and
                          deals.d_date = acc_list.d_to  no-error.
      if available deals then do:
         if deals.amount < 0 then do:
             put "Долг по %% на " at 1 + margin string(deals.d_date)
             absolute(deals.amount)
             format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
             {stmeuro1.i "absolute(deals.amount)" "76"}
         end.
         else do:
             put "Долг по %% на " at 1 + margin string(deals.d_date)
             deals.amount
             format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
             {stmeuro1.i "deals.amount" "96"}
         end.
         /* if acc_list.hbal = 0 then new_acc = yes. */

         new_acc = yes.

         run pwskip(0).
      end.

/*
   /* .. Hold Balances .. */
   if acc_list.hbal <> 0 then
   for each deals where deals.account = acc_list.aaa and deals.servcode = "hbi" break by deals.account.
       put deals.dealsdet format "x(11)"  deals.amount . run pwskip(0).
       put "           " deals.in_value " " deals.d_date " ".
       put deals.ordcust  format "x(30)" "  /  Izpld:".
       put deals.who      format "x(30)".
       if last-of ( deals.account ) then new_acc = yes.
       run pwskip(0).
   end.
*/

run pwskip(5).

/* --- Statement footer Output --- */

put "=========================================== КОНЕЦ ДОКУМЕНТА ==========================================================" at 1 + margin.
run pwskip(1).

balance_mode = no.

/* --- History Registration --- */

define variable r-cif like cif.cif.

run getcv("h-cif",output r-cif).

run hwr(r-cif, acc_list.aaa, acc_list.seq, acc_list.stmsts, acc_list.d_from, acc_list.d_to, "dewide" ).

if return-value = "1" then do:
   run elog("HISTWR","ERR", "History Writer execution not completed.Terminated.").
   return "1".
end.

dpre = no.
end. /* Account List ... */

put skip(1).

/* -------- Codes List Generation ----------------------- */
{codeslist.i}
/********* Информация*/


        put "    Уважаемые клиенты! " skip.
        put "        Примите, пожалуйста, к сведению, что в соответствии с Законом Республики Казахстан 'О внесении " skip.
        put "    изменений в некоторые законодательные акты Республики Казахстан по вопросам идентификационных   " skip.
        put "    номеров' изменена дата введения в действие идентификационных номеров (ИН) с 01 января 2012 года на" skip.
        put "    1 января 2013 года. Начиная с этой даты Банк будет не вправе осуществлять операции по открытию и ведению" skip.
        put "    банковских счетов юридических лиц, не имеющих Бизнес-идентификационного номера (далее - БИН), и " skip.
        put "    физических лиц, не имеющих Индивидуального идентификационного номера (далее - ИИН), а также проводить " skip.
        put "    платежи и переводы денег указанных лиц.  " skip.
        put "        Обратите внимание на то, что у большинства граждан Республики Казахстан в удостоверениях личности " skip.
        put "    уже имеется ИИН, так как данный номер впечатывается в удостоверение личности с августа 1997 года. " skip.
        put "        Юридическим лицам рекомендуем заранее провести работу со своими партнерами по внесению " skip.
        put "    соответствующих изменений в действующие договоры, во избежание каких-либо недоразумений при " skip.
        put "    проведении платежей и перевода средств через Банк. " skip.
        put "        Просим Вас переоформить (при необходимости) ранее выданные документы на документы с БИН/ИИН и " skip.
        put "    предоставить их в Банк в срок до 1 января 2013 года." skip.
        put "    " skip.


/*********/
/* ------------------------------------------------------ */
output close.
/* ------------------------------------------------------ */