/* ncrc.f
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

/* ncrc.f 
   Форма к смене курсов валют НБ РК

   18.10.2002 nadejda - добавлены данные о замене неактуальных валют
   18.03.2008 galina - удален вывод на экран поле H/S
*/

def var v-newval as char.
def var v-newvaldt as date.
def var v-newvalcurs as deci.

def buffer b-ncrc for ncrc.

form ncrc.crc LABEL "ВАЛ" FORMAT 'Z9' 
     ncrc.des  LABEL "НАЗВАНИЕ ВАЛЮТЫ" FORMAT "X(23)" 
     ncrc.rate[1] LABEL "КУРС KZT "  format "zzzz.9999"
     ncrc.rate[9] label "РАЗМ" format "zz9" 
     ncrc.decpnt  label "ДЕС" format "z9"
     ncrc.code    LABEL "КОД " 
     ncrc.stn LABEL "ЦИФКОД" format "zz9"
     ncrchis.rdt label "РЕГ.ДАТА"
    /* t9 validate(t9 = 'H' or t9 = 'S' or t9 = 'L',"Некорректн.вид")
     label "H/S"*/  
     with  centered row  3 down frame ncrc.

form ncrc.rate[2] label "   ПОКУПКА НАЛИЧ "
     ncrc.rate[3] label "   ПРОДАЖА НАЛИЧ "
     ncrc.rate[4] label "  ПОКУПКА БЕЗНАЛ "
     ncrc.rate[5] label "  ПРОДАЖА БЕЗНАЛ "
     ncrc.rate[6] label " ПОКУПКА ДОР.ЧЕК "
     ncrc.rate[7] label " ПРОДАЖА ДОР.ЧЕК "
     skip(1)
     "    ЗАМЕНА НЕАКТУАЛЬНОЙ ВАЛЮТЫ" skip
     v-newval     LABEL "   ВАЛЮТА ЗАМЕНЫ " format "x(3)" 
       help " Укажите 3-символьный код заменяющей валюты"
       validate(v-newval = "" or can-find(b-ncrc where b-ncrc.crc <> ncrc.crc and b-ncrc.code = v-newval no-lock), " Валюта не найдена!")
     v-newvaldt   LABEL "     ДАТА ЗАМЕНЫ " format "99/99/9999"
       help " Укажите дату ввода заменяющей валюты"
       validate(v-newvaldt = ? or v-newvaldt <= g-today, " Дата не может быть больше текущей!")
     v-newvalcurs LABEL " КУРС  1 новая = " format "zzzzzzzzz9.999999"
       help " Укажите курс заменяющей валюты"
       validate(v-newvalcurs = ? or v-newvalcurs > 0, " Курс должен быть > 0!")

     with row 5 centered 1 col 1 down overlay top-only frame rate.

