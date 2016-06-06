  /* wpreg.p
  * MODULE
      Название Программного Модуля
      Коммунальные платежи
  * DESCRIPTION
      Назначение программы, описание процедур и функций
      Формирование реестра платежей ИВЦ / Алсеко
  * MENU
      Перечень пунктов Меню Прагмы
      п. 3.2.10.5.2 Формирование реестра по платежам
      новый пункт 5,2,1,5,2
  * AUTHOR
      31/12/99 pragma
  * CHANGES
      22.07.03 kanat Добавил формирование пачек платежей по 100 шт.
      15/07/04 kanat - добавил возможность просмотра реестров, убрал формирование и отправку файлов
      22/07/05 kanat - увеличил формат вывода коммиссии
      24/05/06 u00568 Evgeniy - исправил ошибки, + no-undo
      02/11/06 u00568 Evgeniy - для атырау водоканала ТЗ 231 + немного оптимизировал по скорости и читабельности
  */



  {comm-txb.i}
  def var seltxb as int no-undo.
  seltxb = comm-cod().

  {global.i}
  {comm-chk.i} /* Проверка незачисленных платежей на АРП по счету за дату */
  {comm-com.i}

  def temp-table tcommpl no-undo like commonpl.
  def var dat as date no-undo.
  def var summa as decimal no-undo.
  def var tsum as decimal init 0 no-undo.  /*общая сумма комиссии*/
  def var ttsum as decimal init 0 no-undo. /*общая сумма + комиссия*/
  def var tcnt as integer init 0 no-undo.
  /*def var i as integer no-undo.*/
  def var files as char initial "" no-undo.
  def var outf as char no-undo.
  def var subj as char no-undo.
  def var selgrp  as integer no-undo.
  def var selarp  as char no-undo.
  /*def var selprc  as decimal format "9.9999".*/
  def var p_count as integer init 0 no-undo.

  def var p-patch as integer init 1 no-undo.
  def var p-patch-sum as decimal init 0 no-undo.
  def var p-patch-comsum as decimal init 0 no-undo.  /*сумма комиссии по пачке*/
  def var p_parameter as integer init 100 no-undo.  /*количество платежей в пачке*/


  DEFINE STREAM s1.

  do while true:
    run comm-grp(output selgrp).
    if selgrp > 0 then
      leave.
    else
      if selgrp = -1 then
        return.
  end.

  dat = g-today.
  update dat label ' Укажите дату ' format '99/99/99' skip
  with side-label row 5 centered frame dataa.

  update p_parameter label ' Введите количество платежей в пачке ' format '>>>>>>9' skip
  with side-label row 6 centered frame dataa.


  find first commonls where commonls.txb = seltxb
                        and commonls.grp = selgrp
                        and commonls.visible = yes
                      no-lock no-error.
  if avail commonls then
    selarp = commonls.arp.
  else do:
    MESSAGE "Не найден справочник организаций commonls"
    VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
  end.


  /*selprc = commonls.comprc.*/


  outf = "Tr" + string(dat, "99.99.99").
  substr(outf, 5, 1) = "".
  if comm-chk(selarp,dat) then
    return.
  /*i = 0.*/
  /*for each txb where txb.city = seltxb and txb.visible no-lock:*/
    for each commonpl no-lock where commonpl.txb = seltxb /*txb.txb*/
                                and commonpl.date = dat
                                and /* commonpl.rmzdoc <> ?
                                and */ commonpl.arp = selarp
                                and commonpl.deluid = ?
                                and commonpl.grp = selgrp
                              /*break by commonpl.sum by commonpl.date*/:
      create tcommpl.
      buffer-copy commonpl to tcommpl.
    end.
  /*end.*/


  if not can-find (first tcommpl no-lock) then do:
    MESSAGE "Отправленные платежи не найдены." VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
  end.

  OUTPUT STREAM s1 TO wpreg.txt.
  tsum = 0.0.
  ttsum = 0.0.
  put STREAM s1 unformatted
    "                            Реестр" skip
    "          извещений по приему платежей за услуги " + selname(selgrp) skip
    "                         За " + string(dat,'99/99/9999') + " г." skip
    fill("=", 66) format "x(66)"                                      skip(2).


  /*---body---*/

  for each tcommpl no-lock break by tcommpl.date by tcommpl.sum:
    if p_count = 0 then
    do:
      put STREAM s1 unformatted
        "                            Пачка N " p-patch format ">>>>>>9"   skip
        fill("-", 66) format "x(66)"                                      skip
        "    Номер       Номер           Сумма      Комиссия       Всего" skip
        "  документа    счета "                                           skip
        fill("-", 66) format "x(66)"                                      skip.
    end.
    summa = summa + tcommpl.sum.
    p-patch-sum = p-patch-sum + tcommpl.sum.
    tcnt = tcnt + 1.
    tsum = tsum + tcommpl.comsum.
    p-patch-comsum = p-patch-comsum + tcommpl.comsum.
    ttsum = ttsum + tcommpl.sum + tcommpl.comsum.
    put stream s1
      tcommpl.dnum format "zzzzzzz9" space(1)
      tcommpl.accnt space(1)
      tcommpl.sum format ">,>>>,>>>,>>9.99" space(4)
      tcommpl.comsum format ">>>,>>9.99" tcommpl.sum + tcommpl.comsum format ">,>>>,>>>,>>9.99".
      /*---begin--- для атырау водоканала */
      if seltxb = 3 and selgrp = 7 then do:
        find first vodokanal-ls no-lock where vodokanal-ls.num = tcommpl.accnt and vodokanal-ls.deluid = ? no-error.
        if avail vodokanal-ls then do:
          put stream s1
             space(1) vodokanal-ls.fio     format 'x(35)'
             space(1) vodokanal-ls.adr     format 'x(35)'.
        end.
      end.
      /*---end--- для атырау водоканала */
    put stream s1 skip.
    p_count = p_count + 1.
    if (p_count = p_parameter) or (last-of(tcommpl.date) and (p_count <> 0)) then do:
      put STREAM s1 unformatted
        fill("-", 66) format "x(66)" skip
        "ИТОГО ПЛАТЕЖЕЙ ПО ПАЧКЕ " p-patch format ">>>>>>>9" " НА СУММУ " truncate(p-patch-sum,2) format ">,>>>,>>>,>>9.99" skip
        " КОМИССИЯ ПАЧКИ" truncate(p-patch-comsum, 2) format ">>>,>>9.99" skip
        fill("-", 66) format "x(66)" skip(5).
      p-patch-sum = 0.0.
      p-patch-comsum = 0.0.
      p_count = 0.
      p-patch = p-patch + 1.
    end.
  end.

  /*---footer---*/
  find ofc where ofc.ofc = g-ofc no-lock.
    put STREAM s1 unformatted
      fill("=", 66) format "x(66)"  skip
      "ИТОГО " tcnt format ">>>>" " ПЛАТЕЖЕЙ   НА СУММУ " summa format ">,>>>,>>>,>>9.99" skip
      "                      КОМИССИЯ         " truncate(tsum,2)  format ">>>,>>9.99" skip
      "                         ВСЕГО (с комиссией)" truncate(ttsum,2) format ">,>>>,>>>,>>9.99" skip(2)
      "Менеджер операцион-" skip
      " ного департамента                " ofc.name format "x(30)" skip(2)
      "Подпись исполнителя:" skip(2)
      fill("=", 66) format "x(66)" skip(2).
  OUTPUT STREAM s1 CLOSE.

  run menu-prt ("wpreg.txt").









  /*
  unix silent value ( ' cp wpreg.txt ' + outf ).
  */
  /*
  if summa > 0 then do:
  files = files + ";" + outf.
  display
  "Сформирован файл "
  outf format "x(9)"
  " на сумму "
  summa with no-labels.
  pause.
  end.
  */
  /*
  substr(files,1,1) = "".
  if files = "" then subj = "За " + string(dat,"99.99.99") + " платежей не было.".
  else subj = "Реестр платежей за " + string(dat,"99.99.99").


  MESSAGE "Отправить реестр платежей платежи по электронной почте на сумму "
  (ACCUM TOTAL tcommpl.sum)
  " тенге ?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
  TITLE "Платежи Казахтелеком" UPDATE choicereg as logical.
  case choicereg:
  when false then return.
  end.


  run mail("demidova@elexnet.kz,gulnur@elexnet.kz,bozdarenko@elexnet.kz,
  litosh@elexnet.kz,alex@netbank.kz,koval@elexnet.kz",
  "TexaKaBank <" + userid("bank") + "@elexnet.kz>", subj, "", "1", "", files).
  */
