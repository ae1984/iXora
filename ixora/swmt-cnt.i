/* swmt-cnt.i
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
 * CHANGES
        10.05.2010 k.gitalov добавил функции GetContent,GetType,FreeContent, изменил алгоритм заполнения полей
        20.07.2011 Luiza добавила вывод подсказки для поля = "50" и тип "F".
        14.02.2012 aigul - recompile
        16.02.2012 aigul - reocmpile
        02.09.2013 evseev - tz-926
*/

/*** KOVAL Ввод свифтовых макетов ***/

def var tmpstr2 as char init "".
def var resultt as log init true.
def var result1 as log init true.
def var result2 as log init true.
def var v-code as char.

def var contentt as char init "".
def var content1 as char init "".
def var content2 as char init "".
def var content3 as char init "".
def var symbi as integer init 0.

/* Определение и обработчиков фрейма для ввода содержимого полей макета */

    /* MT100				 */
    /* для полей 52, 53, 54, 56, 57      */
    /* 59 - Cчет, наименование (RW)      */
    /* 71 BEN/OUR 			 */
    /* 50, 4 строки наименование клиента */
    /* При 56  поле 57 обязательно       */
    /* При 53Б появляется тип К или Н    */

def frame ord-info
 contentt format "x(3)"  view-as text at 1 swin.type       format "x(1)"  at 6 validate (resultt,err)
 content1 format "x(15)" view-as text at 9 swin.content[1] format "x(35)" at 25 validate (result1,err) skip
 content2 format "x(15)" view-as text at 9 swin.content[2] format "x(35)" at 25 validate (result2,err) skip
 content3 format "x(15)" view-as text at 9 swin.content[3] format "x(35)" at 25 skip
					   swin.content[4] format "x(35)" at 25 skip
			    		   swin.content[5] format "x(35)" at 25 skip
 			    		   swin.content[6] format "x(35)" at 25
 with no-label overlay row 16 size 80 by 6.

 on help of swin.type in frame ord-info do:
   message "Допустимые значения типа: " + swin.feature.
 end.

 on help of swin.content in frame ord-info do:
     {swmt-hlp.i}
 end.

/***********k.gitalov***********************************************/

{swiban.i}
 function GetContent returns log (input Level as int , input NM as char):
   def buffer b-swin for swin.
   find first b-swin where b-swin.swfield = NM no-lock no-error.
   if avail b-swin then
   do:
     if b-swin.content[Level] = "" or b-swin.content[Level] = "NONE" then return false.
     else return true.
   end.
   else return false.
 end function.
/*******************************************************************/
 function GetType returns char (input NM as char):
   def buffer b-swin for swin.
   find first b-swin where b-swin.swfield = NM no-lock no-error.
   if avail b-swin then
   do:
     return b-swin.type.
   end.
   else return "".
 end function.
/*******************************************************************/
 function FreeContent returns log (input Level as int , input NM as char):
   def buffer b-swin for swin.
   def var i as int.
   find first b-swin where b-swin.swfield = NM no-lock no-error.
   if avail b-swin then
   do:
     if Level > 0 and Level < 6 then
     do:
        b-swin.content[Level] = "".
     end.
     else do:
       repeat i=1 to 6:
        b-swin.content[i] = "".
       end.
     end.
     apply "value-changed" to self.
    return true.
   end.
   else return false.
 end function.
/*******************************************************************/

 /* Проверка на типы полей A, B, D, N */
 on leave of swin.type in frame ord-info do:
    assign err = '' resultt = TRUE.
    swin.type:screen-value = caps(swin.type:screen-value).
    tmpstr = swin.type:screen-value.

    /*if lookup(tmpstr,swin.feature) = 0 then do:
         assign resultt = false err = 'Допустимые значения: ' + swin.feature.
         return.
    end.*/
    if swin.content[1]:screen-value="NONE" then swin.content[1]:screen-value="".
    /* Формируем внешний вид фрейма */
    case tmpstr:
        when 'A' then do: /* Cчет(RW), BIC (RW), Bank name (RO) */
                     disable swin.content[3] swin.content[4] swin.content[5] swin.content[6] with frame ord-info.
                     swin.content[5]:screen-value="".
                     swin.content[6]:screen-value="" .
	             resultt = true.
		     contentt:screen-value="Тип".
		     content1:screen-value="        /Счет:".
		     content2:screen-value="    Swift-код:".
		     content3:screen-value="  Наименование:".



		     if swmt = '103' then swin.type = tmpstr.


        end.
        when 'B' then do: /* Cчет(RW), Корреспондент отправителя (RW) */
             disable swin.content[3] swin.content[4] swin.content[5] swin.content[6] with frame ord-info.
             swin.content[3]:screen-value="".
             swin.content[4]:screen-value="".
             swin.content[5]:screen-value="".
             swin.content[6]:screen-value="".
             resultt = true.
	     find first swspr where swspr.swspr="CORR" and swspr.chval = destination no-lock no-error.
	     if not avail swspr then do:
            run savelog("swiftmaket", "swmt-cnt.i 152. " + destination).
         end.
         contentt:screen-value="Тип".
	     content1:screen-value="        /Счет:".
	     content2:screen-value="Корреспондент:".
	     content3:screen-value="".

             /* Выбираем коррсчет, для RUR бывает два вида */
	     if remtrz.tcrc = 4 then do:
		     run sel("Выберите значение","Тип К|Тип Н").
		     swin.content[1] = "/" + entry(integer(return-value), swspr.descr, ",") no-error.
		     /*swin.content[2] = ".".*/
		     swin.content[2] = "".
	     end.
	     else swin.content[1] = "/" + entry(1, swspr.descr)  no-error.
	     /*swin.content[2]:screen-value=".".*/
	     swin.content[2]:screen-value="".

 	     swin.content[1]:screen-value = swin.content[1].
        end.
        when 'D' or when 'K' then do: /* Cчет(RW), Наименование (RW) */
             disable swin.content[6] with frame ord-info.
             swin.content[6]:screen-value="".
             resultt = true.
	     contentt:screen-value="Тип".
	     content1:screen-value="        /Счет:".
	     content2:screen-value="        Адрес:".
	     content3:screen-value="".

	     if swmt = '103' then swin.type = tmpstr.
        end.
/* Luiza ---------------------------------------------------------------------------------*/
        when 'F' then if swin.swfield = "50" then do: /* для России */
             disable swin.content[6] with frame ord-info.
             swin.content[6]:screen-value="".
             resultt = true.
	     contentt:screen-value="Тип".
	     content1:screen-value="Идент.стороны:".
	     content2:screen-value="        Адрес:".
	     content3:screen-value="".

	     if swmt = '103' then swin.type = tmpstr.
        end.

/*-----------------------------------------------------------------------------------------*/
        when 'N' then do:
             swin.content[1]:screen-value="NONE".
             swin.content[2]:screen-value="".
             swin.content[3]:screen-value="".
             swin.content[4]:screen-value="".
             swin.content[5]:screen-value="".
             swin.content[6]:screen-value="".
             disable swin.content[1] swin.content[2] swin.content[3] swin.content[4] swin.content[5] swin.content[6] with frame ord-info.
             resultt = true.
	     contentt:screen-value="".
	     content1:screen-value="".
	     content2:screen-value="".
	     content3:screen-value="".
             APPLY "GO" TO swin.type IN FRAME ord-info.
        end.
        OTHERWISE assign resultt = false err = ' Неверный тип поля.'.
    end case.
 end.


 on return , go of swin.content[1] in frame ord-info do:

   assign err = '' result1 = true.
   if not(substring(swin.content[1]:screen-value,1,3) = "(VO" and swin.swfield = "70") then swin.content[1]:screen-value = caps(swin.content[1]:screen-value).
   tmpstr = swin.content[1]:screen-value.

  /* message swmt view-as alert-box.*/
   /*************************************************************************************************/
   CASE swmt:
     WHEN '103' THEN DO:
        case swin.swfield:

          when '50' or when '52' or when '53' or when '56' or when '57' or when '59'  then do:
            if swin.swfield = "50" and swin.type = "F" then swin.content[1]:screen-value = tmpstr. /* Luiza */
            else do:
                if not CheckAcc(tmpstr) then
                do:
                  result1 = false.
                  err = "Ошибочный формат счета! ".
                  swin.content[1]:screen-value = "/".
                end.
                else swin.content[1]:screen-value = tmpstr.
            end.
         end.

        end case.
     END.
   /*************************************************************************************************/
     OTHERWISE DO:
        case swin.type:screen-value:		/* Account  */
         when "D" or when "A" or when "K" then do:
		          /* Проверка 1 */
		       if substr(tmpstr,1,1) <> "/" and length(tmpstr) > 1 then assign
                					 result1 = false
      	        				 err = ' Поле должно быть заполненo если начинается с символа /. '.
		      /* Проверка 2 */
		      if tmpstr = "/" then assign
      					         result1 = false
      					         err = ' Счет должен быть заполнен. '.
         end.
        end case.

        if (swin.swfield="59" or swin.swfield="72") then do:		/* Account  */
		      /* Проверка 1 */
		      if substr(tmpstr,1,1) <> "/" and length(tmpstr) > 1 then assign
               					 result1 = false
      	        				 err = ' Поле должно быть заполненo если начинается с символа /. '.
		      /* Проверка 2 */
		      if tmpstr = "/" then assign
      					         result1 = false
      					         err = ' Поле или счет должны быть заполнены правильно. '.
        end.
     END.
   END CASE.



   apply "value-changed" to self.
 end.





 on return , go of swin.content[2] in frame ord-info do:
   assign err = '' result2 = true.
   tmpstr = swin.content[2]:screen-value.
  /* if length(tmpstr) > 0 then do: */

     /* Если присутствует счет в поле с типом А, то проверим наличие / */

     case swin.type:screen-value:
      when "A" then do:
	      swin.content[2]:screen-value = caps(swin.content[2]:screen-value).
	      tmpstr = swin.content[2]:screen-value.

	      /* Поиск Swift - кода банка */
	      run swfind(INPUT tmpstr, INPUT-OUTPUT result2, INPUT-OUTPUT mesg).
	      if not result2 then err = err + mesg + ' '.

	      /* Если все ОК закидываем наименование банка */
	      if result2 then do:

	        assign swin.content[2]:screen-value = substr(mesg,1,35)
	               swin.content[3]:screen-value = substr(mesg,36,35)
	               swin.content[4]:screen-value = substr(mesg,71,35).

          end.
          else do:
              assign /* swin.content[1]:screen-value = ""*/
	                 swin.content[2]:screen-value = ""
	                 swin.content[3]:screen-value = ""
	                 swin.content[4]:screen-value = "".

          end.
              /* Возьмем код страны из кода банка */
	      if swin.swfield="57" then country=substr(tmpstr,5,2).
      end.
      when "D" then do:
          if length(tmpstr) = 0 then  assign result2 = false err = "Заполните наименование".
      end.
     end case.

  /* end. */ /* if length(tmpstr) > 0 */
  /* else do:*/
     /*   if swin.type:screen-value="D" then assign result2 = false err = "Заполните наименование".*/
  /* end.*/

  apply "value-changed" to self.
 end.
