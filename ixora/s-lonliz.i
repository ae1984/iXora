/* s-lonliz.i
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
        10/08/10 aigul - вывод суммы
        17/09/2010 aigul - вывод суммы по валютам
        26/07/12 dmitriy - добавил ppay-kom
        09/08/2012 kapar - ТЗ ASTANA-BONUS
*/

/*
* s-lonliz.i
* Shared var for leasing
* S.Kuzema 25.03.98
*/
define {1} shared var avnpay      as decimal.   /* avansa summa nominal–*/
define {1} shared var avnpay1     as decimal.   /* avans summa val­t–*/
define {1} shared var pvnpay      as decimal.   /* PVN summa nominal–*/
define {1} shared var pvnpay1     as decimal.   /* PVN summa val­t–*/
define {1} shared var noform-pay  as decimal.   /* noformeЅana nominal–*/
define {1} shared var noform-pay1 as decimal.   /* noformeЅana val­t–*/
define {1} shared var atalg-pay   as decimal.   /* atalogЅana nomin–la*/
define {1} shared var atalg-pay1  as decimal.   /* atalogЅana valut–*/
define {1} shared var total-pay   as decimal.   /* kopёja summa nomin–l–*/
define {1} shared var total-pay1  as decimal.   /* kopёja summa val­t–*/
define {1} shared var total-pay2  as decimal. /*всего сумма*/
define {1} shared var total-pay-all  as decimal.   /*всего сумма–*/
define {1} shared var total-pay-all2  as decimal.   /*всего сумма–*/
define {1} shared var depo-pay    as decimal.   /* deposita summa nomin–l–*/
define {1} shared var depo-pay1   as decimal.   /* deposita summa val­t–*/
define {1} shared var lon-pvn     as decimal.   /* PVN % */
define {1} shared var s-glrem     as char.      /* piezЁme */
define {1} shared var s-glremx    as char extent 10. /* piezЁme 10 lines */
define {1} shared var s-ordtype   as integer.   /* ordera tips */
define {1} shared var ppay-kom    as decimal.   /* комиссия по годовой ставке */
