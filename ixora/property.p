/* property.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Ввод информации по наличию имущества у клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        28/01/2010 galina
 * BASES
        BANK
 * CHANGES
        01/02/2010 galina - убрала проверку на наличие кредита
        26/03/2010 galina - можно вводить несколько счетов в одном банке
        21/09/2010 galina - поменяла формат ввода для движимого имущества
*/

{global.i}


def var v-cif like cif.cif.
def var v-indt as date.
def var v-outdt as date.
def var v-innum as char.
def var v-outnum as char.
def var v-des as char.
def var v-cifname as char.
def var v-sel as integer.
def var v-type as char.
def var v-title as char.
def var v-ciftitle as char.
def var v-rid as rowid.
def var v-choice as logi init no.
def var v-bname as char no-undo.
def var v-acc as char no-undo.


def var v-carnum as char no-undo.
def var v-carcalor as char no-undo.
def var v-carmark as char no-undo.
def var v-caryear as char no-undo.
form
    v-cif label 'Код клиента' format "x(6)" help "F2 - Поиск" validate(can-find(cif where cif.cif = v-cif no-lock) and v-cif <> '','Клиент не найден!') skip
    v-cifname label 'Наименование клиента' format "x(40)"
with centered side-label row 5 title "ВЫБЕРИТЕ КЛИЕНТА" frame f-cif.

form
  v-outnum label 'Исх.Номер' format "x(20)"  help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip
  v-outdt label ' Дата' format "99/99/9999" help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip
  v-innum label 'Вход.Номер ответа' format "x(20)"  help "<F1>-Сохранить, <F4>-Выйти без сохранения"
  v-indt label ' Дата' format "99/99/9999"  help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip
  v-des label 'Сведения о наличии имущества' view-as editor size 60 by 3 help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip (2)
  with centered side-label row 5 width 95 title v-title frame fprop2 .

form
  v-carnum label 'Гос.номер' format "x(20)"  help "<F1>-Сохранить, <F4>-Выйти без сохранения"
  v-carcalor label 'Цвет' format "x(20)" help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip
  v-carmark label 'Марка' format "x(20)"  help "<F1>-Сохранить, <F4>-Выйти без сохранения"
  v-caryear label 'Год выпуска' format "9999"  help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip
  v-des label 'Примечание' view-as editor size 60 by 3 help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip (2)
  with centered side-label row 5 width 95 title v-title frame fprop1 .


form
  v-bname label 'Наименование банка' format "x(60)"  help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip
  v-acc label 'Номер счета' view-as editor size 60 by 4 help "<F1>-Сохранить, <F4>-Выйти без сохранения" skip
  with centered side-label row 5 width 95 title v-title frame fprop3 .


/*repeat ON ENDKEY UNDO, return:
  update v-cif with frame f-cif.
  find first lon where lon.cif = v-cif and lon.sts <> 'c' no-lock no-error.
  if not avail lon then  message 'У клиента нет кредита!' view-as alert-box.
  else leave.
end.*/

update v-cif with frame f-cif.

find first cif where cif.cif = v-cif no-lock no-error.
if cif.type = 'B' then v-cifname = cif.pref + ' ' + cif.name.
else  v-cifname = cif.name.

display v-cifname with frame f-cif.
v-ciftitle = cif.cif + ' ' + cif.sname.
run sel2('ВЫБЕРИТЕ ПРИЗНАК',' Недвижимое имущество| Движимое имущество | Счета в БВУ',output v-sel).
if v-sel = 1 then assign  v-type = 'real' v-title = v-ciftitle + ' Недвижимое имущество'.
if v-sel  = 2 then assign v-type = 'mov'  v-title = v-ciftitle + ' Движимое имущество'.
if v-sel = 3 then assign  v-type = 'acc' v-title = v-ciftitle + ' Счета в БВУ'.


define query qprop for property.
define browse bprop query qprop
displ property.outnum label "Исх.Номер" format "x(20)"
      property.outdt label "Дата" format "99/99/9999"
      property.innum label "Вход.номер ответа" format "x(20)"
      property.indt label "Дата" format "99/99/9999"
      property.des label "Описание" format "x(40)"
      with 30 down overlay no-label no-box.

define frame fprop bprop  help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl-D>-Удалить, <F4>-Выход"
 with width 110 row 3 overlay no-label title v-title.

define query qacc for property.

define browse bacc query qacc
displ property.info[1] label "Наименование банка" format "x(80)"
      property.info[2] label "Номер счета" format "x(21)"
      with 30 down overlay no-label no-box.

define frame facc bacc  help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl-D>-Удалить, <F4>-Выход"
 with width 110 row 3 overlay no-label title v-title.

define query qcar for property.
define browse bcar query qcar
displ property.info[1] label "Гос.номер" format "x(20)"
      property.info[3] label "Марка" format "x(20)"
      property.info[4] label "Год выпуска" format "x(4)"
      property.des label "Описание" format "x(40)"
      with 30 down overlay no-label no-box.

define frame fcar bcar  help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl-D>-Удалить, <F4>-Выход"
 with width 110 row 3 overlay no-label title v-title.



on "return" of bprop in frame fprop do:
   find current property no-lock no-error.
   if not avail property then return.
   assign v-outnum = property.outnum
          v-outdt = property.outdt
          v-innum = property.innum
          v-indt = property.indt
          v-des = property.des.


   update v-outnum v-outdt v-innum v-indt v-des with frame fprop2.

   find current property exclusive-lock.
   assign property.outnum = v-outnum
          property.outdt = v-outdt
          property.innum = v-innum
          property.indt = v-indt
          property.des = v-des.

   open query qprop for each property where property.cif = v-cif and property.type = v-type  no-lock.
   find first property where property.cif = v-cif and property.type = v-type  no-lock no-error.
   if avail property then bprop:refresh().
end.

on "insert-mode" of bprop in frame fprop do:

    create property.
    assign property.cif = v-cif
           property.who = g-ofc
           property.whn = g-today
           property.type = v-type
           property.tim = time.

    bprop:set-repositioned-row(bprop:focused-row, "always").
    v-rid = rowid(property).
    open query qprop for each property where property.cif = v-cif and property.type = v-type no-lock.
    reposition qprop to rowid v-rid no-error.
    find first property where property.cif = v-cif and property.type = v-type no-lock no-error.
    if avail property then bprop:refresh().

    /*v-new = yes.*/

    apply "return" to bprop in frame fprop.


end.

on "delete-line" of bprop in frame fprop do:
    find current property no-lock no-error.
    if not avail property then return.
    MESSAGE skip " Удалить запись?" skip(1)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "ИМУЩЕСТВО" UPDATE v-choice.
    if v-choice then do:
        bprop:set-repositioned-row(bprop:focused-row, "always").
        find current property exclusive-lock.
        delete property.
        open query qprop for each property where property.cif = v-cif and property.type = v-type no-lock.
        find first property where property.cif = v-cif and property.type = v-type no-lock no-error.
        if avail property then bprop:refresh().
    end.
end.

on "return" of bacc in frame facc do:
   find current property no-lock no-error.
   if not avail property then return.
   assign v-bname = property.info[1]
          v-acc = property.info[2].

   update v-bname v-acc with frame fprop3.

   find current property exclusive-lock.
   assign property.info[1] = v-bname
          property.info[2] = v-acc.

   open query qacc for each property where property.cif = v-cif and property.type = v-type  no-lock.
   find first property where property.cif = v-cif and property.type = v-type  no-lock no-error.
   if avail property then bacc:refresh().
end.

on "insert-mode" of bacc in frame facc do:

    create property.
    assign property.cif = v-cif
           property.who = g-ofc
           property.whn = g-today
           property.type = v-type
           property.tim = time.

    bacc:set-repositioned-row(bacc:focused-row, "always").
    v-rid = rowid(property).
    open query qacc for each property where property.cif = v-cif and property.type = v-type no-lock.
    reposition qacc to rowid v-rid no-error.
    find first property where property.cif = v-cif and property.type = v-type no-lock no-error.
    if avail property then bacc:refresh().

     apply "return" to bacc in frame facc.
end.

on "delete-line" of bacc in frame facc do:
    find current property no-lock no-error.
    if not avail property then return.
    MESSAGE skip " Удалить запись?" skip(1)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "СЧЕТА В БВУ" UPDATE v-choice.
    if v-choice then do:
        bacc:set-repositioned-row(bacc:focused-row, "always").
        find current property exclusive-lock.
        delete property.
        open query qacc for each property where property.cif = v-cif and property.type = v-type no-lock.
        find first property where property.cif = v-cif and property.type = v-type no-lock no-error.
        if avail property then bacc:refresh().
    end.
end.
/**/
on "return" of bcar in frame fcar do:
   find current property no-lock no-error.
   if not avail property then return.
   assign v-carnum = property.info[1]
          v-carcalor = property.info[2]
          v-carmark = property.info[3]
          v-caryear = property.info[4]
          v-des = property.des.


   update v-carnum v-carcalor v-carmark v-caryear v-des  with frame fprop1.

   find current property exclusive-lock.
   assign property.info[1] = v-carnum
          property.info[2] = v-carcalor
          property.info[3] = v-carmark
          property.info[4] = v-caryear
          property.des = v-des.

   open query qcar for each property where property.cif = v-cif and property.type = v-type  no-lock.
   find first property where property.cif = v-cif and property.type = v-type  no-lock no-error.
   if avail property then bcar:refresh().
end.

on "insert-mode" of bcar in frame fcar do:

    create property.
    assign property.cif = v-cif
           property.who = g-ofc
           property.whn = g-today
           property.type = v-type
           property.tim = time.

    bcar:set-repositioned-row(bcar:focused-row, "always").
    v-rid = rowid(property).
    open query qcar for each property where property.cif = v-cif and property.type = v-type no-lock.
    reposition qcar to rowid v-rid no-error.
    find first property where property.cif = v-cif and property.type = v-type no-lock no-error.
    if avail property then bcar:refresh().

    apply "return" to bcar in frame fcar.
end.

on "delete-line" of bcar in frame fcar do:
    find current property no-lock no-error.
    if not avail property then return.
    MESSAGE skip " Удалить запись?" skip(1)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "СЧЕТА В БВУ" UPDATE v-choice.
    if v-choice then do:
        bcar:set-repositioned-row(bcar:focused-row, "always").
        find current property exclusive-lock.
        delete property.
        open query qcar for each property where property.cif = v-cif and property.type = v-type no-lock.
        find first property where property.cif = v-cif and property.type = v-type no-lock no-error.
        if avail property then bcar:refresh().
    end.
end.

if KEYFUNCTION(LASTKEY) = "END-ERROR" then return.
if v-sel <> 0 then do:
    if v-sel = 1 then do:
       for each property where property.cif = v-cif and property.type = v-type exclusive-lock:
         if property.innum = '' and property.outnum = '' and property.indt = ? and property.outdt = ? then  delete property.
       end.
       open query qprop for each property where property.cif = v-cif and property.type = v-type no-lock.
       enable bprop with frame fprop.
    end.
    if v-sel = 2 then do:
       for each property where property.cif = v-cif and property.type = v-type exclusive-lock:
         if property.info[1] = '' and property.info[2] = '' and property.info[3] = '' and property.info[4] = '' and  property.des = '' then  delete property.
       end.
       open query qcar for each property where property.cif = v-cif and property.type = v-type no-lock.
       enable bcar with frame fcar.
    end.
    if v-sel = 3 then do:
       for each property where property.cif = v-cif and property.type = v-type exclusive-lock:
         if property.info[1] = '' and property.info[2] = '' then  delete property.
       end.
       open query qacc for each property where property.cif = v-cif and property.type = v-type no-lock.
       enable bacc with frame facc.
    end.
end.

wait-for window-close of current-window.
pause 0.
