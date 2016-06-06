/* debop.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Ввод данных по контрактам и счетам-фактурам
        Возвращает "ok" если все в порядке (данные введены)
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
        14/11/03 sasco
 * CHANGES
        12/01/04 sasco Исправил validate`ы так, чтобы не было отката
        13/01/04 sasco ПЕРЕКОМПИЛЯЦИЯ
        21/01/04 sasco Расширил поле v-nk до 21 символа
        05/02/04 sasco ввел редактирование РНН
        05/02/04 sasco новые параметры - date, ctime, amt, nf, df
        05/03/04 sasco добавил редактирование debmon.rnn, debmon.ser, debmon.num, debmon.country
        09/03/04 sasco сделал возможность ввода сумм с минусом
        07/04/04 sasco Добавил запись серии и номера свидетельства в debmon
                       Добавил обновление постоянной информации (nf,df,nk,dk,rnn,ser,num,country)
        12/05/04 sasco Убрал запрос pklass
        13/05/04 sasco Пауза = 0 после displ * prasp
        02/06/04 suhckov - Добавлена обработка цифрового кода единиц измерения.
        18/11/2011 evseev  - переход на ИИН/БИН
        04/04/2013 Luiza - ТЗ 1743 добавление поля БИН головной организации
*/

{global.i}
{yes-no.i}
{trx-debhist.i "shared"}

{comm-rnn.i}

{chbin.i}
{chk12_innbin.i}

def var v-sel as int no-undo.
run sel2 ("Выберите :", " 1. БИН Головной организации дебитора | 2. БИН филиала дебитора ", output v-sel).
if keyfunction (lastkey) = "end-error" then v-sel = 2.
if (v-sel < 1) or (v-sel > 2) then v-sel = 2.

function checkRNN returns logical (cRNN as char).
    define variable cc as character.
    define variable ii as int.

    cc = trim (cRNN).
    do ii = 1 to length (cc):
       /* любое число, чтобы была ошибка */
       if lookup (substring(cc, ii, 1), "0,1,2,3,4,5,6,7,8,9") = 0 then return true.
    end.

    if v-bin = yes then return not chk12_innbin(cRNN).
                   else return comm-rnn (cRNN).
end function.

&scoped-define PRASP "1,2,3,4"

define input parameter v-grp like debls.grp.
define input parameter v-ls like debls.ls.
define input parameter v-nf like debmon.nf.
define input parameter v-df like debmon.df.
define input parameter v-jh like debhis.jh.
define input parameter v-date like debhis.date.
define input parameter v-ctime like debhis.ctime.
define input parameter v-res as logical. /* резидентство РК */
define input parameter v-dam as decimal. /* сумма проводки */

define variable v-rnn like debls.rnn.
define variable v-ser like debls.ser.
define variable v-num like debls.num.
define variable v-countnum as character format 'x(3)' label "Код страны".

define variable v-name as character.

define variable v-code as integer .

       /* контракт */
define variable v-nk like debmon.nk.
define variable v-dk like debmon.dk.

       /* есть счет-фактура или нет */
define variable validnf as logical initial yes.

       /* внутр. номер сч-фактуры, если validnf = no */
define variable v-innf like debmon.innf.

define buffer btmon for tmon.

define variable izmdes as character format 'x(50)' label ''.
define variable praspdes as character format 'x(50)' label ''.
define variable pklassdes as character format 'x(50)' label ''.

define frame deb-res-nf
             tmon.nk format "x(21)"
             tmon.dk
             tmon.name
             tmon.descr
             tmon.edizm format 'x(40)'
             izmdes view-as text
             tmon.qty
             tmon.totsum format '-z,zzz,zzz,zz9.99' label "Сумма без НДС"
             tmon.oblsum format '-z,zzz,zzz,zz9.99'
             tmon.nds
             tmon.sumnds format '-z,zzz,zzz,zz9.99'
             tmon.aksum format  '-z,zzz,zzz,zz9.99'
             tmon.prasp validate (tmon.prasp = "" or can-find (first codfr where codfr.codfr = 'prasp' and codfr.code = tmon.prasp no-lock),
                                  "Укажите правильный признак книги покупок!"
                                  )
             praspdes view-as text
             /*
             tmon.pklass validate (tmon.pklass = "" or can-find (first codfr where codfr.codfr = 'pklass' and codfr.code = tmon.pklass no-lock),
                                  "Укажите правильный признак распределения!"
                                  )
             pklassdes view-as text
             */
             with row 3 1 column side-labels overlay centered.

define frame deb-nonres-nf
             tmon.nk format "x(21)"
             tmon.dk
             tmon.name
             tmon.descr
             tmon.edizm format 'x(40)'
             izmdes view-as text
             tmon.qty
             tmon.totsum  format '-z,zzz,zzz,zz9.99' label "Сумма без НДС"
             tmon.nds
             tmon.sumnds format '-z,zzz,zzz,zz9.99'
             tmon.taxsum format '-z,zzz,zzz,zz9.99'
             tmon.ptsum format '-z,zzz,zzz,zz9.99'
             tmon.prasp
             praspdes view-as text
             /*
             tmon.pklass
             pklassdes view-as text
             */
             with row 3 1 column side-labels overlay centered.

define frame getsernum
       v-rnn format "x(12)" label "РНН"
                 validate (v-rnn <> "" and not checkRNN (v-rnn), "Неправильный код РНН!")
       v-ser format "x(5)" label "Серия св-ва"
                 validate (v-ser = '' or length(v-ser) = 5, "Длина серии св-ва должна быть 5 символов!")
       v-num format "x(7)" label "Номер св-ва"
                 validate (v-num = '' or length(v-num) = 7, "Длина номера св-ва должна быть 7 символов!")
       with row 3 centered side-labels 1 column title "Постановка на учет по НДС".
define frame getsernum1
       v-rnn format "x(12)" label "ИИН/БИН"
                 validate (v-rnn <> "" and not checkRNN (v-rnn), "Неправильный ИИН/БИН!")
       v-ser format "x(5)" label "Серия св-ва"
                 validate (v-ser = '' or length(v-ser) = 5, "Длина серии св-ва должна быть 5 символов!")
       v-num format "x(7)" label "Номер св-ва"
                 validate (v-num = '' or length(v-num) = 7, "Длина номера св-ва должна быть 7 символов!")
       with row 3 centered side-labels 1 column title "Постановка на учет по НДС".

define frame getcountry
             v-countnum
             with row 3 centered side-labels 1 column title "Страна нерезидента".

on "help" of tmon.name in frame deb-res-nf do:
   run h-selectdebname.
   tmon.name:screen-value = return-value.
   tmon.name = return-value.
end.

on "help" of tmon.name in frame deb-nonres-nf do:
   run h-selectdebname.
   tmon.name:screen-value = return-value.
   tmon.name = return-value.
end.

/* suchkov */
on "return" of tmon.edizm in frame deb-res-nf do:
    v-code = integer (tmon.edizm:screen-value) no-error .
    if v-code > 0 then do:
        find codfr where codfr.codfr = 'edizm' and codfr.code = string(v-code,"99") no-lock no-error .
        if available codfr then assign
            tmon.edizm = codfr.name[1]
            tmon.edizm:screen-value = codfr.name[1].
        else do:
            message "Ошибочный код!!!".
            pause 2.
            tmon.edizm:screen-value = tmon.edizm.
        end.
    end.
end.


define query qt for tmon.

define browse bt query qt
              displ tmon.name format 'x(25)' label 'Наименование'
                    tmon.descr format 'x(20)' label 'Описание'
                    tmon.qty format 'zzzzz9.99' label 'Количество'
                    tmon.totsum format '-zz,zzz,zz9.99' label 'Сумма без НДС'
              with row 1 centered 7 down title 'Список товаров и услуг'.

define frame ft  'Дебитор: ' at 10 v-name format 'x(50)' view-as text skip
                 'Счет-фактура N: 'at 10 v-nf format 'x(20)' skip
                 'Дата сч-фактуры ' at 10 v-df format '99/99/9999' skip
                 'Контракт N: 'at 10 v-nk format 'x(20)' skip
                 'Дата контракта ' at 10 v-dk format '99/99/9999' skip
                 'Внутренний номер счета: ' v-innf skip(2)
                 bt help "ENTER-просмотр/редактирование, F1-добавить, F2-выход, F8-удалить"
                 with row 1 centered no-label overlay title 'Списание суммы с дебитора'.

define frame fnf v-nf skip
                 v-df skip
                 /* v-nk skip
                 v-dk  */
                 with row 3 centered overlay side-labels title ''.


/* - - - - - - - - - - - - - - - - - - - - - - - - - */
/*              ТРИГГЕРЫ                             */
/* - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Единица измерения */

on "value-changed" of tmon.edizm in frame deb-res-nf do:
    find codfr where codfr.codfr = 'edizm' and codfr.code = tmon.edizm:screen-value no-lock no-error.
    if available codfr then izmdes = codfr.name[1].
                            else izmdes = ''.
    displ izmdes with frame deb-res-nf.
end.

on "value-changed" of tmon.edizm in frame deb-nonres-nf do:
    find codfr where codfr.codfr = 'edizm' and codfr.code = tmon.edizm:screen-value no-lock no-error.
    if available codfr then izmdes = codfr.name[1].
                            else izmdes = ''.
    displ izmdes with frame deb-nonres-nf.
end.



/* Книга покупок - признак распр. */
on "value-changed" of tmon.prasp in frame deb-res-nf do:
    find codfr where codfr.codfr = 'prasp' and codfr.code = tmon.prasp:screen-value no-lock no-error.
    if available codfr then praspdes = codfr.name[1].
                            else praspdes = ''.
    displ praspdes with frame deb-res-nf. pause 0.
end.

on "value-changed" of tmon.prasp in frame deb-nonres-nf do:
    find codfr where codfr.codfr = 'prasp' and codfr.code = tmon.prasp:screen-value no-lock no-error.
    if available codfr then praspdes = codfr.name[1].
                            else praspdes = ''.
    displ praspdes with frame deb-nonres-nf. pause 0.
end.



/* Классификация в реестре */
/*
on "value-changed" of tmon.pklass in frame deb-res-nf do:
    find codfr where codfr.codfr = 'pklass' and codfr.code = tmon.pklass:screen-value no-lock no-error.
    if available codfr then pklassdes = codfr.name[1].
                            else pklassdes = ''.
    displ pklassdes with frame deb-res-nf.
end.

on "value-changed" of tmon.pklass in frame deb-nonres-nf do:
    find codfr where codfr.codfr = 'pklass' and codfr.code = tmon.pklass:screen-value no-lock no-error.
    if available codfr then pklassdes = codfr.name[1].
                            else pklassdes = ''.
    displ pklassdes with frame deb-nonres-nf.
end.
*/


/* НОВАЯ ЛИНИЯ */
on "go" of browse bt do:
   if not yes-no ('', 'Добавить линию?') then leave.

   if v-res then
   do while true on endkey undo, return:
      create tmon.
      assign tmon.grp = v-grp
             tmon.ls = v-ls
             tmon.nf = v-nf
             tmon.df = v-df
             tmon.nk = v-nk
             tmon.dk = v-dk
             tmon.rnn = v-rnn
             tmon.country = v-countnum
             tmon.date = v-date
             tmon.ctime = v-ctime
             tmon.amt = v-dam
             tmon.nds = 12
             tmon.ser = v-ser
             tmon.num = v-num
             .

      update tmon.nk tmon.dk
             tmon.name tmon.descr
             tmon.edizm tmon.qty
             tmon.totsum
             tmon.oblsum
             tmon.nds tmon.sumnds
             tmon.aksum
             tmon.prasp
             with frame deb-res-nf
             editing:
                 readkey.
                 apply lastkey.
                 if frame-field = "edizm" then apply "value-changed" to tmon.edizm in frame deb-res-nf.
                 /* if frame-field = "pklass" then apply "value-changed" to tmon.pklass in frame deb-res-nf. */
                 if frame-field = "prasp" then apply "value-changed" to tmon.prasp in frame deb-res-nf.
             end.

      /*
      if lookup(trim(tmon.prasp), {&PRASP}) = 0 then tmon.pklass = ''. else update tmon.pklass with frame deb-res-nf.
      apply "value-changed" to tmon.pklass in frame deb-res-nf.
      displ tmon.pklass with frame deb-res-nf. pause 0.
      */

      /* 1 validate */
/*      find codfr where codfr.codfr = 'edizm' and codfr.code = tmon.edizm no-lock no-error.
      if not available codfr then do:
         message "Нет такой единицы измерения!" view-as alert-box title ''.
         delete tmon.
         next.
      end.
*/
      /* 2 validate */
/*
      find codfr where codfr.codfr = 'prasp' and codfr.code = tmon.prasp no-lock no-error.
      if not available codfr and tmon.prasp <> '' then do:
         message "Укажите признак для книги покупок!" view-as alert-box title ''.
         delete tmon.
         next.
      end.
*/
      /* 3 validate */
/*
      find codfr where codfr.codfr = 'pklass' and codfr.code = tmon.pklass no-lock no-error.
      if not available codfr and lookup(trim(tmon.prasp), {&PRASP}) > 0 then do:
         message "Укажите признак классификации!" view-as alert-box title ''.
         delete tmon.
         next.
      end.
*/
      leave.

   end.
   else do while true on endkey undo, return:
      create tmon.
      assign tmon.grp = v-grp
             tmon.ls = v-ls
             tmon.nf = v-nf
             tmon.df = v-df
             tmon.nk = v-nk
             tmon.dk = v-dk
             tmon.rnn = v-rnn
             tmon.country = v-countnum
             tmon.date = v-date
             tmon.ctime = v-ctime
             tmon.amt = v-dam
             tmon.nds = 12
             tmon.ser = v-ser
             tmon.num = v-num
             .

      update tmon.nk tmon.dk
             tmon.name tmon.descr
             tmon.edizm tmon.qty
             tmon.totsum
             tmon.nds
             tmon.sumnds
             tmon.taxsum
             tmon.ptsum
             tmon.prasp
             with frame deb-nonres-nf
             editing:
                 readkey.
                 apply lastkey.
                 if frame-field = "edizm" then apply "value-changed" to tmon.edizm in frame deb-nonres-nf.
                 /* if frame-field = "pklass" then apply "value-changed" to tmon.pklass in frame deb-nonres-nf. */
                 if frame-field = "prasp" then apply "value-changed" to tmon.prasp in frame deb-nonres-nf.
             end.

      /*
      if lookup(trim(tmon.prasp), {&PRASP}) = 0 then tmon.pklass = ''. else update tmon.pklass with frame deb-nonres-nf.
      apply "value-changed" to tmon.pklass in frame deb-nonres-nf.
      displ tmon.pklass with frame deb-nonres-nf. pause 0.
      */

      /* 1 validate */
/*      find codfr where codfr.codfr = 'edizm' and codfr.code = tmon.edizm no-lock no-error.
      if not available codfr then do:
         message "Нет такой единицы измерения!" view-as alert-box title ''.
         delete tmon.
         next.
      end.
*/
      /* 2 validate */
/*
      find codfr where codfr.codfr = 'prasp' and codfr.code = tmon.prasp no-lock no-error.
      if not available codfr and tmon.prasp <> '' then do:
         message "Укажите признак для книги покупок!" view-as alert-box title ''.
         delete tmon.
         next.
      end.
*/
      /* 3 validate */
/*
      find codfr where codfr.codfr = 'pklass' and codfr.code = tmon.pklass no-lock no-error.
      if not available codfr and lookup(trim(tmon.prasp), {&PRASP}) > 0 then do:
         message "Укажите признак классификации!" view-as alert-box title ''.
         delete tmon.
         next.
      end.
*/

      leave.

   end.

   if available tmon then do:

      v-nk = tmon.nk.
      v-dk = tmon.dk.
      displ v-nk v-dk with frame ft.

      close query qt.
      open query qt for each tmon.
      browse bt:refresh().

   end.

end.

/* ПРОСМОТР / РЕДАКТИРОВАНИЕ */
on "return" of browse bt do:
   if not available tmon then leave.

   if v-res then do while true on endkey undo, return:

      apply "value-changed" to tmon.edizm in frame deb-res-nf.
      /* apply "value-changed" to tmon.pklass in frame deb-res-nf. */
      apply "value-changed" to tmon.prasp in frame deb-res-nf.

      update tmon.nk tmon.dk
             tmon.name tmon.descr
             tmon.edizm tmon.qty
             tmon.totsum
             tmon.oblsum
             tmon.nds tmon.sumnds
             tmon.aksum
             tmon.prasp
             with frame deb-res-nf
             editing:
                 readkey.
                 apply lastkey.
                 if frame-field = "edizm" then apply "value-changed" to tmon.edizm in frame deb-res-nf.
                 /* if frame-field = "pklass" then apply "value-changed" to tmon.pklass in frame deb-res-nf. */
                 if frame-field = "prasp" then apply "value-changed" to tmon.prasp in frame deb-res-nf.
             end.

      /*
      if lookup(trim(tmon.prasp), {&PRASP}) = 0 then tmon.pklass = ''. else update tmon.pklass with frame deb-res-nf.
      apply "value-changed" to tmon.pklass in frame deb-res-nf.
      displ tmon.pklass with frame deb-res-nf. pause 0.
      */

      /* 1 validate */
/*      find codfr where codfr.codfr = 'edizm' and codfr.code = tmon.edizm no-lock no-error.
      if not available codfr then do:
         message "Нет такой единицы измерения!" view-as alert-box title ''.
         next.
      end.
*/
      /* 2 validate */
      find codfr where codfr.codfr = 'prasp' and codfr.code = tmon.prasp no-lock no-error.
      if not available codfr and tmon.prasp <> '' then do:
         message "Укажите признак для книги покупок!" view-as alert-box title ''.
         next.
      end.
      /* 3 validate */

      /*
      find codfr where codfr.codfr = 'pklass' and codfr.code = tmon.pklass no-lock no-error.
      if not available codfr and lookup(trim(tmon.prasp), {&PRASP}) > 0 then do:
         message "Укажите признак классификации!" view-as alert-box title ''.
         next.
      end.
      */

      leave.

   end.
   else do while true on endkey undo, return:

      apply "value-changed" to tmon.edizm in frame deb-nonres-nf.
      /* apply "value-changed" to tmon.pklass in frame deb-nonres-nf. */
      apply "value-changed" to tmon.prasp in frame deb-nonres-nf.

      update tmon.nk tmon.dk
             tmon.name tmon.descr
             tmon.edizm tmon.qty
             tmon.totsum
             tmon.nds
             tmon.sumnds
             tmon.taxsum
             tmon.ptsum
             tmon.prasp
             with frame deb-nonres-nf
             editing:
                 readkey.
                 apply lastkey.
                 if frame-field = "edizm" then apply "value-changed" to tmon.edizm in frame deb-nonres-nf.
                 /* if frame-field = "pklass" then apply "value-changed" to tmon.pklass in frame deb-nonres-nf. */
                 if frame-field = "prasp" then apply "value-changed" to tmon.prasp in frame deb-nonres-nf.
             end.

      /*
      if lookup(trim(tmon.prasp), {&PRASP}) = 0 then tmon.pklass = ''. else update tmon.pklass with frame deb-nonres-nf.
      apply "value-changed" to tmon.pklass in frame deb-nonres-nf.
      displ tmon.pklass with frame deb-nonres-nf. pause 0.
      */

      /* 1 validate */
/*      find codfr where codfr.codfr = 'edizm' and codfr.code = tmon.edizm no-lock no-error.
      if not available codfr then do:
         message "Нет такой единицы измерения!" view-as alert-box title ''.
         next.
      end.
*/
      /* 2 validate */
      find codfr where codfr.codfr = 'prasp' and codfr.code = tmon.prasp no-lock no-error.
      if not available codfr then do:
         message "Укажите признак для книги покупок!" view-as alert-box title ''.
         next.
      end.
      /* 3 validate */
      /*
      find codfr where codfr.codfr = 'pklass' and codfr.code = tmon.pklass no-lock no-error.
      if not available codfr and lookup(trim(tmon.prasp), {&PRASP}) > 0 then do:
         message "Укажите признак классификации!" view-as alert-box title ''.
         next.
      end.
      */

      leave.

   end.

   if available tmon then do:

      v-nk = tmon.nk.
      v-dk = tmon.dk.
      displ v-nk v-dk with frame ft.

      close query qt.
      open query qt for each tmon.
      browse bt:refresh().

   end.

end.

/* УДАЛЕНИЕ ЛИНИИ */
on "clear" of browse bt do:
   if not available tmon then leave.
   if not yes-no ('', 'Удалить линию?') then leave.

   delete tmon.
   browse bt:refresh().

   find first tmon no-error.
   if available tmon then do:

      v-nk = tmon.nk.
      v-dk = tmon.dk.
      displ v-nk v-dk with frame ft.

      close query qt.
      open query qt for each tmon.
      browse bt:refresh().

   end.

end.


/* КОНЕЦ РАБОТЫ */
on "help" of browse bt do:
   if not yes-no ('', 'Вы действительно хотите выйти из редактирования?') then leave.
   hide frame ft.
   apply "enter-menubar" to frame ft.
end.

on "endkey" of frame ft do:
/*   hide frame ft.  */
   return "no".
end.

on "end-error" of frame ft do:
/*   hide frame ft.  */
   return "no".
end.

on "endkey" of browse bt do:
/*   hide frame ft.  */
   return "no".
end.

on "end-error" of browse bt do:
/*   hide frame ft.  */
   return "no".
end.


/* - - - - - - - - - - - - - - - - - - - - - - - - - */
/*              ОСНОВНАЯ ЧАСТЬ                       */
/* - - - - - - - - - - - - - - - - - - - - - - - - - */

find debls where debls.grp = v-grp and debls.ls = v-ls no-lock no-error.
if not available debls then do:
   message "Не найден дебитор [" v-grp  " : " v-ls "] " view-as alert-box title ''.
   return "no".
end.
v-name = debls.name.

if v-nf = ? or v-df = ? then
do:
   update v-nf v-df /* v-nk v-dk */ with frame fnf.
   hide frame fnf.
end.

/* для резидентов - серия и номер св-ва постановки на учет по НДС */
find current debls.

if v-sel = 1 then v-rnn = debls.bingo. else v-rnn = debls.rnn.
v-ser = debls.ser.
v-num = debls.num.

if v-res then do: /* resident */
   if v-bin then update v-rnn v-ser v-num with frame getsernum1.
   else update v-rnn v-ser v-num with frame getsernum.
   if v-sel = 1 then if debls.bingo = '' then debls.bingo = v-rnn.
   if v-sel = 2 then if debls.rnn = '' then debls.rnn = v-rnn.
   if debls.ser = '' then debls.ser = v-ser.
   if debls.num = '' then debls.num = v-num.
end.
else do: /* non-resident */
   update v-countnum with frame getcountry.
   hide frame getcountry.
   if debls.country = '' then debls.country = v-countnum.
end.


find current debls no-lock.

if v-nf = "" and v-dk = ? then do: hide all. pause 0. return "yes". end.

/* если не введен счет-фактура, то сделаем внутреннюю нумерацию */
if v-nf = "0" then do:
   find last debmon no-lock use-index innf no-error.
   if available debmon then v-innf = debmon.innf + 1.
                       else v-innf = 1.
end.

/* номер и дата контракта */
find first tmon no-lock no-error.
if avail tmon then assign  v-nk = tmon.nk
                           v-dk = tmon.dk.

/* обновим постоянную информацию */
for each tmon:
    assign tmon.nf = v-nf
           tmon.df = v-df
           tmon.nk = v-nk
           tmon.dk = v-dk
           tmon.rnn = v-rnn
           tmon.country = v-countnum
           tmon.ser = v-ser
           tmon.num = v-num
           .
end.

open query qt for each tmon.
enable all with frame ft.

displ v-name v-nf v-df v-nk v-dk v-innf with frame ft.
pause 0.

wait-for "window-close" of current-window or "enter-menubar" of frame ft or "window-close" of frame ft focus browse bt.
hide frame ft.

/* обновим постоянную информацию */
for each tmon:
    assign tmon.nk = v-nk
           tmon.dk = v-dk
           tmon.rnn = v-rnn
           tmon.country = v-countnum
           tmon.ser = v-ser
           tmon.num = v-num.
end.

return "yes".


/* ------------------------------------------------------------ */

/* выбор наименования товара для дебитора в счете-фактуре */
procedure h-selectdebname.
{aapbra.i
      &head      = "codfr"
      &index     = "main no-lock"
      &formname  = "debmon"
      &framename = "hdebname"
      &where     = " codfr.codfr = 'debname' and codfr.code <> 'msc' "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "codfr.name[1]"
      &highlight = "codfr.name[1]"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do
                          on endkey undo, leave:
                           hide frame hdebname.
                           return codfr.name[1].
                    end."
      &end = "hide frame hdebname."
}
end procedure.
