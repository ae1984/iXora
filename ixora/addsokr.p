/* addsokr.p
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
*/

/* ------------------------------- */
/* Добавление получателя в таблицу */
/* допустимых название/сокращений  */
/* 13.03.2003 by sasco             */
/* ------------------------------- */
{lgps.i}
{comm-txb.i}
{trim.i}
{yes-no.i}

define shared var s-remtrz like remtrz.remtrz.

define var v-s1   as char no-undo init "".
define var v-s2   as char no-undo init "".
define var v-bbbb as char no-undo init "".
define var i      as int  no-undo.
define var v-teng as char no-undo init "".
define var seltxb as int  no-undo.
define var gv-s1 as char NO-UNDO init "".
define var tmpi as int NO-UNDO.
define var rnnind as int NO-UNDO.
define var tmpd as decimal NO-UNDO.

   find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
   if not avail remtrz then do:
      message "НЕТ ТАКОГО RMZ!" view-as alert-box title "".
      undo, return.
   end.

   if remtrz.rsub <> "x-pref" and remtrz.rsub <> "x-name" then undo, return.

   find aaa where aaa.aaa = remtrz.racc no-lock no-error.
   if not avail aaa then do:
      message "НЕТ ТАКОГО КЛИЕНТСКОГО СЧЕТА!" view-as alert-box title "".
      undo, return.
   end.

   find cif where cif.cif = aaa.cif no-lock no-error.
   if not avail cif then do:
      message "НЕТ ТАКОГО КЛИЕНТА!" view-as alert-box title "".
      undo, return.
   end.

   run 3-crcl.

   do i = 1 to 3:
      v-bbbb = trim( remtrz.bn[i] ).
      v-s1   = v-s1 + if length( v-bbbb ) = 60 then v-bbbb else v-bbbb + " ".
   end.
   v-bbbb = v-s1.
   i = r-index( v-bbbb, "/RNN/" ).
   if i <> 0 then do:
      v-s1 = trim( substring( v-bbbb, 1, i - 1 )).
      v-s2 = trim( substring( v-bbbb, i + 5, 12 )).
   end.
   else do:
      v-bbbb = "".
      do i = 1 to 3: v-bbbb = v-bbbb + trim(remtrz.bn[i]). end.
      i = r-index(v-bbbb, "/RNN/").
      if i <> 0 then do:
         v-s1 = trim(substring(v-bbbb, 1, i - 1)).
         v-s2 = trim(substring(v-bbbb, i + 5, 12)).
      end.
   end.

   {trim-rnn.i}

   v-teng = GPSTrim(GEnglish(v-s1)).
   seltxb = comm-cod().

   find comm.sokrat where comm.sokrat.txb = seltxb and 
                          comm.sokrat.type = 1 and
                          comm.sokrat.key = cif.cif and
                          comm.sokrat.teng = v-teng
                          no-lock no-error.

   if avail comm.sokrat then do:
      message "Такая запись уже существует!~nДобавление не возможно" view-as alert-box title "".
      undo, return.
   end.

   if not yes-no ("", "Добавить наименование получателя~n" + v-s1 + "~nв справочник допустимых сокращений клиента?") then undo, return.

   create comm.sokrat.
   comm.sokrat.txb  = comm-cod().
   comm.sokrat.type = 1.
   comm.sokrat.key  = cif.cif.
   comm.sokrat.full = v-s1.
   comm.sokrat.teng = GPSTrim(GEnglish(v-s1)).

   v-text = remtrz.remtrz + " Наименование получателя добавлено в справочник допустимых названий клиента".
   run lgps.
   
   message "Запись успешно добавлена" view-as alert-box title "".

