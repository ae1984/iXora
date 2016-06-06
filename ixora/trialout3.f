/* trialout3.f
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

      display jl.gl label "СГК" gl.sname label "  НАИМЕНОВАНИЕ"
                  vglbal label " ВХ.ОСТАТОК."
                  dr ( total by jl.crc ) label " ДЕБЕТ  "
                  cr (total by jl.crc )  label " КРЕДИТ  "
                  vsubbal  label " ИСХ.ОСТАТОК"
                  with no-box width 132 .

      display skip  "               курс =" + string( unitls,">>>>>9") +  "/" +
                   string ( ratels, "999.9999" ) format "x(34)" at 1
                "           KZT="  drr ( total by jl.crc )
                "KZT= "  crr ( total by jl.crc ) skip " "
                with no-box no-label width 132.
