/* chk-rekv.i
 * MODULE
        Платежные карты
 * DESCRIPTION
        Функция сравнения реквизитов, где вместо спец.символов стоят ???
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
        30/10/2012 id00810
 * BASES
        BANK
 * CHANGES
 */

  function chk-rekv returns logi (p-rekv1 as char, p-rekv2 as char).
    def var v-chk as logi no-undo.
    def var k     as int  no-undo.
    do k = 1 to length(p-rekv1).
        if substr(p-rekv1,k,1) = '?' then do:
            p-rekv1 = substr(p-rekv1,1,k - 1) + ' ' + substr(p-rekv1,k + 1).
            p-rekv2 = substr(p-rekv2,1,k - 1) + ' ' + substr(p-rekv2,k + 1).
        end.
    end.
    if p-rekv1 = p-rekv2 then v-chk = yes.
    return v-chk.
  end function.
