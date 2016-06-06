/* kcmr-fr.p
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
        11.05.2004 nadejda - показывать платежи ТОЛЬКО сегодняшней даты опердня
        01.09.2004 dpuchkov - ограничение по менеджеру.
        08.09.2004 dpuchkov - запись удачных попыток
        21.04.2005 kanat - проверка на очереди DIRIN - очереди входящих платежей для ПКО
        22.04.2005 kanat - убрал проверки на вводимый счет чтобы юзера могли видеть все платежи
        29.07.2005 kanat - убрал проверку на счет для платежей ПКО
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/

/* KOVAL - Ведомость прогнозных платежей */
/* 17.03.2003 SASCO - Сверка наименования получателя */

{d-2-u.i} /* Транслятор DOS - Unix */
{name-compare.i}

/* def shared var g-today as date. */

{global.i}
def stream s-file.

def frame  a-show with row 4 centered overlay no-labels title '[ Ждите ]'.

def var v-file as char no-undo init ''.
def var cl     as char no-undo.
def var ds     as dec  decimals 2 no-undo format '>>>,>>>,>>>,>>9.99'.
def var dss    as dec  decimals 2 no-undo format '>>>,>>>,>>>,>>9.99'.
def var c1     as char no-undo format 'x(08)'.
def var c2     as char no-undo format 'x(25)'.
def var c3     as char no-undo format 'x(09)'.
def var c4     as char no-undo format 'x(09)'.
def var c5     as char no-undo format 'x(09)'.
def var c6     as char no-undo format 'x(09)'.
def var c7     as char no-undo format 'x(08)'.
def var c8     as char no-undo format 'x(25)'.
def var c9     as char no-undo format 'x(09)'.
def var c10    as char no-undo format 'x(09)'.
def var c11    as char no-undo format 'x(09)'.
def var c12    as char no-undo format 'x(09)'.
def var c13    as char no-undo format 'x(09)'.
def var c14    as char no-undo format 'x(1)'.
def var c15    as char no-undo.
def var accnt  as integer no-undo format '999999999'.
def var faccnt as integer no-undo format '999999999'.
def var i      as integer no-undo.
def var ourbank as char no-undo format 'x(09)'.

def var v-bad-name as logical no-undo.
def var v-bad-pref as logical no-undo.
def var v-s1 as char NO-UNDO.
def var v-s2 as char NO-UNDO.
def var gv-s1 as char NO-UNDO init "".
def var tmpi as int NO-UNDO.
def var rnnind as int NO-UNDO.
def var tmpd as decimal NO-UNDO.

find sysc where sysc.sysc = "CLECOD" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " This isn't record CLECOD in sysc file !!".
    pause.
    return.
end.
ourbank = trim(sysc.chval).

find first sysc where sysc.sysc = "150fle" no-lock no-error.
if avail sysc then v-file = trim(sysc.chval). 
              else v-file = "/data/import/150.txt".

    update accnt label "Укажите счет" with frame aa.
    hide frame aa.


    find last aaa where aaa.aaa = string(integer(accnt), "999999999") no-lock no-error.
    if avail aaa then 

        find cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
         find last cifsec where cifsec.cif = cif.cif no-lock no-error.
         if avail cifsec then
         do:
            find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
            if not avail cifsec then
            do:
               message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
               create ciflog.
               assign
                 ciflog.ofc = g-ofc
                 ciflog.jdt = today
                 ciflog.cif = cif.cif
                 ciflog.sectime = time
                 ciflog.menu = "1.10 Прогнозные платежи (КЦМР)".
                 return.
            end.
            else
            do:
              create ciflogu.
              assign
                 ciflogu.ofc = g-ofc
                 ciflogu.jdt = today
                 ciflogu.sectime = time
                 ciflogu.cif = cif.cif
                 ciflogu.menu = "1.10 Прогнозные платежи (КЦМР)" .
             end.
         end.
     end.







    display "Идет обработка данных..." skip with frame a-show.

    output to rpt.img.
     put unformatted space(15) "Ведомость прогнозных платежей по счету " string(accnt,"999999999") skip
     "Сформирована " string(today,"99.99.99") "г. в " string(time,"HH:MM:SS")  skip (1)
     fill("-", 80) format "x(80)" skip.
     
    i = 0. dss = 0.
    input stream s-file from value( v-file ) no-echo.
    repeat:
    
       import stream s-file unformatted cl.
       cl  = d-2-u(  cl ).
       c1  = substr( cl, 01, 08 ). /* Дата       */
       c2  = substr( cl, 10, 25 ). /* Референс   */
       c3  = substr( cl, 36, 09 ). /* Банк отпр. */
       c4  = substr( cl, 46, 09 ). /* Счет отпр. */
       c5  = substr( cl, 56, 09 ). /* Банк получ */
       c6  = substr( cl, 66, 09 ). /* Счет получ */
       c7  = substr( cl, 76, 16 ). /* Сумма      */
       c8  = substr( cl, 93, 08 ). /* Плат.сис.  */
       c9  = substr( cl,102, 06 ). /* Дата вал.пл*/
       c10 = substr( cl,109, 12 ). /* Рнн отпр.  */
       c11 = substr( cl,122, 12 ). /* Рнн получ. */
       c12 = substr( cl,135, 80 ). /* Отправитель*/
       c13 = substr( cl,216, 80 ). /* Получатель */
       c14 = substr( cl,297, 01 ). /* Final ? 0/1*/
       c15 = substr( cl,299, length(cl) - 298 ). /* Назначение */

       faccnt = integer( c6 ).

       /* Этого нам и не хватало :-) */
/*       if accnt = faccnt and c5 = ourbank then do:  */
       /* 11.05.2004 nadejda - условие на платежи ТОЛЬКО сегодняшней даты опердня */
       if (accnt = faccnt or accnt = 0) and c5 = ourbank and date (c1) = g-today then do:  

          /*--- sasco: проверка наименований ----*/
          release cif.
          v-bad-name = no.
          v-bad-pref = no.
          find aaa where aaa.aaa = c6 no-lock no-error.
          if avail aaa then find cif where cif.cif = aaa.cif no-lock no-error.
          if avail cif then do:

    v-s1 = c13.
    v-s2 = c11.

    {trim-rnn.i}

             if not GCompare (cif.prefix + " " + cif.name  , v-s1, cif.cif) then
             if not GCompare (cif.prefix + " " + cif.sname , v-s1, cif.cif) then 
             if not GCompare (cif.name   + " " + cif.prefix, v-s1, cif.cif) then
             if not GCompare (cif.sname  + " " + cif.prefix, v-s1, cif.cif) then v-bad-name = yes.

             /* если не прошла сверка по имени - проверим форму собств. */
             if v-bad-name then 
                /* сверяем форму собств. в начале названия */
                if CAPS (cif.prefix) <> SUBSTR (TRIM(CAPS(v-s1)), 1, LENGTH (cif.prefix)) then 
                do:
                   /* если не прошло - то в конце названия */
                   if LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) + 1 > 0 and 
                      CAPS (cif.prefix) <> SUBSTR (TRIM(CAPS(v-s1)), LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) + 1) 
                           then v-bad-pref = yes.
                   else 
                   if LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) > 0 
                   then if SUBSTR (TRIM(CAPS(v-s1)), LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix), 1) <> " " 
                                 then v-bad-pref = yes.
                end.
          end.
          /*-------------------------------------*/
          
          ds = dec( trim(c7) ).  /* Сумма */
          dss = dss + ds.
          i = i + 1.
          c9 = substr(c9,5,2) + "." + substr(c9,3,2) + "." + substr(c9,1,2).
          if c14 = "1" then c14 = "FINAL".
                       else c14 = "PRESENT".
          put unformatted string(i,">>>9") at 0 "Тип: " c14 "  Плат.система: " c8 "  Референс: " c2 skip
                          "    Получен банком: " c1 skip
                          "    Банк отпр.: " c3 "    Счет отпр.: " c4 skip
                          "    Дата валютирования платежа: " c9 skip 
                          "    Банк получ: " c5 "    Счет получ: " c6 skip 
                          "    РНН отпрв : " c10 " " trim(substr(c12,1,50)) skip
                          "    РНН получ : " c11 " " trim(substr(c13,1,50)) skip.
          if trim(substr(c13, 51)) <> "" then put unformatted substr(c13,51) skip.
          if v-bad-name then put unformatted skip "     - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" skip
                                             "    ВНИМАНИЕ! Платеж не прошел сверку по наименованию получателя" skip
                                             "            ! Возможно зачисление средств на счет до выяснения  " skip.
          if v-bad-pref then put unformatted "       - не соответствие формы собственности" skip.
          if v-bad-name then put unformatted "       - не соответствие наименования получателя" skip.
          if v-bad-name then put unformatted "     - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" skip.

          put unformatted "    Сумма: " trim(string(ds,'>>>,>>>,>>>,>>9.99')) skip
                          "    Назначение платежа: " skip
                          space(4) substr(c15,1,55) skip
                          space(4) substr(c15,56,75) skip 
                          space(4) substr(c15,131,75) skip 
                          space(4) substr(c15,206,75) skip(1) .
       end.
    end.

    hide frame a-show. pause 0.

    input stream s-file close. pause 0.


/* 21.04.2005 kanat - проверка на очереди DIRIN - очереди входящих платежей для ПКО */
for each que where que.pid = "DIRIN" no-lock.

	find first remtrz where remtrz.remtrz = que.rem and replace(trim(remtrz.ba),"/","") = string(accnt,"999999999") no-lock no-error.
	if avail remtrz then do:
	 	find first aaa where aaa.aaa = replace(trim(remtrz.ba),"/","") no-lock no-error. /* remtrz.racc иногда бывает пустой ... */
	 	if avail aaa and aaa.aaa = string(integer(accnt), "999999999") then do:

          v-bad-name = no.
          v-bad-pref = no.

          find cif where cif.cif = aaa.cif no-lock no-error.
          if avail cif then do:

    if trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]) <> "" then do:  
    v-s1 = entry(1, trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]),"/"). 
    v-s2 = entry(3, trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]),"/"). 
    end.

    {trim-rnn.i}

             if not GCompare (cif.prefix + " " + cif.name  , v-s1, cif.cif) then
             if not GCompare (cif.prefix + " " + cif.sname , v-s1, cif.cif) then 
             if not GCompare (cif.name   + " " + cif.prefix, v-s1, cif.cif) then
             if not GCompare (cif.sname  + " " + cif.prefix, v-s1, cif.cif) then v-bad-name = yes.

             /* если не прошла сверка по имени - проверим форму собств. */
             if v-bad-name then 
                /* сверяем форму собств. в начале названия */
                if CAPS (cif.prefix) <> SUBSTR (TRIM(CAPS(v-s1)), 1, LENGTH (cif.prefix)) then 
                do:
                   /* если не прошло - то в конце названия */
                   if LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) + 1 > 0 and 
                      CAPS (cif.prefix) <> SUBSTR (TRIM(CAPS(v-s1)), LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) + 1) 
                           then v-bad-pref = yes.
                   else 
                   if LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix) > 0 
                   then if SUBSTR (TRIM(CAPS(v-s1)), LENGTH(TRIM(CAPS(v-s1))) - LENGTH (cif.prefix), 1) <> " " 
                                 then v-bad-pref = yes.
                end.
                end.

          dss = dss + remtrz.amt.
          end. /* avail aaa ... */
          i = i + 1.
          put unformatted string(i,">>>9") at 0 "Тип: PRESENT Плат.система: ПКО Референс: " remtrz.remtrz skip
                          "    Получен банком: " remtrz.valdt1 skip
                          "    Банк отпр.: " remtrz.sbank "    Счет отпр.: " remtrz.sacc skip
                          "    Дата валютирования платежа: " remtrz.valdt1 skip 
                          "    Банк получ: " remtrz.rbank "    Счет получ: " replace(remtrz.ba,"/","") skip. 


                          if (trim(remtrz.ordcst[1]) + trim(remtrz.ordcst[2]) + trim(remtrz.ordcst[3])) = "" then 
          put unformatted 
                          "    РНН отпрв : " entry(3, trim(remtrz.ord), "/") skip.
                          else
          put unformatted 
                          "    РНН отпрв : " entry(3, trim(remtrz.ordcst[1] + remtrz.ordcst[2] + remtrz.ordcst[3]), "/") skip.


                          if (trim(remtrz.ben[1]) + trim(remtrz.ben[2]) + trim(remtrz.ben[3])) = "" then 
          put unformatted 
                          "    РНН получ : " entry(3, trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]),"/") skip.
                          else
          put unformatted 
                          "    РНН отпрв : " entry(3, trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]),"/") skip.


          put unformatted entry(1, trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]),"/") skip.
          if v-bad-name then 
                        put unformatted skip "     - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" skip
                                             "    ВНИМАНИЕ! Платеж не прошел сверку по наименованию получателя" skip
                                             "            ! Возможно зачисление средств на счет до выяснения  " skip.

          if v-bad-pref then put unformatted "       - не соответствие формы собственности" skip.
          if v-bad-name then put unformatted "       - не соответствие наименования получателя" skip.
          if v-bad-name then put unformatted "     - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" skip.

          put unformatted "    Сумма: " trim(string(remtrz.amt,'>>>,>>>,>>>,>>9.99')) skip
                          "    Назначение платежа: " trim(remtrz.detpay[1]) + trim(remtrz.detpay[2]) + 
                                                     trim(remtrz.detpay[3]) + trim(remtrz.detpay[4]) skip.
	end. /* if avail remtrz ... */
end. /* for each que ... */

    put unformatted fill("-", 80) format "x(80)" skip
    "Итого платежей " string(i,">>9") " На сумму " trim(string(dss,'>>>,>>>,>>>,>>9.99')) skip (1).

    output close. pause 0.

    if i > 0 then run menu-prt("rpt.img").
             else MESSAGE "Платежей по счету " + string(accnt,"999999999") + " не найдено." 
                  VIEW-AS ALERT-BOX QUESTION BUTTONS OK TITLE "Внимание".


