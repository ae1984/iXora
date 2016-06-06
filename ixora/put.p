/* put.p
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
        23.02.06   marinav   -  Доп логи в  dayclose.prt 
        31.03.06   marinav   -  Доп логи в  dayclose.prt 
*/

def input parameter kk as int.
def shared stream m-out.
def var putik as char extent 45 format "x(40)" init[
"Dayclose begins........................",
"Calculate Accrued Interest.............",
"                 ......................",
"dcls55           ......................",
"FUN interest     ......................",
"                 ......................",
"Start Pay Accrued Interest.............",
"                 ......................",
"Start ODA Accrued Interest dcls2.......",
"                 ......................",
"dcls32           ......................",
"Start CIF Subled Treatment trxoda......",
"dcls27           ......................",
"Start Trx Posting and Back.............",
"                 ......................",
"                 ......................",
"Start Convert to Local Currrency.......",
"                 ......................",
"Start Balance Update dcls51............",
"                 ......................",
"Start Points Dayclose dcls26...........",
"                 ......................",
"Posting Expense........................",
"                 ......................",
"Balance Sheet..........................",
"                 ......................",
"Interest Paid Upto date ...............",
"                 ......................",
"Totaling G/L for Average Balance... ...",
"                 ......................",
"Dayclose finished......................",
"_______________________________________",
"Closing non-active SAV accounts........",
"Income/Expenses of Profit-centers......",
"8 stroka data calculating .............",
"dcls56           ......................",
"dcls54           ......................",
"dclsind          ......................",
"dcls57           ......................",
"dclsprov         ......................",
"dcls17           ......................",
"dcls18           ......................",
"getcom           ......................",
"s-fakturis0      ......................",
"                 ......................"
].

put stream m-out putik[kk] string(time,"HH:MM:SS") skip.
