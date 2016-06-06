/* convert.p
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
        25.02.04 nataly была добавлена кросс-конвертация из любой валюты в любую
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        26/05/2011 evseev - изменил условие для проверки отрасли экономики клиента
*/

/* 17/04/03  nataly
 была добавлена процедура cif-new2  и строка по удалению записи aaa , если aaa.cif = "" */

/* cif-new.p
   setup new account from cif
   changes:
           st-period - период выписки всегда равен 0
   13.06.01 - при удалении счета проверяются записи в таблице sub-cod
   04.12.01 - добавлено меню - оплата за откр счета - делается запись
   в таб-цу bxcif,
  в таб-це ааа : поле vip   - код оплаты, (1- со счета, 2-льготный,
                                           3- оплата налом, 4- бесплатно )
                      penny - сумма комисии

   01.07.02 - проверка соответствия ЕКНП клиента группе счетов при открытии нового счета

*/
{global.i}
def var v-aaacif like aaa.aaa.
def shared var s-cif like cif.cif.
def new shared var s-aaa like aaa.aaa.
def new shared var s-lgr like lgr.lgr.
def new shared  Variable V-sel As Integer FORMAT "9" init 1.
def new shared var in_command as decimal .
def new shared  var v-rate as decimal.
def new shared var v-gl like gl.gl.

def var val1 as integer.
def new shared var val2 as integer.


def var v-log as log init no.
def var s-lgr2 like lgr.lgr.

def var ans as log.
def var v-lgr like lgr.lgr.
def var vans as log.
def new shared  variable st_period as integer initial 30.
def new shared var opt as cha format "x(1)".

def var v-lgrwrong as log init false.
def new shared var v-usd like aaa.aaa.


define button b5 label 'USD->EUR'.
define button b6 label 'USD->KZT'.
define button b7 label 'KZT->USD'.
define button b8 label 'EUR->KZT'.
define button b9 label 'KZT->EUR'.
define button b10 label 'EUR->USD'.
define button b4 label 'Выход'.

define frame becrc
  b5  skip b10  skip b6  skip b7 skip b8  skip b9 /*skip b4*/ with centered row 8 title "Выберите тип конвертации".

 /*USD-EUR*/
on choose of b5
do:
   val1 = 2.
   val2 = 11.
   hide frame becrc.
end.

 /*EUR-USD*/
on choose of b10
do:
   val1 = 11.
   val2 = 2.
   hide frame becrc.
end.

 /*USD-KZT*/
on choose of b6
do:
   val1 = 2.
   val2 = 1.
   hide frame becrc.
end.

 /*KZT-USD*/
on choose of b7
do:
   val1 = 1.
   val2 = 2.
   hide frame becrc.
end.

 /*EUR-KZT*/
on choose of b8
do:
   val1 = 11.
   val2 = 1.
   hide frame becrc.
end.

 /*KZT-EUR*/
on choose of b9
do:
   val1 = 1.
   val2 = 11.
   hide frame becrc.
end.
/*
on choose of b4
do:
   hide frame becrc. return.
end.
  */
enable all with frame becrc.
wait-for WINDOW-CLOSE of current-window or choose of b5 or choose of b10 or choose of b6 or choose of b7
  or choose of b8  or choose of b9.

find crc where crc.crc = val1 no-lock no-error.

update v-usd no-label with frame ww column 20 row 10
   title "Введите  счет" .


define frame vlgr s-lgr2 FORMAT "x(3)"       LABEL "Группа"      COLON 18
             with overlay SIDE-LABELS row 15 no-box col 4.


find aaa where aaa.aaa = v-usd no-lock no-error.
 if not avail aaa  or aaa.cif <> s-cif
  then do:
    message 'Счет ' v-usd 'не найден  или не является счетом данного клиента !!!' view-as alert-box.
  undo,retry.
  end.

  find lgr where lgr.lgr = aaa.lgr no-lock no-error.
 if lgr.led <> 'tda'
  then do:
    message ' Заданный счет ' v-usd 'не является депозитным типа TDA или CDA  !!!' view-as alert-box.
    undo,retry.
  end.

v-gl = aaa.gl.
def buffer bcrc for crc.
find crc where crc.crc = aaa.crc no-lock no-error.
find bcrc where bcrc.crc = val1 no-lock no-error.

if crc.crc <> val1 then do:
    message 'Счет ' v-usd ' в валюте ' crc.code '!' skip
    'Задайте счет в валюте ' bcrc.code ' или выберете другой тип кросс-конвертации! ' view-as alert-box.
    undo,retry.
  end.

find cif where aaa.cif = cif.cif no-lock no-error.
{print-dolg.i}
{desp.i 0401 18 opt}

 if opt eq "C" or opt eq "D"
  then do:
    message 'Режим ' opt  'в данном п.п. меню недоступен! ' view-as alert-box.
    undo,retry.
  end.
if opt eq "N"
then do:

        update s-lgr2 with frame vlgr.

        s-lgr2 = frame-value.
        s-lgr2 = caps(s-lgr2).
        find lgr where lgr.lgr eq s-lgr2.
        find led where led.led eq lgr.led.
        find crc where crc.crc = lgr.crc no-lock.
        if lgr.crc <> val2
         then do:
          message ' Вы выбрали депозитную группу не в той валюте !!!' view-as alert-box.
          undo,retry.
         end.
  hide frame ww.
    s-lgr = s-lgr2.
/* 01/07/02 - nadejda
проверка соответствия признаков клиента признаку группы открываемого счета - требуется обязательное совпадение
lgr.tlev по справочнику lgrsts с признаками клиента по справочникам clnsts, secek, ecdivis
  tlev = 1: юрлицо, у клиента должно быть юрлицо, сектор 1-8, отрасль 1-97
  tlev = 2: физлицо, у клиента должно быть физлицо, сектор 9, отрасль 98
  tlev = 3: ЧП, у клиента должно быть юрлицо, сектор 9, отрасль 98
*/
        if lgr.tlev = 0 then do:
           message "Не указан тип клиентов для этой группы счетов. Нельзя открыть счет.".
           pause.
           v-lgrwrong = true.
        end.

        find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
            and sub-cod.d-cod = "clnsts" no-lock no-error.
        if not avail sub-cod or sub-cod.ccode = "msc" then do:
           message "Неверное значение статуса клиента - msc. Нельзя открыть счет.".
           pause.
           v-lgrwrong = true.
        end.
        if not ((lgr.tlev = 1 and int(sub-cod.ccode) = 0) /* юр лицо */ or
                (lgr.tlev = 2 and int(sub-cod.ccode) = 1) /* физ лицо */ or
                (lgr.tlev = 3 and int(sub-cod.ccode) = 0)) /* ЧП */ then do:
           message "Статус клиента не соответствует типу клиентов для этой группы счетов. Нельзя открыть счет.".
           pause.
           v-lgrwrong = true.
        end.

        find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
            and sub-cod.d-cod = "secek" no-lock no-error.
        if not avail sub-cod or sub-cod.ccode = "msc" then do:
           message "Неверное значение сектора экономики клиента - msc. Нельзя открыть счет.".
           pause.
           v-lgrwrong = true.
        end.
        if not ((lgr.tlev = 1 and
                 ((int(sub-cod.ccode) >= 1 and int(sub-cod.ccode) <= 8)) or
                  (trim(sub-cod.ccode) = "A")) /* юр лицо */ or
                (lgr.tlev = 2 and int(sub-cod.ccode) = 9) /* физ лицо */ or
                (lgr.tlev = 3 and int(sub-cod.ccode) = 9) /* ЧП */ ) then do:
           message "Сектор экономики клиента не соответствует типу клиентов для этой группы счетов. Нельзя открыть счет.".
           pause.
           v-lgrwrong = true.
        end.

        find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif
            and sub-cod.d-cod = "ecdivis" no-lock no-error.
        if not avail sub-cod or sub-cod.ccode = "msc" then do:
           message "Неверное значение отрасли экономики клиента - msc. Нельзя открыть счет.".
           pause.
           v-lgrwrong = true.
        end.
        if /*not ((lgr.tlev = 1 and
                   ((int(sub-cod.ccode) >= 1 and int(sub-cod.ccode) <= 97) or
                    (int(sub-cod.ccode) = 99))) /* юр лицо */ or
                (lgr.tlev = 2 and int(sub-cod.ccode) = 98) /* физ лицо */ or
                (lgr.tlev = 3 and int(sub-cod.ccode) = 98) /* ЧП */ )*/

           not ((lgr.tlev = 1 and
                   ((int(sub-cod.ccode) >= 1 and int(sub-cod.ccode) <= 99))) /* юр лицо */ or
                (lgr.tlev = 2 and int(sub-cod.ccode) = 0) /* физ лицо */ or
                (lgr.tlev = 3 /*and int(sub-cod.ccode) = 98*/) /* ЧП */ )
                then do:
           message "Отрасль экономики клиента не соответствует типу клиентов для этой группы счетов. Нельзя открыть счет.".
           pause.
           v-lgrwrong = true.
        end.

        if v-lgrwrong then
          return.
/* конец проверки соответствия признаков */

/* проверка допустимости валюты */
        if crc.sts = 9 then do:
           message "Невозможно открыть счет, валюта " + crc.code + " закрыта.".
           pause.
           return.
        end.

        if keyfunction(lastkey) eq "GO" or keyfunction(lastkey) eq "RETURN"
        then do transaction on error undo,return :
               {mesg.i 1808} update ans.

               if ans eq false then return.
               /* run aaa-num. */
               if lgr.nxt eq 0 then do:
                 {mesg.i 1812} update s-aaa.
               end.
               else do:
                 run new-acc .
               end.
               if s-aaa eq "" then do:
                  message "Account number generation error.".

                  pause 5.
                return.
               end.

               run  convert2.

               find aaa where aaa.aaa = s-aaa no-lock no-error.
                if avail  aaa and  aaa.cif = "" then  delete aaa.

             end.



/*-------------------------- Льготное открытие счета ----------------------------------*/
/*

 def var d_opendate as date.

 def var s_kzt_string as char.
 def var s_val_string as char.
 def var s_all_string as char.

 def var i_kzt_total as integer.
 def var s_kzt_value as char.
 def var i_kzt_count as integer init 1.

 def var d_init_sum as decimal init 0.
 def var d_temp_sum as decimal init 0.
 def var d_final_sum as decimal init 0.

 s_kzt_string = '104|403|409|422|106|214|215|141|142|163|164|151|194'.
 s_val_string = '165|166|167|168'.
 s_all_string = '104|403|409|422|106|214|215|141|142|163|164|151|194'.


 d_opendate = g-today.

 if d_opendate >= 03/21/2003 and d_opendate <= 04/21/2003 then do:

   find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif and sub-cod.d-cod = "clnsts" no-lock no-error.
   if sub-cod.ccode = '0' then do:

 	find first aaa where aaa.aaa = s-aaa no-lock no-error.
	if avail aaa then do:


	i_kzt_total = num-entries(s_all_string,'|').

        repeat while i_kzt_count <= i_kzt_total:
    	s_kzt_value = entry(i_kzt_count,s_all_string,'|').

    	find first tarif2 where tarif2.str5 = s_kzt_value no-lock no-error.
    	if avail tarif2 then do:

	find first tarifex where tarifex.cif = s-cif and tarifex.whn <= 04/21/2003 and tarifex.str5 = s_kzt_value no-error.
        if avail tarifex then do:

	find first trfex_nauryz where trfex_nauryz.cif = tarifex.cif and trfex_nauryz.str5 = tarifex.str5 no-error.
        if not avail trfex_nauryz then do:

        run trfx-ins(tarifex.kont, tarifex.pakalp, tarifex.str5, tarifex.whn, aaa.crc, tarifex.ost, tarifex.proc, tarifex.max1, tarifex.min1, 'nauryz').

        	    update
			tarifex.ost              = 0.
			tarifex.proc             = 0.
			tarifex.max1             = 0.
			tarifex.min1             = 0.

        end.
        end.
        end.

	i_kzt_count = i_kzt_count + 1.
        end.

        find first lgr where (lgr.lgr = aaa.lgr and lgr.led = 'tda') or
                             (lgr.lgr = aaa.lgr and lgr.led = 'cda') no-lock no-error.

        if not avail lgr then do:

		if aaa.crc = 1 then do:                                                             /*для тенге*/

        i_kzt_count = 1.
        i_kzt_total = num-entries(s_kzt_string,'|').

                	repeat while i_kzt_count <= i_kzt_total:
    			s_kzt_value = entry(i_kzt_count,s_kzt_string,'|').

 	                find first tarif2 where tarif2.str5 = s_kzt_value
                                            and tarif2.stat = 'r' no-lock no-error.
			if avail tarif2 then do:

			find first tarifex where tarifex.cif = s-cif and tarifex.str5 = s_kzt_value
                                             and tarifex.stat = 'r' no-error.
			if not avail tarifex then do:
			run tarifex-ins(tarif2.kont, tarif2.pakalp, tarif2.str5, g-today, aaa.crc, 0, 0, 0, 0).
			run trfx-ins(tarif2.kont, tarif2.pakalp, tarif2.str5, g-today, aaa.crc, 0, 0, 0, 0, g-ofc).
			end.
			end.
    			i_kzt_count = i_kzt_count + 1.
   			end.
   		end.
        end.
        end.
   end.
 end.


procedure tarifex-ins.
def input parameter ms-kont as integer.
def input parameter ms-pakalp as char.
def input parameter ms-str as char.
def input parameter ms-date as date.
def input parameter ms-crc as integer.
def input parameter ms-ost as decimal.
def input parameter ms-proc as decimal.
def input parameter ms-max1 as decimal.
def input parameter ms-min1 as decimal.

                    create tarifex.
        	    update
	                tarifex.cif              = s-cif.
                	tarifex.kont             = ms-kont.
                	tarifex.pakalp           = ms-pakalp.
			tarifex.str5             = ms-str.
			tarifex.ost              = ms-ost.
			tarifex.proc             = ms-proc.
			tarifex.max1             = ms-max1.
			tarifex.min1             = ms-min1.
			tarifex.whn              = ms-date.
			tarifex.who              = g-ofc.
			tarifex.crc              = ms-crc.
			tarifex.stat             = 'r'.
			tarifex.wtim             = time.
		run tarifexhis_update.

end procedure.

/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
create tarifexhis.
assign tarifexhis.cif    = tarifex.cif
       tarifexhis.kont   = tarifex.kont
       tarifexhis.pakalp = tarifex.pakalp
       tarifexhis.ost    = tarifex.ost
       tarifexhis.proc   = tarifex.proc
       tarifexhis.max1   = tarifex.max1
       tarifexhis.min1   = tarifex.min1
       tarifexhis.str5   = tarifex.str5
       tarifexhis.crc    = tarifex.crc
       tarifexhis.who    = tarifex.who
       tarifexhis.whn    = tarifex.whn
       tarifexhis.wtim   = tarifex.wtim
       tarifexhis.akswho = tarifex.akswho
       tarifexhis.akswhn = tarifex.akswhn
       tarifexhis.awtim  = tarifex.awtim
       tarifexhis.delwho = tarifex.delwho
       tarifexhis.delwhn = tarifex.delwhn
       tarifexhis.dwtim  = tarifex.dwtim
       tarifexhis.stat   = tarifex.stat.
end procedure.

procedure trfx-ins.
def input parameter ms-kont as integer.
def input parameter ms-pakalp as char.
def input parameter ms-str as char.
def input parameter ms-date as date.
def input parameter ms-crc as integer.
def input parameter ms-ost as decimal.
def input parameter ms-proc as decimal.
def input parameter ms-max1 as decimal.
def input parameter ms-min1 as decimal.
def input parameter ms-ofc as char.

                     create trfex_nauryz.
        	     update
	                trfex_nauryz.cif         = s-cif.
                	trfex_nauryz.kont        = ms-kont.
                	trfex_nauryz.pakalp      = ms-pakalp.
			trfex_nauryz.str5        = ms-str.
			trfex_nauryz.ost         = ms-ost.
			trfex_nauryz.proc        = ms-proc.
			trfex_nauryz.max1        = ms-max1.
			trfex_nauryz.min1        = ms-min1.
			trfex_nauryz.whn         = ms-date.
			trfex_nauryz.who         = ms-ofc.
			trfex_nauryz.crc         = ms-crc.
end procedure.

*/
/*-------------------------------------------------------------------------------------*/


     end.
else if opt eq "C"
then do:
        prompt-for v-aaacif with centered color message frame aaa.
        s-aaa = input v-aaacif.
        find aaa where aaa.aaa eq s-aaa.
        find cif where cif.cif eq aaa.cif.
        find lgr where lgr.lgr eq aaa.lgr.
        find led where led.led eq lgr.led.
        if keyfunction(lastkey) eq "GO" or keyfunction(lastkey) eq "RETURN"
        then do:
           {print-dolg2.i}.
           aaa.penny = in_command.   /*Величина Комиссии*/
           aaa.vip = V-sel.      /*  код выбранного пункта меню  */

      /*   message  "v-sel =" v-sel "s-aaa = " s-aaa. pause 200.*/
        end.
        hide all /*aaa*/.
     end.
else if opt = "D"
    then do:
        prompt-for v-aaacif with centered side-label color message frame aaa.
        s-aaa = input v-aaacif.
        find aaa where aaa.aaa eq s-aaa.
        find lgr where lgr.lgr eq aaa.lgr.
        find led where led.led eq lgr.led.
        bell.
        {mesg.i 0824} update vans.
       if vans then do:
         if aaa.cdt ne ? or aaa.ddt ne ? then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
         end.
         if can-find(first aal of aaa) then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
          end.
          if aaa.dr[1] ne 0 or aaa.cr[1] ne 0 then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
          end.
          if can-find(first trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and
             (trxbal.dam ne 0 or cam ne 0)) then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
          end.
          for each sub-cod where sub-cod.sub = 'cif'
                             and sub-cod.acc = aaa.aaa.
              delete sub-cod.
          end.
          find bxcif where bxcif.cif = aaa.cif and bxcif.aaa = aaa.aaa no-error.
          if available bxcif then do:
           message "У клиента задол-ть за открытие счета " aaa.aaa                              "на сумму " aaa.penny "USD. Удалить ?" update v-log.
             if v-log then  delete bxcif.
           end.
          delete aaa.
         {mesg.i 2201}.
       end.
       hide frame aaa.
    end.


