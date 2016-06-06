/* adres.f
 * MODULE

 * DESCRIPTION
        Форма для ввода адреса в формате, необходимом для КФМ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25/02/2010 galina
 * BASES
        BANK
 * CHANGES
        26/02/2010 galina - убрала global.i
        07/03/2010 madiyar - добавил код страны
        19/03/2010 galina - сделала обязательным к заполнению страну, город, улицу и номер дома
*/


def var v-adres as char no-undo.
def var v-country2 as char no-undo.
def var v-country_cod as char no-undo.
def var v-region as char no-undo.
def var v-city as char no-undo.
def var v-street as char no-undo.
def var v-house as char no-undo.
def var v-office as char no-undo.
def var v-index  as char no-undo.
def var v-title  as char no-undo.

function chkIndex returns logi (input p-data as char).
    def var res as logi no-undo init yes.
    def var v-i as integer no-undo.
    v-i = integer(p-data) no-error.
    if error-status:error then res = no.
    return res.
end function.

form
  v-adres no-label colon 23 format "x(60)"  skip
  v-country2 label 'Страна' colon 23 format "x(40)" validate(trim(v-country2) <> '','Введите название страны') skip
  v-country_cod label 'Код страны' colon 23 format "x(2)" validate(can-find(codfr where codfr.codfr = "iso3166" and codfr.code = v-country_cod no-lock), "Код страны не введен или отсутствует в справочнике!") skip
  v-region label 'Область' colon 23 format "x(40)" skip
  v-city label 'Город (поселок и т.д.)' colon 23 format "x(40)" validate(trim(v-city) <> '','Введите название города') skip
  v-street label 'Наименование улицы' colon 23 format "x(40)" validate(trim(v-street) <> '','Введите название улицы') skip
  v-house label '№ дома' colon 23 format "x(40)" validate(trim(v-house) <> '','Введите номер дома') skip
  v-office label '№ офиса/квартиры' colon 23 format "x(40)" skip
  v-index label 'Почтовый индекс' colon 23 format "x(10)" validate(chkIndex(v-index),"Некорректный индекс!") skip
with centered side-label row 5 width 100 overlay  title v-title frame fadr .

on help of v-country_cod in frame fadr do:
    find first codfr where codfr.codfr = "iso3166" no-lock no-error.
    if avail codfr then do:
        {itemlist.i
            &file = "codfr"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " codfr.codfr = 'iso3166' "
            &flddisp = " codfr.code label 'Код' format 'x(8)' codfr.name[1] label 'Значение' format 'x(40)' "
            &chkey = "code"
            &index  = "cdco_idx"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        v-country_cod = codfr.code.
        displ v-country_cod with frame fadr.
    end.
end.

on "END-ERROR" of frame fadr do:
  hide frame fadr no-pause.
end.
