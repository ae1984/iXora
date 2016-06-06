/* push.i
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Описание стандартных переменных и параметров
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        28/03/05 sasco
 * CHANGES
*/

/*  ID отчета  */
def {1} shared var vid as int.

/*  дата  */
def {1} shared var vdt as date.

/*  период  */
def {1} shared var vd1 as date.
def {1} shared var vd2 as date.

/*  параметры */
def {1} shared var vparams as char.

/*  параметры файла  */
def {1} shared var vprefix as char.
def {1} shared var vfname as char.

/*  процедура запуска  */
def {1} shared var vproc as char.

/*  куда копировать отчет  */
def {1} shared var vhost as char.
def {1} shared var vpath as char.

/*  сотрудник  */
def {1} shared var vofc as char.

/*  результат - прошел отчет (yes) или нет (no)  */
def {1} shared var vres as logical.

/*  описание ошибки (если есть необходимость) */
def {1} shared var vrdes as char.

/*  текущие параметры времени */
def {1} shared var vdate as int.
def {1} shared var vmont as int.
def {1} shared var vquar as int.
def {1} shared var vyear as int.


/*  Функция генерации даты - передается день, месяц, год, вид даты месяца ("beg"-начало, "end"-конец) */
function GenDate returns date (fm as int, fy as int, ftype as char).
def var vfm as int.
def var vfy as int.
def var delta as int.
         
         vfm = fm.
         vfy = fy.
         if ftype <> "beg" and ftype <> "end" then return ?.

         repeat:
         
                if vfm >= 1 and vfm <= 12 then leave.
                
                if vfm < 1 then do:
                   vfm = 12 - vfm.
                   vfy = vfy - 1.
                end.
                
                if vfm > 12 then do:
                   vfm = vfm - 12.
                   vfy = vfy + 1.
                end.
         end.

         if ftype = "beg" then return date ("01/" + string(vfm) + "/" + string(vfy)).
         else do: /* end */
                  vfm = vfm + 1.
                  if vfm = 13 then do: vfy = vfy + 1. vfm = 1. end.
                  return date ("01/" + string(vfm) + "/" + string(vfy)) - 1.
         end.

end function.


/*  корректировка дня, месяца, года и квартала  */
procedure update_dates.
   
   def input parameter fromdt as date.

   vdate = DAY (fromdt).
   vmont = MONTH (fromdt).
   vyear = YEAR (fromdt).
   vquar = 0.
   case vmont:

        when 1 OR 
        when 2 OR 
        when 3 then vquar = 1.
        
        when 4 OR 
        when 5 OR 
        when 6 then vquar = 2.

        when 7 OR 
        when 8 OR 
        when 9 then vquar = 3.

        when 10 OR 
        when 11 OR 
        when 12 then vquar = 4.

   end.

end procedure.



/* -------------------------------- */

if "{1}" = "new" then do:
   vres = no.
   vrdes = "".
   run update_dates (g-today).
end.


define buffer b-pushrep for pushrep.

procedure help-pushid.
          {skappbra.i
                &head      = "b-pushrep"
                &index     = "id no-lock"
                &formname  = "help-push"
                &framename = "hid"
                &where     = " "
                &addcon    = "false"
                &deletecon = "false"
                &display   = "b-pushrep.id b-pushrep.des"
                &highlight = "b-pushrep.id b-pushrep.des"
                &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                                    on endkey undo, leave:
                                     frame-value = b-pushrep.id.
                                     hide frame hid.
                                     return.  
                              end."
                &end = "hide frame hid."
          }          
end.
