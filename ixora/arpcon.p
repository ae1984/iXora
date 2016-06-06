/* arpcon.p
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
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

/* ----------------------------------------- */
/* Настройка счетов АРП, подлежащих контролю */
/* ----------------------------------------- */
{yes-no.i}
{comm-txb.i}

def shared var g-today as date.

def temp-table tmp like arpcon
                   field ridJ as rowid
                   field ridR as rowid
                   field des  as char format "x(40)".

def query q1 for tmp.
def browse b1 query q1
              displ tmp.arp column-label "АРП"
                    tmp.des column-label "Описание"
                    tmp.checkmax format "Конт/ " column-label "Макс!месяц"
                    tmp.checktrx format "Конт/ " column-label "Макс!транз"
                    with row 1 7 down no-box.

def var varp like tmp.arp.

def frame f1 b1
          HELP "ENTER - редактировать; F1 - добавить запись; F8 - удалить"
          with row 1 centered title "Настройка счетов АРП для контроля".

def frame fdet tmp.max    label "Макс сумма за месяц" SKIP
               tmp.maxtrx label "Макс сумма 1й транз" SKIP
               tmp.curr   label "Текущая сумма      " SKIP
               "Список офицеров, которые делают проводки без контроля" SKIP
               tmp.uids   label "Ввод через запятую"
               with row 13 centered side-labels.

def frame fnew varp label "АРП" SKIP
               tmp.des label "Описание" SKIP(2)
               "Контролировать общую сумму за месяц" tmp.checkmax format "да/нет" label "" SKIP
               "Контролировать сумму 1 проводки" tmp.checktrx format "да/нет" label "" SKIP(2)

               "Введите максимальную сумму всех проводок за месяц" SKIP
               tmp.max label "Сумма" SKIP
               "Введите максимальную сумму одной проводки" SKIP
               tmp.maxtrx label "Сумма" SKIP (2)
               "Список офицеров, которые делают проводки без контроля" SKIP
               tmp.uids   label "Через запятую"
               with row 2 centered side-labels overlay.

on "clear" of b1 do:
   if avail tmp then do:
      if yes-no ("ВНИМАНИЕ", "Удалить запись?") then
      do:
         find arpcon where rowid (arpcon) = tmp.ridR no-error.
         if avail arpcon then delete arpcon.
         find arpcon where rowid (arpcon) = tmp.ridJ no-error.
         if avail arpcon then delete arpcon.
         delete tmp.
         open query q1 for each tmp.
         if can-find (first tmp) then browse b1:refresh().
      end.
   end.
end.

on "value-changed" of varp in frame fnew do:
    varp = varp:screen-value.
    find arp where arp.arp = varp:screen-value no-lock no-error.
    if avail arp then tmp.des = arp.des.
                 else tmp.des = "".
    displ tmp.des with frame fnew.
end.

on "end-error" of frame fnew do:
   hide frame fnew.
   varp = "EXIT".
   enable all with frame f1.
end.

on "go" of b1 do:
   if varp = "EXIT" then do: varp = "". leave. end.
   if not yes-no ("", "Добавить запись?") then leave.
   varp = "".
   create tmp.
   tmp.old-sts = "new".
   tmp.txb = comm-txb().
   tmp.checkmax = no.
   tmp.checktrx = no.
   tmp.uids = "".
   tmp.curr = 0.0.
   tmp.max = 0.0.
   tmp.maxtrx = 0.0.
   tmp.crc = 1.

   update varp
          with frame fnew
          editing:
                  readkey.
                  apply lastkey.

                  if frame-field = "varp" then
                     apply "value-changed" to varp in frame fnew.
           end.

    if tmp.des = "" then do:
       message "Не найден АРП счет!" view-as alert-box title "".
       hide frame fnew.
       undo, leave.
    end.
    tmp.arp = varp.

    update tmp.checkmax tmp.checktrx with frame fnew.
    if tmp.checkmax then update tmp.max with frame fnew.
    if tmp.checktrx then update tmp.maxtrx with frame fnew.
    update tmp.uids with frame fnew.

    hide frame fnew.

    create arpcon.
    assign arpcon.arp = tmp.arp
           arpcon.crc = tmp.crc
           arpcon.checkmax = tmp.checkmax
           arpcon.checktrx = tmp.checktrx
           arpcon.max = tmp.max
           arpcon.maxtrx = tmp.maxtrx
           arpcon.curr = tmp.curr
           arpcon.date = g-today
           arpcon.txb = tmp.txb
           arpcon.sub = "JOU"
           arpcon.uids = tmp.uids
           arpcon.old-sts = tmp.old-sts
           arpcon.new-sts = "baJ".
    tmp.ridJ = rowid (arpcon).

    create arpcon.
    assign arpcon.arp = tmp.arp
           arpcon.crc = tmp.crc
           arpcon.checkmax = tmp.checkmax
           arpcon.checktrx = tmp.checktrx
           arpcon.max = tmp.max
           arpcon.maxtrx = tmp.maxtrx
           arpcon.curr = tmp.curr
           arpcon.date = g-today
           arpcon.txb = tmp.txb
           arpcon.sub = "RMZ"
           arpcon.uids = tmp.uids
           arpcon.old-sts = tmp.old-sts
           arpcon.new-sts = "baR".
    tmp.ridR = rowid (arpcon).

    open query q1 for each tmp.
    browse b1:refresh().
    apply "value-changed" to b1.
end.

on "return" of b1 do:
    if not avail tmp then leave.
    displ tmp.arp @ varp tmp.des tmp.checkmax tmp.checktrx tmp.max tmp.maxtrx tmp.uids with frame fnew.

    update tmp.checkmax tmp.checktrx with frame fnew.
    if tmp.checkmax then update tmp.max with frame fnew.
                    else tmp.max = 0.0.
    if tmp.checktrx then update tmp.maxtrx with frame fnew.
                    else tmp.maxtrx = 0.0.
    displ tmp.max tmp.maxtrx with frame fnew.
    update tmp.uids with frame fnew.

    hide frame fnew.

    find arpcon where rowid (arpcon) = tmp.ridJ.
    assign arpcon.checkmax = tmp.checkmax
           arpcon.checktrx = tmp.checktrx
           arpcon.max = tmp.max
           arpcon.maxtrx = tmp.maxtrx
           arpcon.uids = tmp.uids.

    find arpcon where rowid (arpcon) = tmp.ridR.
    assign arpcon.checkmax = tmp.checkmax
           arpcon.checktrx = tmp.checktrx
           arpcon.max = tmp.max
           arpcon.maxtrx = tmp.maxtrx
           arpcon.uids = tmp.uids.

    open query q1 for each tmp.
    browse b1:refresh().
    apply "value-changed" to b1.
end.

on "value-changed" of b1 do:
   if avail tmp then
      displ tmp.uids tmp.curr tmp.max tmp.maxtrx
            with frame fdet.
   else
      displ ? @ tmp.uids ? @ tmp.curr ? @ tmp.max ? @ tmp.maxtrx
            with frame fdet.
end.

for each arpcon no-lock:
    find tmp where tmp.arp = arpcon.arp no-error.
    if not avail tmp then do:
       find arp where arp.arp = arpcon.arp no-lock no-error.
       if not avail arp then next.
       create tmp.
       buffer-copy arpcon to tmp.
       tmp.des = arp.des.
    end.
    if arpcon.sub = "RMZ" then tmp.ridR = rowid (arpcon).
    if arpcon.sub = "JOU" then tmp.ridJ = rowid (arpcon).
end.

open query q1 for each tmp.
enable all with frame f1.
apply "value-changed" to b1.

wait-for window-close of frame f1 focus browse b1.

