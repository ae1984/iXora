/* zavkas.f
 * MODULE
        Кассовый модуль
 * DESCRIPTION
        Общая для настройки авансов и подкреплений кассиров (касса)
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
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27/01/04 sasco Добавил валюту РУБЛЬ
        24.04.2009 galina - добавила Фунт стерлингов
*/


def var v-ofc like ofc.ofc label "Кассир".
def var v like cashofc.amt extent 12.
def var i as integer.

define frame f-zavkas
    v-ofc label "Кассир" at 1
    v[1] at 45 label "KZT"
    v[2] at 45 label "USD"
    v[3] at 45 label "EUR"
    v[4] at 45 label "RUB"
    v[6] at 45 label "GBP"
    with row 7 centered side-labels overlay.
    
define variable can-go as logical label "Продолжить?" init yes. 

define frame f-can-go
    can-go with centered row 15 side-labels.
    
define button b1 label "АВАНСЫ".
define button b2 label "ПОДКРЕПЛЕНИЯ".
define button b3 label "ВОЗВРАТ ПОДКРЕПЛЕНИЙ".
define button b4 label "СОСТОЯНИЕ КАССЫ".
define button b5 label "ИСТОРИЯ".

define frame mmm
    b1 b2 b3 b4 b5
    with side-labels row 3 centered.
    
define button bb1 label "ВОЗВРАТ ТЕКУЩИХ ПОДКРЕПЛЕНИЙ".
define button bb2 label "ВОЗВРАТ ОСТАТКА В КАССЕ".
define frame mmb
    bb1 bb2
    with row 7 centered.

do i = 1 to 12:
   v[i] = 0.0.
end.

