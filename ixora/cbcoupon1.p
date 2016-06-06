/* cbcoupon1.p
 * MODULE
        Модуль ЦБ (используется таблица cbcoupon
 * DESCRIPTION
        Редактирование Справочника купонов по ЦБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        cbcoupon1.p
 * MENU
        7-1-?
 * BASES
        BANK
 * AUTHOR
        26/06/12 id01143 (ТЗ 1328)
 * CHANGES
*/

{global.i}

define input parameter v-nin like cbcoupon.nin.

define query qh1 for cbcoupon.

define buffer b-cbcoupon for cbcoupon.
def var v-rid as rowid.

open query qh1 for each cbcoupon where nin = v-nin no-lock.

define browse bh1 query qh1
   displ cbcoupon.nin        label "НИН"             format "x(12)"
         cbcoupon.name       label "Название"        format "x(30)"
         cbcoupon.begdate    label "Начало периода"  format "99/99/9999"
         cbcoupon.enddate    label "Конец периода"   format "99/99/9999"
         cbcoupon.factdate   label "Д.выплаты"       format "99/99/9999"
         cbcoupon.couponrate label "Значение"        format "->>,>>9.9999"
         cbcoupon.couponcrc  label "Валюта"          format "9"

   with width 110 centered 30 down overlay no-label title " Справочник купонов ЦБ ".

/*define button btsaveh label "".*/
define frame fh1 bh1 help "<Enter>-Изменить, <F4>-Выход" skip with width 110 row 3 overlay no-box.


on "return" of bh1 in frame fh1 do:
    bh1:set-repositioned-row(bh1:focused-row, "always").
    v-rid = rowid(cbcoupon).


    find first b-cbcoupon where b-cbcoupon.nin = cbcoupon.nin and b-cbcoupon.begdate = cbcoupon.begdate and b-cbcoupon.enddate = cbcoupon.enddate  exclusive-lock no-error.
    if avail b-cbcoupon then do:
        displ b-cbcoupon.nin        /*label "НИН (ЦБ)............"*/ format "x(12)" 	    /*skip*/    view-as fill-in size 12 by 1
              b-cbcoupon.name       /*label "Наименование купона."*/ format "x(30)" 	    /*skip*/    view-as fill-in size 30 by 1
              b-cbcoupon.begdate    /*label "Начало периода......"*/ format "99/99/9999" 	/*skip*/    view-as fill-in size 14 by 1
              b-cbcoupon.enddate    /*label "Конец периода......."*/ format "99/99/9999" 	/*skip*/    view-as fill-in size 13 by 1
              b-cbcoupon.factdate   /*label "Дата выплаты  ......"*/ format "99/99/9999" 	/*skip*/    view-as fill-in size 10 by 1
              b-cbcoupon.couponrate /*label "Значение купона....."*/ format "->>,>>9.9999" 	/*skip*/    view-as fill-in size 12 by 1
              b-cbcoupon.couponcrc  /*label "Валюта купона......."*/ format ">>>>>9"                    /*view-as fill-in size 6  by 1*/
	/*with side-label overlay row 6 column 4 frame fr3 width 110.*/
        with width 110 no-label overlay row bh1:focused-row + 5 column 4 no-box frame fr3.
    end.
   else do:
     message "Редактировать незаведенный купон невозможно" view-as alert-box.
     return.
   end.

/*on help of b-cbcoupon.nin in frame fr3 do:*/
/*message "  Введите НИН...".*/
/*{itemlist.i
        &file = " dealref "
        &frame = "row 6 width 110 centered 28 down overlay "
        &where = " dealref.nin ne '' "
        &flddisp = " dealref.nin label 'НИН' format 'x(15)' dealref.cb label 'Наименование ЦБ' format 'x(20)' dealref.atvalueon label 'Эмитент' format 'x(50)' "
        &chkey = "nin"
        &chtype = "string"
        &index  = "nin"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    b-cbcoupon.nin = dealref.nin.
    displ b-cbcoupon.nin with frame fr3.
end.
*/
on help of b-cbcoupon.name in frame fr3 do:
message "  Введите Наименование купона (№ и дата окончания)...".
end.

on help of b-cbcoupon.begdate in frame fr3 do:
message "  Введите дату начала периода...".
end.

on help of b-cbcoupon.enddate in frame fr3 do:
message "  Введите дату конца периода...".
end.

on help of b-cbcoupon.factdate in frame fr3 do:
message "  Введите дату фактичекого погашения (выплаты купона)...".
end.

on help of b-cbcoupon.couponrate in frame fr3 do:
message "  Введите значение купона...".
end.

on help of b-cbcoupon.couponcrc in frame fr3 do:
		run sel ("Выберите валюту купона:", " 0. % | 1. Тенге | 2. Доллар США | 3. Евро | 4. Российские рубли | 5. Украинская гривна ").
	  	case return-value:
        when "1" then assign b-cbcoupon.couponcrc = 0.
		when "2" then assign b-cbcoupon.couponcrc = 1.
		when "3" then assign b-cbcoupon.couponcrc = 2.
		when "4" then assign b-cbcoupon.couponcrc = 3.
		when "5" then assign b-cbcoupon.couponcrc = 4.
		when "6" then assign b-cbcoupon.couponcrc = 5.
		end case.
	        displ b-cbcoupon.couponcrc with frame fr3.
               end.

    /*repeat:
        update b-cbcoupon.nin with frame fr3.
        find first dealref where dealref.nin eq b-cbcoupon.nin no-lock no-error.
        if not avail dealref then message "Данные отсутствуют в справочнике!".
        else leave.
    end.
    */
        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
            return.
        end.

     repeat:
        update b-cbcoupon.name with frame fr3.
        if b-cbcoupon.name eq "" then message "Введите Наименование купона".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
            return.
        end.

    repeat:
        update b-cbcoupon.begdate with frame fr3.
        if (b-cbcoupon.begdate eq ?) or (b-cbcoupon.begdate < 01/01/1990) or (b-cbcoupon.begdate > 01/01/2035)
	      then message "Введите дату начала купона (дата должна быть больше 01/01/1990 и меньше 01/01/2035)".
          else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
            return.
        end.

    repeat:
        update b-cbcoupon.enddate with frame fr3.
        if (b-cbcoupon.enddate eq ?) or (b-cbcoupon.enddate < 01/01/1990) or (b-cbcoupon.enddate > 01/01/2035)
	      then message "Введите дату конца купона (дата должна быть больше 01/01/1990 и меньше 01/01/2035)".
          else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
            return.
        end.

    repeat:
        update b-cbcoupon.factdate with frame fr3.
        if (b-cbcoupon.factdate eq ?) or (b-cbcoupon.factdate < 01/01/1990) or (b-cbcoupon.factdate > 01/01/2035)
	      then message "Введите дату выплаты купона (дата должна быть больше 01/01/1990 и меньше 01/01/2035)".
          else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
            return.
        end.

    repeat:
        update b-cbcoupon.couponrate with frame fr3.
        if b-cbcoupon.couponrate <= 0 then message "Введите значение купона (ставка или сумма)".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
            return.
        end.

    repeat:
        update b-cbcoupon.couponcrc with frame fr3.
        find first crc where crc.crc eq b-cbcoupon.couponcrc no-lock no-error.
        if not avail crc and b-cbcoupon.couponcrc <> 0 then message "Введите код валюты. Для вызова справочника нажмите F2".
        else leave.
     end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
            return.
        end.


    open query qh1 for each cbcoupon where cbcoupon.nin = v-nin no-lock.
    reposition qh1 to rowid v-rid no-error.
    bh1:refresh().

end.

    open query qh1 for each cbcoupon where cbcoupon.nin = v-nin no-lock.
    enable all with frame fh1.
    wait-for window-close of current-window.
    pause 100.