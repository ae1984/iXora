/* pkstat-2.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Статистика "Портрет задолжника" (БД)
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        pkstat2-2.p
 * MENU
        4-13-15
 * AUTHOR
        10.11.2004 saltanat /  *  modified pkstat.p by sasco *  / 
 * CHANGES
         31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{pk0.i}

{pkstat-2.i "new"}
{gl-utils.i}

/* статистика по каждому филиалу */
for each txb where txb.consolid = true and (is_consolid or txb.bank = seltxb) no-lock:

if connected ("txb") then disconnect "txb".
connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 

    run pkstat2-2 (comm.txb.bank).

if connected ("txb") then disconnect "txb".
    
    run Copy_Txb_Cln (txb.bank).

         /* заемщик */
    if rep_zaj and not rep_con then run Results_output (txb.bank, TRUE, txb.name).
    
         /* отказы */
    /*if rep_otk and not rep_con then run Results_output (txb.bank, FALSE, txb.name).*/

end.

/* консолидированный отчет */

if rep_con then do:

     run Copy_Txb_Cln ("CONS").

     /* заемщик */
     if rep_zaj then run Results_output ("CONS", TRUE, "Консолидированные данные").
     /* отказы */
     /*if rep_otk then run Results_output ("CONS", FALSE, "Консолидированные данные").*/
end.


/*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/


procedure Copy_Txb_Cln.

    define input parameter v-txb as character.
    define variable vals as integer extent 3.

    /* ЗАПИСИ ПО ФИНАНСОВЫМ ОБЯЗАТЕЛЬСТВАМ */
    vals[1] = 0.
    vals[2] = 0.
    vals[3] = 0.
    for each tmpcln where tmpcln.bank = v-txb and tmpcln.loaned:
        if tmpcln.finobrem = yes then vals[1] = vals[1] + 1.
        if tmpcln.finobrem = no then vals[2] = vals[2] + 1.
        if tmpcln.finobrem = ? then vals[3] = vals[3] + 1.
    end.

    run ADD_TMP (v-txb, "finobrem", "Финансовые обязательства", "1", "Да", yes, vals[1]).
    run ADD_TMP (v-txb, "finobrem", "Финансовые обязательства", "2", "Нет", yes, vals[2]).
    run ADD_TMP (v-txb, "finobrem", "Финансовые обязательства", "msc", "Нет данных", yes, vals[3]).

    vals[1] = 0.
    vals[2] = 0.
    vals[3] = 0.
    for each tmpcln where tmpcln.bank = v-txb and not tmpcln.loaned:
        if tmpcln.finobrem = yes then vals[1] = vals[1] + 1.
        if tmpcln.finobrem = no then vals[2] = vals[2] + 1.
        if tmpcln.finobrem = ? then vals[3] = vals[3] + 1.
    end.

    run ADD_TMP (v-txb, "finobrem", "Финансовые обязательства", "1", "Да", no, vals[1]).
    run ADD_TMP (v-txb, "finobrem", "Финансовые обязательства", "2", "Нет", no, vals[2]).
    run ADD_TMP (v-txb, "finobrem", "Финансовые обязательства", "msc", "Нет данных", no, vals[3]).

   

    /* ЗАПИСИ ПО ДЕТЯМ */
    vals[1] = 0.
    vals[2] = 0.

    for each tmp where tmp.bank = v-txb and tmp.kritcod = 'childhas':
        if tmp.loaned then vals[1] = tmp.cnt.
                      else vals[2] = tmp.cnt.
    end.
    if vals[1] = 0 then run ADD_TMP (v-txb, "childhas", "Наличие детей", "1", "Да", yes, 0).
    if vals[2] = 0 then run ADD_TMP (v-txb, "childhas", "Наличие детей", "1", "Да", no, 0).

    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = yes.
    if tmpcnt.cnt > vals[1] then run ADD_TMP (v-txb, "childhas", "Наличие детей", "2", "Нет", yes, tmpcnt.cnt - vals[1]).

    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = no.
    if tmpcnt.cnt > vals[2] then run ADD_TMP (v-txb, "childhas", "Наличие детей", "2", "Нет", no, tmpcnt.cnt - vals[2]).

    /* ЗАПИСИ ПО НЕДВИЖИМОСТИ */
    vals[1] = 0.
    vals[2] = 0.
    for each tmp where tmp.bank = v-txb and tmp.kritcod = 'hasnedvizh':
        if tmp.loaned then vals[1] = tmp.cnt.
                      else vals[2] = tmp.cnt.
    end.
    if vals[1] = 0 then run ADD_TMP (v-txb, "hasnedvizh", "Недвижимость в собственности", "1", "Да", yes, 0).
    if vals[2] = 0 then run ADD_TMP (v-txb, "hasnedvizh", "Недвижимость в собственности", "1", "Да", no, 0).

    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = yes.
    if tmpcnt.cnt >= vals[1] then run ADD_TMP (v-txb, "hasnedvizh", "Недвижимость в собственности", "2", "Нет", yes, tmpcnt.cnt - vals[1]).

    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = no.
    if tmpcnt.cnt >= vals[2] then run ADD_TMP (v-txb, "hasnedvizh", "Недвижимость в собственности", "2", "Нет", no, tmpcnt.cnt - vals[2]).

    /* ЗАПИСИ ПО АВТОМОБИЛЯМ */
    vals[1] = 0.
    vals[2] = 0.
    for each tmp where tmp.bank = v-txb and tmp.kritcod = 'hasauto':
        if tmp.loaned then vals[1] = tmp.cnt.
                      else vals[2] = tmp.cnt.
    end.
    if vals[1] = 0 then run ADD_TMP (v-txb, "hasauto", "Автомобиль в собственности", "1", "Да", yes, 0).
    if vals[2] = 0 then run ADD_TMP (v-txb, "hasauto", "Автомобиль в собственности", "1", "Да", no, 0).
  
    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = yes.
    run ADD_TMP (v-txb, "hasauto", "Автомобиль в собственности", "2", "Нет", yes, tmpcnt.cnt - vals[1]).

    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = no.
    run ADD_TMP (v-txb, "hasauto", "Автомобиль в собственности", "2", "Нет", no, tmpcnt.cnt - vals[2]).


    /* ЗАПИСИ ПО СЧЕТАМ */
    
    vals[1] = 0. /* loaned */
    vals[2] = 0. /* NOT loaned */
    
    for each tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak3":
        if tmp.loaned then vals[1] = vals[1] + tmp.cnt.
                      else vals[2] = vals[2] + tmp.cnt.
    end.

    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = yes.
    if tmpcnt.cnt > vals[1] then vals[1] = tmpcnt.cnt - vals[1].
                            else vals[1] = 0.
    
    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = no.
    if tmpcnt.cnt > vals[2] then vals[2] = tmpcnt.cnt - vals[2].
                            else vals[2] = 0.

    run ADD_TMP (v-txb, "finacc", "Финансовые активы (наличие счета)", "NOak", "Счетов нет", yes, vals[1]).
    run ADD_TMP (v-txb, "finacc", "Финансовые активы (наличие счета)", "NOak", "Счетов нет", no, vals[2]).

    find first tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak31" and tmp.loaned = yes no-error.
    if not avail tmp then run ADD_TMP (v-txb, "finacc", "Финансовые активы (наличие счета)", "ak31", "Депозитный", yes, 0).

    find first tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak31" and tmp.loaned = no no-error.
    if not avail tmp then run ADD_TMP (v-txb, "finacc", "Финансовые активы (наличие счета)", "ak31", "Депозитный", no, 0).

    find first tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak32" and tmp.loaned = yes no-error.
    if not avail tmp then
    find first tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak34" and tmp.loaned = yes no-error.
    if not avail tmp then run ADD_TMP (v-txb, "finacc", "Финансовые активы (наличие счета)", "ak32", "Карточный", yes, 0).

    find first tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak32" and tmp.loaned = no no-error.
    if not avail tmp then
    find first tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak34" and tmp.loaned = no no-error.
    if not avail tmp then run ADD_TMP (v-txb, "finacc", "Финансовые активы (наличие счета)", "ak32", "Карточный", no, 0).

    find first tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak33" and tmp.loaned = yes no-error.
    if not avail tmp then run ADD_TMP (v-txb, "finacc", "Финансовые активы (наличие счета)", "ak33", "Текущий", yes, 0).

    find first tmp where tmp.bank = v-txb and tmp.kritcod = "finacc" and tmp.valcod begins "ak33" and tmp.loaned = no no-error.
    if not avail tmp then run ADD_TMP (v-txb, "finacc", "Финансовые активы (наличие счета)", "ak33", "Текущий", no, 0).

    /* ЗАПИСИ ПО КЛИЕНТАМ ТКБ */
    vals[1] = 0.
    vals[2] = 0.
    for each tmpcln where tmpcln.bank = v-txb and tmpcln.loaned:
        if tmpcln.cln then vals[1] = vals[1] + 1.
                      else vals[2] = vals[2] + 1.
    end.

    run ADD_TMP (v-txb, "txbcln", "Клиент ТКБ", "1", "Да", yes, vals[1]).
    run ADD_TMP (v-txb, "txbcln", "Клиент ТКБ", "2", "Нет", yes, vals[2]).

    vals[1] = 0.
    vals[2] = 0.
    for each tmpcln where tmpcln.bank = v-txb and not tmpcln.loaned:
        if tmpcln.cln then vals[1] = vals[1] + 1.
                      else vals[2] = vals[2] + 1.
    end.

    run ADD_TMP (v-txb, "txbcln", "Клиент ТКБ", "1", "Да", no, vals[1]).
    run ADD_TMP (v-txb, "txbcln", "Клиент ТКБ", "2", "Нет", no, vals[2]).

    /* УРЕГУЛИРОВАНИЕ ПРОЧИХ */

    run CORRECT_MISC (v-txb, "mf", "Пол", "msc", "Нет данных").
    run CORRECT_MISC (v-txb, "bdt", "Возраст", "msc", "Нет данных").
    run CORRECT_MISC (v-txb, "rajon", "Район фактического проживания", "(Район не известен)", "(Район не известен)").
    run CORRECT_MISC (v-txb, "jobp", "Место работы", "msc", "Нет данных").
    run CORRECT_MISC (v-txb, "jobs", "Категория должности", "msc", "Нет данных").
    run CORRECT_MISC (v-txb, "jobt", "Стаж работы", "msc", "Другое").
    run CORRECT_MISC (v-txb, "jobpr2", "Ср/мес доход чистый", "msc", "Нет данных").
    run CORRECT_MISC (v-txb, "family", "Семейное положение", "msc", "Другое").
    run CORRECT_MISC (v-txb, "childhas", "Наличие детей", "msc", "Нет данных").
    run CORRECT_MISC (v-txb, "hasnedvizh", "Недвижимость в собственности", "msc", "Нет данных").
    run CORRECT_MISC (v-txb, "hasauto", "Автомобиль в собственности", "msc", "Нет данных").
    run CORRECT_MISC (v-txb, "finacc", "Финансовые активы (наличие счета)", "NOXXX", "Нет данных").
    run CORRECT_MISC (v-txb, "txbcln", "Клиент ТКБ", "msc", "Нет данных").

end procedure.

/*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

procedure CORRECT_MISC.
    define input parameter v-txb as character.
    define input parameter p-kc as character.
    define input parameter p-kn as character.
    define input parameter p-vc as character.
    define input parameter p-vn as character.
    define variable vals as integer extent 2.

    vals[1] = 0.
    vals[2] = 0.

    for each tmp where tmp.bank = v-txb and tmp.kritcod = p-kc and tmp.valcod <> p-vc:
        if tmp.loaned then vals[1] = vals[1] + tmp.cnt.
                      else vals[2] = vals[2] + tmp.cnt.
    end.

    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = yes.
    if tmpcnt.cnt > vals[1] then vals[1] = tmpcnt.cnt - vals[1].
                            else vals[1] = 0.
    
    find tmpcnt where tmpcnt.bank = v-txb and tmpcnt.loaned = no.
    if tmpcnt.cnt > vals[2] then vals[2] = tmpcnt.cnt - vals[2].
                            else vals[2] = 0.

    if vals[1] >= 0 then run ADD_TMP (v-txb, p-kc, p-kn, p-vc, p-vn, yes, vals[1]).
    if vals[2] >= 0 then run ADD_TMP (v-txb, p-kc, p-kn, p-vc, p-vn, no, vals[2]).

end procedure.


/*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

procedure Results_output.
    define input parameter v-txb as character.
    define input parameter v-loaned as logical.
    define input parameter v-head as character.

    output to value (v-txb + (if v-loaned then "TRUE" else "FALSE") + ".html").
    {html-start.i}

    find bookcod where bookcod.bookcod = 'credtype' and bookcod.code = s-credtype no-lock no-error.
    
    put unformatted "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""0"" width=""100%"">" skip.
    put unformatted "<TR><TD colspan=""6""><H2>Портрет " if v-loaned then "задолжника" else "отказника" " : " v-head "</H2></TD></TR>" skip.
    put unformatted "<TR><TD colspan=""6""><H3>(" bookcod.name " с " vd1 " по " vd2 " )</H3></TD></TR>" skip.
    put unformatted "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip.

    /* PREFORMAT */
    for each tmp where tmp.bank = v-txb and 
                       tmp.loaned = v-loaned and
                       lookup (tmp.kritcod, valouts) > 0:
        tmp.cid = lookup(tmp.kritcod, valouts).
    end.

    for each tmp where tmp.bank = v-txb and 
                       tmp.loaned = v-loaned and
                       lookup (tmp.kritcod, valouts) > 0
                       break by tmp.cid by tmp.valcod:

        if first-of (tmp.cid) then do:
           put unformatted "<TR>" skip.
           put unformatted "<TD style=""border:1px solid black; background: #D0D0D0; "">" tmp.kritname "</TD>" skip.
           put unformatted "</TR>" skip.
        end.

        put unformatted "<TR><TD>&nbsp;</TD>" skip.
        put unformatted "<TD align=""left"" style=""border:1px solid black; "">" tmp.valdes "</TD>" skip.
        put unformatted "<TD style=""border:1px solid black; "">" tmp.cnt "</TD>" skip.
        put unformatted "</TR>" skip.

    end. /* each tmp */

    put unformatted "</TABLE>" skip. /* основная таблица */

    {html-end.i}
    output close.
    unix silent value ("cptwin " + v-txb + (if v-loaned then "TRUE" else "FALSE") + ".html excel").
    unix silent value ("rm " + v-txb + (if v-loaned then "TRUE" else "FALSE") + ".html").
   
end procedure.


procedure ADD_TMP.
    define input parameter v-txb as character.
    define input parameter p-kc as character.
    define input parameter p-kn as character.
    define input parameter p-vc as character.
    define input parameter p-vn as character.
    define input parameter p-l as logical.
    define input parameter p-c as integer.

    find tmp where tmp.bank = v-txb and
                   tmp.kritcod = p-kc and
                   tmp.valcod = p-vc and
                   tmp.loaned = p-l
                   no-error.

    if not avail tmp then create tmp.

    assign tmp.bank = v-txb
           tmp.kritcod = p-kc
           tmp.kritname = p-kn
           tmp.valcod = p-vc
           tmp.valdes = p-vn
           tmp.loaned = p-l
           tmp.cnt = p-c
           .

end procedure.

