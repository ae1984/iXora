/* ibdisacc.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Блокировка клиентов Internet Office у которых нет активных счетов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        ibplm7.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.8.6
 * BASES
        BANK COMM IB
 * AUTHOR
        07/05/03 sasco
 * CHANGES
        16/09/03 sasco - поправил изменение cnt для savelog :-)
        29/06/05 sasco - переделал поиск ib.usr с одной записи (find) на все по CIF`у (через for each)
*/

  DEF VAR laccs as char NO-UNDO.
  DEF VAR cnt as int NO-UNDO.

  CNT = 0.

  run savelog ("ioffice", " - НАЧАЛО ПОИСКА КЛИЕНТОВ - ").


  /* цикл по всем клиентам */
  for each cif no-lock:
  
     /* поиск клиента в Интернет Офисе; если таких нет, то пропускаем */
     find first ib.usr where ib.usr.cif = cif.cif no-lock no-error.
     if not avail ib.usr then next.

     /* получим список счетов, доступных через Интернет */
     laccs = ''.
     FOR each aaa WHERE aaa.cif = cif.cif AND aaa.sta <> "c" no-lock:
        FIND lgr WHERE lgr.lgr = aaa.lgr NO-LOCK NO-ERROR.
        IF NOT AVAIL lgr THEN NEXT.
        IF lgr.led = "DDA" OR lgr.led = "SAV" THEN laccs = laccs + "," + aaa.aaa.
     END.

     /* если есть действующие счета, то пропускаем клиента */
     if laccs <> '' then next.

     /* цикл по всем учетным записям Интернет Офис по текущему CIF */
     for each ib.usr where ib.usr.cif = cif.cif exclusive-lock:

         /* пропустим уже закрытые */
         if usr.perm[6] <> 0 then next.
     
         /* закрываем договор */
         cnt = cnt + 1.
         usr.perm[6] = 1. /* закрываем договор */
         run savelog ("ioffice", "  ID: " + string(usr.id, "zzzz9") + " LOGIN: " + string(usr.login, "x(15)") + " CIF: " + cif.cif).

     end. /* ib.usr */

     release usr.

  end. /* cif */

  IF CNT > 0 then message SUBSTITUTE ("ГОТОВО! Закрыто &1 договоров~nДетали - в ioffice.log", cnt) view-as alert-box title "".
             else message "Договора без открытых счетов не найдены!~Попробуйте еще раз..." view-as alert-box title ''.

  run savelog ("ioffice", " - КОНЕЦ - НАЙДЕНО: " + string(cnt, "zzzz9")).

