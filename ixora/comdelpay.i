/* comdelpay.i
 * MODULE
      Коммунальные платежи 
 * DESCRIPTION
  
  Удаление платежей - ОБЩАЯ ДЛЯ ВСЕХ
  Прописывает в нужную таблицу причину удаления

  -----------------------------------------------------

  &tbl        имя таблицы
  &tbldate    название поля таблицы с датой 
  &tbluid     название поля таблицы с логином менеджера
  &tbldnum    название поля таблицы с номером документа
  &tblwhy     название поля таблицы с причиной удаления
  &tblwdnum   название поля таблицы со ссылкой на номер нового платежа
  &tbldeluid  название поля таблицы с удалившим менеджером 
  &tbldeldate название поля таблицы с датой удаления

  &whylist    список допустимых номеров причин для удаления

  &tblrnn
  &tblsum

  &whereRNN
  &whereSUM
  &whereALL
        
  &exceptRNN
  &exceptSUM
  &exceptALL

  &olddate    переменная с датой текущего платежа
  &oldtxb     переменная с кодом филиала
  &olduid     переменная с логином менеджера
  &olddnum    переменная с номером платежа
  &where      дополнительное условие

  -----------------------------------------------------
  
 * RUN
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
 * AUTHOR
     24.09.2003 sasco
 * CHANGES
     08.10.2003 sasco Переделал логику удаления
     13.10.2003 sasco Добавил пункт "Другая причина" в список причин для удаления
*/

define variable pd-rid as rowid.
define variable pd-list as character no-undo.
define variable pd-why as character no-undo.
define variable pd-num as integer no-undo.
define variable pd-ndate as date no-undo.
define variable pd-ndoc as integer no-undo.
define variable pd-candel as log no-undo.
define variable pd-logic as log no-undo.

define variable pd-valid as char.
define variable pd-array as character extent 4 initial 
                ["Неправильный РНН", "Неправильная сумма", "Повторно набранный платеж", "Другая причина"].
define buffer buftable for {&tbl}.


/* СтершеКассировость человека */
pd-candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if not available sysc then pd-candel = no.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then pd-candel = no.

/* Инициализация */
pd-rid = rowid ({&tbl}).
pd-why = ''.
pd-ndoc = ?.
pd-ndate = today.
pd-list = "".
do pd-num = 1 to num-entries ("{&whylist}", ","):

   pd-list = pd-list + "|" + pd-array [ integer ( entry ( pd-num, "{&whylist}", "," ) ) ].

end.
if pd-list ne "" then pd-list  = SUBSTR (pd-list, 2). 

/* ########################################################################## */

if pd-candel then do: /* Старший менеджер */

   do while pd-why = '':
      update pd-why format "x(300)" with frame getwhyframe overlay row 5 centered 
                    top-only scrollable no-label title 'Укажите причину удаления платежа'.
      pd-why = trim(pd-why).
      if pd-why = '' then message "Вы должны указать причину удаления!" view-as alert-box title 'Ошибка'.
   end.
   hide frame getwhyframe.

end. /* pd-candel = YES */

/* ########################################################################## */

else do: /* Простой смертный */

   run sel ("Выберите причину", pd-list).
   pd-why = return-value.
   pd-num = ?.

   /* получим относительный номер причины */
   pd-num = integer (pd-why) no-error.
   if pd-num = ? then do:
      message "Ошибка выбора!" view-as alert-box title ' '.
      find {&tbl} where rowid ({&tbl}) = pd-rid no-error.
      return.
   end.

   /* получим абсолютный номер причины */
   pd-why = trim (entry (pd-num, pd-list, "|")).
   do pd-ndoc = 1 to 4:
      if pd-array[pd-ndoc] = pd-why then pd-num = pd-ndoc.
   end.

   if pd-num = 4 then do: /* Указать причину вручную */
      pd-why = ''.
      pd-ndoc = ?.
      do while pd-why = '':
         update pd-why format "x(300)" with frame getwhyframe overlay row 5 centered 
                       top-only scrollable no-label title 'Укажите причину удаления платежа'.
         pd-why = trim(pd-why).
         if pd-why = '' then message "Вы должны указать причину удаления!" view-as alert-box title 'Ошибка'.
      end.
      hide frame getwhyframe.
      pd-why = pd-array[4] + ": " + pd-why.
      pd-logic = true.
   end.
   else do: /* запрос на новый документ */

   pd-ndoc = 0.
   pd-ndate = {&tbl}.{&tbldate}.

/* ########################################################################## */

   /* Попытка найти платеж автоматически ... */
   find buftable where buftable.txb = {&oldtxb} and
                       buftable.{&tbldate} = pd-ndate and
                       buftable.{&tbldnum} <> {&tbl}.{&tbldnum} and
                       buftable.{&tbluid} = {&olduid} and
                       buftable.{&tbldeluid} = ? and
                       {&wherebuffer} and
                             (
                               (pd-num = 1 and ({&whereRNN})) or
                               (pd-num = 2 and ({&whereSUM})) or
                               (pd-num = 3 and ({&whereALL})) 
                             )
                            no-lock no-error.

   pd-logic = false.

   /* Если нашли платеж автоматически - сравним его с буфером ... */
   if available buftable then do:
   
      case pd-num:
        when 1 then buffer-compare {&tbl} except {&exceptRNN} to buftable save result in pd-logic.
        when 2 then buffer-compare {&tbl} except {&exceptSUM} to buftable save result in pd-logic.
        when 3 then buffer-compare {&tbl} except {&exceptALL} to buftable save result in pd-logic.
      end case.

      if pd-logic then assign pd-ndate = buftable.{&tbldate}
                              pd-ndoc  = buftable.{&tbldnum}.

   end.
   /* Если не получилось - запросим номер документа ... */
   else do:

      displ  skip
              pd-why format "x(40)" label "Причина"
             skip (1)
             "Не удалось найти новый платеж. Укажите вручную!"
             skip
             "          " pd-ndoc format "zzzzzzzz9" label "Номер нового пл." 
             with row 5 1 column centered side-labels overlay frame getndoc title "Не найден новый платеж".

      update pd-ndoc with frame getndoc.
      hide frame getndoc.

      pd-logic = false.
      find buftable where rowid (buftable) = rowid ({&tbl}) no-lock no-error.
      find first {&tbl} where {&tbl}.txb = {&oldtxb} and 
                              {&tbl}.{&tbldate} = pd-ndate and
                              {&tbl}.{&tbluid} = {&olduid} and
                              {&tbl}.{&tbldnum} = pd-ndoc and
                              {&tbl}.{&tbldnum} <> {&olddnum} and
                              {&tbl}.{&tbldeluid} = ? and
                              {&wherebuffer} 
                             no-lock no-error.


      if not available {&tbl} then do:
         message "Вы не можете указать этот номер платежа~nНе ваш платеж или платеж не найден" view-as alert-box title ' '.
         find {&tbl} where rowid ({&tbl}) = pd-rid no-error.
         return.
      end.

      /* Сравним платеж с буфером ... */ 
      case pd-num:
 
        when 1 then do: buffer-compare {&tbl} except {&exceptRNN} to buftable save result in pd-logic.
                        if {&tbl}.{&tblrnn} = buftable.{&tblrnn} then pd-logic = false.
                   end.
        
        when 2 then do: buffer-compare {&tbl} except {&exceptSUM} to buftable save result in pd-logic.
                        if {&tbl}.{&tblsum} = buftable.{&tblsum} then pd-logic = false.
                   end.
        
        when 3 then do: buffer-compare {&tbl} except {&exceptALL} to buftable save result in pd-logic.
                   end.

      end case.

      if not pd-logic then do:
         message "Вы не можете указать этот номер платежа~nНе ваш платеж или платеж не найден" view-as alert-box title ' '.
         find {&tbl} where rowid ({&tbl}) = pd-rid no-error.
         return.
      end.

   end. /* запрос номера */

   end. /* запрос на новый документ */

   if not pd-logic then do:
      message "Вы не можете указать этот номер платежа~nНе ваш платеж или платеж не найден" view-as alert-box title ' '.
      find {&tbl} where rowid ({&tbl}) = pd-rid no-error.
      return.
   end.

end. /* pd-candel = NO */

   
/* ########################################################################## */
/* ########################################################################## */

/* отметим платеж как удаленный */
find first {&tbl} where {&tbl}.txb = {&oldtxb} and
                        {&tbl}.{&tbldate} = {&olddate} and
                        {&tbl}.{&tbldnum} = {&olddnum} and
                        {&tbl}.{&tbluid} = {&olduid} and
                        {&tbl}.{&tbldeluid} = ? and
                        {&where} no-lock no-error.
if not available {&tbl} then do: message "Нет записи для удаления!" view-as alert-box title 'Ошибка'. return. end.

for each {&tbl} where {&tbl}.txb = {&oldtxb} and
                      {&tbl}.{&tbldate} = {&olddate} and
                      {&tbl}.{&tbldnum} = {&olddnum} and
                      {&tbl}.{&tbluid} = {&olduid} and
                      {&tbl}.{&tbldeluid} = ? and
                      {&where} :

    ASSIGN 
           {&tbl}.{&tbldeldate} = pd-ndate
           {&tbl}.{&tblwhy}   = TRIM (pd-why)
           {&tbl}.{&tblwdnum} = pd-ndoc
           NO-ERROR.

end.

find {&tbl} where rowid ({&tbl}) = pd-rid no-error.

