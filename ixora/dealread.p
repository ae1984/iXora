/* dealread.p
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
    repeat:  /* начало огромного репита */


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
def var v-closeprice  as dec.
def var v-closesum    as dec.
def var v-ccrc     as deci.
def var v-col      like deal.ncrc[2].
def var v-profit   like deal.profit.
def var v-bcrc     as dec.
def var v-dealsum  as dec.
def var v-crc      like crc.crc.
def var v-regdt    as date.
def var v-valdt    like deal.valdt.
def var v-kontr    like deal.broke.

def var v-com      as char.
def var v-lsch     as char.
def var v-cif      like cif.cif.

def var v-geo    as char.
def var v-sector   as char.

form v-com no-label format "x(50)"
with frame comt row 15 centered width 80 title "Введите причину исправления".


{deal3.f}

on help of v-nin in frame deal do:
    {itemlist.i 
        &file = " dealref "
        &frame = "row 6 width 110 centered 28 down overlay "
        &where = " dealref.nin ne '' "
        &flddisp = " dealref.nin label 'НИН' format 'x(15)' dealref.cb label 'Наименование' format 'x(20)' "
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
    
    displ v-nin v-cbname v-crc v-atval v-type v-sort v-ncrc v-intrate v-issuedt v-maturedt v-paydt v-inttype 
        with frame deal no-error.
end.


on help of v-deal in frame deal do:
        if cln 
	then do:

    {itemlist.i 
        &set = "1" 
	&file = " deal "
        &frame = "row 6 width 110 centered 28 down overlay"
	&where = " deal.grp eq 70 "
	&flddisp = " deal.deal label 'Номер сделки' format '999999999' deal.nin label 'НИН' format 'x(12)' deal.ncrc[2] label 'Количество' format '>>,>>>,>>>,>>9' deal.ccrc label 'Чистая цена' format '->>>,>>>,>>>,>>9' deal.regdt label 'Д. сделки' format '99/99/9999' deal.valdt label 'Д. валютир.' format '99/99/9999' deal.grp label 'Группа' format '>9' deal.base label 'База' format 'x(6)' deal.broke label 'Брокер' format 'x(12)' "
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
	&flddisp = " deal.deal label 'Номер сделки' format '999999999' deal.nin label 'НИН' format 'x(12)' deal.ncrc[2] label 'Количество' format '>>,>>>,>>>,>>9' deal.ccrc label 'Чистая цена' format '->>>,>>>,>>>,>>9' deal.regdt label 'Д. сделки' format '99/99/9999' deal.valdt label 'Д. валютир.' format '99/99/9999' deal.grp label 'Группа' format '>9' deal.base label 'База' format 'x(6)' deal.broke label 'Брокер' format 'x(12)' "
        &chkey = "deal"
        &chtype = "string"
        &index  = "deal" 
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
	end.


    v-deal = deal.deal.
	find first dealref where dealref.nin = deal.nin.

    v-nin	= dealref.nin.
    v-cbname	= dealref.cb.
    v-crc	= dealref.crc.
    v-atval	= dealref.atvalueon.
    v-type	= dealref.type.
    v-sort	= dealref.sort.
    v-ncrc	= dealref.ncrc.
    v-intrate	= dealref.intrate.
    v-issuedt	= dealref.issuedt.
    v-maturedt	= dealref.maturedt.
    v-paydt	= dealref.paydt.
    v-inttype	= dealref.inttype.
    v-closeprice = deal.intamt.
    v-closesum	= deal.totamt.
    v-paydt	= deal.whn.

    v-dealsum	= deal.prn. 
    v-profit	= deal.profit.

    v-geo	= deal.geo.        /* Гео признак		*/
    v-sector	= deal.arrange.     /* Сектор экономики	*/

    displ v-deal v-nin v-cbname v-crc v-atval v-type v-sort v-ncrc v-intrate v-issuedt v-maturedt v-paydt v-inttype v-closeprice v-closesum v-paydt 
        with frame deal no-error.
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

/*
    if deal.fun ne "" then do:
        message "По данной сделке произведена транзакция." view-as alert-box.
    end.

    if deal.fun eq "" then do:
        message "По данной сделке не была произведена транзакция." view-as alert-box.
    end.
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
    v-closeprice = deal.intamt.
    v-closesum	= deal.totamt.
    v-dealsum	= deal.prn. 
    v-profit	= deal.profit.
    v-bcrc	= deal.brkgfee.
    v-paydt	= deal.whn.

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

/*
    v-dealsum = v-col * v-bcrc. 
    v-profit = (v-bcrc - v-ccrc) * v-col.
    v-bcrc = (v-ccrc * v-ncrc / 100) + v-ncrc * v-intrate / 100 / int(entry(2, v-base, "/")) * (v-regdt - v-lpaydt).
*/

    clear frame deal.

    if cln then do:

        displ v-deal v-cif v-lsch v-nin v-cbname v-atval v-type
            v-sort v-ncrc v-intrate v-issuedt v-maturedt v-paydt
            v-base v-inttype v-col v-profit v-ccrc v-crc v-regdt
            v-valdt v-kontr v-dval2 v-dealsum v-bcrc v-closesum 
	    v-closeprice v-geo v-sector with frame deal no-error.
 
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
            v-paydt v-base v-inttype v-col v-profit v-ccrc v-crc v-regdt v-valdt v-kontr v-dval2 v-closesum v-closeprice
            v-dealsum v-bcrc v-geo v-sector with frame deal no-error. 

        
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

end. /*transaction*/
message "Для выхода нажмите пробел и F4". pause.
end.  /* конец огромного репита */