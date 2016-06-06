/* dealnew.p
 * MODULE
        Модуль ЦБ (используется таблица deal) 
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
        11/07/08 id00209
 * CHANGES
*/

{global.i}
    repeat: /* начало огромного репита */

def input parameter cln as logical.

def shared var v-new as log init no.
def shared var v-edit as log init yes.
def shared var v-deal like deal.deal.

/*общая часть*/
def var v-scugrp   like deal.grp.
def var v-gl       like gl.gl.
def var vgl        like gl.gl.
def var v-gldes    like gl.des.

/*Сведения о ЦБ*/
def var v-nin      like dealref.nin.
def var v-cbname   like deal.rem[3].
def var v-atval    like deal.atvalueon[3].
def var v-type     like dealref.type.
def var v-sort     like dealref.sort.
def var v-ncrc     like dealref.ncrc.
def var v-intrate  like deal.intrate.
def var v-issuedt  like dealref.issuedt.
def var v-maturedt like dealref.maturedt.
def var v-paydt    like dealref.paydt.
def var v-dval2    as int.
def var v-dval3    as int.
def var v-base     like deal.base.
def var v-inttype  like deal.inttype.
def var v-lpaydt   like dealref.lpaydt.

/*Сведения о сделке*/
def var v-ccrc     as deci.
def var v-col      like deal.ncrc[2].
def var v-profit   like deal.profit.
def var v-bcrc     as dec.
def var v-dealsum  as dec.
def var v-closeprice  as dec.
def var v-closesum    as dec.
def var v-crc      like crc.crc.
def var v-regdt    as date.
def var v-valdt    like deal.valdt.
def var v-kontr    like deal.broke.
def var v-eqne     as char.
def var v-grp      as char.

def var v-com      as char.
def var v-lsch     as char.

def var v-cif      like cif.cif.

def var v-geo    as char.
def var v-sector   as char.

{deal3.f}

form v-com format "x(78)" 
with frame comt no-label row 15 centered width 80.



on help of v-nin in frame deal do:
    {itemlist.i 
        &file = " dealref "
        &frame = "row 6 width 110 centered 28 down overlay "
        &where = " dealref.nin ne '' "
        &flddisp = " dealref.nin label 'НИН' format 'x(15)' dealref.cb label 'Наименование' format 'x(40)'"
        &chkey = "nin"
        &chtype = "string"
        &index  = "nin"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }

    
    v-nin = dealref.nin.
    v-cbname = dealref.cb.
    v-crc = dealref.crc.
    v-atval = dealref.atvalueon.
    v-type = dealref.type.
    v-sort = dealref.sort.
    v-ncrc = dealref.ncrc.
    v-intrate = dealref.intrate.
    v-issuedt = dealref.issuedt.
    v-maturedt = dealref.maturedt.
    v-paydt = dealref.paydt.
    v-inttype = dealref.inttype.


    displ v-deal v-nin v-cbname v-crc v-atval v-type v-sort v-ncrc v-intrate v-issuedt v-maturedt v-paydt  v-inttype 
        with frame deal.
end.

on help of v-deal in frame deal do:
        if cln 
	then do:

    {itemlist.i 
        &set = "1" 
	&file = " deal "
        &frame = "row 6 width 110 centered 28 down overlay"
	&where = " deal.grp eq 70 "
	&flddisp = " deal.deal label 'Номер сделки' format '999999999' deal.nin label 'НИН' format 'x(12)' deal.ncrc[2] label 'Количество' format '>>,>>>,>>>,>>9' deal.ccrc label 'Чистая цена' format '>>,>>>,>>9' deal.regdt label 'Дата сделки' format '99/99/9999' deal.valdt label 'Дата валютирования' format '99/99/9999' deal.grp label 'Группа' format '>9' deal.base label 'База' format 'x(6)' deal.broke label 'Контрагент' format 'x(6)'                         "
        &chkey = "deal"
        &chtype = "string"
        &index  = "deal" 
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
	end.


	else do:
    {itemlist.i
	&set = "2" 
        &file = " deal "
        &frame = "row 6 width 110 centered 28 down overlay"
	&where = " deal.grp ge 0 and deal.grp le 70 "
	&flddisp = " deal.deal label 'Номер сделки' format '999999999' deal.nin label 'НИН' format 'x(12)' deal.ncrc[2] label 'Количество' format '>>,>>>,>>>,>>9' deal.ccrc label 'Чистая цена' format '>>,>>>,>>9' deal.regdt label 'Дата сделки' format '99/99/9999' deal.valdt label 'Дата валютирования' format '99/99/9999' deal.grp label 'Группа' format '>9' deal.base label 'База' format 'x(6)' deal.broke label 'Контрагент' format 'x(6)'                         "
        &chkey = "deal"
        &chtype = "string"
        &index  = "deal" 
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
	end.



    v-deal = deal.deal.
    find first dealref where dealref.nin = deal.nin.

    v-nin = dealref.nin.
    v-cbname = dealref.cb.
    v-crc = dealref.crc.
    v-atval = dealref.atvalueon.
    v-type = dealref.type.
    v-sort = dealref.sort.
    v-ncrc = dealref.ncrc.
    v-intrate = dealref.intrate.
    v-issuedt = dealref.issuedt.
    v-maturedt = dealref.maturedt.
    v-paydt = dealref.paydt.
    v-inttype = dealref.inttype.


    displ v-deal v-nin v-cbname v-crc v-atval v-type v-sort v-ncrc v-intrate v-issuedt v-maturedt v-paydt v-inttype 
        with frame deal.
end.



do transaction:

if cln then hide v-scugrp in frame deal.
if not cln then hide v-cif v-lsch in frame deal.

    clear frame deal.

    update v-deal with frame deal.


    find first deal where deal.deal eq v-deal no-lock no-error.
    if not avail deal then do:
        message "Не найдена сделка " v-deal.
        pause 100.
        undo, retry.
    end.

    if deal.fun ne "" then do:
        message "Произведена транзакция - редактирование недопустимо".
        pause 100.
        undo, retry.
    end.


/*
    v-deal = deal.deal.
    v-nin = dealref.nin.
    v-cbname = dealref.cb.
    v-crc = dealref.crc.
    v-atval = dealref.atvalueon.
    v-type = dealref.type.
    v-sort = dealref.sort.
    v-ncrc = dealref.ncrc.
    v-intrate = dealref.intrate.
    v-issuedt = dealref.issuedt.
    v-maturedt = dealref.maturedt.
    v-paydt = dealref.paydt.
    v-lpaydt = dealref.lpaydt.
    v-inttype = dealref.inttype.
*/    

    if v-deal ne "" then find first deal where deal.deal eq v-deal no-lock.
    v-cif = deal.cif.
    find first cif where cif.cif eq deal.cif no-error.
    if avail cif then v-lsch = cif.head[1].
    v-scugrp = deal.grp.
    v-nin = deal.nin.
    v-base = deal.base.
    v-ccrc = deal.ccrc.
    v-col = deal.ncrc[2].
    v-profit = deal.profit.
    v-crc = deal.crc.
    v-regdt = deal.regdt.
    v-valdt = deal.valdt.
    v-kontr = deal.broke.
    v-dealsum = deal.prn.
    v-closeprice = deal.intamt.
    v-closesum = deal.totamt.
    v-bcrc = deal.brkgfee.
    v-geo	= deal.geo.        /* Гео признак		*/
    v-sector	= deal.arrange.     /* Сектор экономики	*/


    find first dealref where dealref.nin eq deal.nin no-lock no-error.
    v-cbname = dealref.cb.
    v-atval = dealref.atvalueon.
    v-type = dealref.type.
    v-sort = dealref.sort.
    v-ncrc = dealref.ncrc.
    v-intrate = dealref.intrate.
    v-issuedt = dealref.issuedt.
    v-maturedt = dealref.maturedt.
    v-paydt = dealref.paydt.
    v-inttype = dealref.inttype.

    v-dval2 = v-maturedt - v-regdt.
    v-dval3 = v-paydt - v-regdt.

    clear frame deal.

    if cln then do:

        displ v-deal v-cif v-lsch v-nin v-cbname v-atval v-type
            v-sort v-ncrc v-intrate v-issuedt v-maturedt v-paydt
            v-base v-inttype v-col v-profit v-ccrc v-crc v-regdt
            v-valdt v-kontr v-dval2 v-dealsum 
            v-bcrc v-closesum v-closeprice v-geo v-sector with frame deal.
 
        update v-cif v-nin v-base v-ccrc v-col v-profit v-regdt v-valdt v-kontr with frame deal.

        if v-cif ne deal.cif then do:
            update v-com with frame comt.
            create dealhist.
            assign dealhist.deal = deal.deal
                dealhist.rdt = today
                dealhist.rtm = time
                dealhist.fname = "Код клиента"
                dealhist.who = g-ofc
                dealhist.oldval = deal.cif
                dealhist.newval = v-cif
                dealhist.com = v-com.
 
            find current deal exclusive-lock.
            deal.cif = v-cif.
        end.
    end.

    if not cln then do:

        displ v-deal v-scugrp v-nin v-cbname v-atval v-type v-sort v-ncrc v-intrate v-issuedt v-maturedt
            v-paydt v-base v-inttype v-col v-profit v-ccrc v-crc v-regdt v-valdt v-kontr v-dval2
            v-dealsum v-bcrc v-closesum v-closeprice v-geo v-sector with frame deal.
 
        
       do on error undo, retry:
            update v-scugrp label "Группа......" with frame deal.
            find scugrp where scugrp.scugrp = v-scugrp no-lock no-error.
            if not available scugrp then undo, retry.
            v-gl = scugrp.gl.
            find gl where gl.gl eq v-gl no-error.
            if not avail gl then do:
                message "Не найден счет " v-gl " в Главной Книге".
                pause.
                undo, retry.
            end.
        end. /* do on error for gl checking */
        
on help of v-base in frame deal do:
		run sel ("Выберете базу:", " 1. 30/360 | 2. 30/365 | 3. 31/360 | 4. 31/365").
	  	case return-value:
		when "1" then assign v-base = "30/360".
		when "2" then assign v-base = "30/365".
		when "3" then assign v-base = "31/360".
		when "4" then assign v-base = "31/365".
		end case. 
	        displ v-base with frame deal.
               end.

on help of v-geo in frame deal do: 
		run sel ("Выберете признак:", " 021 Резидент | 022 Нерезедент").
	  	case return-value:
		when "1" then assign v-geo = "021".
		when "2" then assign v-geo = "022".
		end case. 
	        displ v-geo with frame deal.
end.

on help of v-ccrc in frame deal do:
message "  Чистая цена должна быть больше 0!".
end.

on help of v-col in frame deal do:
message "  Каличество ЦБ должно быть больше 0!".
end.

on help of v-profit in frame deal do:
message "  Доходность должна быть больше 0!".
end.

on help of v-regdt in frame deal do:
message "  Введите дату сделки (дата должна быть больше 01/01/1990 и даты выпуска ЦБ, а также меньше 01/01/2035)".
end.

on help of v-valdt in frame deal do:
message "  Введите дату валютирования (дата должна быть больше 01/01/1990 и даты выпуска ЦБ, а также меньше 01/01/2035)".
end.

on help of v-kontr in frame deal do:
message "  Введите контрагента!".
end.

       
    repeat:
    update v-nin with frame deal.
    find first dealref where dealref.nin eq v-nin no-lock no-error.
        if not avail dealref then message "Данные отсутствуют в справочнике!".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.

    repeat:
        update v-base with frame deal.
        if v-base eq "" then message "Невведена база!".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.

    repeat:     
        update v-geo with frame deal.
        if (v-geo eq "") then message "Признак резиденства не может быть пустым".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.


    repeat:     
        update v-sector with frame deal.
        if (v-sector eq "") then message "Сектор экономики не может быть пустым".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.

    
    repeat:     
        update v-ccrc with frame deal.
        if (v-ccrc eq 0) or (v-ccrc le 0) then message "Чистая цена < = 0!".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.
   
    repeat:
        update v-col with frame deal.
        if (v-col eq 0) or (v-col le 0) then message "Количество < = 0!".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.
    
     repeat:
        update v-profit with frame deal.
        if (v-profit eq 0) or (v-profit le 0) then message "Доходность < = 0!".
        else leave.
    end.
    
/*
    repeat:
        update v-crc with frame deal.
        find first crc where crc.crc eq v-crc no-lock no-error.
        if not avail crc then message "Валюта отсутствует в справочнике!".
        else leave.
    end.
*/
    repeat:
        update v-regdt with frame deal.
        if (v-regdt eq ?) or (v-regdt < 01/01/1990) or (v-regdt < v-issuedt) or (v-regdt > v-paydt) or (v-regdt > v-maturedt) or (v-regdt > 01/01/2035) then message "Неверно введена дата сделки! Нажмите F2.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.


    repeat:
        update v-valdt with frame deal.
        if (v-valdt eq ?) or (v-valdt < 01/01/1990) or (v-valdt < v-issuedt) or (v-valdt > v-paydt) or (v-valdt > v-maturedt) or (v-valdt > 01/01/2035) then message "Неверно введена дата валютирования! Нажмите F2.".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.
    

    repeat:
        update v-kontr with frame deal.
        if v-kontr eq "" then message "Невведен контрагент!".
        else leave.
    end.

        if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.


on help of v-com in frame comt do:
message "Справочник не предусмотрен.".
end.

        if v-scugrp ne deal.grp then do:
	 frame comt:title = "Введите причину исправления поля 'Группа ЦБ'".

    repeat:
        update v-com with frame comt.
        if v-com eq ? then message "Не введен коментарий.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Все изменения не сохранятся!" view-as alert-box.
            return. end.

            create dealhist.
            assign dealhist.deal = deal.deal
                dealhist.rdt = today
                dealhist.rtm = time
                dealhist.fname = "Группа ЦБ"
                dealhist.who = g-ofc
                dealhist.oldval = string(deal.grp)
                dealhist.newval = string(v-scugrp)
                dealhist.com = v-com.
 
            find current deal exclusive-lock.
            deal.grp = v-scugrp.
            find scugrp where scugrp.scugrp = v-scugrp no-lock no-error.
            deal.gl = scugrp.gl.
            find current deal no-lock.
        end.
    end.

    if v-nin ne deal.nin then do:
	 frame comt:title = "Введите причину исправления поля 'НИН'".

    repeat:
        update v-com with frame comt.
        if v-com eq ? then message "Не введен коментарий.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Все изменения не сохранятся!" view-as alert-box.
            return. end.

        create dealhist.
        assign dealhist.deal = deal.deal
            dealhist.rdt = today
            dealhist.rtm = time
            dealhist.fname = "НИН"
            dealhist.who = g-ofc
            dealhist.oldval = deal.nin
            dealhist.newval = v-nin
            dealhist.com = v-com.
 
        find current deal exclusive-lock.
        deal.nin = v-nin.
        find current deal no-lock.
    end.

    if v-base ne deal.base then do:
	 frame comt:title = "Введите причину исправления поля 'БАЗА'".

    repeat:
        update v-com with frame comt.
        if v-com eq ? then message "Не введен коментарий.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Все изменения не сохранятся!" view-as alert-box.
            return. end.

        create dealhist.
        assign dealhist.deal = deal.deal
            dealhist.rdt = today
            dealhist.rtm = time
            dealhist.fname = "БАЗА"
            dealhist.who = g-ofc
            dealhist.oldval = deal.base
            dealhist.newval = v-base
            dealhist.com = v-com.

        find current deal exclusive-lock.
        deal.base = v-base.
        find current deal no-lock.
    end.

/*
    if v-ccrc ne deal.ccrc then do:
        update v-com with frame comt title "Введите причину исправления поля 'Офицер'".
        create dealhist.
        assign dealhist.deal = deal.deal
            dealhist.rdt = today
            dealhist.rtm = time
            dealhist.fname = "Офицер"
            dealhist.who = g-ofc
            dealhist.oldval = string(deal.ccrc)
            dealhist.newval = string(v-ccrc)
            dealhist.com = v-com.

        find current deal exclusive-lock.
        deal.ccrc = v-ccrc.
        find current deal no-lock.
    end.
*/

    if v-col ne deal.ncrc[2] then do:
	 frame comt:title = "Введите причину исправления поля 'Количество'".

    repeat:
        update v-com with frame comt.
        if v-com eq ? then message "Не введен коментарий.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Все изменения не сохранятся!" view-as alert-box.
            return. end.

        create dealhist.
        assign dealhist.deal = deal.deal
            dealhist.rdt = today
            dealhist.rtm = time
            dealhist.fname = "Количество"
            dealhist.who = g-ofc
            dealhist.oldval = string(deal.ncrc[2])
            dealhist.newval = string(v-col)
            dealhist.com = v-com.
 
        find current deal exclusive-lock.
        deal.ncrc[2] = v-col.
        find current deal no-lock.
    end.

    if v-profit ne deal.profit then do:
	 frame comt:title = "Введите причину исправления поля 'Доходность'".

    repeat:
        update v-com with frame comt.
        if v-com eq ? then message "Не введен коментарий.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Все изменения не сохранятся!" view-as alert-box.
            return. end.

        create dealhist.
        assign dealhist.deal = deal.deal
            dealhist.rdt = today
            dealhist.rtm = time
            dealhist.fname = "Доходность"
            dealhist.who = g-ofc
            dealhist.oldval = string(deal.profit)
            dealhist.newval = string(v-profit)
            dealhist.com = v-com.

        find current deal exclusive-lock.
        deal.profit = v-profit.
        find current deal no-lock.
    end.


    if v-regdt ne deal.regdt then do:
	 frame comt:title = "Введите причину исправления поля 'Дата сделки'".

    repeat:
        update v-com with frame comt.
        if v-com eq ? then message "Не введен коментарий.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Все изменения не сохранятся!" view-as alert-box.
            return. end.

        create dealhist.
        assign dealhist.deal = deal.deal
            dealhist.rdt = today
            dealhist.rtm = time
            dealhist.fname = "Дата сделки"
            dealhist.who = g-ofc
            dealhist.oldval = string(deal.regdt)
            dealhist.newval = string(v-regdt)
            dealhist.com = v-com.

        find current deal exclusive-lock.
        deal.regdt = v-regdt.
        find current deal no-lock.
    end.

    if v-kontr ne deal.broke then do:
	 frame comt:title = "Введите причину исправления поля 'Контрагент'".

    repeat:
        update v-com with frame comt.
        if v-com eq ? then message "Не введен коментарий.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Все изменения не сохранятся!" view-as alert-box.
            return. end.

        create dealhist.
        assign dealhist.deal = deal.deal
            dealhist.rdt = today
            dealhist.rtm = time
            dealhist.fname = "Контрагент"
            dealhist.who = g-ofc
            dealhist.oldval = deal.broke
            dealhist.newval = v-kontr
            dealhist.com = v-com.

        find current deal exclusive-lock.
        deal.broke = v-kontr.
        find current deal no-lock.
    end.

    if v-valdt ne deal.valdt then do:
	 frame comt:title = "Введите причину исправления поля 'Дата валютирования'".

    repeat:
        update v-com with frame comt.
        if v-com eq ? then message "Не введен коментарий.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do: 
            message "Вы нажали F4! Все изменения не сохранятся!" view-as alert-box.
            return. end.

        create dealhist.
        assign dealhist.deal = deal.deal
            dealhist.rdt = today
            dealhist.rtm = time
            dealhist.fname = "Дата валютирования"
            dealhist.who = g-ofc
            dealhist.oldval = string(deal.valdt)
            dealhist.newval = string(v-valdt)
            dealhist.com = v-com.

        find current deal exclusive-lock.
        deal.valdt = v-valdt.
        find current deal no-lock.
    end.


  /*  run dealval2.*/


end. /*transaction*/
message "Для выхода нажмите пробел и F4". pause.
end.  /* конец огромного репита */