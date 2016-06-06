/* debsfsel.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Выбор дебитора для редактирования и ввод счетов/фактур
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        PRAGMA
 * AUTHOR
        05/02/04 sasco
 * CHANGES
        05.03.2004 recompile
        07.05.2004 sasco добавил поля для поиска debmon для удаления после выхода из "run debmon.p"
*/

{debls.f}
{global.i}
{yes-no.i}

{trx-debhist.i "new shared"}

define variable v-nf like debmon.nf.
define variable v-df like debmon.df.
define variable v-jh like debmon.jh.
define variable v-date as date.
define variable v-ctime like debmon.ctime.
define variable v-res as logical.

define frame fnf v-nf skip
                 v-df skip
                 with row 3 centered overlay side-labels title ''.

/* -------------------------------------- */


define temp-table tmp like debhis.
define query qt for tmp.
define browse bt query qt 
              displ tmp.date format "99/99/99" label "Дата"
                    tmp.jh format "zzzzzzz9" label "Проводка"
                    tmp.amt format "zzz,zzz,zz9.99"
                    tmp.rem[1] format "x(30)"
              with row 1 centered 10 down title "Выберите проводку".
define frame ft bt help "ENTER - выбрать" with row 1 centered overlay no-label no-box.


on "return" of browse bt do:
   if not avail tmp then leave.
   if not yes-no ("", "Выбрать проводку?") then leave.
   v-jh = tmp.jh.
   v-ctime = tmp.ctime.
   v-date = tmp.date.
   v-amt = tmp.amt.
   apply "endkey" to frame ft.
end.

/* -------------------------------------- */

update v-grp with frame get-grp.
find debgrp where debgrp.grp = v-grp no-lock.
displ debgrp.des @ v-grp-des with frame get-grp-all.
pause 0.

if v-grp <> 0 then do:
update v-ls with frame get-grp.
find debls where debls.grp = v-grp and debls.ls = v-ls no-lock.
displ debls.name @ v-ls-des with frame get-grp-all.
pause 0.
end.

hide frame get-grp.

run sel (debls.name, "Редактирование счета-фактуры|Ввод нового счета-фактуры").
if lookup (return-value, "1,2") = 0 then do:
   message "Ошибка выбора!" view-as alert-box title "".
   return.
end.

/* -------------------------------------- */

/* резиденство */   
find debgrp where debgrp.grp = v-grp no-lock no-error.
find arp where arp.arp = debgrp.arp no-lock no-error.
if arp.crc = 1 then v-res = yes.
               else v-res = no.


/* редактирование */
if return-value = "1" then do:
   
   update v-nf v-df with frame fnf.
   hide frame fnf.
   
   for each debmon where debmon.grp = v-grp and debmon.ls = v-ls and
                           debmon.nf = v-nf and debmon.df = v-df no-lock:
       create tmon.
       buffer-copy debmon to tmon.
   end.

   find first debmon where debmon.grp = v-grp and debmon.ls = v-ls and
                           debmon.nf = v-nf and debmon.df = v-df no-lock no-error.

   if avail debmon then do:

      run debmon (v-grp, v-ls, debmon.nf, debmon.df, debmon.jh, debmon.date, debmon.ctime, v-res, debmon.amt).
      
      if return-value = "yes" then 
      do:
         for each debmon where debmon.grp = v-grp and debmon.ls = v-ls and
                           debmon.nf = v-nf and debmon.df = v-df:
             delete debmon.
         end. 
         for each tmon:
             create debmon.
             buffer-copy tmon to debmon.
             delete tmon.
         end. 
   
      end. /* return-value */
      else message "Некорректный выход из ввода счета-фактуры!" view-as alert-box title "".

   end. /* avail debmon */

   else do:
        message SUBSTITUTE ("Не найден счет-фактура &1 за дату &2", v-nf, v-df) view-as alert-box title "".
        return.
  end.

end.

/* дальше по программе не пойдем */
if return-value = "1" then return.
if return-value <> "2" then return.


/* -------------------------------------- */

update v-d1 v-d2 with frame get-dates.
hide frame get-dates.


/* список проводок по списанию без счетов-фактур */
for each debhis where debhis.grp = v-grp and debhis.ls = v-ls and debhis.type > 2 and 
                      debhis.date >= v-d1 and debhis.date <= v-d2 no-lock:
    find first debmon where debmon.grp = v-grp and debmon.ls = v-ls and debmon.jh = debhis.jh and
                            debmon.date = debhis.date no-lock no-error.
    if avail debmon then next.
    create tmp.
    buffer-copy debhis to tmp.
end.


open query qt for each tmp.
enable all with frame ft.
wait-for "endkey" of frame ft or window-close of current-window focus browse bt.
hide frame ft.

/* если выбрали, то запустим процедуру ввода сч/фактуры */
if v-ctime <> ? and v-jh <> ? then /* run debsfnew (v-grp, v-ls, v-jh, v-ctime). */
do:
      run debmon (v-grp, v-ls, ?, ?, v-jh, v-date, v-ctime, v-res, v-amt).

      if return-value = "yes" then 
      do:
         for each debmon where debmon.grp = v-grp and 
                               debmon.ls = v-ls and
                               debmon.nf = v-nf and 
                               debmon.df = v-df and 
                               debmon.jh = v-jh and 
                               debmon.date = v-date and 
                               debmon.ctime = v-ctime:
             delete debmon.
         end. 
         for each tmon:
             create debmon.
             buffer-copy tmon to debmon.
             debmon.jh = v-jh.
             debmon.ctime = v-ctime.
             debmon.date = v-date.
             delete tmon.
         end. 
   
      end. /* return-value */
      else message "Некорректный выход из ввода счета-фактуры!" view-as alert-box title "".
end.
