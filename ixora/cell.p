/* cell.p
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
        8-1-8-15 
 * AUTHOR
        17/10/2005 dpuchkov
 * CHANGES
        15.03.2006 dpuchkov - очищаем ячейку если брак.
        01.02.10 marinav - расширение поля счета до 20 знаков
*/


  {global.i}
  def var v-dep as integer.
  def buffer b-cellx for cellx.
  def var vln as integer.
  def var i_cellnum as integer.
  def var i_cellsize as char.
  def var v-ans as logical.
  def var file1 as char format "x(20)".

/* validate(aas.bnf <> "", "Введите название налогового комитета (F2-поиск)") */
   file1 = "file1.html". 

define frame cellfr
   i_cellnum  format ">>>" label       "Номер ячейки. " validate(i_cellnum <> 0, "Введите номер сейфовой ячейки") skip
   cellx.type format "x(10)" label                    "Тип           " validate(cellx.type <> "" and (cellx.type = "Маленькая" or cellx.type = "Средняя" or cellx.type = "Большая"), "Неверный статус (Используйте F2)") skip
   cellx.sts  label                    "Статус        " validate(cellx.sts <> "" and (cellx.sts = "Свободна" or cellx.sts = "Занята" or cellx.sts = "Брак"), "Неверный статус (Используйте F2)") skip
   cellx.aaa  format "x(20)" label "ИИК.          " skip
   cellx.name format "x(50)" label     "Владелец      " skip
with side-labels centered row 8.


on help of cellx.type in frame cellfr do:
   run sel ("Выберите тип ячейки", "Маленькая|Средняя|Большая").
   if int(return-value) = 1 then cellx.type = "Маленькая". else
   if int(return-value) = 2 then cellx.type = "Средняя  ". else
   if int(return-value) = 3 then cellx.type = "Большая  ". 
   displ cellx.type with frame cellfr.
end.


on help of cellx.sts in frame cellfr do:
   run sel ("Выберите статус ячейки", "Свободна|Занята|Брак").
   if int(return-value) = 1 then cellx.sts = "Свободна". else
   if int(return-value) = 2 then cellx.sts = "Занята  ". else
   if int(return-value) = 3 then cellx.sts = "Брак    ".
   displ cellx.sts with frame cellfr.
end.


do transaction on error undo, return:
   run sel2 (" ДЕПОЗИТАРИЙ ", " Добавить ячейку | Отчет по ячейкам | Подключить данные к базе", output v-dep).
   if v-dep = 1 then do:  /*Добавить ячейку*/
      update i_cellnum  with frame cellfr.
      find last cellx where cellx.cell = i_cellnum exclusive-lock no-error.  
      if avail cellx then do:
         message "Ячейка " + string(cellx.cell) +  " уже существует. РЕДАКТИРОВАТЬ?" view-as alert-box question buttons yes-no title "" update v-ans.
         if not v-ans then do: undo, return. end. else 
         do:
            displ cellx.name cellx.sts cellx.aaa with frame cellfr.

            update cellx.type  /*cellx.name*/  with frame cellfr.
            update cellx.sts with frame cellfr.

if cellx.sts <> "Брак" and cellx.sts <> "Свободна"  then do:
            update cellx.aaa with frame cellfr.
            find last aaa where aaa.aaa = cellx.aaa no-lock no-error.
            find last cif where cif.cif = aaa.cif no-lock no-error.
            if avail cif and avail aaa then do:
                  cellx.name = cif.name.
                  displ cellx.name with frame cellfr.
            end.
end. 
if cellx.sts = "Свободна" then do:
   cellx.name = "".
   cellx.aaa  = "". 
end.
if cellx.sts = "Брак" then do:
   cellx.name = "".
   cellx.aaa  = "". 
end.

         end.
      end. else do:
           create cellx.
                  cellx.cell = i_cellnum.


 

           find last depo where depo.cellnum = string(cellx.cell) and depo.lstdt <= g-today and depo.prlngdate >= g-today  no-lock no-error.
           if avail depo then do:
              find last aaa where aaa.aaa = depo.aaa no-lock no-error.
              find last cif where cif.cif = aaa.cif no-lock no-error.
           end.
           if avail depo and avail cif and avail aaa then do:
                 cellx.aaa  = depo.aaa.
                 cellx.name = cif.name.
                 cellx.sts = "Занята".
                 cellx.type = depo.cellsize.
                 displ cellx.type cellx.name cellx.sts cellx.aaa with frame cellfr.
/*               update cellx.aaa with frame cellfr.*/
                 find last aaa where aaa.aaa = cellx.aaa no-lock no-error.
                 if not avail aaa then do: message "Счет не найден". pause. undo, return. end.
                 find last cif where cif.cif = aaa.cif no-lock no-error.
                 cellx.name = cif.name.
                 displ cellx.name with frame cellfr.
/*                 update cellx.sts with frame cellfr.*/


           end.
           else
           do:
             update cellx.type with frame cellfr.
             update cellx.sts with frame cellfr.	 
if cellx.sts <> "Брак" and cellx.sts <> "Свободна"  then do:
             update cellx.aaa with frame cellfr.
             find last aaa where aaa.aaa = cellx.aaa no-lock no-error.
             if not avail aaa then do: message "Счет не найден". pause. undo, return. end.
             find last cif where cif.cif = aaa.cif no-lock no-error.
             cellx.name = cif.name.
             displ cellx.name with frame cellfr.
end.
           end.
      end.
   end.

   if v-dep = 2 then do: /* Отчет по ячейкам */
      output to value(file1).
{html-title.i} 
        put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Отчет по зарегистрированным сейфовым ячейкам" "<BR>" skip
        " <br>  </br></P>"
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
        put unformatted                         
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>Номер ячейки<br>п/п</TD>" skip
        "<TD>Тип ячейки</TD>" skip
        "<TD>Статус</TD>" skip
        "<TD>ИИК</TD>" skip
        "<TD>Владелец</TD>" skip.
        for each cellx where cellx.type = "Маленькая"  no-lock break by  integer(cellx.cell) :
              put unformatted
                   "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                   "<TD>" cellx.cell "</TD>" skip
                   "<TD>" cellx.type "</TD>" skip
                   "<TD>" cellx.sts  "</TD>" skip.
if cellx.aaa <> "" then 
              put unformatted
                   "<TD> '" cellx.aaa  "</TD>" skip.
else
              put unformatted
                   "<TD> " cellx.aaa  "</TD>" skip.
              put unformatted
                   "<TD>" cellx.name "</TD>" skip.
 
        end.
        for each cellx where cellx.type = "Средняя"  no-lock break by  integer(cellx.cell) :
              put unformatted
                   "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                   "<TD>" cellx.cell "</TD>" skip
                   "<TD>" cellx.type "</TD>" skip
                   "<TD>" cellx.sts  "</TD>" skip.
if cellx.aaa <> "" then 
              put unformatted
                   "<TD> '" cellx.aaa  "</TD>" skip.
else
              put unformatted
                   "<TD> " cellx.aaa  "</TD>" skip.
              put unformatted
                   "<TD>" cellx.name "</TD>" skip.
 
        end.
        for each cellx where cellx.type = "Большая"  no-lock break by  integer(cellx.cell) :
              put unformatted
                   "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                   "<TD>" cellx.cell "</TD>" skip
                   "<TD>" cellx.type "</TD>" skip
                   "<TD>" cellx.sts  "</TD>" skip.
if cellx.aaa <> "" then 
              put unformatted
                   "<TD> '" cellx.aaa  "</TD>" skip.
else
              put unformatted
                   "<TD> " cellx.aaa  "</TD>" skip.
              put unformatted
                   "<TD>" cellx.name "</TD>" skip.
 
        end.



        {html-end.i " "}
        output close .  
        unix silent cptwin value(file1) excel.
   end.
   if v-dep = 3 then do: /* Подключение базы */
      message "Внимание: Проверьте достоверность всей введенной информации. " skip "Подключить данные к АБПК ПРАГМА?" view-as alert-box question buttons yes-no title "" update v-ans1 as logical.
      if v-ans1 = True then do:
         find sysc where sysc.sysc= "CELLX" exclusive-lock no-error.
         if avail sysc then do:
            if sysc.chval = "1"  then do: message "Данные уже подключены". pause.   end.
            else
            if sysc.chval = "0"  then do: sysc.chval = "1". message "Данные по ячейкам УСПЕШНО ПРОГРУЖЕНЫ". pause.  end.
           
         end. else do:
              message "Не найдена системная переменная". pause.
         end.
      end.
      else do:
          message "Данные по ячейкам НЕ ПРОГРУЖЕНЫ". pause.
      end.
   end.
end.


