/* dealref.p
 * MODULE
        Модуль ЦБ (используется таблица dealref
 * DESCRIPTION
        Редактирование Справочника по ЦБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        dealref.p
 * MENU
        7-1-4
 * BASES
        BANK
 * AUTHOR
        11/07/08 id00024
 * CHANGES
        26/06/2012 id01143 s.kalbagayev добавлена обработка новых полей справочника (ТЗ 1328)
        29/06/2012 id01143 перекомпиляция из-за изменений в dates.i
*/

{global.i}

{dates.i}
{is-wrkday.i}

define query qh for dealref.

define buffer b-dealref for dealref.
define buffer b-cbcoupon for cbcoupon.
def var v-rid as rowid.
def var dt  as date.
def var dt1 as date.
def var dt2 as date.
def var n   as integer.

define browse bh query qh
   displ dealref.nin       label "НИН"             format "x(12)"
         dealref.cb        label "ЦБ"              format "x(12)"
         dealref.crc       label "В"               format "9"
         dealref.atvalueon label "Эмитент"         format "x(17)"
         dealref.type      label "Тип"             format "x(3)"
         dealref.sort      label "Вид"             format "x(3)"
         dealref.ncrc      label "Номинал"         format ">>>>>9"
         dealref.intrate   label "Купон%"          format "zz.99"
         dealref.inttype   label "Т"               format "x(1)"
         dealref.issuedt   label "Д. выпуска"      format "99/99/9999"
         dealref.maturedt  label "Д. погашен"      format "99/99/9999"
         dealref.coupper   label "К.п"             format ">>9"
         dealref.base      label "База"            format "x(6)"
/*         dealref.lpaydt    label "Д. пос.вып"      format "99/99/9999" */
/*         dealref.paydt     label "Д. выплаты"      format "99/99/9999" */

   with width 110 centered 30 down overlay no-label title " Справочник ЦБ ".

/*define button btsaveh label "".*/
define frame fh bh help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl+D>-удаление, <F4>-Выход" skip "<Ctrl+B>-информация о купонах" skip with width 110 row 3 overlay no-box.


on "return" of bh in frame fh do:
    bh:set-repositioned-row(bh:focused-row, "always").
    v-rid = rowid(dealref).


   find first b-dealref where b-dealref.nin = dealref.nin exclusive-lock.
   displ b-dealref.nin       label "НИН................." format "x(12)" 	skip
         b-dealref.cb        label "Наименование ЦБ....." format "x(82)" 	skip
         b-dealref.crc       label "Валюта ЦБ..........." format "9"	 	skip
         b-dealref.atvalueon label "Эмитент............." format "x(82)" 	skip
         b-dealref.type      label "Тип эмитента........" format "x(3)"  	skip
         b-dealref.sort      label "Вид эмитента........" format "x(3)"  	skip
         b-dealref.ncrc      label "Номинал............." format ">,>>>,>>9" 	skip
         b-dealref.intrate   label "Купон %............." format "zz.99" 	skip
         b-dealref.inttype   label "Тип ЦБ ............." format "x(1)" 	skip
	     b-dealref.issuedt   label "Дата выпуска........" format "99/99/9999" 	skip
         b-dealref.maturedt  label "Дата погашения......" format "99/99/9999" 	skip
         b-dealref.coupper   label "Куп.период.........." format ">,>>>,>>9"  skip
         b-dealref.base      label "База ничисления....." format "x(8)"  	skip
         b-dealref.cbtype    label "Тип ЦБ.............." format "x(50)"  	skip
/*         b-dealref.lpaydt    label "Дата послед. выплаты" format "99/99/9999" 	skip */
/*         b-dealref.paydt     label "Дата выплаты купона." format "99/99/9999" 	skip */
	with side-label overlay row 6 column 4 frame fr2 width 110.




on help of b-dealref.nin in frame fr2 do:
message "  Введите НИН...".
end.

on help of b-dealref.cb in frame fr2 do:
message "  Введите Наименование ЦБ...".
end.


on help of b-dealref.crc in frame fr2 do:
		run sel ("Выберете валюту:", " 1. Тенге | 2. Доллар США | 3. Евро | 4. Российские рубли | 5. Украинская гривна ").
	  	case return-value:
		when "1" then assign b-dealref.crc = 1.
		when "2" then assign b-dealref.crc = 2.
		when "3" then assign b-dealref.crc = 3.
		when "4" then assign b-dealref.crc = 4.
		when "5" then assign b-dealref.crc = 5.
		end case.
	        displ b-dealref.crc with frame fr2.
               end.

on help of b-dealref.atvalueon in frame fr2 do:
message "  Введите Эмитента...".
end.

on help of b-dealref.type in frame fr2 do: run h-emittype.
                    b-dealref.type :screen-value = return-value.
                    b-dealref.type = b-dealref.type :screen-value.
               end.

on help of b-dealref.sort in frame fr2 do: run h-emitview.
                    b-dealref.sort :screen-value = return-value.
                    b-dealref.sort = b-dealref.sort :screen-value.
               end.

on help of b-dealref.ncrc in frame fr2 do:
message "  Введите Сумму...".
end.

on help of b-dealref.intrate in frame fr2 do:
message "  Введите % ставку...".
end.

on help of b-dealref.inttype in frame fr2 do:
		run sel ("Выберете Тип ЦБ:", " Accural | Discount ").
	  	case return-value:
		when "1" then assign b-dealref.inttype = "A".
		when "2" then assign b-dealref.inttype = "D".
		end case.
	        displ b-dealref.inttype with frame fr2.
               end.

on help of b-dealref.issuedt in frame fr2 do:
message "  Введите дату выпуска ЦБ...".
end.

on help of b-dealref.maturedt in frame fr2 do:
message "  Введите дату погашения...".
end.

on help of b-dealref.coupper in frame fr2 do:
message "  Введите кол-во месяцев в купонном периоде...".
end.

on help of b-dealref.base in frame fr2 do:
        run sel ("Выберете базу:", " 1. 30/360 | 2. 30/365 | 3. 31/360 | 4. 31/365").
	  	case return-value:
		when "1" then assign b-dealref.base = "30/360".
		when "2" then assign b-dealref.base = "30/365".
		when "3" then assign b-dealref.base = "31/360".
		when "4" then assign b-dealref.base = "31/365".
		end case.
		  displ b-dealref.base with frame fr2.
end.

on help of b-dealref.cbtype in frame fr2 do:
        run sel ("Выберете тип ЦБ:", " 1. Облигации | 2. Акции | 3. Собственные облигации | 4. Собственные акции").
	  	case return-value:
		when "1" then assign b-dealref.cbtype = "1.Облигации".
		when "2" then assign b-dealref.cbtype = "2.Акции".
		when "3" then assign b-dealref.cbtype = "3.Собственные облигации".
		when "4" then assign b-dealref.cbtype = "4.Собственные акции".
		end case.
		  displ b-dealref.cbtype with frame fr2.
end.
/*
on help of b-dealref.lpaydt in frame fr2 do:
message "  Введите дату послед. выплаты...".
end.

on help of b-dealref.paydt in frame fr2 do:
message "  Введите дату выплаты купона...".
end.
*/

    repeat:
        update b-dealref.nin with frame fr2.
        if length(b-dealref.nin) <> 12 then message "В поле НИН Вы ввели не 12 символов. Таких ЦБ не бывает".
            else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.cb with frame fr2.
        if b-dealref.cb eq "" then message "Введите Наименование ЦБ".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

     repeat:
        update b-dealref.crc with frame fr2.
        find first crc where crc.crc eq b-dealref.crc no-lock no-error.
        if not avail crc then message "Введите код валюты. Для вызова справочника нажмите F2".
        else leave.
     end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.atvalueon  with frame fr2.
        if b-dealref.atvalueon eq "" then message "Введите Эмитента".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.type with frame fr2.
        if (b-dealref.type eq "1") or (b-dealref.type eq "2") or (b-dealref.type eq "3") or (b-dealref.type eq "4") or (b-dealref.type eq "5") or (b-dealref.type eq "msc") then leave.
        else message "Введите тип Эмитента. Для вызова справочника нажмите F2".
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.sort  with frame fr2.
        if (b-dealref.sort eq "1") or (b-dealref.sort eq "2") or (b-dealref.sort eq "3") or (b-dealref.sort eq "4") or (b-dealref.sort eq "5") or (b-dealref.sort eq "6") or (b-dealref.sort eq "msc") then leave.
        else message "Введите вид Эмитента. Для вызова справочника нажмите F2".
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.ncrc with frame fr2.
        if b-dealref.ncrc <= 0 then message "Введите Сумму".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.intrate with frame fr2.
        if b-dealref.intrate <= 0 then message "Введите % ставку".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.inttype with frame fr2.
	    b-dealref.inttype = CAPS(b-dealref.inttype). display b-dealref.inttype with frame fr2.
        if (b-dealref.inttype eq "A") or (b-dealref.inttype eq "D") then leave.
        else message "Выберете тип ЦБ. Accural / Discount.".
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.issuedt with frame fr2.
        if (b-dealref.issuedt eq ?) or (b-dealref.issuedt < 01/01/1990) or (b-dealref.issuedt > 01/01/2035)
	      then message "Введите дату выпуска ЦБ (дата должна быть больше 01/01/1990 и меньше 01/01/2035)".
          else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

    repeat:
        update b-dealref.maturedt with frame fr2.
        if (b-dealref.maturedt eq ?) or (b-dealref.maturedt < 01/01/1990) or (b-dealref.maturedt > 01/01/2035) or (b-dealref.maturedt <= b-dealref.issuedt)
	      then message "Введите дату погашения ЦБ (дата должна быть больше 01/01/1990 и даты выпуска ЦБ, а также меньше: 01/01/2035)".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.
    repeat:
        update b-dealref.coupper with frame fr2.
        if b-dealref.coupper <= 0 and b-dealref.inttype = "A" then message "Кол-во месяцев".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.
   repeat:
        update b-dealref.base with frame fr2.
        if (b-dealref.base eq "30/360") or (b-dealref.base eq "30/365") or (b-dealref.base eq "31/360") or (b-dealref.base eq "31/365") then leave.
	    else message "Не введена база! 30/360 30/365 факт/360 факт/факт".
   end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.
   repeat:
        update b-dealref.cbtype with frame fr2.
        if (substring(b-dealref.cbtype,1,2) eq "1.") or (substring(b-dealref.cbtype,1,2) eq "2.") or (substring(b-dealref.cbtype,1,2) eq "3.") or (substring(b-dealref.cbtype,1,2) eq "4.") then leave.
	    else message "Не выбран тип ЦБ".
   end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return.
        end.

/*
    repeat:
        update b-dealref.lpaydt with frame fr2.
        if (b-dealref.lpaydt eq ?) or (b-dealref.lpaydt < 01/01/1990) or (b-dealref.lpaydt > 01/01/2035) or (b-dealref.lpaydt <= b-dealref.issuedt) or (b-dealref.lpaydt >= b-dealref.maturedt)
	then message "Введите дату последней выплаты ЦБ (дата должна быть больше 01/01/1990 и даты выпуска ЦБ, а также меньше: 01/01/2035 и(или) и даты погашения ЦБ)".
        else leave. end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return. end.

    repeat:
        update b-dealref.paydt with frame fr2.
        if (b-dealref.paydt eq ?) or (b-dealref.paydt < 01/01/1990) or (b-dealref.paydt > 01/01/2035) or (b-dealref.paydt <= b-dealref.lpaydt) or (b-dealref.paydt >= b-dealref.maturedt)
	then message "Введите дату выплаты купона (дата должна быть больше 01/01/1990 и даты выпуска ЦБ, а также меньше: 01/01/2035 и(или) и даты погашения ЦБ)".
        else leave. end.

        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Форма редактирования будет закрыта!" view-as alert-box.
            return. end.
*/
    open query qh for each dealref  no-lock.
    reposition qh to rowid v-rid no-error.
    bh:refresh().

end.

on "insert-mode" of bh in frame fh do:
    create dealref.
    bh:set-repositioned-row(bh:focused-row, "always").
    v-rid = rowid(dealref).
    open query qh for each dealref  no-lock.
    reposition qh to rowid v-rid no-error.
    bh:refresh().
    apply "return" to bh in frame fh.
		find first dealref where length(dealref.nin) = 0 or length(dealref.cb) = 0 or length(dealref.atvalueon) = 0 or length(dealref.type) = 0 or length(dealref.sort) = 0 exclusive-lock no-error.
		if avail dealref then do:
		delete dealref.
		message "Вы закрыли форму редактирования оставив некоторые поля пустыми! Данная ЦБ не может быть сохранена!" view-as alert-box title " ВНИМАНИЕ ".
		end.
end.

on "delete-line" of bh in frame fh do:
    find first b-dealref where b-dealref.nin = dealref.nin no-lock.

        if avail(b-dealref) then do:
          find first deal where deal.nin = b-dealref.nin no-lock no-error.
	  if avail deal then do:
	  message "Вы не можете удалить эту ЦБ!!! Она используется в сделке!" view-as alert-box title " ВНИМАНИЕ ".
	  end.
	  else do:
            def var choice as logical.
            choice = no.
            message "Вы уверены что хотите удалить эту ЦБ?"
                view-as alert-box question buttons yes-no
                    title "" update choice.

            find current b-dealref exclusive-lock.
                if choice = yes then do:
                 delete b-dealref.
                end.
	   end.
        end.

    open query qh for each dealref  no-lock.
    bh:refresh().
end.

on "editor-backtab" of bh in frame fh do:
    bh:set-repositioned-row(bh:focused-row, "always").
    v-rid = rowid(dealref).
    n = 0.
    find first b-dealref where b-dealref.nin = dealref.nin no-lock.

    find first b-cbcoupon where b-cbcoupon.nin = dealref.nin no-error.
    if not avail(b-cbcoupon) then do:
        if b-dealref.inttype = "A" then do:
            if b-dealref.coupper = 0 then do:
                message "По ЦБ не задан купонный период" view-as alert-box.
                return.
            end.
            dt = b-dealref.issuedt.
            dt1 = monthsadd(dt, b-dealref.coupper).
            if is-working-day(dt1) then dt2 = dt1.
            else dt2 = nextworkday(dt1).
            repeat:
                do transaction :
                    n = n + 1.
                    create cbcoupon.
                    cbcoupon.nin        = b-dealref.nin.
                    cbcoupon.begdate    = dt.
                    cbcoupon.couponrate = b-dealref.intrate.
                    cbcoupon.couponcrc  = 0.
                    cbcoupon.enddate    = dt1.
                    cbcoupon.factdate   = dt2.
                    cbcoupon.name       = string(n,"999. ") + b-dealref.nin + string(day(dt1)," 99/") + string(month(dt1),"99/") + string(year(dt1),"9999").
                end.
                dt = dt1.
                dt1 = monthsadd( dt, b-dealref.coupper).
                if is-working-day(dt1) then dt2 = dt1.
                else dt2 = nextworkday(dt1).
                if dt1 > b-dealref.maturedt then leave.
            end.
        end.
        else do:
            message "Для дисконтных ЦБ купона не предусмотрен" view-as alert-box.
            return.
        end.
    end.

    frame fh:visible = no.
    run cbcoupon1(dealref.nin).
    frame fh:visible = yes.

    /*for each cbcoupon where cbcoupon.nin = b-dealref.nin :
     displ cbcoupon
     with width 210 centered 30 down overlay no-label title " Справочник купонов ЦБ ".
    end.*/

    /*repeat:
    readkey.
    if keyfunction(lastkey) eq "end-error" then do:
           return.
    end.
    */
    /*end.*/
    open query qh for each dealref no-lock.
    ENABLE ALL WITH FRAME fh.
    reposition qh to rowid v-rid no-error.
    bh:refresh().

end.

    open query qh for each dealref   no-lock.
    enable all with frame fh.
    wait-for window-close of current-window.
    pause 0.