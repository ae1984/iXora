/* h-secamt.f
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

define shared variable s-lon    as character.
define shared variable g-today  as date.

define shared variable m-ln as integer init 1.


form
    lonsec1.prm    label "Apraksts........" help "F1,F4-t–l–k"
    lonsec1.vieta  label "AtraЅan–s vieta." help "F1,F4-t–l–k"
    lonsec1.novert label "Novёrtёjums....." help "F1,F4-t–l–k"
    lonsec1.proc   label "VёrtЁbas %......" help "F1,F4-t–l–k"
    lonsec1.secamt label "VёrtЁbas summa.."
    lonsec1.apdr   label "ApdroЅin–Ѕana..." help "F1,F4-–r–"
    with row 6 column 1 1 columns overlay side-label title
	 "NodroЅin–juma apraksta ievade" frame colla.
