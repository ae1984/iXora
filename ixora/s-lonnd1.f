/* s-lonnd1.f
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
        07.10.2005 marinav изменена форма
        01/03/2011 madiyar - изменена форма
        07/03/2013 sayat(id01143) - ТЗ 1655 добавлены поля "№ договора"(lonsec1.numdog), "Дата дог."(lonsec1.dtdog) и "ТипЗал"(lonsec1.sectp) с выбором значения из справочника
        18/07/2013 Sayat(id01143) - ТЗ 1637 от 28/12/2012 "Доработка модуля по залогам" добавлены обязательность заполнения lonsec1.numdog и lonsec1.dtdog и форма sec2
        25/07/2013 Sayat(id01143) - ТЗ 1637 от 28/12/2012 "Доработка модуля по залогам" обязательность заполнения lonsec1.numdog для lonsec1.lonsec=5 (без обеспечения) отключена
        25/07/2013 Sayat(id01143) - ТЗ 1637 от 28/12/2012 "Доработка модуля по залогам" добавлена обязательность заполнения lonsec1.sectp (ТипЗал)
*/

/*----------------------------------
  #3.NodroЅin–jums
----------------------------------*/


define new shared variable m-ln as integer init 1.
define new shared variable grp as integer init 1.

define variable s1   like lon.opnamt no-undo.
define variable s2   as decimal format "zz9.99" no-undo.
define variable s3   as decimal format "zz9.99" no-undo.
define variable s4   like lon.opnamt no-undo.
define variable dzest as logical no-undo.

form lonsec1.ln           label "N "
     lonsec1.lonsec       label "Код"     help "F2-код; F1-далее; F4-выход;"
     lonsec1.pielikums[1] label "Залогодатель  " format "x(42)"
     lonsec1.numdog       label "№ договора" format "x(15)" validate(lonsec1.numdog <> '' or lonsec1.lonsec = 5 ,"Номер договора залога должен быть заполнен!")
     lonsec1.dtdog        label "Дата дог." format "99/99/9999" validate(lonsec1.dtdog <> ? ,"Дата договора залога должна быть указана!")
     lonsec1.sectp        label "ТипЗал" format "x(2)" validate(lonsec1.sectp <> '' ,"Тип залога должен быть указан!") help "F2-справочник; F1-далее; F4-выход"
     lonsec1.crc          label "Вал"  help "F2-валюта; F1-далее; F4-выход; "
     lonsec1.secamt       label "Сумма"   help "F1-далее; F4-выход; "
     with 20 down row 6 width 110 overlay scroll 1
     title "Ввод обеспечения " frame sec1.

form
    s1         label "Сумма обеспечения"
    s2         label "% обеспечения"
    s3         label "%,с учетом % риска"
    with row 17 column 15 overlay title "Сумма кредита ном.валюте" +
    string(crchis.rate[1] / crchis.rate[9] * lon.opnamt,"zzz,zzz,zzz,zz9.99")
    + " " + s-lon frame br.

on help of lonsec1.sectp in frame sec1 do:
    {itemlist.i
        &set = "1"
        &file = " codfr "
        &form = " codfr.code label ""Код"" format ""x(5)"" codfr.name[1] label ""Наименование"" format ""x(80)"" "
        &frame = " 28 down row 6 width 100 overlay "
        &where = " codfr.codfr = ""sectp"" "
        &flddisp = " codfr.code codfr.name[1] "
        &chkey = "code"
        &chtype = "string"
        &index = "cdco_idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    /*if codfr.code = 'msc' then lonsec1.sectp = "00".
    else*/
    lonsec1.sectp = codfr.code.

    display lonsec1.sectp with frame sec1.
end.

form lonsec1.ln           label "N "
     lonsec1.lonsec       label "Код"     help "F2-код; F1-далее; F4-выход;"
     lonsec1.pielikums[1] label "Залогодатель  " format "x(20)"
     lonsec1.numdog       label "№ договора" format "x(15)" validate(lonsec1.numdog <> '' or lonsec1.lonsec = 5 ,"Номер договора залога должен быть заполнен!")
     lonsec1.dtdog        label "Дата дог." format "99/99/9999" validate(lonsec1.dtdog <> ? ,"Дата договора залога должна быть указана!")
     lonsec1.sectp        label "ТипЗал" format "x(2)" validate(lonsec1.sectp <> '' ,"Тип залога должен быть указан!") help "F2-справочник; F1-далее; F4-выход"
     lonsec1.crc          label "Вал"  help "F2-валюта; F1-далее; F4-выход; "
     lonsec1.secamt       label "Сумма" help "F1-далее; F4-выход; "
     lonsec1.fdt          label "Дата с    " format "99/99/9999" validate(lonsec1.fdt = lonsec1.dtdog ,"'Дата c' должна совпадать с датой договора!")
     lonsec1.tdt          label "Дата до   " format "99/99/9999" validate(lonsec1.tdt >= lonsec1.fdt ,"'Дата до' не может быть меньше чем 'Дата с'!")
     with 20 down row 6 width 110 overlay scroll 1
     title "Корректировка обеспечения " frame sec2.

on help of lonsec1.sectp in frame sec2 do:
    {itemlist.i
        &set = "1"
        &file = " codfr "
        &form = " codfr.code label ""Код"" format ""x(5)"" codfr.name[1] label ""Наименование"" format ""x(80)"" "
        &frame = " 28 down row 6 width 100 overlay "
        &where = " codfr.codfr = ""sectp"" "
        &flddisp = " codfr.code codfr.name[1] "
        &chkey = "code"
        &chtype = "string"
        &index = "cdco_idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    /*if codfr.code = 'msc' then lonsec1.sectp = "00".
    else*/
    lonsec1.sectp = codfr.code.

    display lonsec1.sectp with frame sec2.
end.