/* reprko.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Отчет по принятым платежам за период в разрезе СПФ
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
        29/01/04 nataly было добавлено условие p_f_payment.deluid = ?
        05/02/04 sasco  добавил ИВЦ, Алсеко, Водоканал, АПК, Прочие коммю плат., Казахтелеком
        17/02/04 kanat  подправил цикл по коммунальным платежам (type = 3).
        01/07/04 kanat  переделал запросы по кнопкам - отчет раньше вообще не работал.
        14/04/05 kanat  добавил формирование данных по социальным платежам
        03/05/05 kanat  добавил дополнительные проверки по visible = yes для коммунальных платежей
        05/05/05 kanat  переделал запросы по commonpl и убрал все массивы
        10/05/05 kanat  добавил анализ платежей АЛМАТВ
        02/05/05 kanat  переделал обработку пенсионных платежей
        05/09/05 kanat  переделал обработку коммунальных платежей
        01/08/2006 Evgeniy u00568 - добавил ещё один отчет, всвязи с тем, что пенсионные отправляются в ГЦВП
        02/08/2006 Evgeniy u00568 - переделал -- СВОДНЫЙ ОТЧЕТ --, всвязи с тем, что пенсионные отправляются в ГЦВП + no-undo
*/

  {global.i}
  {get-dep.i}

  {comm-txb.i}
  def var seltxb as int no-undo.
  seltxb = comm-cod().

  def var v-date-begin as date no-undo.
  def var v-date-fin as date no-undo.

  define temp-table ttax no-undo like tax
  field dep like ppoint.depart
  field name like commonls.bn.

  define temp-table tcommpl no-undo like commonpl
  field dep like ppoint.depart
  field name as char.

  define temp-table tcommpl1 no-undo like commonpl
  field dep like ppoint.depart
  field name as char.

  define temp-table payment1 no-undo like p_f_payment
  field dep like ppoint.depart.

  define temp-table payment2 no-undo like p_f_payment
  field dep like ppoint.depart.

  define temp-table almpay no-undo like almatv
  field dep like ppoint.depart.

  def var dlm as char init "|".

  def var v-report-name as char no-undo.
  def var usrnm as char no-undo.
  def var v-grp as char no-undo.
  def var v-sum as decimal no-undo.
  def var pens_or_soc like commonpl.abk no-undo.

  def var v-param-list as char init "4,5,6,7,8,9,10".

  def temp-table ttmps no-undo
  field type as integer
  field kol as decimal
  field sum as decimal
  field comsum as decimal
  field name as char
  field dep as integer.

  def var i as integer init 0 no-undo.
  def var n as integer init 0 no-undo.
  def var v-operation as char no-undo.

  v-date-begin = g-today.
  v-date-fin = v-date-begin.

  update v-date-begin format '99/99/9999' label " Начальная дата "
  v-date-fin format '99/99/9999' label " Конечная дата "
  with centered frame df.

  run sel ("Выберите тип операции",
  "1. -- СВОДНЫЙ ОТЧЕТ --    |" +
  "2. Налоговые платежи      |" +
  "3. Станции диагностики    |" +
  "4. Сотовая связь          |" +
  "5. Казахтелеком           |" +
  "6. ИВЦ                    |" +
  "7. АЛСЕКО                 |" +
  "8. ВОДОКАНАЛ              |" +
  "9. АПК                    |" +
  "10.Прочие платежи         |" +
  "11.В Пенс. фонды платежи  |" +
  "12.-------------------    |" + /*"12.Пенсионные (прочие) |" +*/
  "13.Социальные платежи ГЦВП|" +
  "14.АЛМАТВ                 |" +
  "15.Пенсионные платежи ГЦВП|" +
  "16.    -- ВЫХОД -- ").

  v-operation = return-value.

  /*
  case return-value:
  when "1" then v-operation = "1".
  when "2" then v-operation = "2".
  when "3" then v-operation = "3".
  when "4" then v-operation = "4".
  when "5" then v-operation = "5".
  when "6" then v-operation = "6".
  when "7" then v-operation = "7".
  when "8" then v-operation = "8".
  when "9" then v-operation = "9".
  when "10" then v-operation = "10".
  when "11" then v-operation = "11".
  when "12" then v-operation = "12".
  when "13" then v-operation = "13".
  when "14" then v-operation = "14".
  when "15" then v-operation = "15".
  end.
  */
  v-grp = "ALL".

  if v-operation = "16" then
    return.

  if v-operation = "1" then
    v-grp = "ALL".

  if v-operation = "3" then
    /* Станции диагностики */
    v-grp = "1,3,4,5,6,7,8,9".

  if v-operation = "4" then
    /* Сотовая связь */
    v-grp = "4".

  if v-operation = "5" then
    /* Казахтелеком */
    v-grp = "3".

  if v-operation = "6" then
    /* ИВЦ */
    v-grp = "5".

  if v-operation = "7" then
    /* АЛСЕКО */
    v-grp = "6".

  if v-operation = "8" then
    /* ВОДОКАНАЛ */
    v-grp = "7".

  if v-operation = "9" then
    /* АПК */
    v-grp = "8".

  if v-operation = "10" then
    /* Прочие коммунальные */
    v-grp = "9".

  if v-operation = "13" then do:
    /* Социальные платежи */
    v-grp = "15".
    pens_or_soc = 0.
  end.

  if v-operation = "15" then do:
  /*15.Пенсионные платежи ГЦВП*/
    v-grp = "15".
    v-operation = "13".
    pens_or_soc = 1.
  end.




  /* Коммунальные платежи */

  if v-operation = "1" then
  do:
    for each commonpl where commonpl.txb = seltxb and commonpl.date >= v-date-begin and commonpl.date <= v-date-fin and
    commonpl.deluid = ? no-lock use-index datenum:
      find first commonls where commonls.txb = seltxb and commonls.grp = commonpl.grp and commonls.visible = yes and
      commonls.type = commonpl.type no-lock no-error.
      if avail commonls then
      do:
        create tcommpl.
        buffer-copy commonpl to tcommpl.
        tcommpl.dep = get-dep(commonpl.uid, commonpl.date).
        tcommpl.name = commonls.bn.
      end.
    end.


    for each tcommpl no-lock break by tcommpl.dep by tcommpl.arp:

      accumulate tcommpl.sum (sub-count by tcommpl.dep by tcommpl.arp).
      accumulate tcommpl.sum (sub-total by tcommpl.dep by tcommpl.arp).
      accumulate tcommpl.comsum (sub-total by tcommpl.dep by tcommpl.arp).

      if last-of (tcommpl.arp) then
      do:

        create ttmps.
        update ttmps.type = 4
        ttmps.dep = tcommpl.dep
        ttmps.kol = (accum sub-count by tcommpl.arp tcommpl.sum)
        ttmps.sum = (accum sub-total by tcommpl.arp tcommpl.sum)
        ttmps.comsum = (accum sub-total by tcommpl.arp tcommpl.comsum)
        ttmps.name = tcommpl.name.
      end.
    end.
  end. /* if v-operation = "1" then ... */

  /* Коммунальные по выбору */
  if lookup(v-operation, v-param-list) <> 0 then
  do:
    for each commonpl where commonpl.txb = seltxb and commonpl.date >= v-date-begin and commonpl.date <= v-date-fin and
    commonpl.deluid = ? and commonpl.grp = integer(v-grp) no-lock use-index datenum:
      find first commonls where commonls.txb = seltxb and commonls.grp = commonpl.grp and
      commonls.arp = commonpl.arp and commonls.visible = yes and
      commonls.type = commonpl.type no-lock no-error.
      if avail commonls then
      do:
        create tcommpl.
        buffer-copy commonpl to tcommpl.
        tcommpl.dep = get-dep(commonpl.uid, commonpl.date).
        tcommpl.name = commonls.bn.
      end.
    end.


    for each tcommpl no-lock break by tcommpl.dep by tcommpl.arp:

      accumulate tcommpl.sum (sub-count by tcommpl.dep by tcommpl.arp).
      accumulate tcommpl.sum (sub-total by tcommpl.dep by tcommpl.arp).
      accumulate tcommpl.comsum (sub-total by tcommpl.dep by tcommpl.arp).

      if last-of (tcommpl.arp) then
      do:

        create ttmps.
        update ttmps.type = 5
        ttmps.dep = tcommpl.dep
        ttmps.kol = (accum sub-count by tcommpl.dep tcommpl.sum)
        ttmps.sum = (accum sub-total by tcommpl.dep tcommpl.sum)
        ttmps.comsum = (accum sub-total by tcommpl.dep tcommpl.comsum)
        ttmps.name = tcommpl.name.
      end.
    end.
  end.

  /* Станции диагностики */
  if v-operation = "3" then
  do:
    for each commonpl where commonpl.txb = seltxb and commonpl.date >= v-date-begin and commonpl.date <= v-date-fin and
    lookup(string(commonpl.grp), v-grp) <> 0 and commonpl.deluid = ? no-lock use-index datenum:
      find first commonls where commonls.txb = seltxb and commonls.grp = commonpl.grp and
      commonls.arp = commonpl.arp and commonls.type = commonpl.type and
      commonls.visible = yes no-lock no-error.
      if avail commonls then
      do:
        create tcommpl.
        buffer-copy commonpl to tcommpl.
        tcommpl.dep = get-dep(commonpl.uid, commonpl.date).
        tcommpl.name = commonls.bn.
      end.
    end.


    for each tcommpl no-lock break by tcommpl.dep by tcommpl.arp:

      accumulate tcommpl.sum (sub-count by tcommpl.dep by tcommpl.arp).
      accumulate tcommpl.sum (sub-total by tcommpl.dep by tcommpl.arp).
      accumulate tcommpl.comsum (sub-total by tcommpl.dep by tcommpl.arp).

      if last-of (tcommpl.arp) then
      do:

        create ttmps.
        update ttmps.type = 6
        ttmps.dep = tcommpl.dep
        ttmps.kol = (accum sub-count by tcommpl.arp tcommpl.sum)
        ttmps.sum = (accum sub-total by tcommpl.arp tcommpl.sum)
        ttmps.comsum = (accum sub-total by tcommpl.arp tcommpl.comsum)
        ttmps.name = tcommpl.name.
      end.
    end.
  end.



  /* Социальные платежи и пенсионные платежи ГЦВП*/
  n = 0.
  if v-operation = "1" then do:
    n = 2.
    pens_or_soc = 0.
  end.
  if v-operation = "13" then
    n = 1.
  do i = 1 to n:
    for each tcommpl1 exclusive-lock:
      delete tcommpl1.
    end.
    if i = 2 then pens_or_soc = 1.
    for each commonpl where commonpl.txb = seltxb and commonpl.date >= v-date-begin and commonpl.date <= v-date-fin and
    commonpl.grp = 15 and commonpl.deluid = ? no-lock use-index datenum:
      if   (pens_or_soc = 1  /*пен*/ and commonpl.abk = 1)
        or (pens_or_soc = 0  /*соц*/ and commonpl.abk <> 1) then do:
        find first commonls where commonls.txb = seltxb and commonls.grp = commonpl.grp
          and commonls.arp = commonpl.arp
          and commonls.visible = no no-lock no-error.
        if avail commonls then
        do:
          create tcommpl1.
          buffer-copy commonpl to tcommpl1.
          tcommpl1.dep = get-dep(commonpl.uid, commonpl.date).
          if pens_or_soc = 1  /*пен*/ then tcommpl1.name = "Пенсионные платежи ГЦВП".
          if pens_or_soc = 0  /*соц*/ then tcommpl1.name = "Социальные платежи ГЦВП".
        end.
      end.
    end.


    for each tcommpl1 no-lock break by tcommpl1.dep by tcommpl1.arp:

      accumulate tcommpl1.sum (sub-count by tcommpl1.dep by tcommpl1.arp).
      accumulate tcommpl1.sum (sub-total by tcommpl1.dep by tcommpl1.arp).
      accumulate tcommpl1.comsum (sub-total by tcommpl1.dep by tcommpl1.arp).

      if last-of (tcommpl1.arp) then
      do:
        create ttmps.
        update ttmps.type = 6
        ttmps.dep = tcommpl1.dep
        ttmps.kol = (accum sub-count by tcommpl1.arp tcommpl1.sum)
        ttmps.sum = (accum sub-total by tcommpl1.arp tcommpl1.sum)
        ttmps.comsum = (accum sub-total by tcommpl1.arp tcommpl1.comsum)
        ttmps.name = tcommpl1.name.
      end.
    end.
  end.

  /* Налоговые платежи */
  if v-operation = "1" or v-operation = "2" then
  do:
    for each tax where tax.txb = seltxb and tax.date >= v-date-begin and tax.date <= v-date-fin and tax.duid = ? no-lock:
      create ttax.
      buffer-copy tax to ttax.
      ttax.dep = get-dep(tax.uid, tax.date).
    end.

    for each ttax no-lock break by ttax.dep by ttax.kb:

      accumulate ttax.sum (sub-count by ttax.kb).
      accumulate ttax.sum (sub-total by ttax.kb).
      accumulate ttax.comsum (sub-total by ttax.kb).

      if last-of (ttax.kb) then
      do:

        create ttmps.
        update ttmps.type = 1
        ttmps.dep = ttax.dep
        ttmps.kol = (accum sub-count by ttax.kb ttax.sum)
        ttmps.sum = (accum sub-total by ttax.kb ttax.sum)
        ttmps.comsum = (accum sub-total by ttax.kb ttax.comsum)
        ttmps.name = "Налоги. КБК: " + string(ttax.kb).

      end.
    end.
  end.
  /* if v-operation = "1" then ... */



  /* Пенсионные платежи  */

  if v-operation = "1" or v-operation = "11" then
  do:
    for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date >= v-date-begin and p_f_payment.date <= v-date-fin and
    p_f_payment.deluid = ? and p_f_payment.cod <> 400 no-lock:
      create payment1.
      buffer-copy p_f_payment to payment1.
      payment1.dep = get-dep(p_f_payment.uid, p_f_payment.date).
    end.
  end.
  /* if v-operation = "1" then ... */

  for each payment1 no-lock break by payment1.dep:

    accumulate payment1.amt (sub-count by payment1.dep).
    accumulate payment1.amt (sub-total by payment1.dep).
    accumulate payment1.comiss (sub-total by payment1.dep).

    if last-of (payment1.dep) then
    do:

      define buffer paycod for payment1.
      find first paycod where paycod.dep = payment1.dep and
      paycod.cod <> 400 no-lock no-error.

      if available paycod then
      do:
        for each paycod where paycod.dep = payment1.dep and
        paycod.cod <> 400 no-lock:
          accumulate paycod.amt
          (total count).
          accumulate paycod.comiss
          (total).
        end.

        create ttmps.
        update ttmps.type = 2
        ttmps.dep = payment1.dep
        ttmps.kol = (accum count paycod.amt).
        ttmps.sum = (accum total paycod.amt).
        ttmps.comsum = (accum total paycod.comiss).
        ttmps.name = "Пенсионные платежи".
      end.
    end.
  end.





  /* Пенсионные прочие платежи */
  for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date >= v-date-begin and p_f_payment.date <= v-date-fin and
  p_f_payment.deluid = ? and p_f_payment.cod = 400 no-lock:
    create payment2.
    buffer-copy p_f_payment to payment2.
    payment2.dep = get-dep(p_f_payment.uid, p_f_payment.date).
  end.
  for each payment2 no-lock break by payment2.dep:

    accumulate payment2.amt (sub-count by payment2.dep).
    accumulate payment2.amt (sub-total by payment2.dep).
    accumulate payment2.comiss (sub-total by payment2.dep).

    if last-of (payment2.dep) then
    do:

      define buffer paycod1 for payment2.
      find first paycod1 where paycod1.dep = payment2.dep and
      paycod1.cod = 400 no-lock no-error.

      if available paycod1 then
      do:
        for each paycod1 where paycod1.dep = payment2.dep and
        paycod1.cod = 400 no-lock:
          accumulate paycod1.amt
          (total count).
          accumulate paycod1.comiss
          (total).
        end.

        create ttmps.
        update ttmps.type = 3
        ttmps.dep = payment2.dep
        ttmps.kol = (accum count paycod1.amt).
        ttmps.sum = (accum total paycod1.amt).
        ttmps.comsum = (accum total paycod1.comiss).
        ttmps.name = "Пенсионные (прочие) платежи".
      end.
    end.
  end.


  /* 10/05/05 kanat  добавил анализ платежей АЛМАТВ */

  /* Платежи АЛМАТВ */
  if v-operation = "1" or v-operation = "14" then
  do:
    for each almatv where almatv.txb = seltxb and almatv.dtfk >= v-date-begin and almatv.dtfk <= v-date-fin and almatv.deluid = ? no-lock:
      create almpay.
      buffer-copy almatv to almpay.
      almpay.dep = get-dep(almatv.uid, almatv.dtfk).
    end.

    for each almpay no-lock break by almpay.dep:

      accumulate almpay.summfk (sub-count by almpay.dep).
      accumulate almpay.summfk (sub-total by almpay.dep).
      accumulate almpay.cursfk (sub-total by almpay.dep).

      if last-of (almpay.dep) then
      do:
        create ttmps.
        update ttmps.type = 7
        ttmps.dep = almpay.dep
        ttmps.kol = (accum sub-count by almpay.dep almpay.summfk)
        ttmps.sum = (accum sub-total by almpay.dep almpay.summfk)
        ttmps.comsum = (accum sub-total by almpay.dep almpay.cursfk)
        ttmps.name = "АЛМАТВ".
      end.
    end.
  end.

  /* 10/05/05 kanat  добавил анализ платежей АЛМАТВ */


  find first ttmps no-lock no-error.
  if available ttmps then
  do:

    if v-operation = "1" then
      v-report-name  = " Сводный отчет по всем видам платежей ".
    else
      if v-operation = "2" then
        v-report-name  = " Сведения по налоговым платежам ".
    else
      if v-operation = "3" then
        v-report-name  = " Сведения по коммунальным платежам ".
    else
      if v-operation = "4" then
        v-report-name  = " Сведения по платежам за сотовую связь".
    else
      if v-operation = "5" then
        v-report-name  = " Сведения по платежам Казахтелеком ".
    else
      if v-operation = "6" then
        v-report-name  = " Сведения по платежам ИВЦ ".
    else
      if v-operation = "7" then
        v-report-name  = " Сведения по платежам Алсеко ".
    else
      if v-operation = "8" then
        v-report-name  = " Сведения по платежам Водоканала ".
    else
      if v-operation = "9" then
        v-report-name  = " Сведения по платежам АПК ".
    else
      if v-operation = "10" then
        v-report-name = " Сведения по прочим (коммунальным) платежам ".
    else
      if v-operation = "11" then
        v-report-name = " Сведения по пенсионным платежам ".
    else
      if v-operation = "12" then
        v-report-name = " Сведения по прочим (пенсионным) платежам ".
    else
      if v-operation = "13" then
        if pens_or_soc = 1  /*пен*/ then
          v-report-name = " Сведения по пенсионным платежам ".
        else
          v-report-name = " Сведения по социальным платежам ".
    else
      if v-operation = "14" then
        v-report-name = " Сведения по платежам АЛМАТВ ".

    output to reprko.txt.

    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if available ofc then
      usrnm = ofc.name. else
      usrnm = "UNKNOWN".

    put unformatted
    g-comp format "x(55)" skip
    "Исполнитель " usrnm format "x(35)" skip
    "Дата  " today " " string(time,"HH:MM:SS") skip(3)
    v-report-name  skip(1)
    "    за период с " v-date-begin FORMAT "99/99/9999" " по " v-date-fin FORMAT "99/99/9999" skip(2)
    fill("-", 80) format "x(80)" skip
    " Назначение платежа            " dlm "Кол.платежей" dlm "          Сумма   " dlm "      Комиссия " dlm skip
    fill("-", 80) format "x(80)" skip.

    for each ttmps no-lock break by ttmps.dep by ttmps.type:

      accumulate ttmps.kol (sub-total by ttmps.dep).

      accumulate ttmps.sum (sub-total by ttmps.dep).

      accumulate ttmps.comsum (sub-total by ttmps.dep).

      accumulate ttmps.kol (total).

      accumulate ttmps.sum (total).

      accumulate ttmps.comsum (total).


      if first-of(ttmps.dep) then
      do:
        find first ppoint where ppoint.point = 1 and ppoint.depart = ttmps.dep no-lock no-error.
        put unformatted
        skip(1) "     " ppoint.name skip
        fill("-", 80) format "x(80)" skip.
      end.

      put unformatted
      " " ttmps.name format "x(29)" " " dlm
      " " ttmps.kol format ">>>>>>>>>9" " " dlm
      " " ttmps.sum format ">>>>>>>>>>>>9.99" " " dlm
      " " ttmps.comsum format ">>>>>>>>>9.99" " " dlm skip.

      if last-of(ttmps.dep) then
      do:
        put unformatted
        fill("-", 80) format "x(80)" skip
        "     Итого" space(21) dlm
        " " (accum sub-total by ttmps.dep ttmps.kol) format ">>>>>>>>>9" " " dlm
        " " (accum sub-total by ttmps.dep ttmps.sum) format ">>>>>>>>>>>>9.99" " " dlm
        " " (accum sub-total by ttmps.dep ttmps.comsum) format ">>>>>>>>>9.99" " " dlm skip
        fill("-", 80) format "x(80)" skip.
      end.
    end.


    put unformatted
    fill("-", 80) format "x(80)" skip
    "     Всего"  space(21) dlm
    " " (accum total ttmps.kol) format ">>>>>>>>>9" " " dlm
    " " (accum total ttmps.sum) format ">>>>>>>>>>>>9.99" " " dlm
    " " (accum total ttmps.comsum) format ">>>>>>>>>9.99" " " dlm skip
    fill("-", 80) format "x(80)" skip.

    output close.
    run menu-prt ("reprko.txt").

  end.
  /* if avail ttmps then ... */
  else
  do:
    message "Платежей не найдено" view-as alert-box title "Внимание".
    return.
  end.
