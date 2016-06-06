/* dcls23.p
 * MODULE
        Операционист
 * DESCRIPTION
        Расчет комиссии по сейфовым ячейкам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        cif-new2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.2
 * AUTHOR
        25.05.2005 dpuchkov
 * CHANGES
       03.04.2006 dpuchkov - добавил новый алгоритм по расчету ячеек ТЗ-293.
	*/
def var m15 	 as integer.
def var m18 as integer.
def var mD as integer.
        m15 = 0. m18 = 0.

/* Алгоритм расчета добавлен 04.04.06 ТЗ-293 */
        mD = (iiyear * 12) + iimonth.
        if mD > 14 then do:
              iiyear = 0. iimonth = 0.
              m18 = truncate(mD / 18, 0).
              mD = mD - (truncate(mD / 18, 0) * 18).
              m15 = truncate(mD / 15, 0).
              mD = mD - (truncate(mD / 15, 0) * 15).
              iiyear = truncate(mD / 12, 0).
              mD = mD - (truncate(mD / 12, 0) * 12).
              iimonth = truncate(mD / 1, 0).
        end.
/* Алгоритм расчета добавлен 04.04.06 ТЗ-293 */

        /*За количество лет*/
        find last depoval where depoval.period = "12mon" no-lock no-error.
        if avail depoval then do:
            if depo.cellsize = "Маленькая" then  dsum = iiyear * depoval.small.
            if depo.cellsize = "Средняя"   then  dsum = iiyear * depoval.average.
            if depo.cellsize = "Большая"   then  dsum = iiyear * depoval.big.
        end.

  find last depoval where depoval.period = "15mon" no-lock no-error.
  if avail depoval then do:
      if depo.cellsize = "Маленькая" then  dsum = dsum + (m15 * depoval.small).
      if depo.cellsize = "Средняя"   then  dsum = dsum + (m15 * depoval.average).
      if depo.cellsize = "Большая"   then  dsum = dsum + (m15 * depoval.big).
  end.
  find last depoval where depoval.period = "18mon" no-lock no-error.
  if avail depoval then do:
     if depo.cellsize = "Маленькая" then  dsum = dsum + (m18 * depoval.small).
     if depo.cellsize = "Средняя"   then  dsum = dsum + (m18 * depoval.average).
     if depo.cellsize = "Большая"   then  dsum = dsum + (m18 * depoval.big).
  end.

         /*За количество месяцев*/                      
         
         find last depoval where depoval.period = string(iimonth) + "mon"  no-lock no-error.
         if avail depoval then do:
            if depo.cellsize = "Маленькая" then dsum = dsum + depoval.small.
            if depo.cellsize = "Средняя"   then dsum = dsum + depoval.average.
            if depo.cellsize = "Большая"   then dsum = dsum + depoval.big.
         end.
         /*За количество дней если больше 10 дней*/
         find last depoval where depoval.period = "10day" no-lock no-error.
         if avail depoval then do:                                           
             if depo.cellsize = "Маленькая" then dsum = dsum + (truncate(iiday / 10, 0) * depoval.small) .
             if depo.cellsize = "Средняя"   then dsum = dsum + (truncate(iiday / 10, 0) * depoval.average).
             if depo.cellsize = "Большая"   then dsum = dsum + (truncate(iiday / 10, 0) * depoval.big).
         end.
         /*За количество дней если меньше 10 дней*/
         find last depoval where depoval.period = "1day" no-lock no-error.
         if avail depoval then do:
             if depo.cellsize = "Маленькая" then dsum = dsum + ((iiday - (truncate(iiday / 10, 0) * 10)) * depoval.small).
             if depo.cellsize = "Средняя"   then dsum = dsum + ((iiday - (truncate(iiday / 10, 0) * 10)) * depoval.average).
             if depo.cellsize = "Большая"   then dsum = dsum + ((iiday - (truncate(iiday / 10, 0) * 10)) * depoval.big).
         end.
