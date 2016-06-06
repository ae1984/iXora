/* indval1.p
 * MODULE
        Модуль ЦБ (используется таблица indval
 * DESCRIPTION
        Редактирование справочника котировок ЦБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        indval1.p
 * MENU
        7-1-?
 * BASES
        BANK
 * AUTHOR
        26/06/12 id01143 (ТЗ 1328)
 * CHANGES
*/

def var v-dt as date initial today no-undo.
update v-dt label "Котировки на дату:..." format "99/99/9999" with centered frame ww row 10 NO-BOX NO-LABELS overlay. pause 0.
hide all.

{global.i}


define query qh1 for indval.

define buffer b-indval for indval.
define buffer b1-indval for indval.
def var v-rid as rowid.

open query qh1 for each indval where (indval.begdate <= v-dt or indval.begdate = ?) and ( indval.enddate > v-dt or indval.enddate = ? ) no-lock.

define browse bh1 query qh1
    displ indval.nin      label "НИН"              format "x(12)"
        indval.begdate    label "Действует с"      format "99/99/9999" space(4)
        indval.enddate    label "Действует по"     format "99/99/9999" space(3)
        indval.rateval    label "Значение"         format "->>,>>9.9999"
        indval.valcrc     label "Валюта"           format "9"
    with width 110 centered 30 down overlay no-label title " Котировки ЦБ ".

/*define button btsaveh label "".*/
define frame fh1 bh1 help "<Enter>-Изменить,<Ins>-Ввод,<Ctrl+D>-Удалить,<F4>-Выход" skip "<Ctrl+B>-загрузка котировок" skip with width 110 row 3 overlay no-box.


on "return" of bh1 in frame fh1 do:
    bh1:set-repositioned-row(bh1:focused-row, "always").
    v-rid = rowid(indval).

    find first b-indval where b-indval.nin = indval.nin and b-indval.begdate = indval.begdate and b-indval.enddate = indval.enddate  exclusive-lock no-error.
    if not avail b-indval then do:
        message "Невозможно редактировать незаведенную котировку" view-as alert-box.
        return.
    end.
    if b-indval.enddate <> ? then do:
        message "Редактировать можно только последнюю котировку" view-as alert-box.
        return.
    end.
    if avail b-indval then do:
        displ b-indval.nin        /*label "НИН (ЦБ)............"*/ format "x(12)" 	    /*skip*/    view-as fill-in size 12 by 1
              b-indval.begdate    /*label "Действует с........."*/ format "99/99/9999" 	/*skip*/    view-as fill-in size 14 by 1
              b-indval.enddate    /*label "Действует по........"*/ format "99/99/9999" 	/*skip*/    view-as fill-in size 13 by 1
              b-indval.rateval    /*label "Значение............"*/ format "->>,>>9.9999" 	/*skip*/view-as fill-in size 12 by 1
              b-indval.valcrc     /*label "Валюта.............."*/ format ">>>>>9"                    /*view-as fill-in size 6  by 1*/
	    with width 110 no-label overlay row bh1:focused-row + 5 column 4 no-box frame fr3.
    end.
    else do:
        message "Редактировать незаведенную котировку невозможно" view-as alert-box.
        return.
    end.

    on help of b-indval.nin in frame fr3 do:
    message "  Введите НИН...".
        {itemlist.i
            &file = " dealref "
            &frame = "row 6 width 110 centered 28 down overlay "
            &where = " dealref.nin ne '' "
            &flddisp = " dealref.nin label 'НИН' format 'x(15)' dealref.cb label 'Наименование ЦБ' format 'x(20)' dealref.atvalueon label 'Эмитент' format 'x(50)' "
            &chkey = "nin"
            &chtype = "string"
            &index  = "nin"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
        b-indval.nin = dealref.nin.
        displ b-indval.nin with frame fr3.
    end.

    on help of b-indval.begdate in frame fr3 do:
        message "  Введите дату начала действия...".
    end.

    on help of b-indval.enddate in frame fr3 do:
        message "  Введите дату конца действия...".
    end.

    on help of b-indval.rateval in frame fr3 do:
        message "  Введите значение котировки...".
    end.

    on help of b-indval.valcrc in frame fr3 do:
		run sel ("Выберите валюту котировки:", " 0. % | 1. Тенге | 2. Доллар США | 3. Евро | 4. Российские рубли | 5. Украинская гривна ").
	  	case return-value:
        when "1" then assign b-indval.valcrc = 0.
		when "2" then assign b-indval.valcrc = 1.
		when "3" then assign b-indval.valcrc = 2.
		when "4" then assign b-indval.valcrc = 3.
		when "5" then assign b-indval.valcrc = 4.
		when "6" then assign b-indval.valcrc = 5.
		end case.
	    displ b-indval.valcrc with frame fr3.
    end.

    /*
    repeat:
        update b-indval.nin with frame fr3.
        find first dealref where dealref.nin eq b-indval.nin no-lock no-error.
        if not avail dealref then message "Данные отсутствуют в справочнике!".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.



    repeat:
        update b-indval.begdate with frame fr3.
        if (b-indval.begdate eq ?) or (b-indval.begdate < 01/01/1990) or (b-indval.begdate > 01/01/2035)
	    then message "Введите дату начала действия котировки (дата должна быть больше 01/01/1990 и меньше 01/01/2035)".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.
    */
    /*
    repeat:
        update b-indval.enddate with frame fr3.
        if (b-indval.enddate eq ?) or (b-indval.enddate < 01/01/1990) or (b-indval.enddate > 01/01/2035)
	    then message "Введите дату конца действия котировки (дата должна быть больше 01/01/1990 и меньше 01/01/2035)".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.
    */
    repeat:
        update b-indval.rateval with frame fr3.
        if b-indval.rateval <= 0 then message "Введите значение котировки (ставка или сумма)".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.

    repeat:
        update b-indval.valcrc with frame fr3.
        find first crc where crc.crc eq b-indval.valcrc no-lock no-error.
        if not avail crc and b-indval.valcrc <> 0 then message "Введите код валюты. Для вызова справочника нажмите F2".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.


    open query qh1 for each indval where indval.begdate <= v-dt and ( indval.enddate > v-dt or indval.enddate = ? ) no-lock.
    reposition qh1 to rowid v-rid no-error.
    bh1:refresh().

end.

on "insert-mode" of bh1 in frame fh1 do:
    bh1:set-repositioned-row(bh1:focused-row, "always").
    v-rid = rowid(indval).
    open query qh1 for each indval  no-lock.
    reposition qh1 to rowid v-rid no-error.
    bh1:refresh().
    frame fh1:visible = no.

    def var v-nin like indval.nin.
    def var v-begdate like indval.begdate.
    def var v-enddate like indval.enddate.
    def var v-rateval like indval.rateval.
    def var v-valcrc  like indval.valcrc.

    displ v-nin   label "НИН................." validate(can-find(dealref where dealref.nin = v-nin),"14654564654 ")/*format "x(12)"*/ 	skip
   	    v-begdate   label "Действует с........." format "99/99/9999" 	skip
        v-enddate   label "Действует по........" format "99/99/9999" 	skip
        v-rateval   label "Рыночная цена......." format "->>,>>9.9999" 	skip
        v-valcrc    label "Валюта котировки...." format "9"	 	skip
	with side-label overlay row 6 column 4 frame fr2 width 110.

    on help of v-nin in frame fr2 do:
    message "  Введите НИН...".
        {itemlist.i
            &file = " dealref "
            &frame = "row 6 width 110 centered 28 down overlay "
            &where = " dealref.nin ne '' "
            &flddisp = " dealref.nin label 'НИН' format 'x(15)' dealref.cb label 'Наименование ЦБ' format 'x(20)' dealref.atvalueon label 'Эмитент' format 'x(50)' "
            &chkey = "nin"
            &chtype = "string"
            &index  = "nin"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
        v-nin = dealref.nin.
        displ v-nin with frame fr2.
    end.


    on help of v-begdate in frame fr2 do:
        message "  Введите дату начала действия...".
    end.

    on help of v-enddate in frame fr2 do:
        message "  Введите дату конца действия...".
    end.

    on help of v-rateval in frame fr2 do:
        message "  Введите значение котировки...".
    end.

    on help of v-valcrc in frame fr2 do:
		run sel ("Выберите валюту котировки:", " 0. % | 1. Тенге | 2. Доллар США | 3. Евро | 4. Российские рубли | 5. Украинская гривна ").
	  	case return-value:
        when "1" then assign v-valcrc = 0.
		when "2" then assign v-valcrc = 1.
		when "3" then assign v-valcrc = 2.
		when "4" then assign v-valcrc = 3.
		when "5" then assign v-valcrc = 4.
		when "6" then assign v-valcrc = 5.
		end case.
	    displ v-valcrc with frame fr2.
    end.

    repeat:
        update v-nin with frame fr2.
        find first dealref where dealref.nin eq v-nin no-lock no-error.
        if not avail dealref then message "Данные отсутствуют в справочнике!".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.

    repeat:
        update v-begdate with frame fr2.
        if (v-begdate eq ?) or (v-begdate < 01/01/1990) or (v-begdate > 01/01/2035)
	    then message "Введите дату начала действия котировки (дата должна быть больше 01/01/1990 и меньше 01/01/2035)".
        else do:
            find last indval where indval.nin = v-nin and (indval.begdate >= v-begdate or indval.enddate >= v-begdate) no-lock no-error.
            if avail indval then message "Имеются более поздние котировки".
            else leave.
        end.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.

/*
    repeat:
        update v-enddate with frame fr2.
        if (v-enddate eq ?) or (v-enddate < 01/01/1990) or (v-enddate > 01/01/2035)
	    then message "Введите дату конца действия котировки (дата должна быть больше 01/01/1990 и меньше 01/01/2035)".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.
*/
    repeat:
        update v-rateval with frame fr2.
        if v-rateval <= 0 then message "Введите значение котировки (ставка или сумма)".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.

    repeat:
        update v-valcrc with frame fr2.
        find first crc where crc.crc eq v-valcrc no-lock no-error.
        if not avail crc and v-valcrc <> 0 then message "Введите код валюты. Для вызова справочника нажмите F2".
        else leave.
    end.

    if keyfunction(lastkey) eq "end-error" then do:
        message "Вы нажали F4! Изменения сохранены не будут!" view-as alert-box.
        return.
    end.

    do transaction:
    find last indval where indval.nin = v-nin and indval.begdate < v-begdate and indval.enddate = ? exclusive-lock no-error.
    if avail indval then assign indval.enddate = v-begdate.
    create indval.
    assign indval.nin = v-nin. indval.begdate = v-begdate. indval.rateval = v-rateval. indval.valcrc = v-valcrc.
    end.

    frame fr2:visible = no.
    frame fh1:visible = yes.

    open query qh1 for each indval where (indval.begdate <= v-dt or indval.begdate = ?) and ( indval.enddate > v-dt or indval.enddate = ? ) no-lock.
    reposition qh1 to rowid v-rid no-error.
    bh1:refresh().
end.

on "delete-line" of bh1 in frame fh1 do:
    find first b-indval where b-indval.nin = indval.nin and b-indval.begdate = indval.begdate and b-indval.enddate = indval.enddate and b-indval.rateval = indval.rateval and b-indval.valcrc = indval.valcrc exclusive-lock no-error.
    def var v-nin like indval.nin.
    def var v-begdate like indval.begdate.
    if avail b-indval then do:
        v-nin = b-indval.nin.
        v-begdate = b-indval.begdate.
        if b-indval.enddate <> ? then message "Удалить можно только последнюю котировку!!!" view-as alert-box title " ВНИМАНИЕ ".
        else do:
            delete b-indval.
            find last indval where indval.nin = v-nin and indval.enddate = v-begdate exclusive-lock no-error.
            if avail indval then assign indval.enddate = ?.
        end.
    end.
    open query qh1 for each indval where (indval.begdate <= v-dt or indval.begdate = ?) and ( indval.enddate > v-dt or indval.enddate = ? ) no-lock.
    find first b-indval no-lock no-error.
    if avail b-indval then bh1:refresh().
end.

on "editor-backtab" of bh1 in frame fh1 do:
    bh1:set-repositioned-row(bh1:focused-row, "always").
    v-rid = rowid(indval).
    run priceload.
    open query qh1 for each indval where (indval.begdate <= v-dt or indval.begdate = ?) and ( indval.enddate > v-dt or indval.enddate = ? ) no-lock.
/*    ENABLE ALL WITH FRAME fh.
    reposition qh to rowid v-rid no-error.*/
    find first b-indval no-lock no-error.
    if avail b-indval then bh1:refresh().

end.

open query qh1 for each indval where (indval.begdate <= v-dt or indval.begdate = ?) and ( indval.enddate > v-dt or indval.enddate = ? ) no-lock.
enable all with frame fh1.
wait-for window-close of current-window.
pause 100.