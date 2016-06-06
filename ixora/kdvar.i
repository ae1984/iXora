/* kdvar.i
 * MODULE
        Ќ §ў ­ЁҐ ЏЮ®ёЮ ¬¬­®ё® Њ®¤Ц«О
 * DESCRIPTION
        Ќ §­ ГҐ­ЁҐ ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ ЇЮ®ФҐ¤ЦЮ Ё ДЦ­ЄФЁ©
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        ‘ЇЁА®Є ўК§Кў Ґ¬КЕ ЇЮ®ФҐ¤ЦЮ
 * MENU
        ЏҐЮҐГҐ­Л ЇЦ­ЄБ®ў ЊҐ­Н ЏЮ ё¬К 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        06.01.2004 marinav - Ё§¬Ґ­Ґ­  Ю §¬ҐЮ­®АБЛ  
*/

def {1} shared var v-kolmenu as integer init 8.
define {1} shared variable s-main as character.
define {1} shared variable s-opt as character.
define {1} shared variable s-sign as character format "x" extent 2.
define {1} shared variable s-menu as character format "x(8)" extent 8.
define {1} shared variable s-page as integer.
define {1} shared variable s-noedt as logical.
define {1} shared variable s-nodel as logical.
{2}
