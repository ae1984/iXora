/* dirbik.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Настройки банков для прямых кор. отношений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        11/01/2005 kanat
 * BASES
        BANK COMM
 * CHANGES
        26/01/2005 kanat - добавил обработку DFB счетов для списка
        14/03/2005 kanat - добавил поле обработки референсов участников системы КЦМР
                           добавил поле для пути для исходящих документов
        20/05/2005 kanat - добавил обработку поля по формированию PRESENT выписок
        24/05/2005 kanat - добавил обработку расширений для файлов платежей и выписок
        25/05/2005 kanat - добавил вывод дополнительных сообщений
        02/08/2005 kanat - добавил обработку LORO - счетов банков
        15/03/2006 suchkov - добавлена настройка банка на автоматическую загрузку платежей
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{global.i}
{comm-txb.i}
{yes-no.i}

{bankl_select.i}
{dfb_select.i}

{get-dep.i}
{comm-rnn.i}

define variable seltxb as integer.
define query qt for direct_bank.
define buffer tls for direct_bank.
define temp-table tmp like direct_bank.

def var v-dep-code as integer.
def var v-dep-name as char.
def var v-mname as char.

seltxb = comm-cod().

find first cmp no-lock no-error.

   v-dep-code = get-dep(g-ofc, g-today).
   find first ppoint where ppoint.depart = v-dep-code no-lock no-error.
   if avail ppoint then
   v-dep-name = ppoint.name.
   else do:
   v-dep-name = "Неверный департамент".
   message "Неверный департамент" view-as alert-box title "Внимание".
   return.
   end.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then
   v-mname = ofc.name.
else do:
   v-mname = "Неизвестный офицер".
   message "Неизвестный офицер" view-as alert-box title "Внимание".
   return.
end.

define browse bt query qt
       displ direct_bank.bank1          label "БИК банка" format "x(10)"
             direct_bank.bank2          label "Корр. счет" format "x(10)"
             direct_bank.aux_string[1]  label "Наименование банка" format "x(40)"
       with 15 down centered no-label title "Настройка списка банков".

define frame ft bt help "F8-удалить,F1-новый,ENTER-редактировать,F2-Копировать"
             with row 1 overlay no-label no-box.

define frame frame_for_edit
             tmp.bank1          label "БИК банка" format "x(10)" skip
             tmp.bank2          label "NOSTRO счет" format "x(10)" skip
             tmp.ext[3]         label "LORO счет" format "x(10)" skip
             tmp.aux_string[1]  label "Наименование банка" format "x(40)" skip
             tmp.limit_sum1     label "Минимальная сумма" format ">>>,>>>,>>>,>>9.99" skip
             tmp.limit_sum2     label "Максимальная сумма" format ">>>,>>>,>>>,>>9.99" skip
             tmp.limit_time1    label "Минимальное время" format ">>>,>>>,>>>,>>9.99" skip
             tmp.limit_time2    label "Максимальное время" format ">>>,>>>,>>>,>>9.99" skip
             tmp.limit_percent1 label "Минимальное значение процентов" format ">>>,>>>,>>>,>>9.99" skip
             tmp.limit_percent2 label "Максимальное значение процентов" format ">>>,>>>,>>>,>>9.99" skip
             tmp.aux_string[2]  label "Путь для загрузки платежей:" format "x(45)" skip
             tmp.aux_string[3]  label "Путь для выгрузки платежей:" format "x(45)" skip
             tmp.aux_string[4]  label "Архив исх. документов:" format "x(45)" skip
             tmp.aux_string[5]  label "Референс пользователя КЦМР:" format "x(45)" skip
             tmp.que            validate (tmp.que = "y" or tmp.que = "n", "Неверное значение (y/n)!") label "Отправка PRESENT выписок (y/n)" format "x(1)" skip
             tmp.ext[1]         label "Раcширение файлов платежей" format "x(4)" skip
             tmp.ext[2]         label "Раcширение файлов выписок" format "x(4)" skip
             tmp.auto           label "Автоматическая загрузка платежей" format "да/нет" skip

/*
K0592600000000000000000
*/
             with row 1 side-labels.

    on help of tmp.bank1 in frame frame_for_edit do:
        run bankl_select.
        if return-value <> "" then do:
            find first bankl where bankl.bank = return-value no-lock no-error.
            update tmp.bank1 = bankl.bank
                   tmp.aux_string[1] = bankl.name.
        end.
            displ tmp.bank1 tmp.aux_string[1] with frame frame_for_edit.
    end.

    on help of tmp.bank2 in frame frame_for_edit do:
        run dfb_select.
        if return-value <> "" then do:
            find first dfb where dfb.dfb = return-value no-lock no-error.
            update tmp.bank2 = dfb.dfb.
        end.
            displ tmp.bank2 with frame frame_for_edit.
    end.

    on enter of tmp.bank1 in frame frame_for_edit do:
       tmp.bank1 = tmp.bank1:screen-value.
       find first bankl where bankl.bank = tmp.bank1 no-lock no-error.
       if avail bankl then do:
        tmp.bank1 = bankl.bank.
        tmp.aux_string[1] = bankl.name.
       end.
       else do:
       message "Неверный БИК банка" view-as alert-box title "Внимание".
       undo,retry.
       end.
    displ tmp.bank1 tmp.aux_string[1] with frame frame_for_edit.
    apply "value-changed" to self.
    end.

    on enter of tmp.bank2 in frame frame_for_edit do:
       tmp.bank2 = tmp.bank2:screen-value.
       find first dfb where dfb.dfb = tmp.bank2 no-lock no-error.
       if avail dfb then do:
        tmp.bank2 = dfb.dfb.
       end.
       else do:
       message "Неверный БИК банка" view-as alert-box title "Внимание".
       undo,retry.
       end.
    displ tmp.bank2 with frame frame_for_edit.
    apply "value-changed" to self.
    end.

    on enter of tmp.ext[3] in frame frame_for_edit do:
       tmp.ext[3] = tmp.ext[3]:screen-value.
       if trim(tmp.ext[3]) <> "" and trim(tmp.ext[3]) <> ? then do:
       find first aaa where aaa.aaa = trim(tmp.ext[3]) no-lock no-error.
       if avail aaa then do:
        tmp.ext[3] = aaa.aaa.
       end.
       else do:
       message "Неверный LORO счет банка" view-as alert-box title "Внимание".
       end.
       end.
    displ tmp.ext[3] with frame frame_for_edit.
    apply "value-changed" to self.
    end.

    on enter of tmp.limit_time1 in frame frame_for_edit do:
       tmp.limit_time1 = integer(tmp.limit_time1:screen-value).
    message string(tmp.limit_time1, "HH:MM:SS") view-as alert-box title "Время установки".
    end.

    on enter of tmp.limit_time2 in frame frame_for_edit do:
       tmp.limit_time2 = integer(tmp.limit_time2:screen-value).
    message string(tmp.limit_time2, "HH:MM:SS") view-as alert-box title "Время установки".
    end.

on "clear" of bt in frame ft do:
   if not available direct_bank then leave.
   if not yes-no ("", "Удалить запись?") then leave.
   find tls where rowid(tls) = rowid(direct_bank) no-error.
   delete tls.
   browse bt:refresh().
end.

on "go" of bt in frame ft do:
   if not yes-no ("", "Добавить запись?") then leave.

   create tmp.
   update tmp.bank1
          tmp.bank2
          tmp.ext[3]
          tmp.aux_string[1]
          tmp.limit_sum1
          tmp.limit_sum2
          tmp.limit_time1
          tmp.limit_time2
          tmp.limit_percent1
          tmp.limit_percent2
          tmp.aux_string[2]
          tmp.aux_string[3]
          tmp.aux_string[4]
          tmp.aux_string[5]
          tmp.que
          tmp.ext[1]
          tmp.ext[2]
          tmp.auto
          with frame frame_for_edit.

   assign tmp.regdt = g-today
          tmp.regofc = g-ofc
          tmp.regtime = time
          tmp.whn = today.

   message "Сохранить запись? " update choice as logical.

   if choice then do:
        if trim(tmp.bank1) = "" then do:
        message "Неверный БИК банка (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if trim(tmp.bank2) = "" then do:
        message "Неверный корр. счет банка (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if tmp.limit_sum2 = 0 then do:
        message "Неверная минимальная сумма лимита" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if tmp.limit_time2 = 0 then do:
        message "Неверное максимальное время (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if trim(tmp.ext[3]) <> "" and (not can-find (aaa no-lock where aaa.aaa = trim(tmp.ext[3]))) then do:
        message "Неверный LORO счет банка" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.
   end.

   if choice then do:
      create direct_bank.
      buffer-copy tmp to direct_bank.
      delete tmp.
      close query qt.
      open query qt for each direct_bank no-lock.
      get last qt.
      browse bt:refresh().
   end.
   if available tmp then delete tmp.
   hide frame frame_for_edit.
   apply "value-changed" to bt in frame ft.
end.


on "help" of bt in frame ft do:
   if not available direct_bank then leave.
   if not yes-no ("", "Скопировать запись в новую?") then leave.
   create tmp.
   buffer-copy direct_bank to tmp.

   update tmp.bank1
          tmp.bank2
          tmp.ext[3]
          tmp.aux_string[1]
          tmp.limit_sum1
          tmp.limit_sum2
          tmp.limit_time1
          tmp.limit_time2
          tmp.limit_percent1
          tmp.limit_percent2
          tmp.aux_string[2]
          tmp.aux_string[3]
          tmp.aux_string[4]
          tmp.aux_string[5]
          tmp.que
          tmp.ext[1]
          tmp.ext[2]
          tmp.auto
          with frame frame_for_edit.

   assign tmp.regdt = g-today
          tmp.regofc = g-ofc
          tmp.regtime = time
          tmp.whn = today.

   message "Сохранить запись? " update choice as logical.

   if choice then do:
        if trim(tmp.bank1) = "" then do:
        message "Неверный БИК банка (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if trim(tmp.bank2) = "" then do:
        message "Неверный корр. счет банка (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if tmp.limit_sum2 = 0 then do:
        message "Неверная минимальная сумма лимита" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if tmp.limit_time2 = 0 then do:
        message "Неверное максимальное время (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if trim(tmp.ext[3]) <> ? and (not can-find (aaa no-lock where aaa.aaa = trim(tmp.ext[3]))) then do:
        message "Неверный LORO счет банка" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.
   end.

   if choice then do:
      create direct_bank.
      buffer-copy tmp to direct_bank.
      delete tmp.
      close query qt.
      open query qt for each direct_bank no-lock.
      get last qt.
      browse bt:refresh().
   end.
   if available tmp then delete tmp.
   hide frame frame_for_edit.
   apply "value-changed" to bt in frame ft.
end.

on "return" of bt in frame ft do:
   if not available direct_bank then leave.
   find tls where rowid(tls) = rowid(direct_bank) no-error.
   create tmp.
   buffer-copy direct_bank to tmp.

   find first bankl where bankl.bank = tmp.bank1 no-lock no-error.
   if avail bankl then do:
   tmp.aux_string[1] = bankl.name.
   displ tmp.aux_string[1] with frame frame_for_edit.
   end.

   update tmp.bank1
          tmp.bank2
          tmp.ext[3]
          tmp.aux_string[1]
          tmp.limit_sum1
          tmp.limit_sum2
          tmp.limit_time1
          tmp.limit_time2
          tmp.limit_percent1
          tmp.limit_percent2
          tmp.aux_string[2]
          tmp.aux_string[3]
          tmp.aux_string[4]
          tmp.aux_string[5]
          tmp.que
          tmp.ext[1]
          tmp.ext[2]
          tmp.auto
          with frame frame_for_edit.

   assign tmp.regdt = g-today
          tmp.regofc = g-ofc
          tmp.regtime = time
          tmp.whn = today.

   message "Сохранить запись? " update choice as logical.

   if choice then do:
        if trim(tmp.bank1) = "" then do:
        message "Неверный БИК банка (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if trim(tmp.bank2) = "" then do:
        message "Неверный корр. счет банка (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if tmp.limit_sum2 = 0 then do:
        message "Неверная минимальная сумма лимита" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if tmp.limit_time2 = 0 then do:
        message "Неверное максимальное время (введите заново)" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.

        if trim(tmp.ext[3]) <> "" and (not can-find (aaa no-lock where aaa.aaa = trim(tmp.ext[3]))) then do:
        message "Неверный LORO счет банка" view-as alert-box title "".
        undo,retry.
        choice = false.
        end.
   end.

   if choice then do:
      buffer-copy tmp to direct_bank.
      delete tmp.
      browse bt:refresh().
   end.
   if available tmp then delete tmp.

   hide frame frame_for_edit.
   apply "value-changed" to bt in frame ft.
end.

open query qt for each direct_bank.
enable all with frame ft.
apply "value-changed" to bt in frame ft.
wait-for window-close of frame ft focus browse bt.
pause 0.

