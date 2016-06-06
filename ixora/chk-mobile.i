/* chkmobile.i
 * MODULE
        Платежные карты
 * DESCRIPTION
        Функция проверки мобильного номера на соответствие формата
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
        03/09/2013 yerganat
 * BASES
        BANK
 * CHANGES
 */

  function chk-mobile returns char (mobile as char).
    define variable withoutprefix    as char no-undo.
    define variable mobileidx        as int no-undo init 0.

    if not mobile begins "+7" then do:
        return "Номер мобильного телефона должен начинаться на '+7'".
    end.

    withoutprefix = substring(mobile,3).

    if length(withoutprefix) <> 10 then do:
        return "Количества цифр номера мобильного телефона должно быть '10'".
    end.

    do while mobileidx <  length(withoutprefix):
        mobileidx = mobileidx + 1.
        if index("0123456789", substring(withoutprefix,mobileidx, 1 )) = 0 then do:
            return "Номер мобильного телефона содержит недопустимые символы".
        end.
    end.

    return "".
  end function.
