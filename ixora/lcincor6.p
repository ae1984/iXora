﻿/* lcincor6.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        EXSBLC: Корреспонденция - входящий свифт
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
 * BASES
        BANK
 * AUTHOR
        02/12/2011 id00810
 * CHANGES
*/

def new shared var s-lcprod as char initial 'EXSBLC'.
run lcincor.