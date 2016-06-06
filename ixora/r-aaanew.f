/* r-aaanew.f
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
*/

/* r-aaanew.f
*/
form
     "СЧЕТ# : " aaa.aaa "КИФ  : " aaa.cif "НАИМЕНОВАНИЕ: " aaa.name
     "ДАТА ЗАКРЫТИЯ: " aaa.expdt "  СТАВКА   : " aaa.rate skip
     space(26) "ТИП  : " aaa.lgr  space(8)  "ОПИС. : " lgr.des
     space(20) "СРОК     : "  vterm  space(8) "ДАТА РЕГ. : " aaa.regdt skip
     space(41) "СУММА ОТКР.: "  aaa.opnamt space(17)
     "ТЕКУЩАЯ СУММА: " gbal

     skip(2)
     with width 132 no-box no-label.
