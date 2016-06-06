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
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
*/

{global.i}

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

    repeat:   /* начало огромного репита */

def input parameter cln as logical. /* yes - клиентские сделки. no - собственные сделки.*/

def shared var v-new as log init yes.
def shared var v-edit as log init no.
def shared var v-deal like deal.deal.

/*общая часть*/
def var v-scugrp   like deal.grp.
def var v-gl       like gl.gl.
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
/* def var v-dval3    as int. */
def var v-base     like deal.base.
def var v-inttype  like deal.inttype.

/*Сведения о сделке*/
def var v-ccrc     as deci.
def var v-col      like deal.ncrc[2].
def var v-profit   like deal.profit.
def var v-bcrc     as dec.
def var v-dealsum  as dec.
def var v-closeprice  as dec.
def var v-closesum    as dec.
def var v-crc      like dealref.crc.
def var v-regdt    as date.
def var v-valdt    like deal.valdt.
def var v-kontr    like deal.broke.

def var v-lsch     as char.
def var v-lpaydt   like dealref.lpaydt.
def var v-acc      like deal.deal.
def var v-cif      like cif.cif.
def var v-bankl    like deal.bank.

def var v-geo    as char.
def var v-sector   as char.

/* определение переменных для trxgrn*/
def var v-jh as int init 0.
def var rcode as int.
def var rdes as char.
def var vdel as char init "|".
def var vparam as char.
def var MESS as char.
def var v-arp as char.
def var v-decpnt as integer init 2.
define variable quest   as logical format "Да/Нет" no-undo.


def new shared var s-lgr like lgr.lgr.
{deal3.f}

on help of v-nin in frame deal do:
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
    v-cbname = dealref.cb.
    v-crc = dealref.crc.
    v-atval = dealref.atvalueon.
    v-type = dealref.type.
    v-sort = dealref.sort.
    v-ncrc = dealref.ncrc.
    v-intrate = dealref.intrate.
    v-issuedt = dealref.issuedt.
    v-maturedt = dealref.maturedt.
/*    v-paydt = dealref.paydt. */
    v-lpaydt = dealref.lpaydt.
    v-inttype = dealref.inttype.

    displ v-nin v-cbname v-crc v-atval v-type v-sort v-ncrc v-intrate v-issuedt v-maturedt v-inttype
        with frame deal.
end.


    v-bankl = v-clecod.
    v-gl = 0.

do transaction:

    if cln then do:
        do on error undo, retry:
            v-scugrp = 70.
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
        hide v-scugrp in frame deal.
        update v-cif with frame deal.
        find cif where cif.cif eq v-cif no-error.
        if not avail cif then do:
            message "Не найден код клиента " v-cif.
            pause.
            undo, retry.
        end.
        v-lsch = cif.head[1].
        displ v-lsch with frame deal.
    end.


    if not cln then do:

        hide v-cif v-lsch in frame deal.

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
end.



    run acng(v-gl, true, output v-acc).
        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Редактирование будет закрыто!" view-as alert-box.
            return. end.


    find first fun where fun.fun = v-acc no-error.
    if avail fun then delete fun.
    if input v-deal eq "" then v-deal = v-acc.
    displ v-deal with frame deal.



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


on help of v-sector in frame deal do:
run uni_help1("secek",'*').
end.



on help of v-ccrc in frame deal do:
message "  Чистая цена должна быть больше 0!".
end.


on help of v-col in frame deal do:
message "  Каличество ЦБ должно быть больше 0!".
end.

on help of v-regdt in frame deal do:
message "  Введите дату сделки (дата должна быть больше 01/01/1990 и даты выпуска ЦБ (" string(v-issuedt,"99/99/9999") "), а также меньше 01/01/2050 и даты погашения ЦБ (" string(v-maturedt,"99/99/9999") ")".
end.

on help of v-valdt in frame deal do:
message "  Введите дату валютирования (дата должна быть больше 01/01/1990 и даты выпуска ЦБ (" string(v-issuedt,"99/99/9999") "), а также меньше 01/01/2050 и даты погашения ЦБ (" string(v-maturedt,"99/99/9999") ")".
end.

on help of v-paydt in frame deal do:
message "  Введите дату закрытия сделки (дата должна быть больше 01/01/1990 и даты выпуска ЦБ (" string(v-issuedt,"99/99/9999") "), а также меньше 01/01/2050 и даты погашения ЦБ (" string(v-maturedt,"99/99/9999") ")".
end.

on help of v-bcrc in frame deal do:
message "  Цена открытия должна быть больше 0!".
end.

on help of v-closesum in frame deal do:
message "  Сумма закрытия должна быть больше 0!".
end.

on help of v-closeprice in frame deal do:
message "  Цена закрытия должна быть больше 0 и цены открытия!".
end.


/*
on help of v-kontr in frame deal do:
message "  Введите контрагента!".
end.


on help of v-kontr in frame deal do:
    {itemlist.i
        &file = " deal "
        &frame = "row 22 width 40 centered 15 down overlay "
        &where = " deal.broke ne '' "
        &flddisp = " deal.broke label ' Ранее вводимые Брокеры (Контрагенты) ' format 'x(38)'"
        &chkey = "broke"
        &chtype = "string"
        &index  = "deal"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-kontr = deal.broke.

    displ v-kontr
        with frame deal.
end.
*/



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
        if (v-base eq "30/360") or (v-base eq "30/365") or (v-base eq "31/360") or (v-base eq "31/365") then leave.
	else message "Невведена база! 30/360 30/365 факт/360 факт/факт".
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
        update v-bcrc with frame deal.
        if (v-bcrc <= 0) or (v-bcrc <= v-ccrc) then message "Цена открытия должны быть больше нуля и чистой цены!".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.

        v-dealsum = v-col * v-bcrc.
        v-profit = (v-bcrc - v-ccrc) * v-col.
        displ v-profit v-dealsum with frame deal.


v-regdt = g-today.

    repeat:
        update v-regdt with frame deal.
        if (v-regdt eq ?) or (v-regdt < 01/01/1990) or (v-regdt < v-issuedt) or (v-regdt > v-maturedt) or (v-regdt > 01/01/2035) then message "Неверно введена дата сделки! Нажмите F2.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.

    v-valdt = v-regdt.

        v-dval2 = v-maturedt - v-regdt.
        displ v-dval2 with frame deal.

    repeat:
        update v-valdt with frame deal.
        if (v-valdt eq ?) or (v-valdt < 01/01/1990) or (v-valdt < v-issuedt) or (v-valdt > v-maturedt) or (v-valdt > 01/01/2035) then message "Неверно введена дата валютирования! Нажмите F2.".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.


    repeat:
        update v-closeprice with frame deal.
        if (v-closeprice <= 0) or (v-closeprice <= v-bcrc) then message "Цена закрытия должны быть больше нуля и цены открытия!".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.

	v-closesum = v-col * v-closeprice.
	displ v-closesum with frame deal.

/*
    repeat:
        update v-closesum with frame deal.
        if (v-closesum eq 0) or (v-closesum le 0) then message "Сумма закрытия должны быть больше нуля!".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.
*/

	v-paydt = v-maturedt.

    repeat:
        update v-paydt with frame deal.
        if (v-paydt eq ?) or (v-paydt < 01/01/1990) or (v-paydt < v-issuedt) or (v-paydt > v-maturedt) or (v-paydt > 01/01/2050) then message "Неверно введена дата закрытия сделки! Нажмите F2.".
        else leave.
    end.
         if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.


def temp-table t-list no-undo
    field broke as char
    index idx is primary broke.
empty temp-table t-list.

for each deal where deal.broke ne '' no-lock break by deal.broke:
    if first-of(deal.broke) then do:
       create t-list.
       t-list.broke = deal.broke.
     end.
    end.

on help of v-kontr in frame deal do:
    {itemlist.i
        &file = " t-list "
        &frame = "row 21 width 24 column 72 10 down overlay "
        &where = " t-list.broke ne '' "
        &flddisp = " t-list.broke label 'Ранее вводимые Брокеры' format 'x(22)'"
        &chkey = "broke"
        &chtype = "string"
        &index  = "idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-kontr = t-list.broke.
    displ v-kontr with frame deal.
end.

    repeat:
        update v-kontr with frame deal.
        if v-kontr eq "" then message "Невведен брокер! Нажмине F2 чтоб выбрать из списка уже вводимых брокеров!".
        else leave.
    end.
        if keyfunction(lastkey) eq "end-error" then do:
            message "Вы нажали F4! Редактирование сделки будет закрыто!" view-as alert-box.
            return. end.


/*   Запись из переменных в диал */

    find deal exclusive-lock no-error.
    create deal.
    assign deal.deal	= v-deal	/* номер сделки		*/
        deal.grp	= v-scugrp	/* Группа		*/
        deal.nin	= v-nin         /* НИН			*/
        deal.crc	= v-crc         /* Валюта		*/
        deal.base	= v-base        /* База			*/
        deal.ccrc	= v-ccrc        /* Чистая цена		*/
        deal.ncrc[2]	= v-col         /* Количество ЦБ	*/
        deal.profit	= v-profit      /* Доходность		*/
        deal.regdt	= v-regdt       /* Дата открытия	*/
        deal.valdt	= v-valdt       /* Дата валютир		*/
        deal.broke	= v-kontr       /* Брокер		*/
        deal.gl		= v-gl          /* Счет ГК		*/
	deal.whn	= v-paydt       /* Дата закрытия	*/
        deal.maturedt	= v-maturedt    /* Дата погашен		*/
        deal.intrate	= v-intrate     /* Купон (%)		*/
        deal.inttype	= v-inttype     /* Тип ЦБ (A/D)		*/
        deal.bank	= v-bankl       /* Банк			*/
        deal.prn	= v-dealsum     /* Сумма сделки		*/
	deal.intamt	= v-closeprice  /* Цена закрытия	*/
	deal.totamt	= v-closesum    /* Сумма закрытия	*/
	deal.brkgfee	= v-bcrc        /* Цена открытия	*/
	deal.lonsec	= v-dval2       /* Кол-во дней до погаш */
	deal.geo	= v-geo.        /* Гео признак		*/
	deal.arrange	= v-sector.     /* Сектор экономики	*/
	deal.who	= g-ofc.        /* g-ofc		*/
        if cln then deal.cif = v-cif.

/*   Запись в scu из переменных */

    find scu where scu.scu = v-deal exclusive-lock no-error.
    assign
	scu.grp		= v-scugrp 	/* Группа		*/
	scu.ref		= v-nin		/* НИН			*/
	scu.crc		= v-crc		/* Валюта		*/
	scu.cst		= v-base	/* База			*/
	scu.ydam[1]	= v-ccrc	/* Чистая цена		*/
	scu.ydam[2]	= v-col		/* Количество ЦБ	*/
	scu.ydam[3]	= v-profit	/* Доходность		*/
	scu.ddt[1]	= v-regdt	/* Дата открытия	*/
	scu.ddt[2]	= v-valdt	/* Дата валютир		*/
	scu.broker	= v-kontr	/* Брокер		*/
	scu.gl		= v-gl		/* Счет ГК		*/
	scu.cdt[1]	= v-paydt	/* Дата закрытия	*/
	scu.cdt[2]	= v-maturedt	/* Дата погашен		*/
	scu.intrate	= v-intrate	/* Купон (%)		*/
	scu.itype	= v-inttype	/* Тип ЦБ (A/D)		*/
	scu.tbank	= v-bankl	/* Банк			*/
	scu.ycam[1]	= v-dealsum	/* Сумма сделки		*/
	scu.ycam[2]	= v-closeprice	/* Цена закрытия	*/
	scu.ycam[3]	= v-closesum	/* Сумма закрытия	*/
	scu.ycam[4]	= v-bcrc	/* Цена открытия	*/
	scu.lonsec	= v-dval2	/* Кол-во дней до погаш */
	scu.geo		= v-geo.        /* Гео признак		*/
	scu.type	= v-sector.     /* Сектор экономики	*/
	scu.who		= g-ofc.	/* g-ofc		*/
         if cln then scu.cif = v-cif.
     end.

/* trx-gen */
	if (v-scugrp = 30) or (v-scugrp = 40) then do:
		v-arp = "KZ66470151852A020100".
		quest = false.
		message "Подготовленна проводка: Дебет счета scu-" + scu.scu + ". Кредет счета arp-" + v-arp + ". Сумма проводки-" + string( v-dealsum ) + ".".
		message "Провести транзакцию?" update quest.
        		if quest then do:
			run СhargeSCU(v-dealsum).
			if rcode = 0 then MESS = "Проводка успешно проведена! Дебет scu " + scu.scu + " кредет arp " + v-arp + ". Номер проводки " + string( v-jh ) + ". Сумма " + string( v-dealsum ).
			message MESS skip rdes view-as alert-box.
			end.
		end.

/* procedures */
Procedure СhargeSCU.
    def input param sum as decimal decimals 2 format "zzz,zzz,zzz,zzz,zzz,zz9.99-".
    sum = round(sum,v-decpnt).
    vparam = string(sum) + vdel + scu.scu + vdel + string(v-arp) + vdel + "Проводка дебет scu кредет arp" + vdel + "" .
    run trxgen("SCU0001", vdel, vparam, "SCU", scu.scu, output rcode, output rdes, input-output v-jh).
    if rcode ne 0 then do:
      MESS = "Не удалось сформировать проводку для счета " + scu.scu + " в сумме " + string( sum ) + ".".
    end.
end procedure.


message "Для выхода нажмите пробел". pause.
return.
end.   /* конец огромного репита */

