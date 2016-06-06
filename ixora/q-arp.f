/* q-arp.f
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
        28.06.2013 Lyubov - ТЗ 1859, добавила поле "ВКЛЮЧИТЬ В СВОДНЫЕ СПРАВКИ"
*/

/* 17/06/03 nataly
   поле arp.penny штраф было заменено на "Доходность к погашению" */

def var v-reasonbank as char.
def var v-spbyname as char.
def var v-akkred as char init "600510".
def var v-debetor as char init "185500".
def var v-sprav as logi.

def buffer b-arp for arp.
def var v-penny as decimal format 'zzz9.99'.

find sysc where sysc.sysc = "glakkr" no-lock no-error.
if avail sysc then v-akkred = sysc.chval.
find sysc where sysc.sysc = "gldebs" no-lock no-error.
if avail sysc then v-debetor = sysc.chval.
form        "НОМЕР :" arp.arp   "ВАЛЮТА:" arp.crc
            "СЧЕТ :" arp.gl gl.sname skip
            "ТИП    :" arp.type format 'zzz'
            validate(can-find(arptype where arptype.arptype eq arp.type),
            "Введите верно код. <F2>- помощь ")
            "    ГЕО :" arp.geo format "x(3)"
             validate(can-find(geo where geo.geo eq geo),
             "Введите верно код. <F2>- помощь")
            "ГРУППА :" arp.cgr
                validate(can-find(cgr where cgr.cgr eq cgr),
                "Введите верно код. <F2>- помощь")
            "   ЗАЛОЖЕННЫЙ АКТИВ ?:" arp.zalog skip
            "ДАТА РЕГ.:" arp.rdt "ДАТА ЗАКР.:" arp.duedt skip
            "ОПИСАНИЕ :" arp.des skip
            "ДЕБЕТ    :" arp.dam[1]
            "КРЕДИТ   :" arp.cam[1] skip
            "ОСТАТОК  :" v-bal skip
            "ПРИМЕЧ.  :" arp.rem skip
            "КОД КЛ.# :" arp.cif  "                 СТАТУС :" arp.sts skip
            "ОБЕСП. :" arp.lonsec
            validate(can-find(lonsec where lonsec.lonsec eq lonsec)
                   or arp.lonsec eq 0, "Введите верно код. <F2>- помощь")
            "          РИСК :" arp.risk
             validate(can-find(risk where risk.risk eq risk)
                    or arp.risk eq 0, "Введите верно код. <F2>- помощь")
            "ДОХОДНОСТЬ К ПОГАШЕНИЮ :" v-penny
/*            validate(penny <= 100, "100% - максимум !")*/ skip
            "ВНЕБАЛАНС (600510):" arp.spby format "x(10)"
               help " ARP-карточка на внебалансовом счете 600510 (аккредитивы)"
               validate (arp.spby = "" or can-find(b-arp where b-arp.arp = arp.spby and
                         lookup(string(b-arp.gl), v-akkred) > 0 no-lock) ,
                         " Неверная карточка аккредитивов!")
            v-spbyname format "x(35)" no-label skip
            "ИСПОЛНЯЮЩИЙ БАНК:" arp.reason format "x(20)"
               help " Исполняющий банк для карточек на счете 600510 (аккредитивы)"
            v-reasonbank format "x(35)" no-label skip
            "ВКЛЮЧИТЬ В СВОДНЫЕ СПРАВКИ:" v-sprav format "yes/no" no-label
            with frame arp row 2 centered no-label .
