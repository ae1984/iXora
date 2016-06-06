/* r-htrx2.f
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

/* r-aaatra.p     04/10/93 AGA  к запуску в банке   */
/* r-aaatra.p     17/10/93 AGA  правлено в банке  12:07:23 */
/* r-aaatra.p     01/03/94 AGA  правлено для разделения переменных */

def var s-toavail like jl.dam label "TotAvail" init 0.
def var cravail like aaa.cbal label "Cr-Avail" init 0.

def var vfdt  as date label "С  - Дата".
def var vtdt  as date label "По - Дата".
def var vtrx  as log  label "Trx Kод /Oпр#" format "Kод /Oпр#".
def var me2   as char format "x(22)" init "ЖДИТЕ   ... ЖДИТЕ   ...".

def var nf2   as char format "x(7)" init "время: ".
def var nf3   as char format "x(9)" init "   дата  ".

def var nf4   as char init "ВЫПИСКА ПО КЛИЕНТСКОМУ СЧЕТУ".
DEF VAR nf5   as char init "операции  с   ".
DEF VAR nf6   as char init "   по    ".
DEF VAR nf7 as char init
     "============================================================".
   /* 1234567890123456789012345678901234567890123456789012345    */
def var nf8 as char format "x(14)"  init "Код клиента : ".
def var nf9 as char format "x(14)"  init "              ".
def var nf9a as char format "x(14)" init "      Адрес : ".
/*
def var nf8 as char format "x(10)" init "CIF#     :".
def var nf9 as char format "x(10)" init "          ".
*/
def var fa3 as  char format "x(9)" init "СЧЕТ # : ".
def var fa4 as  char format "x(11)" init "  БАЛАНС : ".

def var pu1  as char format "x(4)" init "Текущего дня касс. опер. ВСЕГО  ".
def var pu2  as char format "x(18)" init "; Сумма перевода  ".
def var pu3  as char format "x(18)" init "услуги      ".
def var pu4  as char format "x(11)" init "; Konta DB ".
/* def var pu5  as char init "KOP…".  */
def var pu6  as char format "x(4)" init " на  ".
def var pu7  as char format "x(16)" init  " НАЧАЛЬН. ОСТ.:".
def var pu8  as char format "x(16)" init  "ДОСТУПНЫЙ ОСТ :".
def var pu82  as char format "x(10)" init "Нач . бал:".
def var pu9  as char format "x(16)" init  " КРЕДИТН.ЛИН. :".
def var pu10  as char format "x(10)" init "Дебет ост:".
def var pu11  as char format "x(11)" init "САЛЬДО ? : ".
def var pu12  as char format "x(11)" init "  /  Испол:" .
def var pu14  as char format "x(16)" init " ВСЕГО ОСТАТОК:".
def var pu142  as char format "x(10)" init "Kr-Db:    ".
def var pu15  as char format "x(30)" init "НЕТ ТАКОГО КЛИЕНТА!!".
def var pu16  as char format "x(15)" init "  ВНИМАНИЕ !!!".
def var pu17  as char format "x(50)" init "НАЧ. БАЛ. ВОЗМОЖНО НЕВЕРЕН. СМОТРИ АРХИВ".
def var pu18  as char format "x(50)" init "ДОСТ. БАЛ. ВОЗМОЖНО НЕВЕРЕН. СМОТРИ
АРХИВ".           
def var pu19  as char init "ИСПОЛН. ".


def var px01 as char  format "x(50)" init
 "                ВНИМАНИЕ  !              ".
def var px02 as char  format "x(52)" init
 "   ВЫПИСКА ПО СЧЕТУ ЗА ТЕКУЩИЙ ДЕНЬ      ".
def var px04  as char format "x(52)" init
 "     ЯВЛЯЕТСЯ ТОЛЬКО ИНФОРМАЦИЕЙ   !     ".
/* 1234567890123456789012345678901234567890 */
