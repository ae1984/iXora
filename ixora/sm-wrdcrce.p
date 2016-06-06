/* sm-wrdcrce.p

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
        26.09.2006 u00777
 * CHANGES
        07/03/2008 madiyar - евро 11->3
*/
def var crc1 as char extent 11 initial ["tenge,tyin",
                                       "us dollars,cents",                                       
                                       "euro,eurocents",
                                       "russian rouble,russian kopeck",
                                       "",
                                       "", "", "", "", "", ""].
define input parameter n like crc.crc.
define output parameter des1 as char.
define output parameter des2 as char.
assign des1 = entry(1,crc1[n])
       des2 = entry(2,crc1[n]).


