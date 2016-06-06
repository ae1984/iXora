/* seif.i
 * MODULE
        ДЕПОЗИТАРИЙ
 * DESCRIPTION
        Пролонгация срока аренды сейфовой ячейки
 * RUN

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        31.05.2005 dpuchkov
 * CHANGES
   depo.prim2 - признак удаления "del"
        02.04.06 - dpuchkov исключил дублирование номеров ячеек
        04.05.06 - dpuchkov  закомментарил льготный период(Служебка от 03.05.06)
*/


  def var dt_date as date.
  def var iiday   as integer.
  def var iimonth as integer.
  def var iiyear  as integer.
  def var dsum as decimal decimals 2.
  define buffer b-depo for depo.
  def var return_choice as logical.
  def var lgottarif as logical init False.


  find last aaa where aaa.aaa = v-aaa no-lock no-error.
  for each b-depo where b-depo.aaa = v-aaa  and b-depo.prim2 <> "del" no-lock break by b-depo.f1  :
    i_ind =  f1.
  end.
  find last b-depo where b-depo.aaa = v-aaa and b-depo.prim2 <> "del" and b-depo.f1 = i_ind no-lock no-error .


  def var lgotsum as decimal decimals 2.
  def var lgotperiod as logical init False.
  def var usualperiod as logical init False.

  define frame fr2
    v-aaa label                                 "Номер счета             " format "x(9)" skip
    depo.cellnum format "x(20)"  label          "Номер арендуемой ячейки " skip
    depo.cellsize format "x(20)" label          "Тип ячейки              " skip
    depo.cell1 format "x(9)"  label             "Депозит                 " skip
    usualperiod label                           "Обычный период?         " skip
    depo.lstdt label                            "Начало аренды обычный   " skip
    depo.prlngdate label                        "Оконч. аренды обычный   " skip
    lgottarif label                             "Льготный тариф?         " skip
    depo.sum format "->>>,>>>,>>>,>>9.99" label "Сумма аренды за период  " skip
/*  lgotperiod label                            "Льготный период?        " skip
    depo.dt1 label                              "Начало аренды льготный  " skip
    depo.dt2 label                              "Оконч. аренды льготный  " skip
    lgotsum format "->>>,>>>,>>>,>>9.99" label  "Сумма за льготный период" skip  */
  with side-labels centered row 6.

  on help of depo.cellsize in frame fr2 do:
     run sel ("Выберите тип сейфовой ячейки", "Маленькая|Средняя|Большая").
     if int(return-value) = 1 then depo.cellsize = "Маленькая".
     if int(return-value) = 2 then depo.cellsize = "Средняя".
     if int(return-value) = 3 then depo.cellsize = "Большая".
     display depo.cellsize with frame fr2.
  end.

do transaction:

         create depo.
          depo.aaa = v-aaa.
          if avail b-depo then do:
             depo.f1    = b-depo.f1 + 1.
             depo.cellsize = b-depo.cellsize.
             depo.cellnum  = b-depo.cellnum.
          end.

          displ v-aaa  depo.cell1 with frame fr2.
          find sysc where sysc.sysc= "CELLX" exclusive-lock no-error.
repeat:
          if avail sysc and sysc.chval = "1" then do:
             update depo.cellsize validate (depo.cellsize = "Маленькая" or depo.cellsize = "Средняя" or depo.cellsize = "Большая", "Неверный тип. Используйте - F2 для выбора ") with frame fr2. 
             def var cellnum as integer init 0.

if depo.cellnum = "" then do:
             for each cellx where cellx.type = depo.cellsize and cellx.sts = "Свободна" no-lock break by integer(cellx.cell):
                 cellnum = cellx.cell. leave.
             end.
             if cellnum = 0 then do: message "Свободная ячейка не найдена. Продолжение невозможно". return. end.
/*           depo.cellnum = string(cellx.cell). */
             depo.cellnum = string(cellnum).

end.
             displ depo.cellnum with frame fr2.


    find last cellx where cellx.cell = integer(depo.cellnum) exclusive-lock no-error.
    if avail cellx then do:
        find last cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
           cellx.aaa  = depo.aaa.
           cellx.name = cif.name.
           cellx.sts = "Занята".
           cellx.type = depo.cellsize.
        end.
    end.

    repeat:
       update depo.cell1 with frame fr2.
       if depo.cell1 <> "" then do:
          find last aaa where aaa.aaa = depo.cell1 no-lock no-error.
          if not avail aaa then do:
             message "Депозит не существует". pause.

          end. else leave.
       end.
       else leave.
    end.


             update usualperiod with frame fr2.
             if usualperiod = True then do:  /* Обычный период */

repeat:
depo.lstdt = ?.
depo.prlngdate = ?.
             update depo.lstdt     validate (depo.lstdt <> ?, "Введите дату") 
                    depo.prlngdate validate (depo.prlngdate <> ?, "Введите дату" ) with frame fr2.
     if depo.prlngdate <= depo.lstdt then 
        do: message "Дата окончания должна быть > нач.даты". pause. end.
     else
       leave.
end.
             end.


             find last cif where cif.cif = aaa.cif no-lock no-error.
             find last cellx where cellx.cell = cellnum exclusive-lock no-error.
             if avail cellx then do:
                cellx.type = depo.cellsize.
                cellx.sts  = "Занята".
                cellx.aaa  = v-aaa.
                if avail cif then cellx.name = cif.name.
             end.
          end.


          run DayCount(depo.lstdt, depo.prlngdate, output iiyear, output iimonth, output iiday).
          depo.mon = (iiyear * 12) + iimonth.


          {depo.i}
if usualperiod = True then
  update lgottarif with frame fr2.

if not lgottarif then  do:
          depo.sum = dsum.
end.
else do:
   update depo.sum with frame fr2.
end.

          depo.pr  = "0".
          depo.lev = "0".
          depo.prim1 = "0".
          displ depo.sum with frame fr2.
/*        depo.prim2 = string(g-today) + "   " + string(g-ofc). */
          depo.prlngperiod = string(g-today) + " " + string(g-ofc) + " " + string(time,"hh:mm:ss").

if usualperiod = True and (depo.lstdt = ? or depo.prlngdate = ?) then next.

/* repeat: */
/*          update lgotperiod validate (lgotperiod = True or usualperiod = True, "Необходимо выбрать один из периодов") with frame fr2.*/

/*
          if lgotperiod = True then do: 

 depo.dt1 = ?.
 depo.dt2 = ?.
             update depo.dt1 validate (depo.dt1 <> ?, "Дата неверна")
                    depo.dt2 validate (depo.dt2 <> ?, "Дата неверна") with frame fr2.

            if depo.dt2 <= depo.dt1 then 
               do: message "Дата окончания должна быть > нач.даты". pause. end.
            else
            if (string(depo.lstdt) = ? and string(depo.prlngdate) = ?) or (depo.dt2 = depo.lstdt and depo.dt1 < depo.lstdt) or (depo.dt1 = depo.prlngdate and depo.dt2 > depo.prlngdate) then do:

            end.
            else do: message "Льготный период не может перекрывать основной. ". pause. next. end.

 
 end. else */  leave.



/*  if lgotperiod = True then      do:
         update lgotsum with frame fr2. depo.prim1 = string(lgotsum).
  leave.
  end. */

/*  end. */
  if lgotperiod = False then do:
     depo.dt1 = ?.
     depo.dt2 = ?.
  end.






          if v-sumall <> lgotsum + depo.sum then do:
             message "Внимание введённые вами суммы не совпадают с расчетными: " skip
                     "ВНЕСЕНО:   " trim(string(v-sumall,'zzz,zzz,zz9.99'))       skip
                     "РАССЧИТАНО:" trim(string(lgotsum + depo.sum,'zzz,zzz,zz9.99')) skip view-as alert-box.
  hide frame fr2.
  view frame uni_main.
  /* undo, return. */
               leave.
          end.
          else do:
               leave.
          end.




end.

 end.

hide frame fr2.
